permissionset 50001 "PR Approver"
{
    Caption = 'PR Approver';
    Assignable = true;

    Permissions =
        tabledata "PR Purchase Requisition Header" = RM,
        tabledata "PR Purchase Requisition Line" = R,
        tabledata "PR Purchase Requisition Setup" = R,
        tabledata "PR Dept. Approver Setup" = R,
        codeunit "PR Approval Management" = X,
        codeunit "PR Notification Management" = X,
        page "Purchase Requisition" = X,
        page "PR Purch. Requisition Subform" = X,
        page "PR Purchase Requisitions List" = X,
        page "PRs Pending My Approval" = X,
        page "PR Rejection Reason Dialog" = X,
        report "PR Purchase Requisition" = X;
}
