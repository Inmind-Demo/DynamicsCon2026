table 50002 "PR Purchase Requisition Setup"
{
    Caption = 'Purchase Requisition Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "PR No. Series"; Code[20])
        {
            Caption = 'PR No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(3; "Default Approver ID"; Code[50])
        {
            Caption = 'Default Approver ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(4; "Approval Amount Threshold"; Decimal)
        {
            Caption = 'Approval Amount Threshold';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(5; "Secondary Approver ID"; Code[50])
        {
            Caption = 'Secondary Approver ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(6; "Email Notifications"; Boolean)
        {
            Caption = 'Email Notifications';
            DataClassification = CustomerContent;
        }
        field(7; "Allow Vendor Chg on Conversion"; Boolean)
        {
            Caption = 'Allow Vendor Chg on Conversion';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOnce()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
