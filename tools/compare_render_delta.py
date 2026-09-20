#!/usr/bin/env python3
"""Same-renderer capture comparison for FRONTLINE gate evidence.

Gate protocol compares two captures produced by the same renderer (usually the CI
artifact of the current gate against the artifact of the previous gate) and asks
whether the delta is confined to the geometry the gate added, or whether it has
spread into the protected environment (terrain, architecture, vegetation,
lighting, atmosphere, water).

Usage:
    python3 compare_render_delta.py OLD.png NEW.png [--tolerance 8] [--mask out.png]

Reports the exact-match ratio, the ratio of pixels differing beyond the
tolerance, the delta bounding box, and the delta ratio per named screen region so
the reviewer can see where the change lives. `--mask` writes the new capture with
differing pixels painted red, which makes "vehicle-shaped delta" verifiable at a
glance.

Dependencies: numpy, Pillow. Not wired into CI; run it locally against two
downloaded artifact captures (see the gate evidence records for run IDs).
"""
from __future__ import annotations

import argparse

import numpy as np
from PIL import Image

# Screen regions of the FRONTLINE River Town reference capture (1920x1080). The
# names describe what the region contains, not what changed in it.
REFERENCE_REGIONS: dict[str, tuple[int, int, int, int]] = {
    "sky_and_distant_village": (0, 200, 0, 1920),
    "hero_house": (0, 700, 0, 340),
    "center_village": (200, 420, 340, 1600),
    "vehicle_band": (420, 900, 0, 1920),
    "far_right_field": (400, 800, 1600, 1920),
    "foreground_ground": (900, 1080, 0, 1920),
}


def load(path: str) -> np.ndarray:
    return np.asarray(Image.open(path).convert("RGB"), dtype=np.int16)


def report(old: np.ndarray, new: np.ndarray, tolerance: int) -> int:
    if old.shape != new.shape:
        print(f"FAIL: size mismatch {old.shape} vs {new.shape}")
        return 2
    delta = np.abs(old - new).max(axis=2)
    mask = delta > tolerance
    total = mask.size
    print(f"capture_size={new.shape[1]}x{new.shape[0]} tolerance={tolerance}")
    print(f"exact_match={100.0 * (delta == 0).sum() / total:.4f}%")
    print(f"delta_pixels={100.0 * mask.sum() / total:.4f}% ({int(mask.sum())} px)")
    print(f"max_channel_delta={int(delta.max())}")
    if mask.any():
        rows = np.where(mask.any(axis=1))[0]
        cols = np.where(mask.any(axis=0))[0]
        print(f"delta_bbox=({int(cols[0])},{int(rows[0])})-({int(cols[-1])},{int(rows[-1])})")
    else:
        print("delta_bbox=none")
    print("region report (describe where the change lives):")
    for name, (r0, r1, c0, c1) in REFERENCE_REGIONS.items():
        r1 = min(r1, mask.shape[0])
        c1 = min(c1, mask.shape[1])
        sub_mask = mask[r0:r1, c0:c1]
        sub_delta = delta[r0:r1, c0:c1]
        print(f"  {name}: delta={100.0 * sub_mask.mean():.2f}% mean_abs_delta={sub_delta.mean():.2f}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("old")
    parser.add_argument("new")
    parser.add_argument("--tolerance", type=int, default=8)
    parser.add_argument("--mask", help="write the new capture with differing pixels painted red")
    args = parser.parse_args()
    old = load(args.old)
    new = load(args.new)
    if args.mask:
        delta = np.abs(old - new).max(axis=2)
        visual = np.asarray(Image.open(args.new).convert("RGB")).copy()
        visual[delta > args.tolerance] = (255, 0, 0)
        Image.fromarray(visual).save(args.mask)
        print(f"mask_written={args.mask}")
    return report(old, new, args.tolerance)


if __name__ == "__main__":
    raise SystemExit(main())
