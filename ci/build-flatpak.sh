#!/bin/bash
#
# Build Flatpak package for hello
# This script builds the Flatpak package and single-file bundle from within the active source root
#
# Runs in GitHub Actions and is equally runnable by hand:
#   ./ci/build-flatpak.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"
FLATPAK_ROOT="$SRC/flatpak"
BUILD_DIR="$FLATPAK_ROOT/build-dir"
REPO_DIR="$FLATPAK_ROOT/repo"
DIST_DIR="$FLATPAK_ROOT/dist"
APP_ID="io.github.alvinc_git.hello"
VERSION="1.0.0"

echo "==> Building Flatpak package for hello version $VERSION..."

if ! command -v flatpak-builder >/dev/null 2>&1; then
    echo "!!! flatpak-builder is required to build flatpak packages."
    echo "    Please install flatpak and flatpak-builder."
    exit 1
fi

cd "$FLATPAK_ROOT"

# Clean previous build artifacts
rm -rf "$BUILD_DIR" "$REPO_DIR" "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Ensure Flathub remote is added
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

BUILDER_FLAGS=("--force-clean" "--repo=$REPO_DIR" "--default-branch=stable")

# If running as non-root, use --user for user-installed SDKs
if [ "$(id -u)" -ne 0 ]; then
    BUILDER_FLAGS+=("--user")
fi

# Add install-deps-from if flathub remote exists
if flatpak remotes --user 2>/dev/null | grep -q flathub || flatpak remotes 2>/dev/null | grep -q flathub; then
    BUILDER_FLAGS+=("--install-deps-from=flathub")
fi

echo "==> Building Flatpak application with flatpak-builder..."
flatpak-builder \
    "${BUILDER_FLAGS[@]}" \
    "$BUILD_DIR" \
    "$FLATPAK_ROOT/${APP_ID}.yaml"

echo "==> Creating single-file Flatpak bundle (.flatpak)..."
flatpak build-bundle \
    "$REPO_DIR" \
    "$DIST_DIR/${APP_ID}-${VERSION}.flatpak" \
    "$APP_ID" \
    stable

# Copy bundle to root build/dist if available
if [ -d "$REPO_ROOT/build/dist" ]; then
    cp "$DIST_DIR/${APP_ID}-${VERSION}.flatpak" "$REPO_ROOT/build/dist/"
fi

echo "==> Flatpak build complete!"
echo "    Bundle: hello-1.0.0/flatpak/dist/${APP_ID}-${VERSION}.flatpak"
