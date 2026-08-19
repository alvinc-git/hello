#!/bin/bash

# Test script to verify the Rust implementation builds correctly

set -euo pipefail

echo "Testing Rust hello build..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "Cargo.toml" ]; then
    echo "Error: Cargo.toml not found"
    exit 1
fi

echo "Building release binary..."
cargo build --release

if [ -f "target/release/hello" ]; then
    echo "✅ Build successful!"
    echo "Binary location: target/release/hello"
    echo ""
    echo "Program output:"
    ./target/release/hello
    echo ""
    echo "Program version info:"
    ./target/release/hello --version
else
    echo "❌ Build failed!"
    exit 1
fi
