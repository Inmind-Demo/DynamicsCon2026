table 50000 "PR Purchase Requisition Header"
{
    Caption = 'Purchase Requisition Header';
    DataClassification = CustomerContent;
    LookupPageId = "PR Purchase Requisitions List";
    DrillDownPageId = "PR Purchase Requisitions List";

    fields
    {
        field(1; "PR No."; Code[20])
        {
            Caption = 'PR No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PRSetup: Record "PR Purchase Requisition Setup";
                NoSeries: Codeunit "No. Series";
            begin
                if "PR No." <> xRec."PR No." then begin
                    PRSetup.GetRecordOnce();
                    NoSeries.TestManual(PRSetup."PR No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Requested By"; Code[50])
        {
            Caption = 'Requested By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(4; "Request Date"; Date)
        {
            Caption = 'Request Date';
            DataClassification = CustomerContent;
        }
        field(5; "Required By Date"; Date)
        {
            Caption = 'Required By Date';
            DataClassification = CustomerContent;
        }
        field(6; "Department Code"; Code[20])
        {
            Caption = 'Department Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                PropagateHeaderDimensionToLines(1, "Department Code");
            end;
        }
        field(7; "Cost Centre"; Code[20])
        {
            Caption = 'Cost Centre';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                PropagateHeaderDimensionToLines(2, "Cost Centre");
            end;
        }
        field(8; "Preferred Vendor No."; Code[20])
        {
            Caption = 'Preferred Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if "Preferred Vendor No." <> '' then begin
                    Vendor.Get("Preferred Vendor No.");
                    "Preferred Vendor Name" := Vendor.Name;
                end else
                    "Preferred Vendor Name" := '';
            end;
        }
        field(9; "Preferred Vendor Name"; Text[100])
        {
            Caption = 'Preferred Vendor Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Justification; Text[250])
        {
            Caption = 'Justification';
            DataClassification = CustomerContent;
        }
        field(11; Status; Enum "PR Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Approver ID"; Code[50])
        {
            Caption = 'Approver ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(13; "Approval Date"; Date)
        {
            Caption = 'Approval Date';
            DataClassification = CustomerContent;
        }
        field(14; "Created PO No."; Code[20])
        {
            Caption = 'Created PO No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));
            Editable = false;
        }
        field(15; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(16; "Total Amount (LCY)"; Decimal)
        {
            Caption = 'Total Amount (LCY)';
            FieldClass = FlowField;
            CalcFormula = sum("PR Purchase Requisition Line"."Line Amount (LCY)" where("PR No." = field("PR No.")));
            Editable = false;
        }
        field(17; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18; "Rejection Reason"; Text[250])
        {
            Caption = 'Rejection Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "PR No.")
        {
            Clustered = true;
        }
        key(Status; Status) { }
        key(RequestedBy; "Requested By") { }
        key(DepartmentCode; "Department Code") { }
    }

    trigger OnInsert()
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "PR No." = '' then begin
            PRSetup.GetRecordOnce();
            PRSetup.TestField("PR No. Series");
            "No. Series" := PRSetup."PR No. Series";
            "PR No." := NoSeries.GetNextNo("No. Series");
        end;
        if "Requested By" = '' then
            "Requested By" := CopyStr(UserId(), 1, 50);
        if "Request Date" = 0D then
            "Request Date" := Today();
        Status := Status::Draft;
    end;

    trigger OnDelete()
    begin
        TestStatusForDelete();
        DeleteLines();
    end;

    local procedure TestStatusForDelete()
    var
        CannotDeleteErr: Label 'You cannot delete Purchase Requisition %1 because its status is %2.', Comment = '%1=PR No., %2=Status';
    begin
        if Status in [Status::"Pending Approval", Status::Approved, Status::Converted] then
            Error(CannotDeleteErr, "PR No.", Status);
    end;

    local procedure DeleteLines()
    var
        PRLine: Record "PR Purchase Requisition Line";
    begin
        PRLine.SetRange("PR No.", "PR No.");
        PRLine.DeleteAll(true);
    end;

    local procedure PropagateHeaderDimensionToLines(DimensionNo: Integer; DimCode: Code[20])
    var
        PRLine: Record "PR Purchase Requisition Line";
    begin
        PRLine.SetRange("PR No.", "PR No.");
        if PRLine.FindSet() then
            repeat
                if DimensionNo = 1 then
                    PRLine."Shortcut Dimension 1 Code" := DimCode
                else
                    PRLine."Shortcut Dimension 2 Code" := DimCode;
                PRLine.Modify();
            until PRLine.Next() = 0;
    end;

    procedure IsEditable(): Boolean
    begin
        exit(Status in [Status::Draft, Status::Rejected]);
    end;
}
