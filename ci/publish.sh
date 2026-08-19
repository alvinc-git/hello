#!/bin/bash
#
# Upload the built artifacts to GitHub Releases.
#
# Intended to run in GitHub Actions on a v* tag release, but is runnable by
# hand against build/dist/ as well when GH_TOKEN or GITHUB_TOKEN is set.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/build/dist"
TAG="${GITHUB_REF_NAME:-${TAG:-}}"

if [ -z "$TAG" ]; then
    echo "!!! TAG or GITHUB_REF_NAME is not set."
    exit 1
fi

if [ ! -d "$DIST" ] || [ -z "$(ls -A "$DIST" 2>/dev/null)" ]; then
    echo "!!! $DIST is empty. Run ci/build.sh first."
    exit 1
fi

echo "==> Publishing artifacts for release $TAG to GitHub Releases"

if command -v gh >/dev/null; then
    gh release upload "$TAG" "$DIST"/* --clobber
    echo "==> Artifacts uploaded successfully via GitHub CLI."
else
    echo "==> gh CLI not found. If running in custom CI, ensure gh is installed."
fi
