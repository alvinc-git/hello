#!/bin/bash
#
# Build and verify hello, producing both binary and source packages.
#
# Runs in GitHub Actions and is equally runnable by hand:
#   ./ci/build.sh
#
# Output lands in build/dist/.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/hello-1.0.0"
BUILD="$ROOT/build"
DIST="$BUILD/dist"

# Exactly the lintian tags this package is known to emit. Anything else is a
# regression and fails the build.
KNOWN_LINTIAN_TAGS='bad-distribution-in-changes-file|initial-upload-closes-no-bugs'

rm -rf "$BUILD"
mkdir -p "$DIST"

echo "==> Provenance"
if command -v git >/dev/null && [ -d "$ROOT/.git" ]; then
    echo "    commit:   $(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
    echo "    describe: $(git -C "$ROOT" describe --tags --always 2>/dev/null || echo unknown)"
fi
echo "    tag:      ${GITHUB_REF_NAME:-${TAG:-<not a tag build>}}"
echo "    image:    $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo unknown)"

echo "==> Bootstrapping autotools"
cd "$SRC"
./autogen.sh 2>&1 | tee "$BUILD/autogen.log"

# autoreconf prints the literal line "autoreconf: export WARNINGS=" on every
# run; it is not a diagnostic. Exclude it before counting.
if grep -iE 'warning|error' "$BUILD/autogen.log" | grep -qv 'export WARNINGS'; then
    echo "!!! autoreconf emitted warnings:"
    grep -iE 'warning|error' "$BUILD/autogen.log" | grep -v 'export WARNINGS'
    exit 1
fi

echo "==> Configuring"
./configure

echo "==> Compiling (warnings are treated as failures)"
make clean >/dev/null
make 2>&1 | tee "$BUILD/make.log"
if grep -qE 'warning:|error:' "$BUILD/make.log"; then
    echo "!!! compiler diagnostics present; the tree must build clean:"
    grep -E 'warning:|error:' "$BUILD/make.log"
    exit 1
fi

echo "==> Creating the upstream tarball"
make dist

echo "==> Assembling the 3.0 (quilt) source tree"
# debian/ is deliberately excluded from EXTRA_DIST, because the quilt format
# expects packaging applied on top of an orig tarball that does not contain it.
cp hello-1.0.0.tar.xz "$BUILD/hello_1.0.0.orig.tar.xz"
cd "$BUILD"
tar xf hello_1.0.0.orig.tar.xz
cp -r "$SRC/debian" hello-1.0.0/debian

echo "==> Building binary and source packages"
cd hello-1.0.0
dpkg-buildpackage -us -uc

echo "==> Linting"
cd "$BUILD"
lintian ./*.changes 2>&1 | tee lintian.log || true
if grep -E '^(E|W):' lintian.log | grep -qvE "$KNOWN_LINTIAN_TAGS"; then
    echo "!!! unexpected lintian findings (only these are permitted:"
    echo "!!! $KNOWN_LINTIAN_TAGS):"
    grep -E '^(E|W):' lintian.log | grep -vE "$KNOWN_LINTIAN_TAGS"
    exit 1
fi

echo "==> Verifying the source package round-trips"
rm -rf "$BUILD/srccheck"
mkdir -p "$BUILD/srccheck"
dpkg-source -x ./*.dsc "$BUILD/srccheck/hello-1.0.0" >/dev/null

echo "==> Collecting artifacts"
cp ./*.deb ./*.dsc ./*.changes ./*.buildinfo ./*.tar.xz "$DIST/" 2>/dev/null || true
cp ./*.ddeb "$DIST/" 2>/dev/null || true
cd "$DIST"
if command -v sha256sum >/dev/null; then
    sha256sum ./* > SHA256SUMS
elif command -v shasum >/dev/null; then
    shasum -a 256 ./* > SHA256SUMS
fi

echo
echo "==> Artifacts in build/dist:"
ls -1sh
echo
echo "==> Package information:"
if ls ./hello_*_*.deb 1>/dev/null 2>&1; then
    dpkg-deb -f ./hello_*_*.deb Package Version Architecture Depends || true
fi
