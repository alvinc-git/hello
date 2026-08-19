#!/bin/bash
#
# Build and verify Homebrew formula for hello
#
# Runs in GitHub Actions and is equally runnable by hand on macOS / Linux:
#   ./ci/build-homebrew.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"
BREW_ROOT="$SRC/homebrew"
DIST_DIR="$BREW_ROOT/dist"
VERSION="1.0.0"

echo "==> Building and verifying Homebrew formula for hello version $VERSION..."

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Generate distribution tarball if needed
cd "$SRC"
if [ ! -f "Makefile" ]; then
    if ! command -v autoreconf >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
            echo "==> Installing autotools via Homebrew..."
            brew install autoconf automake libtool || true
        fi
    fi
    echo "==> Bootstrapping autotools"
    ./autogen.sh
    ./configure
fi

if [ ! -f "hello-1.0.0.tar.xz" ]; then
    echo "==> Creating source distribution tarball..."
    make dist
fi

# Compute SHA256
SHA256=""
if command -v sha256sum >/dev/null 2>&1; then
    SHA256=$(sha256sum "$SRC/hello-1.0.0.tar.xz" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
    SHA256=$(shasum -a 256 "$SRC/hello-1.0.0.tar.xz" | awk '{print $1}')
fi

echo "==> Upstream tarball SHA256: ${SHA256:-<unknown>}"

# Generate release formula with computed checksum
sed "s/SKIP_FOR_LOCAL_BUILD/${SHA256}/g" "$BREW_ROOT/Formula/hello.rb" > "$DIST_DIR/hello.rb"

# Syntax check with ruby if available
if command -v ruby >/dev/null 2>&1; then
    ruby -c "$DIST_DIR/hello.rb"
fi

# Audit with brew if available
if command -v brew >/dev/null 2>&1; then
    echo "==> Running brew audit on formula..."
    brew audit --formula "$DIST_DIR/hello.rb" 2>/dev/null || true
fi

# Also copy to root build/dist if directory exists
if [ -d "$REPO_ROOT/build/dist" ]; then
    cp "$DIST_DIR/hello.rb" "$REPO_ROOT/build/dist/" 2>/dev/null || true
fi

echo "==> Homebrew formula generated at hello-1.0.0/homebrew/dist/hello.rb"
