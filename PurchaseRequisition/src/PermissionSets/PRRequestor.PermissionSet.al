permissionset 50000 "PR Requestor"
{
    Caption = 'PR Requestor';
    Assignable = true;

    Permissions =
        tabledata "PR Purchase Requisition Header" = RIMD,
        tabledata "PR Purchase Requisition Line" = RIMD,
        tabledata "PR Purchase Requisition Setup" = R,
        tabledata "PR Dept. Approver Setup" = R,
        codeunit "PR Approval Management" = X,
        codeunit "PR Notification Management" = X,
        page "Purchase Requisition" = X,
        page "PR Purch. Requisition Subform" = X,
        page "PR Purchase Requisitions List" = X,
        page "My Purchase Requisitions" = X,
        page "PR Rejection Reason Dialog" = X,
        report "PR Purchase Requisition" = X;
}
