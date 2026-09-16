# FRONTLINE Branch Recycle Manifest — 2026-09-16

STATUS=APPROVED_FOR_AUTOMATED_RECYCLE
SOURCE=Issue #37 + repository branch inventory on 2026-09-16

The following branch refs were previously reviewed as stale / merged / superseded / CI-only. Their exact HEADs must be preserved as recycle tags before original branch deletion.

| Original branch | Reviewed HEAD SHA | Recycle tag |
|---|---|---|
| `build/battle01-enemy-ai-v1` | `f2e8b825ff0fbbb227eaf394be023fc401c2fac8` | `recycle/2026-09-16/build/battle01-enemy-ai-v1` |
| `build/combat-skeleton-v1` | `999d039a07f36972dd1bf85a6f66aa12eab2f362` | `recycle/2026-09-16/build/combat-skeleton-v1` |
| `build/multi-formation-command-v1` | `5f35ee130305e009480aea116ed025728ef32728` | `recycle/2026-09-16/build/multi-formation-command-v1` |
| `build/recon-contact-v1` | `adf4f9f34df025d07df494fd09e1962f44d252a0` | `recycle/2026-09-16/build/recon-contact-v1` |
| `build/terrain-los-smoke-v1` | `0a592743c29a8504ef29bb100261cecddf8827c8` | `recycle/2026-09-16/build/terrain-los-smoke-v1` |
| `chore/repository-cleanup-20260902` | `98535f278080c7a730deaeb443957ef92f585ae2` | `recycle/2026-09-16/chore/repository-cleanup-20260902` |
| `ci/formation-definitions-v1` | `f69af7eaad6759a975226513d73b31a662d56fd1` | `recycle/2026-09-16/ci/formation-definitions-v1` |
| `ci/walking-skeleton-verify` | `0a897af4b3e0d3754b9491db5515d2cc400a95c2` | `recycle/2026-09-16/ci/walking-skeleton-verify` |
| `design/battle01-connected-playable-contract-v1` | `009bccc729a0f85190d26ac4b45eb0d7d1f77f9d` | `recycle/2026-09-16/design/battle01-connected-playable-contract-v1` |
| `dev/core-v1-batch1-migration` | `54f10d360a92f782183cf76b577ef7f80962bc09` | `recycle/2026-09-16/dev/core-v1-batch1-migration` |
| `dev/prototype-b-core-v1-migration` | `c69b6cfd045a8d2b0469ced5fe36a0c443738835` | `recycle/2026-09-16/dev/prototype-b-core-v1-migration` |
| `discovery/prototype-a-command-response-v1` | `f098dc45d639fbbc9f8fcba43b98b7c478974841` | `recycle/2026-09-16/discovery/prototype-a-command-response-v1` |
| `discovery/prototype-b-representative-command-battle-v1` | `d893906a436010c03273ccf4cbf0e2cde50fdcf8` | `recycle/2026-09-16/discovery/prototype-b-representative-command-battle-v1` |
| `governance/frontline-project-charter-v2` | `7a84f3b2ebc364d62071f2fd13ceeebc1b4b83b7` | `recycle/2026-09-16/governance/frontline-project-charter-v2` |
| `governance/game-discovery-reset-v1` | `3cb4f8f0bccf5232f0342b412b0de32d0ed6fcb4` | `recycle/2026-09-16/governance/game-discovery-reset-v1` |
| `governance/m2-01-current-state-close` | `3c2996d5a22dc3e8c377237caf860d1a9f9146f2` | `recycle/2026-09-16/governance/m2-01-current-state-close` |
| `governance/unified-production-system-v1` | `ecf743f6f68daf9f52383e98b65085be4be15f60` | `recycle/2026-09-16/governance/unified-production-system-v1` |
| `m2/battle01-runtime-shell-v1` | `2638a749654eb73ab18245876d347736e5f36bed` | `recycle/2026-09-16/m2/battle01-runtime-shell-v1` |
| `qa/formal-roster-runtime-6bdd8dd` | `fab14e1b7a464b0fef16355907b1f8803bf5a67c` | `recycle/2026-09-16/qa/formal-roster-runtime-6bdd8dd` |
| `state/frontline-current-product-state-v1` | `fcc283d0c73ec715782c8c2a12ad12ea9d96f3e3` | `recycle/2026-09-16/state/frontline-current-product-state-v1` |
| `tmp/battle01-3d-foundation-integrated-v1` | `a197372ab5021a5acb0bb6124d734eb84dc7aa35` | `recycle/2026-09-16/tmp/battle01-3d-foundation-integrated-v1` |
| `chore/repository-hygiene-20260909` | `eaf37f09051031c4d0823f277b0e7ed33466e220` | `recycle/2026-09-16/chore/repository-hygiene-20260909` |
| `learning/sprint01-battlefield-construction` | `7fa2fba9e12ffae424b6c8bf5090d00da4da23f0` | `recycle/2026-09-16/learning/sprint01-battlefield-construction` |

## Explicitly not recycled in this pass

ACTIVE:
- `main`
- `learning/sprint01-end-to-end-rts-production`

REFERENCE / HOLD:
- `archive/legacy-unused`
- `dev/godot-golden-scene-v1`
- `dev/visual-production-reset`
- `dev/river-town-local-high-fidelity-v1`
- `dev/reference-region-v1`
- `dev/prototype-b-representative-battle-content-v1`
- `discovery/prototype-b-task-reserve-v1`
- `agent/design-sandbox-01`
- `dev/asset-pipeline-v1`
- `dev/asset-pipeline-v2-multi-source`
- `dev/industrial-repair-workshop-v1`
- `ci/godot-toolchain-unified-cache-sha256-lock`

No branch outside the table above may be deleted by the first-pass recycle workflow.
