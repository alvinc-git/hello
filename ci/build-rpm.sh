#!/bin/bash

# Build RPM package for hello
# This script follows the same approach as the Debian build but for RPM

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"

echo "Building RPM package for hello version 1.0.0..."

# Navigate to hello-1.0.0 directory
cd "$SRC"

# Ensure Makefile exists by running autogen and configure if needed.
# --disable-static-daemon is used here solely so `make dist` can package
# the source tarball regardless of whether glibc-static is installed on the host.
if [ ! -f "Makefile" ]; then
    echo "==> Bootstrapping autotools"
    ./autogen.sh
    echo "==> Configuring"
    ./configure --disable-static-daemon
fi

# Clean previous builds
make clean >/dev/null 2>&1 || true

# Generate distribution tarball
echo "Generating distribution tarball..."
make dist

# Copy tarball to RPM SOURCES directory
echo "Copying source tarball to RPM SOURCES..."
mkdir -p "$REPO_ROOT/rpm/SOURCES"
cp hello-1.0.0.tar.xz "$REPO_ROOT/rpm/SOURCES/"

# Build the RPM package
echo "Building RPM package..."
cd "$REPO_ROOT/rpm"
rpmbuild --define "_topdir $REPO_ROOT/rpm" -ba SPECS/hello.spec

echo "RPM build complete!"
echo "RPM packages are in: rpm/RPMS/"
echo "Source RPM is in: rpm/SRPMS/"
