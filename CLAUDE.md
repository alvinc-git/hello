# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`hello` is the standard Hello program, featuring C, Rust, and Go implementations with comprehensive multi-platform packaging (Debian, RPM, Flatpak, AppImage, Snap, Windows MSI, macOS Homebrew).

## Repository layout

The git root is **not** the build root. All buildable source lives in `hello-1.0.0/`, which is shaped like an unpacked release tarball. Run all build commands from `hello-1.0.0/`.

Release tarballs are generated with `make dist`, not committed.

## Build

```bash
cd hello-1.0.0
./autogen.sh          # autoreconf -v -i -f; only needed after touching configure.ac/Makefile.am
./configure           # AC_PREFIX_DEFAULT is /usr, so bindir=/usr/bin
make
```

Produces binaries: `hello` (C program), `hello-rust` (zero-dependency Rust program, when `cargo` is present), and `hello_go` (zero-dependency Go program, when `go` is present).

`configure` prints a summary of what it resolved. Relevant options:

| Option | Default | Effect |
|---|---|---|
| `--disable-strict` | strict on | Drops `-std=c99 -pedantic -Wextra -Wconversion` and prototype warnings |
| `--enable-werror` | off | Adds `-Werror` |
| `--disable-hardening` | hardening on | Drops `-fstack-protector-strong`, `-D_FORTIFY_SOURCE=2`, `-Wl,-z,relro`, `-Wl,-z,now` |
| `--disable-rust` | auto | Skips building the Rust program |
| `--disable-go` | auto | Skips building the Go program |

**The tree builds with zero warnings under the default flags. Keep it that way** — a new warning is a regression, not background noise.

`make check` runs verification. `make dist` works and produces `hello-1.0.0.tar.xz`, matching the name the Debian orig tarball needs.

Careful when checking for warnings: a bare second `make` is a no-op and will report a clean build regardless. Always `make clean` first.

## Run

```bash
./hello               # Prints "Hello, World!"
./hello --help        # Prints usage
./hello --version     # Prints version

./hello-rust/target/release/hello  # Rust program
./hello-go/hello_go                # Go program
```

## Packaging (Debian, RPM, Flatpak, AppImage, Snap, MSI & Homebrew)

Multiple packaging frameworks package `hello` (C), `hello-rust` (Rust), and `hello_go` (Go) together:

- **Debian packaging:** `hello-1.0.0/debian/` (build script: `./ci/build.sh`)
- **RPM packaging:** `hello-1.0.0/rpm/` (build script: `./ci/build-rpm.sh`)
- **Flatpak packaging:** `hello-1.0.0/flatpak/` (build script: `./ci/build-flatpak.sh`)
- **AppImage packaging:** `hello-1.0.0/appimage/` (build script: `./ci/build-appimage.sh`)
- **Snap packaging:** `hello-1.0.0/snap/` (build script: `./ci/build-snap.sh`)
- **Windows MSI packaging:** `hello-1.0.0/msi/` (build script: `./ci/build-msi.sh`)
- **macOS Homebrew formula:** `hello-1.0.0/homebrew/` (build script: `./ci/build-homebrew.sh`)

```bash
# Debian manual packaging:
cd hello-1.0.0 && make dist
B=/tmp/debbuild && mkdir -p $B
cp hello-1.0.0.tar.xz $B/hello_1.0.0.orig.tar.xz
cd $B && tar xf hello_1.0.0.orig.tar.xz
cp -r /path/to/repo/hello-1.0.0/debian hello-1.0.0/debian
cd hello-1.0.0 && dpkg-buildpackage -us -uc
```

Build outside the repo or in `build/` so packaging output doesn't pollute the working tree.

Man pages live in `man/` upstream, not in `debian/`, and reach the package via `dist_man_MANS` and `dh_installman`.

## Commits

- Commits must be **SSH/GPG signed** (`git commit -S`).
- Use **Conventional Commits** subjects (`feat:`, `fix:`, `chore:`) and write an explanatory body covering *why*, not a restatement of the diff.
- Never push (`git push`) automatically.
