#!/usr/bin/env python3
"""Small static validator for generated GLB file presence and manifest sanity.
This deliberately does not replace Blender or Godot runtime validation.
"""
from __future__ import annotations

import csv
import sys
from pathlib import Path


def main(root: str) -> int:
    p = Path(root)
    manifest = p / "GENERATED_MANIFEST.tsv"
    if not manifest.is_file():
        raise SystemExit("missing GENERATED_MANIFEST.tsv")
    with manifest.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f, delimiter="\t"))
    if len(rows) < 5:
        raise SystemExit(f"expected >=5 generated outputs, got {len(rows)}")
    for row in rows:
        asset = p / row["file"]
        if not asset.is_file() or asset.stat().st_size < 1024:
            raise SystemExit(f"missing/empty GLB: {asset}")
        if int(row["triangles"]) <= 0:
            raise SystemExit(f"invalid triangle count: {row}")
    print(f"FRONTLINE_GENERATED_GLB_STATIC_VALIDATION_PASS count={len(rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1]))
