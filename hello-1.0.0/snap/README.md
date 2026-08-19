# Snap Packaging for hello

This directory contains the Snapcraft packaging infrastructure for `hello` (The standard Hello program). It resides within the versioned source directory (`hello-1.0.0/snap/`) alongside other distribution frameworks (`debian/`, `rpm/`, `flatpak/`, `appimage/`, `msi/`, and `homebrew/`).

## Contents

- `snapcraft.yaml`: Manifest configuring strict confinement, build plugins (autotools + cargo), and binary exports for both `hello` and `hello-rust`.
- `README.md`: This guide.

## Prerequisites

Ensure `snapcraft` and `lxd` (or Multipass) are installed:

```bash
sudo snap install snapcraft --classic
sudo snap install lxd
sudo lxd init --auto
```

## Automated Build Script

Run the automated script from the repository root:

```bash
./ci/build-snap.sh
```

Package artifacts land in `hello-1.0.0/snap/dist/`:
- `hello_1.0.0_<arch>.snap`

## Manual Build Instructions

From within `hello-1.0.0/`:

```bash
# Build using snapcraft
snapcraft --destructive-mode
# Or inside a managed container:
snapcraft

# Test local installation
sudo snap install --dangerous hello_1.0.0_*.snap
hello
hello-rust
```
