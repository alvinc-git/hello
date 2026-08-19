# hello_go (Go Implementation)

![Language Go](https://img.shields.io/badge/Go-1.18+-00ADD8?style=for-the-badge&logo=go)
![Dependencies](https://img.shields.io/badge/dependencies-zero-success?style=for-the-badge)

This directory contains the pure Go implementation of `hello` (`hello_go`) with zero external dependencies.

## Features

- **`hello_go` Executable**: Main program printing "Hello, World!"
- **Zero External Dependencies**: Built using only the Go standard library.
- **Dynamic Build-Time Version Injection**: Injects version via linker `-ldflags "-X main.programVersion=..."`.
- **Standard Options**: Supports `-h` / `--help` and `-v` / `-V` / `--version`.

## Usage

```bash
# Run hello_go
./hello_go

# Show help
./hello_go --help

# Show version
./hello_go --version
```

## Building

```bash
go build -ldflags "-X main.programVersion=1.0.0" -o hello_go main.go
```

The compiled binary will be located at:
- `hello_go`
