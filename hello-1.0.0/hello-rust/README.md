# hello (Rust Implementation)

![Language Rust](https://img.shields.io/badge/Rust-2021-000000?style=for-the-badge&logo=rust)
![Dependencies](https://img.shields.io/badge/dependencies-zero-success?style=for-the-badge)

This directory contains pure Rust implementations of both the `hello` with zero external dependencies.

## Features

- **`hello` Program**: Main program
- **Zero Dependencies**: Built using standard library `std` networking and POSIX system calls.
- **Security Guarantees**: Statically linked and stripped daemon, no NSS symbol dependencies, raw UID/GID checks (`NOBODY_ID`).

## Usage

### Program:
```bash
hello
```


## Building

```bash
# Build client dynamically
cargo build --release --bin hello

# Build daemon statically
RUSTFLAGS="-C target-feature=+crt-static -C relocation-model=static" cargo build --release --bin hello
```

The binaries will be created at:
- `target/release/hello`
