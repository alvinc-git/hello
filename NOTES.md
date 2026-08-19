# Project Notes: hello

## Repository Information

- **GitHub Repository:** `git@github.com:alvinc-git/hello.git`
- **Web URL:** `https://github.com/alvinc-git/hello`
- **Active Release Tree:** `hello-1.0.0/`

---

## Quick Reference Commands

### Building Locally
```bash
cd hello-1.0.0
./autogen.sh
./configure
make clean
make
```

### Running Test Builds
```bash
# C program
./hello-1.0.0/hello

# Rust program
cd hello-1.0.0/hello-rust && ./test-build.sh

# Go program
cd hello-1.0.0/hello-go && ./test-build.sh
```

### Building Packages
```bash
# Debian package
./ci/build.sh

# RPM package
./ci/build-rpm.sh
```

---

## Packaging Guidelines

- **Debian (`debian/`):** Maintain `3.0 (quilt)` packaging standards. Do not include `debian/` in release tarball (`EXTRA_DIST`), as Debian builds unpack packaging onto upstream `orig.tar.xz`.
- **RPM (`hello-1.0.0/rpm/`):** Maintain single unified spec in `hello-1.0.0/rpm/SPECS/hello.spec` packaging `hello`, `hello_rust`, and `hello_go`.
