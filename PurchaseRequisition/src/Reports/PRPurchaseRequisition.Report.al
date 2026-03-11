report 50000 "PR Purchase Requisition"
{
    Caption = 'Purchase Requisition';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;

    dataset
    {
        dataitem(PRHeader; "PR Purchase Requisition Header")
        {
            RequestFilterFields = "PR No.", Status, "Requested By", "Department Code", "Request Date";
            PrintOnlyIfDetail = true;

            column(PRNo; "PR No.")
            {
                IncludeCaption = true;
            }
            column(Description; Description)
            {
                IncludeCaption = true;
            }
            column(Status; Format(Status))
            {
            }
            column(StatusCaption; FieldCaption(Status)) { }
            column(RequestedBy; "Requested By")
            {
                IncludeCaption = true;
            }
            column(RequestDate; "Request Date")
            {
                IncludeCaption = true;
            }
            column(RequiredByDate; "Required By Date")
            {
                IncludeCaption = true;
            }
            column(DepartmentCode; "Department Code")
            {
                IncludeCaption = true;
            }
            column(CostCentre; "Cost Centre")
            {
                IncludeCaption = true;
            }
            column(PreferredVendorNo; "Preferred Vendor No.")
            {
                IncludeCaption = true;
            }
            column(PreferredVendorName; "Preferred Vendor Name")
            {
                IncludeCaption = true;
            }
            column(Justification; Justification)
            {
                IncludeCaption = true;
            }
            column(ApproverID; "Approver ID")
            {
                IncludeCaption = true;
            }
            column(ApprovalDate; "Approval Date")
            {
                IncludeCaption = true;
            }
            column(RejectionReason; "Rejection Reason")
            {
                IncludeCaption = true;
            }
            column(CreatedPONo; "Created PO No.")
            {
                IncludeCaption = true;
            }
            column(CurrencyCode; "Currency Code")
            {
                IncludeCaption = true;
            }
            column(TotalAmountLCY; "Total Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(CompanyName; CompanyName()) { }
            column(PrintedDateTime; Format(CurrentDateTime(), 0, '<Day,2>/<Month,2>/<Year4> <Hours24>:<Minutes,2>')) { }

            dataitem(PRLine; "PR Purchase Requisition Line")
            {
                DataItemLink = "PR No." = field("PR No.");
                DataItemTableView = sorting("PR No.", "Line No.");

                column(LineNo; "Line No.")
                {
                    IncludeCaption = true;
                }
                column(LineType; Format(Type))
                {
                }
                column(LineTypeCaption; FieldCaption(Type)) { }
                column(LineItemNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(LineDescription; Description)
                {
                    IncludeCaption = true;
                }
                column(LineQuantity; Quantity)
                {
                    IncludeCaption = true;
                }
                column(LineUoM; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(LineUnitCost; "Unit Cost (LCY)")
                {
                    IncludeCaption = true;
                }
                column(LineAmount; "Line Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(LineLocation; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(LineExpectedDate; "Expected Receipt Date")
                {
                    IncludeCaption = true;
                }
                column(LineNote; "Line Note")
                {
                    IncludeCaption = true;
                }
                column(LineDim1; "Shortcut Dimension 1 Code") { }
                column(LineDim2; "Shortcut Dimension 2 Code") { }
            }
        }
    }

    // Note: Upload a Word or RDLC layout via Report Layout Selection (search in BC) after deployment.
    // The dataset columns above map all required fields for the print layout described in the spec.
}
