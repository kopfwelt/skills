#!/usr/bin/env bash
# Packages the skill as dist/issue.zip for upload to claude.ai
# (Settings → Capabilities → Skills).
set -euo pipefail

cd "$(dirname "$0")/.."
NAME="issue"
DIST="dist"
REPO_ROOT="$(git rev-parse --show-toplevel)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/$NAME"
cp SKILL.md "$STAGE/$NAME/"
cp -R references "$STAGE/$NAME/"
cp "$REPO_ROOT/LICENSE" "$STAGE/$NAME/"

mkdir -p "$DIST"
rm -f "$DIST/$NAME.zip"
(cd "$STAGE" && zip -qr "$OLDPWD/$DIST/$NAME.zip" "$NAME" -x '*.DS_Store')

echo "Paket: $DIST/$NAME.zip"
unzip -l "$DIST/$NAME.zip"
