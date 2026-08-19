# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Flatpak Packaging**: Added Flatpak packaging definitions (`hello-1.0.0/flatpak/`), AppStream metainfo, desktop entry, automated build script (`ci/build-flatpak.sh`), and GitHub Actions workflow job.
- **AppImage Packaging**: Added AppImage packaging definitions (`hello-1.0.0/appimage/`), `AppRun` runtime script, desktop entry, application icon, automated build script (`ci/build-appimage.sh`), and GitHub Actions workflow job.
- **Snap Packaging**: Added Snapcraft packaging definitions (`hello-1.0.0/snap/`), manifest `snapcraft.yaml`, automated build script (`ci/build-snap.sh`).
- **Windows MSI Packaging**: Added WiX Toolset installer definitions (`hello-1.0.0/msi/hello.wxs`), cross-compilation support via `wixl`/MinGW, automated build script (`ci/build-msi.sh`), and GitHub Actions workflow job.
- **macOS Homebrew Formula**: Added Homebrew formula specification (`hello-1.0.0/homebrew/Formula/hello.rb`), automated checksum verification script (`ci/build-homebrew.sh`), and GitHub Actions workflow job.

## [1.0.0] - 2026-08-18

### Added
- **C Implementation (`hello`)**: Lightweight C99/POSIX implementation printing standard greeting.
- **Rust Implementation (`hello-rust`)**: Zero-dependency pure Rust implementation using only `std`.
- **Command-Line Options**: Standard support for `-h`/`--help` and `-v`/`-V`/`--version` flags across both implementations.
- **Build Infrastructure**: GNU Autotools configuration supporting compiler strictness, hardening flags, and automatic Rust toolchain detection.
- **Manual Pages**: Shipped upstream man pages for `hello.1` and `hello-rust.1`.
- **Debian Packaging**: Complete `3.0 (quilt)` packaging definitions with automated build and Lintian verification script (`ci/build.sh`).
- **RPM Packaging**: RPM spec file (`hello-1.0.0/rpm/SPECS/hello.spec`) with automated packaging script (`ci/build-rpm.sh`).
- **GitHub Actions CI/CD**: Containerized automated build matrix for Debian (`debian:bookworm`) and RPM (`rockylinux:9`) with GitHub Releases integration.
- **Documentation**: Comprehensive guides including `README.md`, `AGENTS.md`, `CLAUDE.md`, `BUILD_HOWTO.md`, `CONTRIBUTING.md`, and `CHANGELOG.md`.

[Unreleased]: https://github.com/alvinc-git/hello/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/alvinc-git/hello/releases/tag/v1.0.0
