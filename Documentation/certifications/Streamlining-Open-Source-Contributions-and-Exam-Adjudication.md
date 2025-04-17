# LabVIEW Certification Redefined: Streamlining Open-Source Contributions (draft)

## Executive Summary

As NI’s open-source LabVIEW ecosystem expands, an **automated and transparent process** for awarding **recertification points** is increasingly crucial. Contributors who merge Pull Requests (PRs) naturally deserve recognition for their effort and impact. However, **manually tracking** these contributions and **verifying** each one for certification has grown **time-consuming** for NI’s Certification Team.

The **Open-Source LabVIEW Program** addresses this challenge by:
1. **Automating** the capture of contributor points (via T-Shirt Size + Priority).  
2. **Emailing** updated totals to the Certification Team each time a PR is merged.  
3. Maintaining **public scoreboards**—both repo-specific and global—that provide real-time, audit-friendly point tallies.

**Why This Matters**:  
- **Rising Demand**: As open-source contributions scale, ensuring fairness, reliability, and minimal overhead is paramount.  
- **Credible Verification**: Public scoreboards offer **transparency**.  
- **Efficiency**: Automating the bulk of the work frees NI staff to focus on high-impact tasks and complex certification reviews.

---

- **[1. Introduction & Context](#1-introduction--context)**
- **[2. How the Hand-Off Works](#2-how-the-hand-off-works)**
- **[3. Retroactive Linking](#3-retroactive-linking)**
- **[4. Steps for the Certification Team](#4-steps-for-the-certification-team)**
- **[5. T-Shirt Sizing as a Badge of Honor](#5-t-shirt-sizing-as-a-badge-of-honor)**
- **[6. Key Considerations & Constraints](#6-key-considerations--constraints)**
- **[7. Closing Summary](#7-closing-summary)**
- **[8. Open Questions](#8-open-questions)**

---

## 1. Introduction & Context

Open-source contributors to NI’s LabVIEW projects earn a **score** (points) when their Pull Requests (PRs) are merged. This score is based on two factors:

### 1.1 T-Shirt Size (Complexity)

| **T-Shirt Size** | **Typical Complexity**    | **Base Points** |
|:----------------:|---------------------------|:---------------:|
| **XS (X Small)**    | Minor changes/fixes      | 1               |
| **S (Small)**   | Moderate scope changes    | 2               |
| **M (Medium)**    | Significant new features  | 5               |
| **L (Large)** | Major architecture work   | 10              |
| **XL (X-Large)**          | Highly complex refactors  | 15              |

### 1.2 Priority (Impact)

| **Priority** | **Code** | **Additional Points** | **Typical Impact**          |
|:------------:|:--------:|:---------------------:|-----------------------------|
| **Low**      | P2       | +0                   | Minor or cosmetic changes   |
| **Medium**   | P1       | +5                   | Moderately important issues |
| **High**     | P0       | +15                  | Critical or high-impact PRs |

These two values are **added** together to form the **final score** per merged PR. A local scoreboard (Markdown file) and a global aggregator track these scores in **real time**.

---

## 2. How the Hand-Off Works

1. **Automation Emails**  
   - Each time a contributor merges a PR (with a linked NI.com account), an **automated email** is sent to Certification.  
   - This email states the user’s **updated total** across NI open-source repos.

2. **Scoreboards**  
   - **Local Scoreboard:** Each repo has a Markdown page listing every contributor’s points for that specific project.  
   - **Global Aggregator:** A separate page compiles totals across all `ni-open-source` repositories.  
   - **Real-Time Updates:** Both are updated automatically upon each merge.

3. **Certification’s Check**  
   - The Certification Team can **use the emailed totals** or **audit** them by opening the public scoreboard pages.

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)

---

## 3. Retroactive Linking

- If a contributor didn’t link their GitHub handle at merge time, the scoreboard still shows points under their handle.  
- Once they **link** that handle to an NI.com account, the open-source automation:
  1. Retroactively associates all prior merges with their identity.
  2. Updates the scoreboard to reflect their *real name* or known identity (if desired).
  3. Sends a new email with the **recalculated total** to Certification.

**Implication:** The Certification Team might see a sudden jump in the contributor’s total if they link after multiple merges.

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)

---

## 4. Steps for the Certification Team

Below is a step-by-step summary for **Certification**:

1. **Receive the Automated Email**  
   - Each merge triggers a message stating: “Contributor X has been attributed with Y points”

2. **Archive or Track**  
   - You can store these emails in an inbox or reference system.
   - **No immediate action** is necessary unless the user requests points for recertification.

3. **When a Participant Requests Points**  
   1. **Check** that participant’s total (from the most recent email or by visiting the relevant scoreboard).  
   2. **Verify** they have at least as many points as they want to apply.  
   3. **Approve** those points if valid and record them in your certification system.

4. **Handling Overclaims**  
   - If the participant requests more than the scoreboard total, you can **deny or partially fulfill**.  
   - If something seems off, reference the scoreboard or contact the Program Owner.

5. **No Merge-Level Approval Required**  
   - The open-source pipeline handles T-Shirt sizing, branch protection, and legal paperwork (for shipping IP).  
   - Your only role is **final point allocation** based on the scoreboard.

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)

---

## 5. T-Shirt Sizing as a Badge of Honor

- **Community Recognition**:  
  Contributors show off their T-Shirt Size + Priority achievements on each repo’s scoreboard, indicating the difficulty/impact of their work.  

- **Certification Points**:  
  The same score also translates into recertification points.

### 5.1 Example Calculations

Below are sample **T-Shirt Size + Priority** combinations and their **total point values**:

| **T-Shirt Size** | **Size Points** | **Priority** | **Priority Points** | **Total Score**      |
|:----------------:|:---------------:|:------------:|:-------------------:|:--------------------:|
| XS                | 1               | P2 (Low)     | +0                 | 1 + 0 = **1**        |
| XS                | 1               | P1 (Medium)  | +5                 | 1 + 5 = **6**        |
| S                | 2               | P0 (High)    | +15                | 2 + 15 = **17**      |
| M               | 5              | P1 (Medium)  | +5                 | 5 + 5 = **10**      |
| L               | 10              | P0 (High)    | +15                | 10 + 15 = **25**     |
| XL              | 15              | P0 (High)    | +15                | 15 + 15 = **30**     |

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)

---

## 6. Key Considerations & Constraints

1. **Real-Time Updates**  
   - The scoreboard (local and global) refreshes automatically once a PR merges.  
   - The automation email to Certification also reflects the new total immediately.

2. **Scoreboard Is Cumulative**  
   - It does *not* subtract points when the user redeems them for recertification.  
   - Think of it as **earned** points, not a “current balance” that goes down.

3. **Global vs. Repo-Specific**  
   - Each repo has its own scoreboard.  
   - A separate **global** aggregator shows the sum across all `ni-open-source` repos for each contributor.  
   - Certification can check either, but the aggregator is usually simpler for verifying total points.

4. **No T-Shirt Size Disputes**  
   - If a participant questions the assigned T-Shirt Size/Priority, direct them to the **Program Owner**.  
   - Certification does not intervene in sizing decisions.

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)

---

## 7. Closing Summary

- **Hand-Off**: The open-source program **emails** you each contributor’s updated total after every merged PR.  
- **Validation**: You can **audit** the scoreboard if needed (each repo’s Markdown file or the global aggregator).  
- **Points Request**: When participants want to recertify, they request some or all of those points.  
- **Retroactive**: Linking can happen any time; the scoreboard and emails adapt accordingly.

**Outcome**: A simple, automated pipeline that **minimizes Certification’s workload** while **maximizing transparency** for contributors and NI staff alike.

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)

---

## 9. Open Questions

1. **Community CLA Role Expansion**  
   - Should the CLAs have authority to grant partial points, or is it always a pass/fail decision?  
   - Do we envision CLAs also **providing feedback** to exam takers for improvement?

2. **Infrastructure & Automation**  
   - What additional tools or scripts (beyond VI Analyzer) might be needed to automate exam checks more thoroughly?  
   - How do we ensure consistency across different LabVIEW versions or project structures?

3. **Operational Logistics**  
   - How often should the third-party board meet or review submissions?  
   - Should there be a rotating membership (e.g., yearly) to prevent burnout and maintain impartiality?

4. **Coordination with NI Certification Team**  
   - In what scenarios could the NI Certification Team *override* a third-party board decision, if ever?

5. **Data Privacy & Confidentiality**  
   - What measures ensure that private exam data or personal information is safeguarded when handled by external reviewers?

**Next Steps**: We encourage stakeholders to review these questions and contribute insights or requirements. Finalizing these details will help ensure a **smooth**, **equitable**, and **efficient** rollout of this enhanced certification model.

---

**Any Clarifying Questions for You**:
- Would you like additional details on how the **automated screening** integrates with existing NI infrastructure?  
- Should there be a formal **onboarding** or **training** process for new third-party adjudicators?  
- Are there any **legal constraints** around awarding “automatic recertification” that we should consider?

[Back to top](#labview-certification-redefined-streamlining-open-source-contributions-and-exam-adjudication)
