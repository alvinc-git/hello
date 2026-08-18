#!/bin/bash
#
# Upload the built artifacts to the repository Downloads area.
#
# Intended to run in Bitbucket Pipelines on a v* tag build, but is runnable by
# hand against build/dist/ as well.
#
# Credentials come from repository variables, which must be marked Secured:
#
#   Repository settings -> Repository variables
#     BITBUCKET_USER          your Bitbucket username (not your email)
#     BITBUCKET_APP_PASSWORD  app password with the repository:write scope
#
# Create the app password under Personal settings -> App passwords.
# Nothing here echoes the credentials.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/build/dist"

WORKSPACE="${BITBUCKET_WORKSPACE:-alvinc-git}"
REPO="${BITBUCKET_REPO_SLUG:-hello}"
API="https://api.bitbucket.org/2.0/repositories/${WORKSPACE}/${REPO}/downloads"

: "${BITBUCKET_USER:?BITBUCKET_USER is not set; add it as a repository variable}"
: "${BITBUCKET_APP_PASSWORD:?BITBUCKET_APP_PASSWORD is not set; add it as a Secured repository variable}"

if [ ! -d "$DIST" ] || [ -z "$(ls -A "$DIST" 2>/dev/null)" ]; then
    echo "!!! $DIST is empty. Run ci/build.sh first, or check that the build"
    echo "    step's artifacts were passed to this step."
    exit 1
fi

echo "==> Uploading to https://bitbucket.org/${WORKSPACE}/${REPO}/downloads/"
echo "    tag: ${BITBUCKET_TAG:-<none>}"
echo

cd "$DIST"
failed=0
for f in *; do
    printf '    %-45s ' "$f"
    code=$(curl -s -o /tmp/bb-upload.out -w '%{http_code}' \
                -u "${BITBUCKET_USER}:${BITBUCKET_APP_PASSWORD}" \
                -X POST "$API" -F "files=@${f}")
    case "$code" in
        200|201) echo "OK ($code)" ;;
        401|403) echo "FAILED ($code) - app password lacks repository:write"; failed=1 ;;
        404)     echo "FAILED ($code) - workspace/repo slug wrong, or token cannot see it"; failed=1 ;;
        *)       echo "FAILED ($code)"; sed 's/^/        /' /tmp/bb-upload.out; failed=1 ;;
    esac
done
rm -f /tmp/bb-upload.out

if [ "$failed" -ne 0 ]; then
    echo
    echo "!!! One or more uploads failed."
    exit 1
fi

echo
echo "==> Done. Downloads are flat and repo-wide: re-uploading a filename"
echo "    silently replaces the previous copy. Version numbers are what keep"
echo "    releases distinct, so never rebuild a released version in place."
echo "    https://bitbucket.org/${WORKSPACE}/${REPO}/downloads/"
