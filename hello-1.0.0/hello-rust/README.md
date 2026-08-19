# hello (Rust Implementation)

![Language Rust](https://img.shields.io/badge/Rust-2021-000000?style=for-the-badge&logo=rust)
![Dependencies](https://img.shields.io/badge/dependencies-zero-success?style=for-the-badge)

This directory contains the pure Rust implementation of `hello` with zero external dependencies.

## Features

- **`hello` Program**: Main program printing "Hello, World!"
- **Zero Dependencies**: Built using only the Rust standard library (`std`).
- **Standard Options**: Supports `-h` / `--help` and `-v` / `--version`.

## Usage

```bash
# Run hello
hello

# Show help
hello --help

# Show version
hello --version
```

## Building

```bash
cargo build --release
```

The compiled binary will be located at:
- `target/release/hello`
