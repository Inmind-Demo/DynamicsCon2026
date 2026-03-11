page 50005 "PR Purchase Requisition Setup"
{
    Caption = 'Purchase Requisition Setup';
    PageType = Card;
    SourceTable = "PR Purchase Requisition Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("PR No. Series"; Rec."PR No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series used to assign numbers to new purchase requisitions.';
                }
                field("Email Notifications"; Rec."Email Notifications")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether email notifications are sent on status changes.';
                }
                field("Allow Vendor Chg on Conversion"; Rec."Allow Vendor Chg on Conversion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether users can select or change the vendor when converting a requisition to a Purchase Order.';
                }
            }
            group(Approval)
            {
                Caption = 'Approval';

                field("Default Approver ID"; Rec."Default Approver ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default approver used when no department-specific approver is configured.';
                }
                field("Approval Amount Threshold"; Rec."Approval Amount Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount above which a secondary approver is required.';
                }
                field("Secondary Approver ID"; Rec."Secondary Approver ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the secondary approver required when the requisition total exceeds the approval threshold.';
                }
            }
            part(DeptApprovers; "PR Dept Approver Setup Subform")
            {
                ApplicationArea = All;
                Caption = 'Approvers by Department';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetRecordOnce();
    end;
}
