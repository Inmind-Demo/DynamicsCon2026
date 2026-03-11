permissionset 50003 "PR Administrator"
{
    Caption = 'PR Administrator';
    Assignable = true;

    Permissions =
        tabledata "PR Purchase Requisition Header" = RIMD,
        tabledata "PR Purchase Requisition Line" = RIMD,
        tabledata "PR Purchase Requisition Setup" = RIMD,
        tabledata "PR Dept. Approver Setup" = RIMD,
        codeunit "PR Approval Management" = X,
        codeunit "PR to PO Conversion" = X,
        codeunit "PR Notification Management" = X,
        page "Purchase Requisition" = X,
        page "PR Purch. Requisition Subform" = X,
        page "PR Purchase Requisitions List" = X,
        page "My Purchase Requisitions" = X,
        page "PRs Pending My Approval" = X,
        page "PR Purchase Requisition Setup" = X,
        page "PR Dept Approver Setup Subform" = X,
        page "PR Rejection Reason Dialog" = X,
        report "PR Purchase Requisition" = X;
}
