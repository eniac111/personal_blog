---
title: "Joystick for changing the Plasma virtual desktops"
author: "Blagovest Petrov"
date: 2023-10-12T12:07:54+03:00
tags:
  - "DIY"
  - "Vintage Hardware"
categories:
  - "Travel"
draft: false
---

The whole project took about ~30 min, using some stuff around the living room and electrical tape. The controller is [Olimex AVR-T32U4](https://www.olimex.com/Products/Duino/AVR/AVR-T32U4/open-source-hardware), Arduino Leonardo clone. It runs really well with the [Kwin script](https://github.com/Aetf/kwin-maxmize-to-new-desktop) for maximizing the windows to a new virtual desktop, when they are in full screen. Just like in Mac.

{{< youtube id="F4hwCTPkHR4" >}}

Here is the code:

```C
#include <Keyboard.h>

const int upPin = 2;
const int downPin = 3;
const int leftPin = 4;
const int rightPin = 5;

void setup() {
  Keyboard.begin();
  pinMode(upPin, INPUT_PULLUP);
  pinMode(downPin, INPUT_PULLUP);
  pinMode(leftPin, INPUT_PULLUP);
  pinMode(rightPin, INPUT_PULLUP);
}

void loop() {
  // Send Ctrl+Win+Right key combination
  if (digitalRead(upPin) == LOW) {
    Keyboard.press(KEY_LEFT_CTRL);
    Keyboard.press(KEY_LEFT_GUI);
    Keyboard.write(KEY_UP_ARROW);
    Keyboard.releaseAll();
    delay(500);
  }
  if (digitalRead(downPin) == LOW) {
    Keyboard.press(KEY_LEFT_CTRL);
    Keyboard.press(KEY_LEFT_GUI);
    Keyboard.write(KEY_DOWN_ARROW);
    Keyboard.releaseAll();
    delay(500);
  }
  if (digitalRead(leftPin) == LOW) {
    Keyboard.press(KEY_LEFT_CTRL);
    Keyboard.press(KEY_LEFT_GUI);
    Keyboard.press(KEY_LEFT_ARROW);
    Keyboard.releaseAll();
    delay(500);
  }
  if (digitalRead(rightPin) == LOW) {
    Keyboard.press(KEY_LEFT_CTRL);
    Keyboard.press(KEY_LEFT_GUI);
    Keyboard.press(KEY_RIGHT_ARROW);
    Keyboard.releaseAll();
    delay(500);
  }
  Keyboard.releaseAll();
}
```
