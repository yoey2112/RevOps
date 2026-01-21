# Environment Comparison Report (Version Comparison Only)

Generated: 2025-12-29T17:42:40.2506135Z

This report compares **solution versions** between Production and DevCore environments to verify that patches/upgrades have been deployed to Production.

## Summary

- **In Sync**: 6 solutions
- **Version Mismatch**: 15 solutions
- **Prod Only**: 10 solutions
- **DevCore Only (Pending Deployment)**: 3 solutions

## Solution Version Comparison

| Solution | Production | DevCore | Status |
|----------|------------|---------|--------|| revopsai | 1.0.0.1 | 1.0.0.2 | [!!] Mismatch |
| revopsdataflows | - | 1.0.0.1 | [D] Pending Deploy |
| revopsflows | 1.28.0.3 | 1.28.0.3 | [OK] In Sync |
| revopsflows_Patch_c9a2b8ba | - | 1.28.1.1 | [D] Pending Deploy |
| revopsplugins | 1.1.0.2 | 1.1.0.2 | [OK] In Sync |
| revopsplugins_Patch_3ce751d2 | 1.1.1.2 | 1.1.1.2 | [OK] In Sync |
| revopsportals | 1.2.0.1 | - | [P] Prod Only |
| revopsportals_Patch_1bc50d9a | 1.2.13.3 | - | [P] Prod Only |
| revopsportals_Patch_2cc2b236 | 1.2.13.5 | - | [P] Prod Only |
| revopsportals_Patch_5e7e67a7 | 1.2.1.7 | - | [P] Prod Only |
| revopsportals_Patch_9797a3c5 | 1.2.12.2 | - | [P] Prod Only |
| revopsportals_Patch_9ec3ca7a | 1.2.5.21 | - | [P] Prod Only |
| revopsportals_Patch_ac120dd3 | 1.2.14.2 | - | [P] Prod Only |
| revopsportals_Patch_b61c1681 | 1.2.5.15 | - | [P] Prod Only |
| revopsportals_Patch_bb3ded54 | 1.2.11.12 | - | [P] Prod Only |
| revopsportals_Patch_bec1ca79 | 1.2.5.19 | - | [P] Prod Only |
| RevOpsRequestsForm | 1.1.0.45 | 1.1.0.45 | [OK] In Sync |
| revopstables | 1.41.0.2 | 1.41.0.3 | [!!] Mismatch |
| revopstables_Patch_1d0279a4 | - | 1.41.2.6 | [D] Pending Deploy |
| revopstables_Patch_74d819bb | 1.41.1.4 | 1.41.1.4 | [OK] In Sync |
| revopstables_Patch_c09dbb7c | 1.41.2.5 | 1.41.2.5 | [OK] In Sync |

## Legend

- [OK] **In Sync**: Solution version matches between Production and DevCore
- [!!] **Mismatch**: Version differs - investigate if deployment is needed
- [P] **Prod Only**: Solution exists only in Production (not in DevCore allowlist)
- [D] **Pending Deploy**: Solution exists in DevCore but not yet deployed to Production
