# FILE: PRIORITY-SCORE.md


# PRIORITY-SCORE.md

> 🛑 **This document defines how NI evaluates and allocates limited R&D effort across eligible open-source repositories.**  
> It is intended for use by NI leadership, the Program Manager, and Steering Committee members to ensure transparency, fairness, and community influence in decision-making.

---

## §1. What “Priority” Means

Priority in the NI Open-Source Program reflects **how much structured effort NI commits** to an open-source repository in a given evaluation cycle.  
It is **not a vote**, nor is it set by an individual—it is the result of:

- Measurable community interest
- Available technical leadership (SteerCo)
- Internal resource alignment
- Objective scoring across defined criteria

> ❗ **Note:** A repository cannot be prioritized until a Steering Committee is formed. SteerCo headcount is the gating requirement for priority evaluation.

---

## §2. Scoring Model Overview

<!-- 🛠 FIX: Clarified structured inputs, removed ambiguity on numeric metrics -->

Scoring includes structured indicators such as:

- Active SteerCo membership
- Public test harness presence
- Community GitHub activity
- Label usage on issues

Numeric metrics are used to **inform**, not dictate, final scoring.  
Final score decisions are made by the Program Manager, with input from R&D, PM, and the community.

SteerCo may propose interest metrics but does **not assign scores**.

---

## §3. What Drives a High Score?

| Score Factor | Examples of Strong Signals |
|--------------|-----------------------------|
| **Practicality** | No private IP. Public test harness exists. Docs are sufficient for onboarding. |
| **Market Breadth** | Many customer types can use it (e.g., Modbus, gRPC). Not tied to a single vertical. |
| **Value** | Directly tied to improving time-to-deploy, cross-platform support, or onboarding. |
| **Interest** | Active GitHub issues. External contributors proposing PRs. Multiple volunteers in SteerCo. |

---

## §4. Who Sets the Score?

<!-- 🛠 FIX: Reinforced role boundaries -->

- Input is collected from R&D, Product Management, and the community
- SteerCo members may suggest interest metrics but **do not control final scores**
- The Program Manager makes final scoring decisions

---

## §5. What Increases Priority?

> ✅ These are **the only accepted ways** to raise a repo’s priority:

- Recruiting SteerCo leadership (must be public, tracked)
- Demonstrating practical readiness (test pass, release candidate)
- Growing community interest (merged PRs, GitHub discussion activity)
- Showing business impact via PM input (customer pull, support demand)

---

## §6. What This Document Does Not Cover

- This document does **not** assign project ownership.
- It does **not** define contributor roles (see [STEERCO-GUIDELINES.md](https://github.com/ni/open-source/blob/main/docs/governance/STEERCO-GUIDELINES.md)).
- It does **not** mandate release—priority ≠ launch. Launch decisions occur after full evaluation and community readiness.

---

## §7. Revision History

| Date       | Summary                         |
|------------|----------------------------------|
| 2025-05-22 | Added 4-factor scoring model and role ownership |
| 2025-04-XX | Initial version |
