# LabVIEW Certification Redefined: Streamlining Open-Source Contributions and Exam Adjudication

## Executive Summary
As NI’s open-source LabVIEW ecosystem expands, **automating recertification points** has become essential. Merged Pull Requests (PRs) deserve recognition without burdening NI’s Certification Team. This document:

1. Details how **Open-Source LabVIEW** automates T-Shirt Size + Priority scoring.
2. Explains a **single escalation** exam-adjudication plan with **third-party CLAs** to handle borderline or disputed certification exams.

The outcome is a **transparent, peer-driven process** that both **rewards** contributors and **minimizes** NI’s workload.

---

## 1. Introduction & Context
Contributors earn **points** for merged PRs, calculated by **T-Shirt Size** (complexity) + **Priority** (impact).  
- **T-Shirt Size**: S = 1, M = 2, L = 5, XL = 10, XXL = 15  
- **Priority**: P2 = +0, P1 = +5, P0 = +15  

This total appears on:
- A **local scoreboard** (per repository)  
- A **global aggregator** (across all `ni-open-source` repos)

---

## 2. Hand-Off to Certification
1. **Automation Emails**: Each merged PR (if linked to NI.com) triggers an email with the contributor’s **updated total**.  
2. **Scoreboards**: Publicly track points in real time.  
3. **Certification’s Role**: They can rely on the email or verify totals on the scoreboard.

---

## 3. Retroactive Linking
If a contributor didn’t link their GitHub handle initially, all past merges remain tracked by handle. Once they link to their NI.com account:
1. The system **retroactively** associates all merges.
2. Sends a **recalculated total** to Certification.

---

## 4. Steps for the Certification Team
1. **Receive Automated Email**: “Contributor X has Y total points.”  
2. **Archive or Track** until the contributor requests to use them.  
3. **Validate** requested points vs. scoreboard totals; **approve** if valid.  
4. **No Merge-Level Approval**: T-Shirt sizing is handled upstream.

---

## 5. T-Shirt Sizing & Examples

### 5.1 T-Shirt Size (Complexity)

| Size  | Complexity                   | Points |
|:-----:|-----------------------------|:------:|
| S     | Minor changes/fixes         | 1      |
| M     | Moderate scope changes      | 2      |
| L     | Significant new features    | 5      |
| XL    | Major architecture overhaul | 10     |
| XXL   | Highly complex refactor     | 15     |

### 5.2 Priority (Impact)

| Priority | Code | Additional Points | Typical Impact      |
|:--------:|:----:|:-----------------:|---------------------|
| Low      | P2   | +0               | Minor or cosmetic   |
| Medium   | P1   | +5               | Moderately important|
| High     | P0   | +15              | Critical changes    |

### 5.3 Example Calculations

| T-Shirt | Size Pts | Priority | Priority Pts | Total |
|:-------:|:--------:|:--------:|:------------:|:-----:|
| M       | 2        | P0       | +15          | 17    |
| XL      | 10       | P1       | +5           | 15    |
| XXL     | 15       | P0       | +15          | 30    |

---

## 6. Key Considerations
- **Real-Time Updates**: Auto-refresh for scoreboards and emailed totals.  
- **Points Are Cumulative**: They do *not* decrease once earned.  
- **Global vs. Repo-Specific**: Verification can happen on either scoreboard.  
- **No T-Shirt Size Disputes**: Forward sizing concerns to the Program Owner.

---

## 7. Proposed Exam-Adjudication Enhancements

### 7.1 One-Level Escalation & Third-Party CLAs
- **Goal**: Offload complex exam reviews to an impartial board of **Community CLAs** (not NI employees).  
- **Process**: An automated pre-check (e.g., VI Analyzer) screens submissions. Only borderline cases escalate to the CLA board.

### 7.2 Rewards for Adjudicators
- **Full Recertification** for active board members, acknowledging their significant review effort.

### 7.3 Workflow Integration
1. **Automated Checks**: Submissions tested with VI Analyzer.  
2. **NI Team**: Receives feasible or nearly passing submissions.  
3. **Third-Party Review**: Handles uncertain or disputed cases.  
4. **CLA Compensation**: Board service = Automatic recertification.

---

## 8. Open Questions
1. Should CLAs be able to **grant partial points** or only **pass/fail**?  
2. How do we **standardize** exam checks for multiple LabVIEW versions?  
3. Does NI **ever override** the third-party board?  
4. What about **data privacy** when external CLAs see exam content?

---

## Potential Contradictions & Clarifications

1. **Single-Level Escalation vs. Possible Overrides**  
   - We state “one-level escalation to a neutral board,” yet we also ask if NI could *override* decisions. This **needs clarity**: is the third-party decision final or can NI still step in?

2. **T-Shirt Sizing vs. Exam Board**  
   - T-Shirt sizing is *fully handled* by the open-source pipeline, but exam adjudication may involve CLAs. These are separate processes, which can be **confused** without emphasizing they’re **independent** tracks.

3. **Brief vs. Detailed**  
   - Some sections highlight automation and others propose manual board review. Ensure it’s understood that **automation is primary**, and **human review** only happens for **edge cases**.

Overall, no direct contradictions affect feasibility. However, the **open questions** underscore that finalizing governance (who can override decisions and how) is crucial for a consistent, streamlined process.

---

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)
