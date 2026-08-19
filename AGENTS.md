# AGENTS.md — Repository Guidance for AI Coding Agents

This repository contains `hello` (The standard Hello program).

---

## 1. Repository Structure & Active Build Root

- **Active Build Root:** `hello-1.0.0/`
- **Rust Program Source:** `hello-1.0.0/hello-rust/`
- **Go Program Source:** `hello-1.0.0/hello-go/`

> **Note:** The git root is **not** the build root. Always execute build and packaging commands from `hello-1.0.0/` or root CI scripts (`./ci/build.sh`, `./ci/build-rpm.sh`).

---

## 2. Build & Compilation

### Unified Build (C, Rust & Go)
```bash
cd hello-1.0.0
./autogen.sh
./configure
make
```
This compiles:
- `hello` — C program.
- `hello_rust` — Zero-dependency Rust program (compiled automatically when `cargo` is present).
- `hello_go` — Zero-dependency Go program (compiled automatically when `go` is present).

### Standalone Rust Crate Build
```bash
cd hello-1.0.0/hello-rust
cargo build --release
```

### Standalone Go Program Build
```bash
cd hello-1.0.0/hello-go
go build -ldflags "-X main.programVersion=1.0.0" -o hello_go main.go
```

---

## 3. Architecture & Dependency Guarantees

1. **Rust Zero External Dependencies:**
   - `hello_rust` (`hello-rust/`) uses only the pure Rust standard library (`std`) with zero third-party dependencies (`Cargo.toml` specifies no `[dependencies]`).
2. **Go Zero External Dependencies:**
   - `hello_go` uses only the pure Go standard library with zero third-party dependencies.
3. **Standard Option Support:**
   - C, Rust, and Go programs support `-h`/`--help` and `-v`/`-V`/`--version` flags while printing "Hello, World!" by default.

## 4. Packaging Infrastructure

Debian, RPM, Flatpak, AppImage, Snap, Windows MSI, and macOS Homebrew packaging build and package `hello`, `hello_rust`, and `hello_go` together:
- **Debian Packaging:** `hello-1.0.0/debian/` (script: `./ci/build.sh`, outputs in `build/dist/`)
- **RPM Packaging:** `hello-1.0.0/rpm/` (script: `./ci/build-rpm.sh`, outputs in `hello-1.0.0/rpm/RPMS/`)
- **Flatpak Packaging:** `hello-1.0.0/flatpak/` (script: `./ci/build-flatpak.sh`, outputs in `hello-1.0.0/flatpak/dist/`)
- **AppImage Packaging:** `hello-1.0.0/appimage/` (script: `./ci/build-appimage.sh`, outputs in `hello-1.0.0/appimage/dist/`)
- **Snap Packaging:** `hello-1.0.0/snap/` (script: `./ci/build-snap.sh`, outputs in `hello-1.0.0/snap/dist/`)
- **Windows MSI Packaging:** `hello-1.0.0/msi/` (script: `./ci/build-msi.sh`, outputs in `hello-1.0.0/msi/dist/`)
- **macOS Homebrew Formula:** `hello-1.0.0/homebrew/` (script: `./ci/build-homebrew.sh`, outputs in `hello-1.0.0/homebrew/dist/`)

---

## 5. Git & Workflow Constraints (STRICT)

- **Signed Commits:** Every git commit MUST be signed (`git commit -S`).
- **Commit Format:** Use Conventional Commit subjects (`feat:`, `fix:`, `docs:`, `perf:`, `chore:`) with clear body explanations covering *why* changes were made.
- **Co-Authorship Attribution:** Every commit generated with or by an AI agent MUST include a `Co-Authored-By:` trailer in the commit message body attributing the AI assistant and the specific model used (e.g., `Co-Authored-By: Antigravity gemini-2.5-pro <noreply@google.com>`).
- **NO Push Rule:** **NEVER execute `git push` or programmatic pushes.** Only the human user executes push operations.
