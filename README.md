# hello (The Standard Hello Program)

![Version](https://img.shields.io/badge/version-1.0.0-0052CC?style=for-the-badge)
![Language C](https://img.shields.io/badge/C-POSIX-00599C?style=for-the-badge&logo=c)
![Language Rust](https://img.shields.io/badge/Rust-2021-000000?style=for-the-badge&logo=rust)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-1.0.0--1-A81D33?style=for-the-badge&logo=debian)
![RPM](https://img.shields.io/badge/RPM-1.0.0--1-CC0000?style=for-the-badge&logo=redhat)

`hello` is the standard Hello program, featuring dual C and Rust implementations, unified autotools build support, and complete Debian (`.deb`) and RPM (`.rpm`) packaging.

---

## Features

- **C Implementation (`hello`)**: Lightweight C99 / POSIX implementation.
- **Rust Implementation (`hello-rust`)**: Zero-dependency pure Rust standard library implementation.
- **Build System**: Unified GNU Autotools (`autoconf` + `automake`).
- **Packaging Parity**: Automated Debian, RPM, Flatpak, and AppImage packaging with man pages.
- **Continuous Integration**: GitHub Actions automated build, test, and release workflows.

---

## Directory Structure

```
hello/
├── .github/
│   └── workflows/
│       └── ci.yml             # GitHub Actions CI/CD workflows
├── ci/
│   ├── build.sh               # Debian packaging and lintian verification script
│   ├── build-rpm.sh           # RPM packaging automation script
│   ├── build-flatpak.sh       # Flatpak packaging automation script
│   ├── build-appimage.sh      # AppImage packaging automation script
│   └── publish.sh             # GitHub Releases publishing script
├── docs/
│   └── BUILD_HOWTO.md         # Detailed build and packaging guide
├── hello-1.0.0/               # Active source and build root
│   ├── configure.ac           # Autoconf script
│   ├── Makefile.am            # Automake configuration
│   ├── autogen.sh             # Autotools bootstrap script
│   ├── src/
│   │   ├── config.h           # Configuration and macro definitions
│   │   └── hello.c            # C implementation
│   ├── hello-rust/            # Rust implementation crate
│   │   ├── Cargo.toml         # Rust crate manifest (zero external dependencies)
│   │   ├── src/
│   │   │   └── main.rs        # Rust implementation
│   │   ├── README.md          # Rust implementation docs
│   │   └── test-build.sh      # Standalone build test script
│   ├── man/
│   │   ├── hello.1            # Manual page for C program
│   │   └── hello-rust.1       # Manual page for Rust program
│   ├── debian/                # Debian packaging definitions (3.0 quilt)
│   │   ├── changelog
│   │   ├── control
│   │   ├── copyright
│   │   ├── rules
│   │   └── source/format
│   ├── rpm/                   # RPM packaging definitions
│   │   ├── README.md
│   │   └── SPECS/
│   │       └── hello.spec     # RPM package specification
│   ├── flatpak/               # Flatpak packaging definitions
│   │   ├── README.md
│   │   ├── io.github.alvinc_git.hello.yaml
│   │   ├── io.github.alvinc_git.hello.json
│   │   ├── io.github.alvinc_git.hello.metainfo.xml
│   │   └── io.github.alvinc_git.hello.desktop
│   └── appimage/              # AppImage packaging definitions
│       ├── README.md
│       ├── AppRun
│       ├── hello.desktop
│       └── hello.svg
```

---

## Building from Source

### Unified Build (C & Rust)
```bash
cd hello-1.0.0
./autogen.sh
./configure
make
```

This builds:
- `hello` (C executable)
- `hello-rust` (Rust executable, when `cargo` is present)

### Standalone Rust Build
```bash
cd hello-1.0.0/hello-rust
cargo build --release
```

---

## Usage

```bash
# Run the C implementation
./hello-1.0.0/hello

# Run with standard options
./hello-1.0.0/hello --help
./hello-1.0.0/hello --version

# Run the Rust implementation
./hello-1.0.0/hello-rust/target/release/hello
```

---

## Packaging

### Debian Package (`.deb`)
```bash
./ci/build.sh
```
Build outputs land in `build/dist/` (including `.deb`, `.dsc`, `.tar.xz`, and `SHA256SUMS`).

### RPM Package (`.rpm`)
```bash
./ci/build-rpm.sh
```
Build outputs land in `hello-1.0.0/rpm/RPMS/` and `hello-1.0.0/rpm/SRPMS/`.

### Flatpak Package (`.flatpak`)
```bash
./ci/build-flatpak.sh
```
Build outputs land in `hello-1.0.0/flatpak/dist/` (e.g. `io.github.alvinc_git.hello-1.0.0.flatpak`).

### AppImage Package (`.AppImage`)
```bash
./ci/build-appimage.sh
```
Build outputs land in `hello-1.0.0/appimage/dist/` (e.g. `hello-1.0.0-x86_64.AppImage`).

---

## Documentation & Contributing

- [Changelog](file:///Users/acura/github/hello/CHANGELOG.md): History of notable changes and releases.
- [Contributing Guide](file:///Users/acura/github/hello/CONTRIBUTING.md): Guidelines for developing, testing, and submitting contributions.
- [Build HOWTO](file:///Users/acura/github/hello/docs/BUILD_HOWTO.md): In-depth build and packaging details.

---

## License

This project is licensed under the MIT License - see the [LICENSE](file:///Users/acura/github/hello/LICENSE) file for details.