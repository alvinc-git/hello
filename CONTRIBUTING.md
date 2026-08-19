# Contributing to hello

Thank you for your interest in contributing to `hello` (The standard Hello program)!

This document outlines the development workflow, coding standards, and contribution guidelines for the project.

---

## 1. Repository Layout & Active Build Root

- **Active Build Root:** [`hello-1.0.0/`](file:///Users/acura/github/hello/hello-1.0.0/)
- **Rust Program Source:** [`hello-1.0.0/hello-rust/`](file:///Users/acura/github/hello/hello-1.0.0/hello-rust/)
- **Go Program Source:** [`hello-1.0.0/hello-go/`](file:///Users/acura/github/hello/hello-1.0.0/hello-go/)

> **Note:** The git root is **not** the build root. Always execute build and packaging commands from `hello-1.0.0/` or from the root CI scripts (`./ci/build.sh`, `./ci/build-rpm.sh`).

---

## 2. Development Guidelines

### C Program (`hello-1.0.0/src/`)
- Adhere strictly to **C99 / POSIX** standards.
- Build clean with zero warnings under default strictness flags (`-std=c99 -pedantic -Wextra -Wconversion -Wstrict-prototypes`).
- Do not introduce runtime library dependencies beyond standard libc.

### Rust Program (`hello-1.0.0/hello-rust/`)
- **Zero External Dependencies:** The Rust implementation (`hello_rust`) must use only the pure Rust standard library (`std`). Third-party crates in `Cargo.toml` (`[dependencies]`) are strictly not permitted.
- Maintain argument and functional parity with the C implementation (`-h`/`--help`, `-v`/`--version`, and standard greeting).

### Go Program (`hello-1.0.0/hello-go/`)
- **Zero External Dependencies:** The Go implementation (`hello_go`) must use only the pure Go standard library. Third-party packages in `go.mod` are strictly not permitted.
- Maintain argument and functional parity with the C implementation (`-h`/`--help`, `-v`/`--version`, and standard greeting).

---

## 3. Local Build & Testing

### Unified Build
```bash
cd hello-1.0.0
./autogen.sh
./configure
make clean
make
```

### Standalone Rust Verification
```bash
cd hello-1.0.0/hello-rust
./test-build.sh
```

### Standalone Go Verification
```bash
cd hello-1.0.0/hello-go
./test-build.sh
```

### Packaging Verification
Ensure both packaging pipelines build cleanly before submitting changes:
```bash
# Debian build & lintian verification
./ci/build.sh

# RPM build verification
./ci/build-rpm.sh
```

---

## 4. Git Commit Standards

Every commit must adhere to the following standards:

1. **Signed Commits (Mandatory):**
   - Every git commit MUST be signed (`git commit -S`).
2. **Conventional Commits:**
   - Use standardized Conventional Commit prefixes:
     - `feat:` for new features or functionality
     - `fix:` for bug fixes
     - `docs:` for documentation updates
     - `refactor:` for code restructurings
     - `chore:` for build scripts, CI, and packaging updates
     - `test:` for adding or updating test scripts
   - Provide a concise subject line followed by a detailed body explaining *why* the changes were made.
3. **Co-Authorship Attribution:**
   - When collaborating with or using AI assistants, append co-authorship trailers to the commit body:
     ```text
     Co-authored-by: Google Antigravity <antigravity@google.com>
     ```
4. **No Direct Push to Main:**
   - Submit all contributions via topic branches and pull requests.

---

## 5. Submitting a Pull Request

1. Fork the repository and create a feature branch (`git checkout -b feature/my-feature`).
2. Make your modifications, adhering to code strictness and zero-dependency guarantees.
3. Verify that all builds, tests, and packaging scripts pass without errors or warnings.
4. Update relevant documentation (including [CHANGELOG.md](file:///Users/acura/github/hello/CHANGELOG.md) under `[Unreleased]`).
5. Commit your changes using signed commits (`git commit -S`).
6. Open a Pull Request on GitHub describing your changes and testing results.
