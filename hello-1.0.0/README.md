# hello

![Version](https://img.shields.io/badge/version-1.0.0-0052CC?style=for-the-badge)
![Language C](https://img.shields.io/badge/C-POSIX-00599C?style=for-the-badge&logo=c)
![Language Rust](https://img.shields.io/badge/Rust-2021-000000?style=for-the-badge&logo=rust)
![Language Go](https://img.shields.io/badge/Go-1.18+-00ADD8?style=for-the-badge&logo=go)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

`hello` is the standard Hello program, featuring C, zero-dependency Rust (`hello_rust`), and zero-dependency Go (`hello_go`) implementations.

## Features

- **C Implementation (`hello`)**: Clean, lightweight C99 / POSIX implementation.
- **Rust Implementation (`hello_rust`)**: Zero-dependency pure Rust implementation using only `std`.
- **Go Implementation (`hello_go`)**: Zero-dependency pure Go implementation using only the standard library.
- **GNU Autotools Build System**: Supports standard `./autogen.sh && ./configure && make`.
- **Packaging Parity**: Co-located multi-platform packaging (Debian, RPM, Flatpak, AppImage, Snap, Windows MSI, macOS Homebrew).

## Building

```bash
./autogen.sh
./configure
make
```

## Running

```bash
./hello
./hello-rust/target/release/hello_rust
./hello-go/hello_go
```
