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

To build the Debian package and run Lintian quality checks:

```bash
./ci/build.sh
```

Package artifacts land in `build/dist/`:
- `hello_1.0.0-1_<arch>.deb`
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

---

## 7. Continuous Integration

Automated builds and packaging tests run on GitHub Actions on every push and pull request via `.github/workflows/ci.yml`. Tagged releases (`1.0.0`, `v*`) automatically build and attach all packages (Debian `.deb`, RPM `.rpm`, and Flatpak `.flatpak`) to the corresponding GitHub Release.
