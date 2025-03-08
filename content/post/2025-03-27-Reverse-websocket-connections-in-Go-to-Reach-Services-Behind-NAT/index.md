---
title: "Using Reverse WebSocket Connections in Go to Reach Services Behind NAT"
author: "Blagovest Petrov"
date: 2025-03-08T01:49:02+03:00
tags:
  - "Go"
  - "Programming"
  - "Websocket"
categories:
  - "Programming"
draft: false
---

# Introduction

Have you ever needed to access a service running on a machine behind NAT—one where you can’t simply open a port and connect from the outside? This scenario is very common for remote management or "agent" scenarios, but not only that. Other use cases might be:

  * * Sharing a local VNC server port to provide remote assistance (similar to RustDesk / TeamViewer)
  * * Accessing IoT devices in a private network
  * * Performing maintenance on equipment in locked-down environments

In all these cases, the challenge is the same: inbound connections into a private network are typically blocked. A reverse WebSocket connection can solve this by having the private-network service (the “client”) initiate an outbound WebSocket connection to a publicly accessible server. Once established, the server can effectively send requests “back” over that channel.

In this post, we’ll walk through a minimal example using two Go applications:

  1. `Server` (publicly reachable) that accepts a WebSocket connection from the private-network machine:
      * Listens for the client on a `/ws` endpoint (WebSocket).
      * Provides an HTTP route at `/client1`. When you visit `http://server:8080/client1`, the server sends a request over the WebSocket to the client. The client fetches its local page and returns it. The server then relays that page back to the browser.
  2. `Client` (behind NAT) that connects out to the server, then listens for requests forwarded from the server—like a small tunnel:
      * Serves a simple “Hello Socket” page on `localhost:8888`.
      * Establishes a WebSocket connection to the Server.
      * Waits for “forward” requests from the Server, then fetches the page at `localhost:8888` and sends it back.

When you run these two programs, any request to `http://your-public-server:8080/client1` will effectively serve content from the client’s local `:8888` page — even though the client is behind NAT or a firewall.

We’ll use the popular [Gorilla WebSocket library](https://github.com/gorilla/websocket) to handle WebSocket connections, and [Cobra](https://cobra.dev/) to provide a simple CLI in the client, if you want to test the example on something different than localhost.

This basic pattern can be adapted to share any TCP-based service—like a VNC server for remote desktop/assistance. All you need is a small piece of logic in the client that proxies traffic from the local service (on the private network) back to the server.

Source code of the server (`server/main.go`):

```golang
package main

import (
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/spf13/cobra"
)

var (
	// Cobra flags
	port    string
	rootCmd = &cobra.Command{
		Use:   "server",
		Short: "Reverse WebSocket server",
		Run:   runServer,
	}
)

var upgrader = websocket.Upgrader{
	// For the demo, allow any origin :)
	CheckOrigin: func(r *http.Request) bool { return true },
}

var (
	clientConn *websocket.Conn
	connMutex  sync.Mutex
)

func init() {
	// Define flags for the server command
	rootCmd.Flags().StringVar(&port, "port", "8080", "Port to listen on")
}

func runServer(cmd *cobra.Command, args []string) {
	// HTTP handlers
	http.HandleFunc("/ws", handleWebSocket)
	http.HandleFunc("/client1", handleClient1)

	addr := ":" + port
	log.Printf("Server listening on %s\n", addr)
	log.Fatal(http.ListenAndServe(addr, nil))
}

// handleWebSocket upgrades an HTTP request to a WebSocket
// and stores the connection for later use.
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("WebSocket upgrade error:", err)
		return
	}

	connMutex.Lock()
	clientConn = conn
	connMutex.Unlock()

	log.Println("Client connected via WebSocket")
}

// handleClient1 handles an HTTP GET request to /client1.
// It forwards the request to the client via WebSocket, then relays the client's response.
func handleClient1(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Unsupported method", http.StatusMethodNotAllowed)
		return
	}

	connMutex.Lock()
	defer connMutex.Unlock()

	if clientConn == nil {
		http.Error(w, "No client connected", http.StatusServiceUnavailable)
		return
	}

	// Send a message to the client to fetch its local page
	err := clientConn.WriteMessage(websocket.TextMessage, []byte("FETCH_PAGE"))
	if err != nil {
		log.Println("Error sending WebSocket message:", err)
		http.Error(w, "Failed to send request to client", http.StatusInternalServerError)
		return
	}

	// Read the response from the client (the HTML content)
	_, resp, err := clientConn.ReadMessage()
	if err != nil {
		log.Println("Error reading from WebSocket:", err)
		http.Error(w, "Failed to get response from client", http.StatusInternalServerError)
		return
	}

	// Write the response back to the caller
	w.Header().Set("Content-Type", "text/html")
	w.Write(resp)
}

func main() {
	// Run the Cobra command
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
```

And the client (`client/main.go`):

```golang
package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"

	"github.com/gorilla/websocket"
	"github.com/spf13/cobra"
)

var (
	// Cobra flags
	serverAddr string
	localPort  string

	rootCmd = &cobra.Command{
		Use:   "client",
		Short: "A reverse WebSocket client that serves a Hello page locally",
		Run:   runClient,
	}
)

func init() {
	rootCmd.Flags().StringVar(&serverAddr, "server", "localhost:8080", "WebSocket server address")
	rootCmd.Flags().StringVar(&localPort, "local-port", "8888", "Local port to serve the Hello Socket page")
}

func main() {
	// Execute the Cobra command
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

// runClient starts a local HTTP server that serves a Hello Socket page,
// then connects to the remote server via WebSocket and waits for requests.
func runClient(cmd *cobra.Command, args []string) {
	// 1. Start the local page server in a goroutine
	go startLocalPageServer(localPort)

	// 2. Connect to the public server via WebSocket
	u := url.URL{Scheme: "ws", Host: serverAddr, Path: "/ws"}
	log.Printf("Connecting to server WebSocket at %s\n", u.String())

	conn, _, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Fatal("WebSocket dial error:", err)
	}
	defer conn.Close()

	// 3. Listen for incoming WebSocket messages (requests from the server)
	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Println("Read error from server WebSocket:", err)
			return
		}

		switch string(msg) {
		case "FETCH_PAGE":
			respondWithLocalPage(conn, localPort)
		default:
			log.Println("Received unknown message:", string(msg))
		}
	}
}

// startLocalPageServer starts a simple server on the specified port
// that returns "Hello Socket" HTML content.
func startLocalPageServer(port string) {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(w, "<html><body><h1>Hello from the client behind NAT!</h1></body></html>")
	})

	addr := ":" + port
	log.Printf("Local client page server listening on %s\n", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		log.Fatalf("Failed to start local client server: %v", err)
	}
}

// respondWithLocalPage fetches the local "Hello Socket" page and sends it back over WebSocket.
func respondWithLocalPage(conn *websocket.Conn, port string) {
	resp, err := http.Get("http://localhost:" + port + "/")
	if err != nil {
		log.Println("Error fetching local page:", err)
		conn.WriteMessage(websocket.TextMessage, []byte("Error fetching local page"))
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Println("Error reading local page content:", err)
		conn.WriteMessage(websocket.TextMessage, []byte("Error reading local page"))
		return
	}

	// Send the page content back to the server
	err = conn.WriteMessage(websocket.TextMessage, body)
	if err != nil {
		log.Println("Error sending page content to server:", err)
	}
}
```

## Testing the setup

<script src="https://asciinema.org/a/ZByuSpeUNhh1DNSuDcAhGf3gC.js" id="asciicast-ZByuSpeUNhh1DNSuDcAhGf3gC" async="true"></script>


This basic pattern can be adapted to share any TCP-based service—like a VNC server for remote desktop/assistance or SSH. All you need is a small piece of logic in the client that proxies traffic from the local service (on the private network) back to the server.