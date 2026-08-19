#!/bin/bash

# Build RPM package for hello
# This script builds the RPM package for hello

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"

echo "Building RPM package for hello version 1.0.0..."

# Navigate to hello-1.0.0 directory
cd "$SRC"

# Ensure Makefile exists by running autogen and configure if needed.
if [ ! -f "Makefile" ]; then
    echo "==> Bootstrapping autotools"
    ./autogen.sh
    echo "==> Configuring"
    ./configure
fi

# Clean previous builds
make clean >/dev/null 2>&1 || true

# Generate distribution tarball
echo "Generating distribution tarball..."
make dist

# Copy tarball to RPM SOURCES directory
echo "Copying source tarball to RPM SOURCES..."
mkdir -p "$REPO_ROOT/rpm/SOURCES" "$REPO_ROOT/rpm/BUILD" "$REPO_ROOT/rpm/RPMS" "$REPO_ROOT/rpm/SRPMS"
cp hello-1.0.0.tar.xz "$REPO_ROOT/rpm/SOURCES/"

# Build the RPM package
echo "Building RPM package..."
cd "$REPO_ROOT/rpm"
rpmbuild --define "_topdir $REPO_ROOT/rpm" -ba SPECS/hello.spec

echo "RPM build complete!"
echo "RPM packages are in: rpm/RPMS/"
echo "Source RPM is in: rpm/SRPMS/"
