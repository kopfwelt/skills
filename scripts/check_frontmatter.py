#!/usr/bin/env python3
"""Check the YAML frontmatter of every skills/**/SKILL.md.

Two consumers read it, and both have to succeed:

- Strict YAML parsers (Claude, PyYAML-based scanners such as Cisco's Skill
  Scanner). An unquoted ": " inside a plain scalar makes them reject the
  whole file — the scanner then skips the skill without saying so.
- The minimal line reader behind kopfwelt.com/wissen/skills, which only
  understands plain `key: value` with indented continuation lines. A block
  scalar (`>-`, `|`) or a quoted value would be rendered literally there.

Usage: python3 scripts/check_frontmatter.py
"""
import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
REQUIRED = ("name", "description")
KEY_LINE = re.compile(r"^([A-Za-z][\w-]*):[ \t]*(.*)$")


def check(path: pathlib.Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not match:
        return ["no frontmatter block (--- … ---) at the top"]
    raw = match.group(1)

    errors = []
    try:
        data = yaml.safe_load(raw)
    except yaml.YAMLError as exc:
        return [f"invalid YAML: {exc}".replace("\n", " ")]
    if not isinstance(data, dict):
        return ["frontmatter is not a mapping"]

    for key in REQUIRED:
        if not isinstance(data.get(key), str) or not data[key].strip():
            errors.append(f"missing or empty `{key}`")
    for key, value in data.items():
        if not isinstance(value, str):
            errors.append(f"`{key}` must be a string, got {type(value).__name__}")

    if data.get("name") != path.parent.name:
        errors.append(
            f"`name` is {data.get('name')!r}, but the folder is {path.parent.name!r}"
        )

    for line in raw.split("\n"):
        m = KEY_LINE.match(line)
        if m and m.group(2)[:1] in (">", "|", '"', "'"):
            errors.append(
                f"`{m.group(1)}` uses a block or quoted scalar; the kopfwelt.com "
                "reader only understands plain values — rephrase instead "
                "(e.g. an em dash instead of ': ')"
            )
    return errors


def main() -> int:
    files = sorted((ROOT / "skills").rglob("SKILL.md"))
    if not files:
        print("no SKILL.md found under skills/", file=sys.stderr)
        return 1
    failed = 0
    for path in files:
        rel = path.relative_to(ROOT)
        errors = check(path)
        if errors:
            failed += 1
            for err in errors:
                print(f"::error file={rel}::{err}")
                print(f"FAIL {rel}: {err}", file=sys.stderr)
        else:
            print(f"ok   {rel}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
