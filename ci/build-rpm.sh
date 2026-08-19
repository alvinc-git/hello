#!/bin/bash

# Build RPM package for hello
# This script builds the RPM package for hello from within the active source root

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRC="$REPO_ROOT/hello-1.0.0"
RPM_ROOT="$SRC/rpm"

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
mkdir -p "$RPM_ROOT/SOURCES" "$RPM_ROOT/BUILD" "$RPM_ROOT/RPMS" "$RPM_ROOT/SRPMS"
cp hello-1.0.0.tar.xz "$RPM_ROOT/SOURCES/"

# Build the RPM package
echo "Building RPM package..."
rpmbuild --define "_topdir $RPM_ROOT" -ba "$RPM_ROOT/SPECS/hello.spec"

echo "RPM build complete!"
echo "RPM packages are in: hello-1.0.0/rpm/RPMS/"
echo "Source RPM is in: hello-1.0.0/rpm/SRPMS/"
