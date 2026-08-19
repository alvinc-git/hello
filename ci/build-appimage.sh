#!/bin/bash
#
# Build AppImage package for hello
# This script builds the AppImage bundle from within the active source root
#
# Runs in GitHub Actions and is equally runnable by hand on Linux:
#   ./ci/build-appimage.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"
APPIMAGE_ROOT="$SRC/appimage"
APPDIR="$APPIMAGE_ROOT/AppDir"
DIST_DIR="$APPIMAGE_ROOT/dist"
VERSION="1.0.0"
ARCH="${ARCH:-$(uname -m)}"

echo "==> Building AppImage package for hello version $VERSION ($ARCH)..."

# Navigate to source root and build
cd "$SRC"

if [ ! -f "Makefile" ]; then
    echo "==> Bootstrapping autotools"
    ./autogen.sh
    echo "==> Configuring"
    ./configure --prefix=/usr
fi

echo "==> Compiling"
make clean >/dev/null 2>&1 || true
make

# Clean and stage AppDir
echo "==> Assembling AppDir structure"
rm -rf "$APPDIR" "$DIST_DIR"
mkdir -p "$APPDIR/usr/bin" \
         "$APPDIR/usr/share/man/man1" \
         "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/icons/hicolor/scalable/apps" \
         "$DIST_DIR"

# Install binaries
cp "$SRC/hello" "$APPDIR/usr/bin/hello"
if [ -f "$SRC/hello-rust/target/release/hello" ]; then
    cp "$SRC/hello-rust/target/release/hello" "$APPDIR/usr/bin/hello-rust"
fi
if [ -f "$SRC/hello-go/hello_go" ]; then
    cp "$SRC/hello-go/hello_go" "$APPDIR/usr/bin/hello_go"
fi

# Install man pages
if [ -f "$SRC/man/hello.1" ]; then
    cp "$SRC/man/hello.1" "$APPDIR/usr/share/man/man1/"
fi
if [ -f "$SRC/man/hello-rust.1" ]; then
    cp "$SRC/man/hello-rust.1" "$APPDIR/usr/share/man/man1/"
fi
if [ -f "$SRC/man/hello_go.1" ]; then
    cp "$SRC/man/hello_go.1" "$APPDIR/usr/share/man/man1/"
fi

# Install AppImage metadata and entrypoint
cp "$APPIMAGE_ROOT/hello.desktop" "$APPDIR/hello.desktop"
cp "$APPIMAGE_ROOT/hello.desktop" "$APPDIR/usr/share/applications/hello.desktop"
cp "$APPIMAGE_ROOT/hello.svg" "$APPDIR/hello.svg"
cp "$APPIMAGE_ROOT/hello.svg" "$APPDIR/usr/share/icons/hicolor/scalable/apps/hello.svg"
cp "$APPIMAGE_ROOT/AppRun" "$APPDIR/AppRun"
chmod +x "$APPDIR/AppRun"

# Locate or download appimagetool
APPIMAGETOOL=""
if command -v appimagetool >/dev/null 2>&1; then
    APPIMAGETOOL="appimagetool"
elif [ -f "$REPO_ROOT/build/appimagetool" ]; then
    APPIMAGETOOL="$REPO_ROOT/build/appimagetool"
else
    echo "==> Downloading appimagetool..."
    mkdir -p "$REPO_ROOT/build"
    APPIMAGETOOL="$REPO_ROOT/build/appimagetool"
    TOOL_URL="https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${ARCH}.AppImage"
    if curl -fsSL "$TOOL_URL" -o "$APPIMAGETOOL"; then
        chmod +x "$APPIMAGETOOL"
    else
        echo "!!! Warning: Could not download appimagetool. AppDir staged at $APPDIR"
        exit 0
    fi
fi

OUTPUT_APPIMAGE="$DIST_DIR/hello-${VERSION}-${ARCH}.AppImage"

echo "==> Packaging AppImage with $APPIMAGETOOL..."
ARCH="$ARCH" "$APPIMAGETOOL" --appimage-extract-and-run "$APPDIR" "$OUTPUT_APPIMAGE" || \
ARCH="$ARCH" "$APPIMAGETOOL" "$APPDIR" "$OUTPUT_APPIMAGE"

# Also copy to root build/dist if directory exists
if [ -d "$REPO_ROOT/build/dist" ]; then
    cp "$OUTPUT_APPIMAGE" "$REPO_ROOT/build/dist/"
fi

echo "==> AppImage build complete!"
echo "    AppImage: hello-1.0.0/appimage/dist/hello-${VERSION}-${ARCH}.AppImage"
