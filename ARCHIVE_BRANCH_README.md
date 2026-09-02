# FRONTLINE legacy / unused archive branch

BRANCH=archive/legacy-unused
STATUS=NON_AUTHORITATIVE_ARCHIVE

This branch exists to preserve historical, superseded, rejected, or currently unused FRONTLINE material without keeping that material on `main`.

Rules:
- `main` is the current stable project baseline.
- Nothing on this branch has current product authority unless explicitly reaccepted in `docs/current/CURRENT_STATE.md` on `main`.
- Historical Battle01 contracts, retired governance documents, old visual targets, and other clearly superseded material may be kept here.
- Potentially reusable runtime code, scenes, tests, and assets should not be moved here merely because they are not active today.
- Do not merge this branch wholesale back into `main`.

The authoritative project entry remains `main:docs/current/CURRENT_STATE.md`.
