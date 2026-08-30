#!/usr/bin/env bash
# Packages the skill as dist/ship.zip for upload to claude.ai
# (Settings → Capabilities → Skills).
set -euo pipefail

cd "$(dirname "$0")/.."
NAME="ship"
DIST="dist"
REPO_ROOT="$(git rev-parse --show-toplevel)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# ship has no runtime assets — SKILL.md is the whole skill.
mkdir -p "$STAGE/$NAME"
cp SKILL.md "$STAGE/$NAME/"
cp "$REPO_ROOT/LICENSE" "$STAGE/$NAME/"

mkdir -p "$DIST"
rm -f "$DIST/$NAME.zip"
(cd "$STAGE" && zip -qr "$OLDPWD/$DIST/$NAME.zip" "$NAME" -x '*.DS_Store')

echo "Paket: $DIST/$NAME.zip"
unzip -l "$DIST/$NAME.zip"
