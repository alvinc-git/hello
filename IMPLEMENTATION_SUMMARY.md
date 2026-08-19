# hello 1.0.0 - Implementation Summary

## Overview

`hello` 1.0.0 is the standard Hello program implemented in both C and pure zero-dependency Rust, built using GNU Autotools, and packaged for both Debian (`.deb`) and RPM (`.rpm`) distributions.

---

## 1. Implementations

### C Program (`hello`)
- **Source:** `hello-1.0.0/src/hello.c`
- **Header:** `hello-1.0.0/src/config.h`
- **Standards:** C99 / POSIX compliant.
- **Features:** Standard greeting output ("Hello, World!"), command-line options (`-h`, `--help`, `-v`, `-V`, `--version`).

### Rust Program (`hello-rust`)
- **Source:** `hello-1.0.0/hello-rust/src/main.rs`
- **Manifest:** `hello-1.0.0/hello-rust/Cargo.toml`
- **Dependencies:** Pure standard library (`std`), zero external crates.
- **Features:** Standard greeting output ("Hello, World!"), command-line options (`-h`, `--help`, `-v`, `-V`, `--version`).

---

## 2. Build & Packaging Architecture

### Unified Autotools Build
- `hello-1.0.0/configure.ac`: Configures compiler strictness (`STRICT_CFLAGS`), hardening flags (`HARDEN_CFLAGS`, `HARDEN_LDFLAGS`), and detects Cargo toolchain for Rust builds.
- `hello-1.0.0/Makefile.am`: Builds C executable, invokes Cargo release build when available, installs `hello` and `hello-rust` binaries, and distributes manual pages.

### Debian Packaging (`3.0 quilt`)
- Defined in `hello-1.0.0/debian/`.
- Automated build & lintian verification via `./ci/build.sh`.
- Generates binary `.deb`, source `.dsc`, and checksum manifests in `build/dist/`.

### RPM Packaging
- Defined in `hello-1.0.0/rpm/SPECS/hello.spec`.
- Automated build via `./ci/build-rpm.sh`.
- Packages `hello`, `hello-rust`, and man pages into `hello-1.0.0/rpm/RPMS/` and `hello-1.0.0/rpm/SRPMS/`.

---

## 3. Continuous Integration

- Converted from legacy Bitbucket Pipelines to **GitHub Actions** (`.github/workflows/ci.yml`).
- Runs automated containerized Debian (`debian:bookworm`) and RPM (`rockylinux:9`) builds.
- Creates GitHub Releases and attaches distributable packages on tag pushes.