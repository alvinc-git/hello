# skydsecd 2.0.0

![Version](https://img.shields.io/badge/version-2.0.0-0052CC?style=for-the-badge)
![Language C](https://img.shields.io/badge/C-POSIX-00599C?style=for-the-badge&logo=c)
![Language Rust](https://img.shields.io/badge/Rust-2021-000000?style=for-the-badge&logo=rust)
![License](https://img.shields.io/badge/license-Proprietary-red?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-2.0.0--1-A81D33?style=for-the-badge&logo=debian)
![RPM](https://img.shields.io/badge/RPM-2.0.0--1-CC0000?style=for-the-badge&logo=redhat)

skydsecd is part of the Skydio Security and IT Management framework

skydsecd is a lightweight program to report security, compliance and
systems managment information.

## Version 2.0.0

This version includes significant enhancements over 1.0.0 and 1.5.0:
- Complete dual C and Rust client & daemon architecture (`skydsec`, `skydsecd`, `skydsec-rust`, `skydsecd-rust`)
- Enhanced security features and build system
- Unified Debian and RPM packaging for C and Rust daemons and clients
- Maintained all original security guarantees (static linking, fresh facts probing, no NSS dependencies)

## Key Features

### Security Implementation
- **Static linking & stripping**: Both daemons (`skydsecd` and `skydsecd-rust`) are statically linked and stripped to prevent attackers from replacing shared libraries
- **No NSS symbols**: Removed all username/group lookups that would pull in NSS symbols  
- **Container/VM detection**: Implemented via file ownership comparison (not NSS calls)
- **Proper error handling**: All functions handle errors gracefully without crashing the daemon

### Packaging Infrastructure
- **Debian packaging**: Maintained original Debian build system with quilt format
- **RPM packaging**: Added complete RPM scaffolding that mirrors Debian approach:
  - `rpm/SPECS/skydsecd.spec` - Complete RPM spec file
  - `rpm/README.md` - Documentation for RPM building
  - `ci/build-rpm.sh` - Build script for RPM generation

### New Features
- **Rust Client & Daemon**: Zero-dependency Rust implementations (`skydsec-rust` and `skydsecd-rust`) with memory safety, zero external dependencies, static linking, and optimized binary size
- **Cross-platform compatibility**: Build system ready for deployment on other hosts
- **Enhanced build system**: All security hardening options enabled by default

## Files Structure

### Core Implementation:
- `skydsecd-2.0.0/src/skydsecd.c` - Secure C daemon implementation with static linking
- `skydsecd-2.0.0/src/skydsec.c` - Original C client implementation
- `skydsecd-2.0.0/skydsec-rust/src/client.rs` - Rust client implementation  
- `skydsecd-2.0.0/skydsec-rust/src/daemon.rs` - Rust daemon implementation (statically linked and stripped)

### Build System:
- `skydsecd-2.0.0/configure.ac` - Updated autotools configuration
- `skydsecd-2.0.0/Makefile.am` - Corrected source file references and build rules
- `skydsecd-2.0.0/m4/ax_check_compile_flag.m4` - Compile flag checking macros  
- `skydsecd-2.0.0/m4/ax_check_link_flag.m4` - Link flag checking macros

### Packaging:
- `rpm/SPECS/skydsecd.spec` - Complete RPM spec file
- `rpm/README.md` - RPM documentation
- `ci/build-rpm.sh` - RPM build automation script

## Build Instructions

### Unified Build (Daemon + C Client + Rust Client & Daemon):
```bash
cd skydsecd-2.0.0
./autogen.sh
./configure --disable-strict --enable-werror --disable-hardening --enable-static-daemon
make
```
`make` will compile the C daemon (`skydsecd`), C client (`skydsec`), and (when `cargo` is installed) the Rust client (`skydsec-rust`) and Rust daemon (`skydsecd-rust`).

### Standalone Rust Build:
```bash
cd skydsecd-2.0.0/skydsec-rust
cargo build --release
```


### Packaging (Debian & RPM):
Both Debian (`dpkg-buildpackage`) and RPM (`rpmbuild`) frameworks package the daemon (`skydsecd`), C client (`skydsec`), and Rust client (`skydsec-rust`) together.

```bash
# Debian packaging
./ci/build.sh

# RPM packaging
./ci/build-rpm.sh
```

## Security Features

- **Static linking**: Daemon cannot be subverted through shared library replacement
- **No NSS dependencies**: Eliminates potential attack vectors through NSS modules
- **Container detection**: Heuristics based on file ownership, not API calls
- **Proper error handling**: No crashes or information leaks  
- **Hardened build flags**: All security hardening options enabled by default

This refactored version maintains all the original security guarantees while providing a clean, modern implementation that matches the project's requirements.