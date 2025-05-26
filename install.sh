#!/bin/bash

# Install script for styli.sh

set -e

SCRIPT_NAME="styli.sh"
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/$SCRIPT_NAME"

# Determine install directory
if [[ $EUID -eq 0 ]]; then
    # Running as root - install system-wide
    INSTALL_DIR="/usr/local/bin"
else
    # Running as user - install to user's local bin
    INSTALL_DIR="$HOME/.local/bin"
    
    # Create the directory if it doesn't exist
    if [[ ! -d "$INSTALL_DIR" ]]; then
        mkdir -p "$INSTALL_DIR"
        echo "Created directory: $INSTALL_DIR"
    fi
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "Warning: $HOME/.local/bin is not in your PATH."
        echo "Add this line to your ~/.bashrc or ~/.zshrc:"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

# Check if styli.sh exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: $SCRIPT_NAME not found in $(dirname "$0")"
    exit 1
fi

# Make script executable
chmod +x "$SCRIPT_PATH"

# Copy to install directory
cp "$SCRIPT_PATH" "$INSTALL_DIR/"

echo "$SCRIPT_NAME installed to $INSTALL_DIR."
echo "You can now run 'styli.sh' from anywhere."