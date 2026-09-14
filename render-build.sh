#!/usr/bin/env bash
# Build command for Render. Render's image ships an old Hugo (0.124), but the
# beton theme needs >= 0.146, so download a pinned Hugo extended release instead.
# Keep HUGO_VERSION in step with the Hugo you use locally.
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.161.0}"
HUGO_DIR="${TMPDIR:-/tmp}/hugo-${HUGO_VERSION}"

if [ ! -x "${HUGO_DIR}/hugo" ]; then
  mkdir -p "${HUGO_DIR}"
  curl -fsSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" \
    | tar -xz -C "${HUGO_DIR}" hugo
fi

"${HUGO_DIR}/hugo" version
"${HUGO_DIR}/hugo" --gc --minify "$@"
