# hello

![Version](https://img.shields.io/badge/version-1.0.0-0052CC?style=for-the-badge)
![Language C](https://img.shields.io/badge/C-POSIX-00599C?style=for-the-badge&logo=c)
![Language Rust](https://img.shields.io/badge/Rust-2021-000000?style=for-the-badge&logo=rust)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

`hello` is the standard Hello program, featuring both C and zero-dependency Rust implementations.

## Features

- **C Implementation (`hello`)**: Clean, lightweight C99 / POSIX implementation.
- **Rust Implementation (`hello-rust`)**: Zero-dependency Rust implementation using only `std`.
- **GNU Autotools Build System**: Supports standard `./autogen.sh && ./configure && make`.
- **Distribution Packages**: Complete packaging for both Debian (`.deb`) and RPM (`.rpm`).

## Building

```bash
./autogen.sh
./configure
make
```

## Running

```bash
./hello
./hello-rust/target/release/hello
```
