permissionset 50002 "PR Manager"
{
    Caption = 'PR Manager';
    Assignable = true;

    Permissions =
        tabledata "PR Purchase Requisition Header" = RIM,
        tabledata "PR Purchase Requisition Line" = RIM,
        tabledata "PR Purchase Requisition Setup" = R,
        tabledata "PR Dept. Approver Setup" = R,
        codeunit "PR Approval Management" = X,
        codeunit "PR to PO Conversion" = X,
        codeunit "PR Notification Management" = X,
        page "Purchase Requisition" = X,
        page "PR Purch. Requisition Subform" = X,
        page "PR Purchase Requisitions List" = X,
        page "My Purchase Requisitions" = X,
        page "PRs Pending My Approval" = X,
        page "PR Rejection Reason Dialog" = X,
        report "PR Purchase Requisition" = X;
}
