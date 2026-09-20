# FRONTLINE EXECUTION MODEL V1

STATUS=ACTIVE
PROJECT=FRONTLINE
DATE=2026-09-20
SOURCE_OF_TRUTH=docs/current/CURRENT_STATE.md
SUPERSEDES=docs/archive/governance/GPT_FOUR_WINDOW_SYSTEM_V5.md
           docs/archive/governance/GPT_WINDOW_RUNTIME_PLAN_V2.md
           docs/archive/governance/gpt_windows/

## 1. Why the window system is retired

The 00/01/02/03 system was a routing layer for several human-driven chat windows. It assigned roles
to window numbers, defined handoffs between them, and shipped copy-paste initialization prompts
(`docs/gpt_windows/`). All of it assumed the work is carried by a person moving between
conversations.

The execution unit is now a single agent that reads and writes this repository, runs the engine,
captures runtime evidence, and can spawn isolated sub-agents. Under that unit the window layer
produced handoff cost and no verification gain: every stale state declaration removed on 2026-09-20
lived in the collaboration layer, not in a product document.

The windows are retired, not renamed. Nothing in this repository routes work by window number.

## 2. What replaces what

| Retired | Replacement |
|---|---|
| WINDOW_00 control / integration | `docs/current/CURRENT_STATE.md` — one state, one writer |
| WINDOW_01 design / evidence | the active task contract — one per task |
| WINDOW_02 development | the agent, directly. No routing layer. |
| WINDOW_03 independent review | an isolated sub-agent (section 3) |
| window initialization prompts | the four-step read path (section 5) |
| handoff receipts | the evidence directory + the decision log |

## 3. Review independence is structural, not nominal

Under the window system "independent review" meant a different conversation — a weak and
unverifiable form, usually the same model holding the same priors.

Independence is now enforced by construction:

- the reviewer receives ONLY the task contract and the evidence directory;
- it is told nothing about the builder's reasoning, summary or conclusions;
- it must name, for every PASS requirement, the artifact it inspected and what it observed there;
- it re-runs the capture driver rather than trusting the committed numbers;
- DOWNGRADE or REJECT is a normal outcome, not a failure of the review.

Allowed verdicts are PASS / DOWNGRADE / FIX / REJECT. The check list it applies is
`docs/audit/WINDOW_03_EVIDENCE_AUDIT_CONTRACT_V1.md`; that filename is retained only because the
protocol it contains is window-independent — it audits evidence to falsification standard and makes
no routing decision.

## 4. Task lifecycle

```
OPEN       write the contract: PRODUCT_QUESTION / AUTHORIZED_SCOPE / NON_GOALS /
           COMPLETION_EVIDENCE / DECISION_AFTER_EVIDENCE
BUILD      change only what the contract authorizes
SELF-CHECK the artifact exists and actually runs — not "the code is present"
REVIEW     isolated sub-agent against the contract
RECORD     evidence committed, CURRENT_STATE updated, decision log appended
CLOSE      gate closes; the next task is chosen in CURRENT_STATE
```

A task that cannot state its completion evidence before BUILD starts is not a task yet. One task is
active at a time; maintenance may run in parallel only if it cannot change product direction.

## 5. Read path — four steps, every session

1. `docs/current/CURRENT_STATE.md` — where the project is
2. the active task contract — what is being built, and what counts as done
3. the active task's evidence directory — what was last proven
4. `docs/current/DECISION_LOG.md` — why the current route looks the way it does

Nothing else may declare current state.

## 6. Evidence rules (hard)

1. Evidence is something the engine produced — a capture, a run log, a runtime metric. Existing
   source code is not evidence. A green CI run is not evidence.
2. The raw run log is archived next to the evidence JSON. A processed conclusion without its raw
   log is not evidence.
3. Capture drivers write to `user://`, never to a hard-coded absolute path.
4. A report may be cited as closure evidence only after its text is committed. Text alive in one
   working tree and in no commit is not evidence.
5. `TECHNICAL_PASS != PRODUCT_PASS`. Whether a result is readable, controllable or worth playing is
   a human judgment, and the builder never self-certifies it.

## 7. Standing constraints

Changing the execution model changed nothing about the product. The high-fidelity River Town scene
remains the product construction mother scene, and the proxy / visual-floor constraints listed in
`docs/current/ACTIVE_WORK.md` stay in force at every gate.

## 8. Documentation rules

- State fields — `CURRENT_*`, `ACTIVE_*`, `NEXT_*`, branch heads — exist in exactly one file:
  `docs/current/CURRENT_STATE.md`. Every other file points at it.
- Governance documents state permanent rules, never the current instance of them.
- `tools/check_doc_authority.py` enforces this and must stay green; CI runs it on `docs/**`.
- Retired material is archived with a supersession entry in
  `docs/archive/governance/ARCHIVE_INDEX.md`. Nothing is deleted while it still has trace value.
