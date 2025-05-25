# OVERRIDE-GUIDE.md

> 🔧 Defines when and how to use override tags in the NI Open-Source Governance Framework — ensuring exceptions are traceable, deliberate, and auditable.

---

## Purpose

This guide exists to:

- Prevent silent governance drift
- Ensure all exceptions are visible and explained
- Empower contributors and reviewers to act responsibly when bypassing enforcement rules
- Make overrides usable by humans, assistants, and bots — consistently

---

## Tags and Their Meanings

| Tag              | Purpose |
|------------------|---------|
| `#manual-edit`   | Allows manual edit of a protected `.md` file without requiring a full-structure rewrite |
| `#manual-override` | Signals that an assistant is permitted to bypass a behavior constraint (e.g., output format, download block) for one interaction only |

---

## Usage Guidelines

### ✅ When to Use `#manual-edit`

- You need to insert a single line into a protected file (e.g., minor policy tweak)
- You're fixing a typo, formatting, or broken link in a governance document
- You're testing GitHub Actions or CI/CD against `.md` files

> ❗ You must document the intent of the edit in the PR or commit description.

---

### ✅ When to Use `#manual-override`

- You explicitly want the assistant to:
  - Provide a download link (normally blocked)
  - Suggest unstructured output for ideation
  - Propose logic that contradicts runtime guardrails (with human review)

> ❗ Use this tag **in your message to the assistant** and explain why you're asking for a deviation.

---

## Best Practices

- Do not use override tags casually — they exist for traceable exceptions, not convenience
- Always accompany overrides with:
  - A short reason
  - A reviewer
  - A milestone or GitHub Issue reference if possible

---

## Assistant Enforcement

If an override tag is used:
- The assistant must log that an override occurred
- File-related edits must include anchor context (before/after sections)
- The assistant must clearly indicate that it is acting outside of standard enforcement

---

Maintained by: Program Manager & Architect  
Last updated: 2025-05-25
