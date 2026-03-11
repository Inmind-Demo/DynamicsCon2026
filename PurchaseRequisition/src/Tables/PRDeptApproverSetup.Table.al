table 50003 "PR Dept. Approver Setup"
{
    Caption = 'PR Department Approver Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Department Code"; Code[20])
        {
            Caption = 'Department Code';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(2; "Approver User ID"; Code[50])
        {
            Caption = 'Approver User ID';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(PK; "Department Code")
        {
            Clustered = true;
        }
    }
}
