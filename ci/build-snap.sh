#!/bin/bash
#
# Build Snap package for hello
# This script builds the Snap package from within the active source root
#
# Runs in GitHub Actions and is equally runnable by hand:
#   ./ci/build-snap.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"
SNAP_ROOT="$SRC/snap"
DIST_DIR="$SNAP_ROOT/dist"
VERSION="1.0.0"

echo "==> Building Snap package for hello version $VERSION..."

if ! command -v snapcraft >/dev/null 2>&1; then
    echo "!!! snapcraft is required to build snap packages."
    echo "    Please install snapcraft (e.g. sudo snap install snapcraft --classic)."
    exit 1
fi

cd "$SRC"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

echo "==> Executing snapcraft..."
snapcraft --destructive-mode || snapcraft

echo "==> Collecting Snap artifacts..."
mv ./*.snap "$DIST_DIR/" 2>/dev/null || true

# Also copy to root build/dist if directory exists
if [ -d "$REPO_ROOT/build/dist" ]; then
    cp "$DIST_DIR"/*.snap "$REPO_ROOT/build/dist/" 2>/dev/null || true
fi

echo "==> Snap build complete!"
echo "    Snap artifacts in: hello-1.0.0/snap/dist/"
