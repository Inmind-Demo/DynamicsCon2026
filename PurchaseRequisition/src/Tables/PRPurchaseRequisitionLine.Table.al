table 50001 "PR Purchase Requisition Line"
{
    Caption = 'Purchase Requisition Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "PR No."; Code[20])
        {
            Caption = 'PR No.';
            DataClassification = CustomerContent;
            TableRelation = "PR Purchase Requisition Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; Type; Enum "PR Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    "No." := '';
                    Description := '';
                    "Unit of Measure Code" := '';
                end;
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case Type of
                    Type::Item:
                        LookupItem();
                    Type::"G/L Account":
                        LookupGLAccount();
                    Type::Resource:
                        LookupResource();
                    Type::"Fixed Asset":
                        LookupFixedAsset();
                end;
            end;

            trigger OnLookup()
            begin
                case Type of
                    Type::Item:
                        LookupItem();
                    Type::"G/L Account":
                        LookupGLAccount();
                    Type::Resource:
                        LookupResource();
                    Type::"Fixed Asset":
                        LookupFixedAsset();
                end;
            end;
        }
        field(5; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcLineAmount();
            end;
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(8; "Unit Cost (LCY)"; Decimal)
        {
            Caption = 'Unit Cost (LCY)';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalcLineAmount();
            end;
        }
        field(9; "Line Amount (LCY)"; Decimal)
        {
            Caption = 'Line Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(11; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
            DataClassification = CustomerContent;
        }
        field(12; "Line Note"; Text[250])
        {
            Caption = 'Line Note';
            DataClassification = CustomerContent;
        }
        field(13; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Department Code';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(14; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Cost Centre';
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
    }

    keys
    {
        key(PK; "PR No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        if PRHeader.Get("PR No.") then begin
            "Shortcut Dimension 1 Code" := PRHeader."Department Code";
            "Shortcut Dimension 2 Code" := PRHeader."Cost Centre";
            if "Expected Receipt Date" = 0D then
                "Expected Receipt Date" := PRHeader."Required By Date";
        end;
    end;

    local procedure CalcLineAmount()
    begin
        "Line Amount (LCY)" := Quantity * "Unit Cost (LCY)";
    end;

    local procedure LookupItem()
    var
        Item: Record Item;
    begin
        if Item.Get("No.") then begin
            Description := Item.Description;
            "Unit of Measure Code" := Item."Base Unit of Measure";
        end;
    end;

    local procedure LookupGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.Get("No.") then
            Description := GLAccount.Name;
    end;

    local procedure LookupResource()
    var
        Resource: Record Resource;
    begin
        if Resource.Get("No.") then begin
            Description := Resource.Name;
            "Unit of Measure Code" := Resource."Base Unit of Measure";
        end;
    end;

    local procedure LookupFixedAsset()
    var
        FixedAsset: Record "Fixed Asset";
    begin
        if FixedAsset.Get("No.") then
            Description := FixedAsset.Description;
    end;
}
