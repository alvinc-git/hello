# AGENTS.md — Repository Guidance for AI Coding Agents

This repository contains `hello` (The standard Hello program).

---

## 1. Repository Structure & Active Build Root

- **Active Build Root:** `hello-1.0.0/`
- **Legacy References:** `hello-0.5.0/`, `hello-0.0.1/`
- **Rust Client Source:** `hello-1.0.0/hello-rust/`

> **Note:** The git root is **not** the build root. Always execute build and packaging commands from `hello-1.0.0/` or root CI scripts (`./ci/build.sh`, `./ci/build-rpm.sh`).

---

## 2. Build & Compilation

### Unified Build (Daemon + C Client + Rust Client & Daemon)
```bash
cd hello-1.0.0
./autogen.sh
./configure
make
```
This compiles:
- `hello` — C program (dynamically linked).
- `hello-rust` — Zero-dependency Rust client (compiled automatically when `cargo` is present).

### Standalone Rust Crate Build
```bash
cd hello-1.0.0/hello-rust
cargo build --release
```


---

## 3. Architecture & Security Guarantees

1. **Static Linking Guarantee (`hello` & `hello-rust`):**
   - **No NSS Symbols:** Do not use `getpwuid` or `getgrgid`. Compare raw `st_uid`/`st_gid` against `NOBODY_ID` (65534) to avoid runtime `dlopen()` dependencies.
2. **Fresh Facts Probing:**
   - `gather_facts()` must run inside the `accept()` loop per connection. Do not hoist fact gathering out of the serve loop.
3. **Rust Zero External Dependencies:**
   - `hello-rust` (crate providing `hello`) uses pure Rust standard library (`std`) networking and arguments with zero third-party dependencies (`Cargo.toml` specifies no `[dependencies]`).

---

## 4. Packaging Infrastructure

Both Debian and RPM packaging build and package `hello` and `hello-rust` together:
- **Debian Packaging:** `./ci/build.sh` (outputs `.deb` artifacts in `build/dist/`)
- **RPM Packaging:** `./ci/build-rpm.sh` (outputs `.rpm` artifacts in `rpm/RPMS/`)


---

## 5. Git & Workflow Constraints (STRICT)

- **Signed Commits:** Every git commit MUST be signed (`git commit -S`).
- **Commit Format:** Use Conventional Commit subjects (`feat:`, `fix:`, `docs:`, `perf:`, `chore:`) with clear body explanations covering *why* changes were made.
- **Co-Authorship Attribution:** Every commit generated with or by an AI agent MUST include a `Co-Authored-By:` trailer in the commit message body attributing the AI assistant and the specific model used (e.g., `Co-Authored-By: Antigravity gemini-2.5-pro <noreply@google.com>`).
- **NO Push Rule:** **NEVER execute `git push` or programmatic pushes.** Only the human user executes push operations.

