page 50002 "PR Purchase Requisitions List"
{
    Caption = 'Purchase Requisitions';
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status of the requisition.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the requisition.';
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date the requisition was created.';
                }
                field("Required By Date"; Rec."Required By Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date by which the goods or services are required.';
                }
                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the requesting department.';
                }
                field("Preferred Vendor Name"; Rec."Preferred Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the preferred vendor name.';
                }
                field("Total Amount (LCY)"; Rec."Total Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of the requisition.';
                }
                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the assigned approver.';
                }
                field("Created PO No."; Rec."Created PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Purchase Order created from this requisition.';
                }
            }
        }
        area(FactBoxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewPR)
            {
                Caption = 'New';
                ToolTip = 'Create a new purchase requisition.';
                ApplicationArea = All;
                Image = New;
                RunObject = page "Purchase Requisition";
                RunPageMode = Create;
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'New';
                actionref(NewPR_Promoted; NewPR) { }
            }
        }
    }

    var
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Draft:
                StatusStyleExpr := 'Standard';
            Rec.Status::"Pending Approval":
                StatusStyleExpr := 'Ambiguous';
            Rec.Status::Approved:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Rejected:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::Converted:
                StatusStyleExpr := 'Strong';
            Rec.Status::Cancelled:
                StatusStyleExpr := 'Subordinate';
        end;
    end;
}
