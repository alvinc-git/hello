# AppImage Packaging for hello

This directory contains the AppImage packaging infrastructure for `hello` (The standard Hello program). It resides within the versioned source directory (`hello-1.0.0/appimage/`) alongside `debian/`, `rpm/`, and `flatpak/` to maintain version-isolated packaging definitions.

## Contents

- `AppRun`: Entrypoint script configuring the portable execution runtime.
- `hello.desktop`: Desktop entry metadata for the AppImage bundle.
- `hello.svg`: Application vector icon.
- `README.md`: This documentation.

## Prerequisites

Building an AppImage requires `appimagetool`. On Linux systems:

```bash
# Download appimagetool
ARCH=$(uname -m)
wget "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${ARCH}.AppImage" -O appimagetool
chmod +x appimagetool
sudo mv appimagetool /usr/local/bin/
```

## Automated Build Script

Run the automated build script from the repository root:

```bash
./ci/build-appimage.sh
```

This compiles both C (`hello`) and Rust (`hello-rust`) implementations, stages the `AppDir` tree, and generates a portable standalone bundle:
`hello-1.0.0/appimage/dist/hello-1.0.0-<arch>.AppImage`

## Manual Assembly Steps

```bash
# 1. Compile binaries from hello-1.0.0
cd hello-1.0.0
./autogen.sh && ./configure --prefix=/usr && make

# 2. Prepare AppDir staging hierarchy
APPDIR=appimage/AppDir
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/man/man1" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/scalable/apps"

# 3. Copy binaries, manual pages, and metadata
cp hello "$APPDIR/usr/bin/"
[ -f hello-rust/target/release/hello ] && cp hello-rust/target/release/hello "$APPDIR/usr/bin/hello-rust"
cp man/hello.1 man/hello-rust.1 "$APPDIR/usr/share/man/man1/"
cp appimage/hello.desktop "$APPDIR/"
cp appimage/hello.desktop "$APPDIR/usr/share/applications/"
cp appimage/hello.svg "$APPDIR/"
cp appimage/hello.svg "$APPDIR/usr/share/icons/hicolor/scalable/apps/"
cp appimage/AppRun "$APPDIR/"
chmod +x "$APPDIR/AppRun"

# 4. Generate the AppImage
ARCH=$(uname -m) appimagetool "$APPDIR" "appimage/dist/hello-1.0.0-${ARCH}.AppImage"
```

## Running the AppImage

```bash
chmod +x hello-1.0.0-x86_64.AppImage
./hello-1.0.0-x86_64.AppImage --help
./hello-1.0.0-x86_64.AppImage --version
```
