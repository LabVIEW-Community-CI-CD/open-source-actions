# GOVERNANCE.md – NI Open-Source Program

> 🧭 This document defines the authority structure, role boundaries, and decision-making logic for the NI Open-Source Program.  
> It exists to ensure transparency, trust, and traceability across all contributor interactions and program operations.

---

## 🧭 Governance Authority Model

 The NI Open-Source Program operates under a **centralized governance model** that mimics key aspects of BDFL-style leadership.

+- While current trust in governance outcomes is supported by the credibility and accountability of both the **Organizational** and **Technical Steering Committees**, the program commits to making all contributor-facing decisions explainable, reproducible, and publicly auditable.

- The **Program Manager** serves as the final authority on:
  - Contributor recognition and badge issuance
  - Repository scoring and readiness evaluation
  - Contributor licensing (CLA/DCO) compliance and enforcement
  - Approval and oversight of Steering Committee formation

- Community input, GitHub activity, and SteerCo engagement are **visible and influential**, but final decisions rest with the Program Manager.

- This model ensures **clear accountability** and **rapid decision-making** while preserving **public input and traceability**.

> 🔒 Note: While this structure reflects BDFL-style authority, the Program Manager role is not permanent or personal. Future delegation or succession must be documented in this file and announced via GitHub Discussions.

---

## 🧑‍⚖️ Role Summary

 | Role                  | Powers / Responsibilities                                             | Status                  |
 |-----------------------|------------------------------------------------------------------------|-------------------------|
 | **Program Manager**   | Final say on scoring, recognition, licensing, and SteerCo gating       | Fully defined           |

+- A change in Program Manager must be accompanied by a published transition plan. This must identify any delegated responsibilities, interim contact points, and reaffirm all outstanding contributor-facing commitments.
+
+- If a majority of active Steering Committees (technical or organizational) flag a governance decision as non-transparent or harmful, the Organizational Steering Committee may issue a **temporary 30-day hold** on implementation.

---

## 🧩 Delegation and Overrides

 - The Program Manager may **delegate specific responsibilities** to trusted roles (e.g., badge issuance, CLA review), but retains final authority.
 - Manual overrides (e.g., scoring exceptions or non-template test acceptance) must be traceable via GitHub comments or governance issues.

+- Governance trust signals (e.g., badge eligibility, scoring inputs, SteerCo recommendations) must persist across Program Manager transitions. These must not be retroactively invalidated or reinterpreted without public rationale.
+
+- A standing GitHub Discussion thread titled “Governance Watch” will be maintained to surface community concerns and track policy drift in real time. This thread must remain open for contributors to flag deviations from expected norms.

---

## 🔄 Change Management

- All changes to this governance model must be:
  - Approved by the Program Manager
  - Documented in `GOVERNANCE-CHANGELOG.md`
  - Communicated via GitHub Discussions when impactful to contributors

---

## 📌 Future Role Clarification (Planned)

The following roles will be scoped in future governance updates:
- Maintainer (repo-level authority, recognition criteria, onboarding)
- Open Source Core Team (membership, scope, escalation path)
- Certification Team (policy interface, scoring model governance)

---

## 📝 Revision History

| Date       | Summary                                                      |
|------------|--------------------------------------------------------------|
| 2025-05-23 | Initial version added to formalize authority and role logic  |
