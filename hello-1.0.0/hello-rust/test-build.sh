#!/bin/bash

# Test script to verify the Rust implementations build correctly

echo "Testing Rust hello build..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "Cargo.toml" ]; then
    echo "Error: Cargo.toml not found"
    exit 1
fi

echo "Building release binaries..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "Binary locations:"
    echo "  Program: target/release/hello"

    echo ""
    echo "Client version info:"
    ./target/release/hello --version

else
    echo "❌ Build failed!"
    exit 1
fi
