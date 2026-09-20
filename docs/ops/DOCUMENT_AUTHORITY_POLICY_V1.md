# FRONTLINE — DOCUMENT AUTHORITY POLICY V1

STATUS=ACTIVE
PROJECT=FRONTLINE
DATE=2026-09-20
CHECKER=tools/check_doc_authority.py
CONTEXT=Written after a pass found seven governance documents all declaring STATUS=ACTIVE at once,
and a directory map that pointed at the oldest of each chain.

## 1. The rule that matters

Exactly one document states the current stage, gate, window routing and verified branch head:

`docs/current/CURRENT_STATE.md`

Every other document **points** at authority; none restates it. A file that declares its own
`STATUS=ACTIVE` is not thereby authoritative.

## 2. Metadata block

Every governance or state document starts with:

```
STATUS=<value>
PROJECT=FRONTLINE
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md      # for anything state-adjacent
SUPERSEDES=...                                      # when it replaces an earlier document
```

Allowed STATUS values:

| Value | Meaning |
|---|---|
| `ACTIVE` | Current authority for its topic. At most one per topic family. |
| `SUPERSEDED` | Replaced. The file moves to `docs/archive/governance/`. |
| `ARCHIVED` | Historical, not authority. Lives under `archive/` or `current/history/`. |
| `POINTER_ONLY` | Entry and navigation files that deliberately hold no state (README, START_HERE, ACTIVE_WORK). |

## 3. Topic families

A topic family is a filename minus its `_V<n>` suffix:

| Family | Archived | Current |
|---|---|---|
| `FRONTLINE_PROJECT_SYSTEM` | V1, V2 | **V3** |
| `GPT_MULTI_WINDOW_SYSTEM` / `GPT_COLLABORATION_SYSTEM` | V2, V3, V4 | **GPT_FOUR_WINDOW_SYSTEM_V5** |
| `GPT_WINDOW_RUNTIME_PLAN` | V1 | **V2** |
| `REPOSITORY_MAP` | V2 | **V3** |

**At most one `STATUS=ACTIVE` per family, outside the archive.** Superseding never means deleting:
move the old file to `docs/archive/governance/` and record the chain in `ARCHIVE_INDEX.md`.

## 4. Archiving

- Superseded governance documents → `docs/archive/governance/`
- One-off historical decisions → `docs/current/history/`
- Archived files keep their historical `STATUS` text but must also carry an archive marker
  (`ARCHIVED=...`), so a reader cannot mistake them for authority.
- Prefer `git mv`, so the move is recorded as a rename rather than a delete plus an add.

## 5. Enforcement

```
python tools/check_doc_authority.py
```

Checks exactly three things:

1. more than one `ACTIVE` in a topic family, outside the archive;
2. an archived document claiming authority without an archive marker;
3. a dangling repository reference in a read-path document — cross-branch references
   (`product/<branch>::docs/x.md`) are ignored, since the file exists on that branch.

Exit code is non-zero when anything is found. The checker is deliberately narrow: it guards the
documents an agent actually loads, not every historical file.

To wire it into CI:

**Wired into CI** as `.github/workflows/doc-authority-verify.yml` (`FRONTLINE Document Authority
Verify`). It runs on pushes to `main` and on pull requests, filtered by `paths` to `docs/**`, the
checker itself and the workflow file, plus manual `workflow_dispatch`. It installs nothing and needs
no Godot — one Python script, seconds to run, so it costs almost nothing in Actions minutes. To
disable it, delete the workflow file; to run it by hand, `python3 tools/check_doc_authority.py`.

## 6. Why this exists

On 2026-09-20 a repository pass found that "current" was decided by a document's own self-declared
STATUS rather than by structure. Seven documents therefore claimed it simultaneously, the directory
map pointed at the oldest of each chain, and a window working in the product worktree read a control
state 22 revisions stale. These rules, plus the checker, move that judgement out of memory and into
the repository.
