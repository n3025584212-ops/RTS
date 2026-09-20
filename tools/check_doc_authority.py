#!/usr/bin/env python3
"""FRONTLINE documentation authority check.

Enforces the rules recorded in docs/ops/DOCUMENT_AUTHORITY_POLICY_V1.md:

  1. ONE ACTIVE PER TOPIC FAMILY. A topic family is a filename minus its _V<n>
     version suffix (FRONTLINE_PROJECT_SYSTEM_V3 -> FRONTLINE_PROJECT_SYSTEM).
     Outside the archive, at most one document per family may declare STATUS=ACTIVE.
     This is the check that would have caught V1/V2/V3 all claiming to be current.
  2. ARCHIVED DOCUMENTS MUST SAY SO. A document under archive/ or history/ may keep
     its historical STATUS=ACTIVE, but only if it also carries an archive marker
     (ARCHIVED / SUPERSEDED / NON-AUTHORITATIVE) so a reader cannot mistake it for
     current authority.
  3. THE AUTHORITY DOCUMENTS MUST NOT DANGLE. The documents on the read path
     (README, START_HERE, docs/README, the control state, the gate contract, the
     repository map, the governance set) must not point at a repository path that no
     longer exists — the usual cause being a document archived while others kept
     citing it. Historical and learning documents are not checked: they legitimately
     describe branches and artefacts that are not on this branch.

Cross-branch references are ignored: `product/<branch>::docs/x.md` names a file on
another branch, so it is not a dangling reference on this one.

Usage
-----
    python tools/check_doc_authority.py [--root <repo root>]

--root wants a real filesystem path. From Git Bash / MSYS on Windows, `/d/Agent/...`
is not understood by Python and resolves to `D:\d\Agent\...`; pass `D:/Agent/...`
or a relative path instead.

Exit code 0 = clean, 1 = findings printed.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ARCHIVE_DIR_NAMES = {"archive", "history"}
ARCHIVE_MARKERS = ("ARCHIVED", "SUPERSEDED", "NON-AUTHORITATIVE", "NON_AUTHORITATIVE")

VERSION_SUFFIX = re.compile(r"_V\d+$", re.IGNORECASE)
STATUS_LINE = re.compile(r"^\s*STATUS\s*=\s*(\S+)", re.MULTILINE)
CROSS_BRANCH_REFERENCE = re.compile(r"\S+::docs/[A-Za-z0-9_./-]*\.md")
DOCS_REFERENCE = re.compile(r"docs/[A-Za-z0-9_][A-Za-z0-9_./-]*\.md")
AUTHORITY_STATUSES = ("ACTIVE", "ACCEPTED")

# The read path: documents an agent or a person actually loads. Only these are
# checked for dangling references, so the check stays a signal rather than noise.
READ_PATH_DOCUMENTS = (
    "README.md",
    "START_HERE.md",
    "docs/README.md",
    "docs/current/CURRENT_STATE.md",
    "docs/current/ACTIVE_WORK.md",
    "docs/current/HIGH_FIDELITY_PRODUCT_SLICE_V1.md",
    "docs/ops/REPOSITORY_MAP_V3.md",
    "docs/FRONTLINE_PROJECT_CHARTER_V3.md",
    "docs/FRONTLINE_PROJECT_SYSTEM_V3.md",
    "docs/FRONTLINE_EXECUTION_MODEL_V1.md",
    "docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md",
)

HEAD_BYTES = 8192


def is_archived(path: Path, docs_dir: Path) -> bool:
    try:
        parts = path.relative_to(docs_dir).parts
    except ValueError:
        return False
    return any(part in ARCHIVE_DIR_NAMES for part in parts[:-1])


def topic_family(path: Path) -> str:
    return VERSION_SUFFIX.sub("", path.stem).upper()


def read_head(path: Path) -> str:
    try:
        with path.open("r", encoding="utf-8", errors="replace") as handle:
            return handle.read(HEAD_BYTES)
    except OSError:
        return ""


def main() -> int:
    parser = argparse.ArgumentParser(description="FRONTLINE documentation authority check")
    parser.add_argument("--root", default=".", help="repository root (default: cwd)")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    docs_dir = root / "docs"
    if not docs_dir.is_dir():
        print(f"no docs directory under {root}")
        return 1

    documents = sorted(p for p in docs_dir.rglob("*.md") if p.is_file())
    findings: list[str] = []
    active_by_family: dict[str, list[Path]] = {}

    for path in documents:
        head = read_head(path)
        status_match = STATUS_LINE.search(head)
        status = status_match.group(1).upper() if status_match else ""
        claims_authority = any(status.startswith(s) for s in AUTHORITY_STATUSES)
        if not claims_authority:
            continue

        if is_archived(path, docs_dir):
            head_upper = head.upper()
            if not any(marker in head_upper for marker in ARCHIVE_MARKERS):
                findings.append(
                    f"[archive claims authority silently] {path.relative_to(root)} declares "
                    f"STATUS={status} without an archive marker "
                    f"({' / '.join(ARCHIVE_MARKERS[:3])})"
                )
            continue

        active_by_family.setdefault(topic_family(path), []).append(path)

    for family, paths in sorted(active_by_family.items()):
        if len(paths) > 1:
            listing = "\n".join(f"        {p.relative_to(root)}" for p in paths)
            findings.append(
                f"[multiple ACTIVE in family {family}] {len(paths)} documents claim to be "
                f"current:\n{listing}"
            )

    checked_references = 0
    for relative in READ_PATH_DOCUMENTS:
        path = root / relative
        if not path.is_file():
            continue
        head = read_head(path)
        without_cross_branch = CROSS_BRANCH_REFERENCE.sub("", head)
        for reference in sorted(set(DOCS_REFERENCE.findall(without_cross_branch))):
            checked_references += 1
            if not (root / reference).is_file():
                findings.append(f"[dangling reference] {relative} -> {reference} does not exist")

    print(f"checked {len(documents)} documents; {checked_references} references on the read path")
    if findings:
        print(f"\n{len(findings)} finding(s):\n")
        for finding in findings:
            print(f"  - {finding}")
        return 1

    print("clean: one ACTIVE per topic family, archive properly marked, read path has no dangling links")
    return 0


if __name__ == "__main__":
    sys.exit(main())
