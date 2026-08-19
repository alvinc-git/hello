# Build and Packaging Guide for hello

This document provides complete instructions for compiling, testing, and packaging `hello` (The standard Hello program).

---

## 1. Prerequisites

### Debian / Ubuntu
```bash
sudo apt-get update
sudo apt-get install -y build-essential autoconf automake libtool cargo debhelper dpkg-dev fakeroot lintian xz-utils
```

### RHEL / Rocky Linux / AlmaLinux / Fedora
```bash
sudo dnf install -y epel-release
sudo dnf install -y rpm-build gcc make autoconf automake libtool cargo xz
```

### macOS (Homebrew)
```bash
brew install autoconf automake rust
```

---

## 2. Standard Source Build

All direct builds are executed from the active build root `hello-1.0.0/`:

```bash
cd hello-1.0.0

# 1. Bootstrap Autotools
./autogen.sh

# 2. Configure build environment
./configure

# 3. Compile binaries
make

# 4. Verify outputs
./hello
./hello --help
./hello --version
```

If `cargo` is detected during `./configure`, `hello-rust` is compiled automatically as part of `make`.

---

## 3. Standalone Rust Build

To build only the zero-dependency Rust implementation:

```bash
cd hello-1.0.0/hello-rust
cargo build --release
./target/release/hello
```

Or run the automated test script:

```bash
cd hello-1.0.0/hello-rust
./test-build.sh
```

---

## 4. Debian Packaging (`.deb`)

To build the Debian package and run Lintian quality checks (supporting both `amd64` and `arm64`):

```bash
./ci/build.sh
```

To cross-build for a specific host architecture:
```bash
DEB_HOST_ARCH=arm64 ./ci/build.sh
```

Package artifacts land in `build/dist/`:
- `hello_1.0.0-1_amd64.deb` / `hello_1.0.0-1_arm64.deb`
- `hello_1.0.0-1.dsc`
- `hello_1.0.0-1.debian.tar.xz`
- `hello_1.0.0.orig.tar.xz`
- `SHA256SUMS`

---

## 5. RPM Packaging (`.rpm`)

To build the RPM package:

```bash
./ci/build-rpm.sh
```

Package artifacts land in `hello-1.0.0/rpm/RPMS/` and `hello-1.0.0/rpm/SRPMS/`:
- `hello-1.0.0/rpm/RPMS/<arch>/hello-1.0.0-1.<dist>.<arch>.rpm`
- `hello-1.0.0/rpm/SRPMS/hello-1.0.0-1.<dist>.src.rpm`

---

## 6. Flatpak Packaging (`.flatpak`)

To build the Flatpak package and create a single-file bundle:

```bash
./ci/build-flatpak.sh
```

Package artifacts land in `hello-1.0.0/flatpak/dist/`:
- `hello-1.0.0/flatpak/dist/io.github.alvinc_git.hello-1.0.0.flatpak`

To test locally with `flatpak`:
```bash
flatpak install --user hello-1.0.0/flatpak/dist/io.github.alvinc_git.hello-1.0.0.flatpak
flatpak run io.github.alvinc_git.hello
flatpak run --command=hello-rust io.github.alvinc_git.hello
```

## 7. AppImage Packaging (`.AppImage`)

To build the standalone AppImage package:

```bash
./ci/build-appimage.sh
```

Package artifacts land in `hello-1.0.0/appimage/dist/`:
- `hello-1.0.0/appimage/dist/hello-1.0.0-<arch>.AppImage`

To run the AppImage:
```bash
chmod +x hello-1.0.0/appimage/dist/hello-1.0.0-*.AppImage
./hello-1.0.0/appimage/dist/hello-1.0.0-*.AppImage
./hello-1.0.0/appimage/dist/hello-1.0.0-*.AppImage --help
```

---

## 8. Snap Packaging (`.snap`)

To build the Snap package:

```bash
./ci/build-snap.sh
```

Package artifacts land in `hello-1.0.0/snap/dist/`:
- `hello-1.0.0/snap/dist/hello_1.0.0_<arch>.snap`

---

## 9. Windows MSI Packaging (`.msi`)

To build the Windows Installer (`.msi`) package (via WiX Toolset on Windows or cross-compiled with `wixl` on Linux):

```bash
./ci/build-msi.sh
```

Package artifacts land in `hello-1.0.0/msi/dist/`:
- `hello-1.0.0/msi/dist/hello-1.0.0-x64.msi`

---

## 10. macOS Homebrew Formula

To verify and generate the Homebrew formula with release checksums:

```bash
./ci/build-homebrew.sh
```

Formula artifact lands in `hello-1.0.0/homebrew/dist/hello.rb`.

To test locally:
```bash
brew install --build-from-source hello-1.0.0/homebrew/Formula/hello.rb
brew test hello-1.0.0/homebrew/Formula/hello.rb
```

---

## 11. Continuous Integration

Automated builds and packaging tests run on GitHub Actions on every push and pull request via `.github/workflows/ci.yml`. Tagged releases (`1.0.0`, `v*`) automatically build and attach all packages (Debian `.deb`, RPM `.rpm`, Flatpak `.flatpak`, AppImage `.AppImage`, Windows `.msi`, and Homebrew formula `.rb`) to the corresponding GitHub Release.
