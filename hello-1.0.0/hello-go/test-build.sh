#!/bin/bash

# Test script to verify the Go implementation builds correctly

set -euo pipefail

echo "Testing Go hello_go build..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "main.go" ]; then
    echo "Error: main.go not found"
    exit 1
fi

echo "Building hello_go binary..."
go build -ldflags "-X main.programVersion=1.0.0" -o hello_go main.go

if [ -f "hello_go" ]; then
    echo "✅ Build successful!"
    echo "Binary location: hello_go"
    echo ""
    echo "Program output:"
    ./hello_go
    echo ""
    echo "Program version info:"
    ./hello_go --version
    echo ""
    echo "Program help info:"
    ./hello_go --help
else
    echo "❌ Build failed!"
    exit 1
fi
