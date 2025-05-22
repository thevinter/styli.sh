#!/bin/bash

# Install script for styli.sh

set -e

SCRIPT_NAME="styli.sh"
INSTALL_DIR="/usr/local/bin"
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$SCRIPT_NAME"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (e.g., with sudo)."
    exit 1
fi

# Check if styli.sh exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: $SCRIPT_NAME not found in $(dirname "$0")"
    exit 1
fi

# Make script executable
chmod +x "$SCRIPT_PATH"

# Copy to /usr/local/bin
cp "$SCRIPT_PATH" "$INSTALL_DIR/"

echo "$SCRIPT_NAME installed to $INSTALL_DIR."
echo "You can now run 'styli.sh' from anywhere."