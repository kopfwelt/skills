#!/usr/bin/env bash
# Paketiert den Skill als dist/design-thinking-methods.zip für den
# Upload in claude.ai (Settings → Capabilities → Skills).
set -euo pipefail

cd "$(dirname "$0")/.."
NAME="design-thinking-methods"
DIST="dist"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# Nur das, was der Skill zur Laufzeit braucht — kein README, kein dist.
mkdir -p "$STAGE/$NAME"
cp SKILL.md "$STAGE/$NAME/"
cp -R references assets scripts "$STAGE/$NAME/"
rm -f "$STAGE/$NAME/scripts/package.sh"

mkdir -p "$DIST"
rm -f "$DIST/$NAME.zip"
(cd "$STAGE" && zip -qr "$OLDPWD/$DIST/$NAME.zip" "$NAME" -x '*.DS_Store')

echo "Paket: $DIST/$NAME.zip"
unzip -l "$DIST/$NAME.zip"
