# Windows MSI Packaging for hello

This directory contains the WiX Toolset Windows MSI installer packaging infrastructure for `hello` (The standard Hello program). It resides within the versioned source directory (`hello-1.0.0/msi/`) alongside other distribution frameworks.

## Contents

- `hello.wxs`: WiX XML schema defining the Windows Installer component hierarchy, x64 architecture targets, installation to `Program Files\Hello`, and system PATH registration.
- `README.md`: This guide.

## Prerequisites

### On Windows (Native WiX Toolset)
- [WiX Toolset v3 or v4](https://wixtoolset.org/)
- MSVC / MinGW GCC and Rust toolchain with `x86_64-pc-windows-msvc` or `x86_64-pc-windows-gnu`

### On Linux (Cross-compilation via msitools & MinGW)
```bash
sudo apt-get install -y msitools gcc-mingw-w64-x86-64
rustup target add x86_64-pc-windows-gnu
```

## Automated Build Script

Run the automated build script from repository root:

```bash
./ci/build-msi.sh
```

Package artifacts land in `hello-1.0.0/msi/dist/`:
- `hello-1.0.0-x64.msi`

## Manual Build Instructions

### Linux (Cross-building with `wixl` & MinGW)
```bash
cd hello-1.0.0

# 1. Compile C binary
x86_64-w64-mingw32-gcc -O2 -o msi/hello.exe src/hello.c

# 2. Compile Rust binary
(cd hello-rust && cargo build --release --target x86_64-pc-windows-gnu)
cp hello-rust/target/x86_64-pc-windows-gnu/release/hello.exe msi/hello-rust.exe

# 3. Create MSI package
cd msi
mkdir -p dist
wixl -v -a x64 -o dist/hello-1.0.0-x64.msi hello.wxs
```

### Windows (Native WiX Toolset)
```powershell
cd hello-1.0.0\msi
candle.exe -arch x64 hello.wxs
light.exe -ext WixUIExtension -out dist\hello-1.0.0-x64.msi hello.wixobj
```
