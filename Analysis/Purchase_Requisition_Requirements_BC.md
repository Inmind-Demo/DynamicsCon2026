# Purchase Requisition — Functional Requirements
**Microsoft Dynamics 365 Business Central | Custom AL Extension**
Version 1.0 · Draft · For Development Team

---

## 1. Overview & Business Context

Business Central does not include a native purchase requisition document. The Requisition Worksheet exists but is designed for demand planning and manufacturing replenishment — not for structured, approval-driven purchase requests initiated by employees or departments.

This feature introduces a new **Purchase Requisition (PR)** document type as a custom AL extension. It creates a formal process for employees to request purchases before a Purchase Order is raised, providing a documented paper trail, an approval workflow before spend is authorized, a controlled conversion path from request → approved PO, and visibility into pending purchasing demand across departments.

**This feature does not replace or modify the existing Requisition Worksheet, Purchase Quote, or Purchase Order functionality.**

---

## 2. Document Structure

### 2.1 Header Fields

| Field Name | Type | Required | Notes |
|---|---|---|---|
| PR No. | Code 20 | Yes (Auto) | From No. Series |
| Description | Text 100 | Yes | Short description of the request |
| Requested By | Code 50 | Yes (Auto) | Defaults to current user |
| Request Date | Date | Yes (Auto) | Defaults to today |
| Required By Date | Date | Yes | When goods/services are needed |
| Department Code | Code 20 | Yes | Global Dimension 1 (or Shortcut) |
| Cost Centre | Code 20 | No | Global Dimension 2 |
| Preferred Vendor No. | Code 20 | No | Lookup to Vendor table |
| Preferred Vendor Name | Text 100 | No | Auto-filled from vendor |
| Justification | Text 250 | No | Business reason |
| Status | Option | Yes (Auto) | Draft, Pending Approval, Approved, Rejected, Converted, Cancelled |
| Approver ID | Code 50 | No | Set during approval workflow |
| Approval Date | Date | No | Set when approved |
| Created PO No. | Code 20 | No | Filled after conversion to PO |
| Currency Code | Code 10 | No | Defaults to LCY |
| Total Amount (LCY) | Decimal | Yes (Calc.) | Sum of all line amounts |

### 2.2 Line Fields

| Field Name | Type | Required | Notes |
|---|---|---|---|
| Line No. | Integer | Yes (Auto) | 10000 increment |
| Type | Option | Yes | Item, G/L Account, Resource, Fixed Asset, Blank |
| No. | Code 20 | Conditional | Required if Type is set |
| Description | Text 100 | Yes | Auto-filled from No. lookup; editable |
| Quantity | Decimal | Yes | Must be > 0 |
| Unit of Measure Code | Code 10 | No | Lookup to UoM table |
| Unit Cost (LCY) | Decimal | No | Estimated cost; not binding |
| Line Amount (LCY) | Decimal | Yes (Calc.) | Qty × Unit Cost |
| Location Code | Code 10 | No | Delivery location |
| Expected Receipt Date | Date | No | Defaults from header Required By Date |
| Line Note | Text 250 | No | Free-text per line |
| Shortcut Dimension 1 | Code 20 | No | Inherited from header; overridable |
| Shortcut Dimension 2 | Code 20 | No | Inherited from header; overridable |

---

## 3. Status Lifecycle & Workflow

### 3.1 Status Values

| Status | Description |
|---|---|
| Draft | PR is being created. All fields editable. No approval initiated. |
| Pending Approval | PR has been submitted. Header and lines are locked (read-only). Awaiting approver action. |
| Approved | Approver has approved. PR is ready to be converted to a Purchase Order. |
| Rejected | Approver has rejected. PR returns to Draft with rejection comments visible. |
| Converted | A Purchase Order has been created from this PR. Document is archived and read-only. |
| Cancelled | PR was cancelled by the requestor. Only possible from Draft or Rejected. |

### 3.2 Status Transitions

- **Draft → Pending Approval:** Triggered by "Send for Approval" action. Requires at least one PR line.
- **Pending Approval → Approved:** Approver clicks "Approve". Sets Approver ID and Approval Date.
- **Pending Approval → Rejected:** Approver clicks "Reject". Must enter rejection reason. PR reverts to Draft.
- **Approved → Converted:** Triggered by "Create Purchase Order" action. Fills Created PO No.
- **Draft or Rejected → Cancelled:** Requestor clicks "Cancel Requisition". Prompts for confirmation.
- **Approved or Converted → Draft:** Not permitted. Status cannot be walked back once approved.

> **Note:** Use Business Central's native Approval Workflow engine (WorkflowEventHandling) if the client already uses it. If not, a simplified in-document approval model using Approver ID from a PR Setup table is acceptable for Phase 1.

---

## 4. Actions & Buttons

| Action | Available When | Behaviour |
|---|---|---|
| Send for Approval | Draft only | Validates completeness, changes status to Pending Approval, notifies approver. |
| Approve | Pending; Approver only | Changes status to Approved, sets Approver ID and approval date. |
| Reject | Pending; Approver only | Opens dialog for rejection reason, returns PR to Draft. |
| Create Purchase Order | Approved only | Runs conversion codeunit, links PO, sets status to Converted. |
| Cancel Requisition | Draft or Rejected | Sets status to Cancelled after confirmation prompt. |
| Print / Preview | Any status | Renders the PR report layout as PDF. |
| Navigate to PO | Converted only | Opens the linked Purchase Order directly. |
| Copy PR | Any status | Copies header and lines into a new Draft PR. |

---

## 5. Conversion to Purchase Order

### 5.1 Conversion Logic

When "Create Purchase Order" is triggered on an Approved PR, the system must:

1. Create a new Purchase Header (Document Type = Order)
2. Map PR header fields to PO header fields (vendor, currency, dimensions)
3. Create Purchase Lines for each PR line (type, no., qty, UoM, location, dimensions)
4. Set Expected Receipt Date on each line from the PR line value
5. Store the new PO No. in the PR header field "Created PO No."
6. Change PR status to Converted
7. Lock the PR as fully read-only

### 5.2 Field Mapping

| PR Field | PO Field | Notes |
|---|---|---|
| Preferred Vendor No. | Buy-from Vendor No. | Required on PO — warn if blank on PR |
| Currency Code | Currency Code | Direct map |
| Department Code | Shortcut Dimension 1 | Direct map |
| Cost Centre | Shortcut Dimension 2 | Direct map |
| Required By Date | Expected Receipt Date (header) | Direct map |
| Line Type | Type | Direct map |
| Line No. | No. | Direct map |
| Quantity | Quantity | Direct map |
| Unit of Measure Code | Unit of Measure Code | Direct map |
| Unit Cost (LCY) | Direct Unit Cost | Informational — buyer may revise on PO |
| Location Code | Location Code | Per line |

> **Note:** If the PR has no Preferred Vendor, warn the user and allow them to select a vendor at conversion time rather than blocking the action.

---

## 6. Setup & Configuration

A dedicated **Purchase Requisition Setup** page must be accessible from search and allow administrators to configure:

| Setting | Type | Purpose |
|---|---|---|
| PR No. Series | Code 20 | Defines the numbering series for new PRs (e.g. PR-0001) |
| Default Approver ID | Code 50 | Fallback approver if no department rule exists |
| Approver by Department | Sub-table | Maps Department Code → Approver User ID |
| Approval Amount Threshold | Decimal | PRs above this value require secondary approval |
| Secondary Approver ID | Code 50 | Used when amount exceeds threshold |
| Email Notifications | Boolean | Enable/disable email alerts on status changes |
| Allow Vendor Change on Conversion | Boolean | If true, prompt user to confirm/change vendor at PO creation |

---

## 7. Pages & Navigation

### 7.1 Required Pages

| Page Name | Page Type | Notes |
|---|---|---|
| Purchase Requisition | Document | Main card page. Header + lines subpage. |
| Purchase Requisition Lines | ListPart | Embedded subpage for line entry. |
| Purchase Requisitions List | List | Shows all PRs. Used as the landing page. |
| My Purchase Requisitions | List | Filtered to current user's own PRs. |
| PRs Pending My Approval | List | Filtered to PRs where Approver = current user and Status = Pending. |
| Purchase Requisition Setup | Card | Admin setup page. |

### 7.2 Navigation

- Purchase Requisitions should be accessible from the Purchasing menu in the Role Centre.
- "My Purchase Requisitions" and "PRs Pending My Approval" should appear as Role Centre cues (tiles) for relevant users.
- The PR list should support filtering by Status, Department Code, Requested By, and Date Range.

---

## 8. Roles & Permissions

| Role | Permissions |
|---|---|
| PR Requestor | Create, edit, delete (Draft only), submit, cancel, print own PRs. View own list. |
| PR Approver | View all PRs assigned to them. Approve or reject. Cannot create PRs. |
| PR Manager | View all PRs across departments. Can convert approved PRs to PO. |
| PR Administrator | Full access. Manage setup table. Can override status. View all. |

Implement as a Permission Set extension. Do not modify existing BC permission sets.

---

## 9. Notifications & Alerts

| Trigger | Recipient | Content |
|---|---|---|
| PR submitted for approval | Approver | PR No., requestor name, total amount, link to PR |
| PR approved | Requestor | PR No., approver name, approval date |
| PR rejected | Requestor | PR No., rejection reason, approver name |
| PR converted to PO | Requestor + PR Manager | PR No., PO No. created, vendor name |
| PR pending > X days (configurable) | Approver + Admin | Reminder of unactioned PRs |

Use BC's built-in My Notifications / Notification Entry framework where possible. Email is secondary if the client has SMTP configured.

---

## 10. Reporting

### 10.1 Print Layout — Purchase Requisition Report

A printable report (RDLC or Word layout) must be created for the PR document, including:

- Company name and logo
- PR No., status, request date, requested by
- Required by date, preferred vendor, department
- Line details: type, description, quantity, UoM, unit cost, line amount
- Totals section with currency
- Approval section: approver name, approval date, signature line (for printed copies)
- Justification and notes fields

### 10.2 Optional Reports (Phase 2)

- PR Summary by Department — total requested spend by department and period
- PR Aging Report — PRs pending approval beyond X days
- PR to PO Conversion Report — PRs and their resulting PO numbers

---

## 11. Technical Requirements

### 11.1 Development Standards

- Build as an AL Extension — no base app modifications
- Target BC SaaS (cloud-compatible; no .NET interop)
- Follow Microsoft AL coding guidelines and AppSourceCop rules
- All objects must use a registered object ID range (confirm with client before starting)
- Prefix all objects and fields (e.g. "PR" or a client-specific prefix) to avoid conflicts
- No direct SQL; use AL table/record operations only

### 11.2 Required Objects

| Object Type | Suggested Name | Purpose |
|---|---|---|
| Table | Purchase Requisition Header | Main header data |
| Table | Purchase Requisition Line | Line item data |
| Table | Purchase Requisition Setup | Configuration |
| Page | Purchase Requisition | Document card page |
| Page | Purchase Requisition Subform | Lines subform |
| Page | Purchase Requisitions List | All PRs list |
| Page | My Purchase Requisitions | Filtered list by current user |
| Page | PRs Pending My Approval | Approver queue |
| Page | Purchase Requisition Setup | Setup card |
| Codeunit | PR Approval Management | Approval workflow logic |
| Codeunit | PR to PO Conversion | Conversion logic |
| Codeunit | PR Notification Management | Email/notification logic |
| Report | Purchase Requisition | Print layout (RDLC) |
| Permission Set | PR Requestor | User permission set |
| Permission Set | PR Approver | User permission set |
| Permission Set | PR Manager / Admin | User permission set |

---

## 12. Out of Scope — Phase 1

The following are explicitly excluded from Phase 1 and are candidates for Phase 2:

- Multi-level approval chains beyond the 2-level threshold model
- Mobile-specific UI optimisation
- Integration with external procurement systems
- Vendor quote request directly from a PR
- Budget validation / budget ledger checks
- Partial conversion (converting a subset of PR lines to a PO)
- PR templates
- Electronic signatures

---

## 13. Acceptance Criteria

The feature is considered complete when all of the following are verified:

1. A user with the PR Requestor role can create, fill, and submit a PR with multiple lines.
2. A user with the PR Approver role can approve or reject the PR and must enter a reason on rejection.
3. A rejected PR returns to Draft status and is editable again.
4. An approved PR can be converted to a Purchase Order by a PR Manager.
5. The resulting PO contains all lines from the PR with correct field mapping.
6. The PR status changes to Converted and is fully read-only thereafter.
7. The Created PO No. field on the PR links directly to the Purchase Order.
8. Notifications are sent at each status transition (when email/notifications are configured).
9. The PR can be printed or previewed at any status.
10. All permission sets enforce role-based restrictions as defined in Section 8.
11. No existing BC functionality (PO, Quote, Requisition Worksheet) is broken or modified.
