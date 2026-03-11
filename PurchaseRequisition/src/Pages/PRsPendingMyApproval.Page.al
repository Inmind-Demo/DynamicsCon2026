page 50004 "PRs Pending My Approval"
{
    Caption = 'PRs Pending My Approval';
    PageType = List;
    SourceTable = "PR Purchase Requisition Header";
    CardPageId = "Purchase Requisition";
    UsageCategory = Lists;
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("PR No."; Rec."PR No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase requisition number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the purchase request.';
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who submitted the requisition.';
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the requisition was submitted.';
                }
                field("Required By Date"; Rec."Required By Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the goods or services are needed.';
                }
                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the requesting department.';
                }
                field("Preferred Vendor Name"; Rec."Preferred Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the preferred vendor.';
                }
                field("Total Amount (LCY)"; Rec."Total Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount requested.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Approve)
            {
                Caption = 'Approve';
                ToolTip = 'Approve the selected purchase requisition.';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                var
                    PRApprovalMgt: Codeunit "PR Approval Management";
                begin
                    PRApprovalMgt.Approve(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ToolTip = 'Reject the selected purchase requisition.';
                ApplicationArea = All;
                Image = Reject;

                trigger OnAction()
                var
                    PRApprovalMgt: Codeunit "PR Approval Management";
                begin
                    PRApprovalMgt.Reject(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Approve_Promoted; Approve) { }
                actionref(Reject_Promoted; Reject) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Approver ID", CopyStr(UserId(), 1, 50));
        Rec.SetRange(Status, Rec.Status::"Pending Approval");
    end;
}
