# Purchase Requisition — User Guide
**Microsoft Dynamics 365 Business Central | Inmind Development**
Version 1.0 · March 2026

---

## Table of Contents

1. [Overview](#1-overview)
2. [Roles & Access](#2-roles--access)
3. [Getting Started — Setup (Administrators)](#3-getting-started--setup-administrators)
4. [Creating a Purchase Requisition (Requestors)](#4-creating-a-purchase-requisition-requestors)
5. [Approving or Rejecting a Requisition (Approvers)](#5-approving-or-rejecting-a-requisition-approvers)
6. [Converting to a Purchase Order (Managers)](#6-converting-to-a-purchase-order-managers)
7. [Status Lifecycle](#7-status-lifecycle)
8. [Actions Reference](#8-actions-reference)
9. [Notifications](#9-notifications)
10. [Printing & Previewing](#10-printing--previewing)
11. [Navigation & Lists](#11-navigation--lists)
12. [Frequently Asked Questions](#12-frequently-asked-questions)

---

## 1. Overview

The **Purchase Requisition** extension introduces a formal, approval-driven purchasing request process into Business Central. It enables employees to raise purchase requests that are reviewed and approved before a Purchase Order is ever created — providing a documented audit trail and controlled spend authorisation.

**Key benefits:**
- Employees submit structured purchase requests with line-level detail.
- Approvers review and approve or reject requests before any commitment is made.
- Approved requests are converted directly into Purchase Orders with full field mapping.
- All status transitions trigger notifications to the relevant parties.

> This extension does **not** replace or modify Business Central's Requisition Worksheet, Purchase Quote, or Purchase Order functionality.

---

## 2. Roles & Access

Four permission sets are included. Your administrator assigns the appropriate role to each user.

| Role | What they can do |
|---|---|
| **PR Requestor** | Create, edit (Draft only), submit, cancel, and print their own PRs. View their own list. |
| **PR Approver** | View PRs assigned to them. Approve or reject. Cannot create PRs. |
| **PR Manager** | View all PRs across departments. Convert approved PRs to Purchase Orders. |
| **PR Administrator** | Full access. Manage the Setup table. Override status. View all PRs. |

---

## 3. Getting Started — Setup (Administrators)

Before any requisitions can be raised, an administrator must configure the **Purchase Requisition Setup** page.

**To open Setup:** Search for `Purchase Requisition Setup` in the Business Central search bar (Alt+Q).

### 3.1 General Settings

| Field | Description |
|---|---|
| **PR No. Series** | The number series that assigns PR numbers (e.g. PR-0001, PR-0002). Select an existing No. Series or create a new one. |
| **Email Notifications** | Toggle on to send email alerts when a PR status changes. Requires SMTP to be configured. |
| **Allow Vendor Change on Conversion** | If enabled, users are prompted to confirm or change the vendor when converting a PR to a Purchase Order. |

### 3.2 Approval Settings

| Field | Description |
|---|---|
| **Default Approver ID** | The fallback approver used when no department-specific approver is defined. |
| **Approval Amount Threshold** | PRs with a total above this amount require a secondary approver before being considered approved. Leave blank to disable two-level approval. |
| **Secondary Approver ID** | The second approver triggered when the PR total exceeds the threshold. |

### 3.3 Approvers by Department

The **Approvers by Department** subgrid maps each Department Code to a specific approver. When a PR is submitted, the system looks up the PR's Department Code here first. If no match is found, it falls back to the **Default Approver ID**.

To add a department rule:
1. Click **New** in the Approvers by Department subgrid.
2. Enter the **Department Code** (must match the Dimension value used on PRs).
3. Enter the **Approver User ID**.
4. The rule is saved automatically.

---

## 4. Creating a Purchase Requisition (Requestors)

### 4.1 Opening a New PR

1. Search for **Purchase Requisitions** (or navigate from the Purchasing menu).
2. Click **New** on the list page.
3. A new Purchase Requisition card opens with a **Draft** status and an automatically assigned PR number.

### 4.2 Filling in the Header

| Field | Required | Notes |
|---|---|---|
| **Description** | Yes | A short title for the request (e.g. "Office Furniture — Marketing"). |
| **Requested By** | Auto | Populated with your user ID. Read-only. |
| **Request Date** | Auto | Today's date. Read-only. |
| **Required By Date** | Yes | When the goods or services must be received. |
| **Department Code** | Yes | Your department (Global Dimension 1). Determines which approver is notified. |
| **Cost Centre** | No | Optional second dimension. |
| **Currency Code** | No | Leave blank for local currency (LCY). |
| **Preferred Vendor No.** | No | Select a vendor if you have a preference. The Vendor Name fills automatically. |
| **Justification** | No | Business reason for the purchase. Visible to the approver. |

### 4.3 Adding Lines

Each line represents one item or service being requested.

| Field | Required | Notes |
|---|---|---|
| **Type** | Yes | Item, G/L Account, Resource, Fixed Asset, or Blank. |
| **No.** | Yes (if Type set) | Lookup to the relevant master record. Description auto-fills. |
| **Description** | Yes | Auto-filled; editable. |
| **Quantity** | Yes | Must be greater than zero. |
| **Unit of Measure Code** | No | Defaults from the Item/Resource if configured. |
| **Unit Cost (LCY)** | No | Estimated cost. Not binding — the buyer may revise on the PO. |
| **Line Amount (LCY)** | Calc. | Quantity × Unit Cost. Calculated automatically. |
| **Location Code** | No | Delivery location for this line. |
| **Expected Receipt Date** | No | Defaults from the header Required By Date; overridable per line. |
| **Line Note** | No | Free text comment for this specific line. |

The **Total Amount (LCY)** at the bottom of the card updates as you add lines.

### 4.4 Submitting for Approval

Once all required fields and at least one line are complete:

1. Click **Send for Approval** in the Process action bar.
2. The system validates the PR and identifies the approver based on the Department Code.
3. Status changes to **Pending Approval**.
4. The header and lines become read-only — no further editing is possible until the approver acts.
5. The approver receives a notification (if configured).

> If the PR has no lines, or if required fields are missing, a validation error will appear and the submission will be blocked.

### 4.5 Cancelling a Requisition

A PR in **Draft** or **Rejected** status can be cancelled:

1. Click **Cancel Requisition**.
2. Confirm the prompt.
3. Status changes to **Cancelled**. The PR is read-only and cannot be re-opened.

> To reuse a cancelled PR's content, use **Copy PR** to create a new Draft.

---

## 5. Approving or Rejecting a Requisition (Approvers)

### 5.1 Finding PRs Awaiting Your Action

Open the **PRs Pending My Approval** list — accessible from the Role Centre tile or by searching for it. This list shows all PRs where you are the assigned approver and the status is Pending Approval.

### 5.2 Reviewing a PR

Click on a PR to open the card. Review:
- The description, department, required date, and preferred vendor.
- The line details (type, quantity, unit cost, totals).
- The justification field.
- The total amount in the Totals section.

### 5.3 Approving

1. Click **Approve** in the Process action bar.
2. Status changes to **Approved**.
3. The **Approver ID** and **Approval Date** fields are populated automatically.
4. The requestor receives a notification (if configured).

### 5.4 Rejecting

1. Click **Reject** in the Process action bar.
2. A dialog prompts you to enter a **Rejection Reason** (required — cannot be left blank).
3. Click **OK**.
4. Status returns to **Draft** (not Cancelled — the requestor can edit and resubmit).
5. The rejection reason is visible on the PR card in the Approval section.
6. The requestor receives a notification containing the rejection reason (if configured).

---

## 6. Converting to a Purchase Order (Managers)

Once a PR reaches **Approved** status, a PR Manager can convert it to a Purchase Order.

### 6.1 Running the Conversion

1. Open the approved PR (from the Purchase Requisitions list or search).
2. Click **Create Purchase Order** in the Process action bar.
3. If **Allow Vendor Change on Conversion** is enabled in Setup, you will be prompted to confirm or change the vendor.
4. If the PR has no Preferred Vendor, you will be prompted to select one — the conversion will not proceed without a vendor.
5. A Purchase Order is created and the following happens automatically:
   - All PR lines are mapped to Purchase Order lines.
   - The PR **Status** changes to **Converted**.
   - The **Created PO No.** field on the PR is populated.
   - The PR becomes fully read-only.
6. A notification is sent to the requestor and PR Manager (if configured).

### 6.2 Field Mapping from PR to Purchase Order

| PR Field | Purchase Order Field |
|---|---|
| Preferred Vendor No. | Buy-from Vendor No. |
| Currency Code | Currency Code |
| Department Code | Shortcut Dimension 1 |
| Cost Centre | Shortcut Dimension 2 |
| Required By Date | Expected Receipt Date (header) |
| Line Type | Line Type |
| Line No. | No. |
| Quantity | Quantity |
| Unit of Measure Code | Unit of Measure Code |
| Unit Cost (LCY) | Direct Unit Cost (informational — buyer may revise) |
| Location Code | Location Code (per line) |
| Expected Receipt Date | Expected Receipt Date (per line) |

### 6.3 Navigating to the Purchase Order

Once converted, the **Navigate to Purchase Order** action becomes available on the PR card. Click it to open the linked PO directly.

---

## 7. Status Lifecycle

```
                  ┌─────────────────────────────────┐
                  │                                 │
         [New] ──▶│  DRAFT  │──Send for Approval──▶│ PENDING APPROVAL │
                  │                                 │        │         │
                  │ ◀── Reject (returns to Draft) ──┘        │ Approve │
                  │                                           ▼         │
                  │                              APPROVED              │
                  │                                 │                   │
            Cancel│                    Create PO    │                   │
                  ▼                                 ▼                   │
            CANCELLED                         CONVERTED                │
                                                                        │
                  ◀──────────────────── Cancel (Draft or Rejected) ────┘
```

| Status | Colour | Editable? | Available Actions |
|---|---|---|---|
| **Draft** | Grey | Yes | Send for Approval, Cancel, Copy PR, Print |
| **Pending Approval** | Amber | No | Approve, Reject (approver only), Print |
| **Approved** | Green | No | Create Purchase Order, Copy PR, Print |
| **Rejected** | Red | Yes (re-edit and resubmit) | Send for Approval, Cancel, Copy PR, Print |
| **Converted** | Bold | No | Navigate to PO, Copy PR, Print |
| **Cancelled** | Dim | No | Copy PR, Print |

> **Note:** Status cannot move backwards once Approved. A converted or approved PR cannot be returned to Draft.

---

## 8. Actions Reference

| Action | Who | When Available | What it does |
|---|---|---|---|
| **Send for Approval** | Requestor | Draft only | Validates PR, sets status to Pending Approval, notifies approver. |
| **Approve** | Approver | Pending Approval | Sets status to Approved, records approver and date. |
| **Reject** | Approver | Pending Approval | Opens reason dialog, returns PR to Draft with reason recorded. |
| **Create Purchase Order** | Manager | Approved only | Creates a linked PO, sets status to Converted. |
| **Cancel Requisition** | Requestor | Draft or Rejected | Cancels the PR after confirmation. |
| **Navigate to Purchase Order** | Manager / Admin | Converted only | Opens the linked Purchase Order. |
| **Copy PR** | Any | Any status | Creates a new Draft PR copying all header and line data. |
| **Print / Preview** | Any | Any status | Renders the PR as a printable report. |

---

## 9. Notifications

When **Email Notifications** is enabled in Setup and SMTP is configured in Business Central, the following emails are sent automatically:

| Event | Who receives it | Content |
|---|---|---|
| PR submitted for approval | Assigned Approver | PR No., requestor name, total amount |
| PR approved | Requestor | PR No., approver name, approval date |
| PR rejected | Requestor | PR No., approver name, rejection reason |
| PR converted to PO | Requestor + PR Manager | PR No., PO No. created, vendor name |

If email is not configured or **Email Notifications** is off, no emails are sent. Status transitions still occur normally.

---

## 10. Printing & Previewing

The **Print / Preview** action is available at any status for any user with access to the PR.

1. Open the PR card (or select a PR in the list).
2. Click **Print / Preview** in the Reports action group.
3. Choose **Preview** to view on screen or **Print** to send to a printer.

The report includes:
- Company name and PR identification details
- Header fields: status, request date, requested by, required date, preferred vendor, department
- Line table: type, description, quantity, UoM, unit cost, line amount
- Total amount
- Approval section: approver name, approval date
- Justification and line notes

> **Note:** A report layout (Word or RDLC) must be uploaded via **Report Layout Selection** after the extension is first deployed. Contact your administrator if the report appears blank or unstyled.

---

## 11. Navigation & Lists

### Available List Pages

| Page | Who uses it | Shows |
|---|---|---|
| **Purchase Requisitions** | Managers, Admins | All PRs across all users and departments |
| **My Purchase Requisitions** | Requestors | Only PRs created by the current user |
| **PRs Pending My Approval** | Approvers | PRs where current user is the approver and status = Pending Approval |

### Filtering the List

All list pages support standard BC filtering. Useful filters:
- **Status** — narrow to Draft, Pending, Approved, etc.
- **Department Code** — view a specific department's requests.
- **Requested By** — filter by requestor (on the full list).
- **Request Date / Required By Date** — filter by date range.

---

## 12. Frequently Asked Questions

**Q: I submitted a PR but it went to the wrong approver. What do I do?**
A: Contact your administrator. The approver is determined by the Department Code on the PR. The administrator can update the department approver mapping in Setup. The approver can also reject the PR so you can correct the department code and resubmit.

**Q: My PR was rejected. Can I edit it and resubmit?**
A: Yes. A rejected PR returns to Draft status and is fully editable. Review the Rejection Reason on the Approval section of the card, make your corrections, and click **Send for Approval** again.

**Q: Can I convert only some lines of a PR to a Purchase Order?**
A: No — the current version converts all lines. Partial conversion is planned for a future release.

**Q: The PR has no preferred vendor. Can I still convert it to a PO?**
A: You will be prompted to select a vendor at conversion time. The conversion cannot complete without a vendor on the Purchase Order.

**Q: Can I reuse an old PR as a template?**
A: Yes. Use the **Copy PR** action on any PR regardless of status. This creates a new Draft with all header and line data copied.

**Q: The PR is Approved but I need to change a line quantity. Is that possible?**
A: No — once a PR is Approved, it is locked. You cannot edit an approved PR. If changes are needed, the approver should not yet have approved, or you should discuss with your PR Manager who may adjust the resulting PO directly.

**Q: Where do I find the Purchase Order that was created from my PR?**
A: Open the PR card. Once converted, the **Created PO No.** field shows the PO number. Click **Navigate to Purchase Order** to open it directly.

**Q: Two-level approval — how does that work?**
A: If the **Approval Amount Threshold** is set in Setup and your PR total exceeds that amount, the PR is first approved by the department/default approver, then requires approval from the **Secondary Approver ID** before reaching Approved status.

**Q: What happens to a converted PR? Can it be deleted?**
A: Converted PRs are read-only and archived. They serve as the audit trail linking the original request to the Purchase Order. They should not be deleted.

---

*Purchase Requisition Extension v1.0 · Inmind Development · For DynamicsCon 2026*
