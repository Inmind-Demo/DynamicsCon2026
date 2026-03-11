page 50000 "Purchase Requisition"
{
    Caption = 'Purchase Requisition';
    PageType = Document;
    SourceTable = "PR Purchase Requisition Header";
    UsageCategory = Documents;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("PR No."; Rec."PR No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier of this purchase requisition.';
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of what is being requested.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the current status of the purchase requisition.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Requested By"; Rec."Requested By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created this purchase requisition.';
                    Editable = false;
                }
                field("Request Date"; Rec."Request Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date this purchase requisition was created.';
                    Editable = false;
                }
                field("Required By Date"; Rec."Required By Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the goods or services are required.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                }
                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department requesting the purchase.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                }
                field("Cost Centre"; Rec."Cost Centre")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost centre for the purchase.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency for this requisition. Leave blank for local currency.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                }
            }
            group(Vendor)
            {
                Caption = 'Preferred Vendor';

                field("Preferred Vendor No."; Rec."Preferred Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the preferred vendor for this purchase.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                }
                field("Preferred Vendor Name"; Rec."Preferred Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the preferred vendor.';
                    Editable = false;
                }
                field(Justification; Rec.Justification)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the business justification for this purchase request.';
                    Editable = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);
                    MultiLine = true;
                }
            }
            part(Lines; "PR Purch. Requisition Subform")
            {
                ApplicationArea = All;
                SubPageLink = "PR No." = field("PR No.");
            }
            group(Totals)
            {
                Caption = 'Totals';

                field("Total Amount (LCY)"; Rec."Total Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total estimated amount of all lines in local currency.';
                }
            }
            group(Approval)
            {
                Caption = 'Approval';

                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user assigned to approve this purchase requisition.';
                    Editable = false;
                }
                field("Approval Date"; Rec."Approval Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date this requisition was approved.';
                    Editable = false;
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason this requisition was rejected.';
                    Editable = false;
                    Visible = Rec.Status = Rec.Status::Rejected;
                }
                field("Created PO No."; Rec."Created PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Purchase Order number created from this requisition.';
                    Editable = false;
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
            action(SendForApproval)
            {
                Caption = 'Send for Approval';
                ToolTip = 'Submit this purchase requisition for approval.';
                ApplicationArea = All;
                Image = SendApprovalRequest;
                Enabled = Rec.Status = Rec.Status::Draft;

                trigger OnAction()
                var
                    PRApprovalMgt: Codeunit "PR Approval Management";
                begin
                    PRApprovalMgt.SendForApproval(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                ToolTip = 'Approve this purchase requisition.';
                ApplicationArea = All;
                Image = Approve;
                Enabled = Rec.Status = Rec.Status::"Pending Approval";

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
                ToolTip = 'Reject this purchase requisition.';
                ApplicationArea = All;
                Image = Reject;
                Enabled = Rec.Status = Rec.Status::"Pending Approval";

                trigger OnAction()
                var
                    PRApprovalMgt: Codeunit "PR Approval Management";
                begin
                    PRApprovalMgt.Reject(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CreatePurchaseOrder)
            {
                Caption = 'Create Purchase Order';
                ToolTip = 'Convert this approved purchase requisition into a Purchase Order.';
                ApplicationArea = All;
                Image = MakeOrder;
                Enabled = Rec.Status = Rec.Status::Approved;

                trigger OnAction()
                var
                    PRtoPOConversion: Codeunit "PR to PO Conversion";
                begin
                    PRtoPOConversion.CreatePurchaseOrder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CancelRequisition)
            {
                Caption = 'Cancel Requisition';
                ToolTip = 'Cancel this purchase requisition.';
                ApplicationArea = All;
                Image = Cancel;
                Enabled = (Rec.Status = Rec.Status::Draft) or (Rec.Status = Rec.Status::Rejected);

                trigger OnAction()
                var
                    PRApprovalMgt: Codeunit "PR Approval Management";
                begin
                    PRApprovalMgt.CancelRequisition(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(NavigateToPO)
            {
                Caption = 'Navigate to Purchase Order';
                ToolTip = 'Open the Purchase Order created from this requisition.';
                ApplicationArea = All;
                Image = Order;
                Enabled = Rec.Status = Rec.Status::Converted;

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    Rec.TestField("Created PO No.");
                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Created PO No.");
                    Page.Run(Page::"Purchase Order", PurchaseHeader);
                end;
            }
            action(CopyPR)
            {
                Caption = 'Copy PR';
                ToolTip = 'Create a new Draft purchase requisition by copying the header and lines from this one.';
                ApplicationArea = All;
                Image = Copy;

                trigger OnAction()
                var
                    NewPRHeader: Record "PR Purchase Requisition Header";
                    PRApprovalMgt: Codeunit "PR Approval Management";
                begin
                    PRApprovalMgt.CopyPR(Rec, NewPRHeader);
                    Page.Run(Page::"Purchase Requisition", NewPRHeader);
                end;
            }
        }
        area(Reporting)
        {
            action(PrintPR)
            {
                Caption = 'Print / Preview';
                ToolTip = 'Print or preview this purchase requisition.';
                ApplicationArea = All;
                Image = Print;

                trigger OnAction()
                begin
                    Report.RunModal(Report::"PR Purchase Requisition", true, false, Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SendForApproval_Promoted; SendForApproval) { }
                actionref(Approve_Promoted; Approve) { }
                actionref(Reject_Promoted; Reject) { }
                actionref(CreatePurchaseOrder_Promoted; CreatePurchaseOrder) { }
                actionref(CancelRequisition_Promoted; CancelRequisition) { }
                actionref(NavigateToPO_Promoted; NavigateToPO) { }
            }
            group(Category_Report)
            {
                Caption = 'Reports';

                actionref(PrintPR_Promoted; PrintPR) { }
            }
        }
    }

    var
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        SetPageVariables();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetPageVariables();
    end;

    local procedure SetPageVariables()
    begin
        CurrPage."Lines".Page.SetEditable(Rec.IsEditable());
        StatusStyleExpr := GetStatusStyle();
    end;

    local procedure GetStatusStyle(): Text
    begin
        case Rec.Status of
            Rec.Status::Draft:
                exit('Standard');
            Rec.Status::"Pending Approval":
                exit('Ambiguous');
            Rec.Status::Approved:
                exit('Favorable');
            Rec.Status::Rejected:
                exit('Unfavorable');
            Rec.Status::Converted:
                exit('Strong');
            Rec.Status::Cancelled:
                exit('Subordinate');
        end;
    end;
}
