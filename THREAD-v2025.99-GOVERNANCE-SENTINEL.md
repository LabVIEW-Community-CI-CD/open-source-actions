# THREAD-v2025.99-GOVERNANCE-SENTINEL.md

title: "NI Open Source Program – Root Governance Thread"
version: v2025.99
status: active
created: 2025-05-27
inherits-from: none

## purpose

This THREAD defines the foundational governance architecture for all repositories participating in the NI Open Source Program. It establishes a structured, declarative inheritance model for governance responsibilities, milestones, and sentinel-based automation.

## roles

- **Governance Sentinel GPT**: Observes repository THREADs, validates inheritance continuity, and flags governance drift.
- **Program Owner**: Maintains this file and adjudicates changes across program-wide governance.
- **Steering Structures**: Delegated per program or project THREADs (e.g., LabVIEW program SteerCo).

## interfaces

- All downstream repositories must declare an `inherits-from:` field referencing a THREAD under this root.
- Sentinel tooling or GPTs may only act on repositories listed in `SENTINEL-WATCHLIST.md`.

## watch-list

All repositories listed in `SENTINEL-WATCHLIST.md` in this repository are considered monitored by the Governance Sentinel.

## milestones

- Governance events (THREAD addition, update, or revocation) must be committed with a semantically meaningful message.
- Each event must be tagged with a governance release in the form: `gov-vYYYY.NN[.PATCH]`

## rules

- No THREAD may declare responsibilities not supported by its inherited THREAD(s).
- Governance roles must either be defined or inherited; undefined roles imply no authority.
- GPTs operating under this structure must derive behavior only from declared THREADs and RUNBOOKs.

## notes

This file serves as the canonical source of truth for program-level governance. All new programs must reference it explicitly in their own THREADs.

