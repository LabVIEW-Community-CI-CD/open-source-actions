# GOVERNANCE.md – NI Open-Source Program

> 🧭 This document defines the authority structure, role boundaries, and decision-making logic for the NI Open-Source Program.  
> It exists to ensure transparency, trust, and traceability across all contributor interactions and program operations.

---

## 🧭 Governance Authority Model

The NI Open-Source Program operates under a **centralized governance model** that mimics key aspects of BDFL-style leadership.

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
| **Open Source Core Team** | Reviews SteerCo applicants; may issue badges in PM’s absence         | Implied, not defined    |
| **Certification Team**| Maintains scoring model for LabVIEW recertification via open source    | Implied, not defined    |
| **Maintainers**       | Provide PR review, issue triage, and domain guidance per repo          | Implied, not defined    |
| **Steering Committee**| Offers roadmap input, test coordination, and community signaling       | Defined in `STEERCO-GUIDELINES.md` |

---

## 🧩 Delegation and Overrides

- The Program Manager may **delegate specific responsibilities** to trusted roles (e.g., badge issuance, CLA review), but retains final authority.
- Manual overrides (e.g., scoring exceptions or non-template test acceptance) must be traceable via GitHub comments or governance issues.

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
