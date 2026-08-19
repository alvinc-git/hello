# Debian Packaging for hello

This directory contains the Debian `3.0 (quilt)` packaging infrastructure for `hello` (The standard Hello program). It resides within the versioned source directory (`hello-1.0.0/debian/`) alongside `rpm/`, `flatpak/`, `appimage/`, `snap/`, `msi/`, and `homebrew/`.

## Multi-Architecture Support

`hello` builds on any architecture (`Architecture: any`), with native and automated CI packaging for both `amd64` and `arm64` (aarch64).

## Contents

- `changelog`: Debian changelog entry.
- `control`: Package metadata, build dependencies (`debhelper-compat (= 12)`, `cargo`), and description.
- `copyright`: Machine-readable Debian copyright file (DEP-5 format).
- `rules`: Executable debhelper makefile configuring compilation of both C and Rust implementations across host architectures.
- `source/format`: `3.0 (quilt)` source format definition.
- `README.md`: This guide.

## Automated Build Script

Run the automated build script from repository root:

```bash
./ci/build.sh
```

To build for a specific host architecture (when cross-compilers are available):
```bash
DEB_HOST_ARCH=arm64 ./ci/build.sh
```

## Manual Build Instructions

```bash
# 1. Create orig tarball
cd hello-1.0.0
./autogen.sh && ./configure && make dist
cp hello-1.0.0.tar.xz /tmp/hello_1.0.0.orig.tar.xz

# 2. Extract and build with dpkg-buildpackage
cd /tmp
tar xf hello_1.0.0.orig.tar.xz
cp -r /path/to/hello-1.0.0/debian hello-1.0.0/debian
cd hello-1.0.0
dpkg-buildpackage -us -uc
```
