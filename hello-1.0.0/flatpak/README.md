# Flatpak Packaging for hello

This directory contains the Flatpak packaging infrastructure for `hello` (The standard Hello program). It resides within the versioned source directory (`hello-1.0.0/flatpak/`) alongside `debian/` and `rpm/` to ensure isolated packaging evolution across major versions.

## Overview

- **Application ID:** `io.github.alvinc_git.hello`
- **Runtime:** `org.freedesktop.Platform` (branch `24.08`)
- **SDK:** `org.freedesktop.Sdk` (branch `24.08`)
- **SDK Extension:** `org.freedesktop.Sdk.Extension.rust-stable` (branch `24.08`)
- **Manifests:**
  - `io.github.alvinc_git.hello.yaml` (YAML format, recommended)
  - `io.github.alvinc_git.hello.json` (JSON format)
- **AppStream Metainfo:** `io.github.alvinc_git.hello.metainfo.xml`
- **Desktop Entry:** `io.github.alvinc_git.hello.desktop`

## Prerequisites

Ensure `flatpak` and `flatpak-builder` are installed:

### Debian / Ubuntu
```bash
sudo apt-get install flatpak flatpak-builder
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08 org.freedesktop.Sdk.Extension.rust-stable//24.08
```

### Fedora / RHEL / Rocky Linux
```bash
sudo dnf install flatpak flatpak-builder
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user flathub org.freedesktop.Platform//24.08 org.freedesktop.Sdk//24.08 org.freedesktop.Sdk.Extension.rust-stable//24.08
```

## Automated Build Script

Run the automated build script from the repository root:

```bash
./ci/build-flatpak.sh
```

This compiles the package, builds the local repository, and exports a standalone bundle to:
`hello-1.0.0/flatpak/dist/io.github.alvinc_git.hello-1.0.0.flatpak`

## Manual Build Instructions

From within the `hello-1.0.0/flatpak/` directory:

```bash
# 1. Build the Flatpak into a local repository
flatpak-builder --force-clean --repo=repo --install-deps-from=flathub build-dir io.github.alvinc_git.hello.yaml

# 2. Create a single-file (.flatpak) bundle
mkdir -p dist
flatpak build-bundle repo dist/io.github.alvinc_git.hello-1.0.0.flatpak io.github.alvinc_git.hello stable

# 3. Install and run locally for testing
flatpak install --user dist/io.github.alvinc_git.hello-1.0.0.flatpak
flatpak run io.github.alvinc_git.hello
flatpak run --command=hello-rust io.github.alvinc_git.hello
```
