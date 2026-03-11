page 50001 "PR Purch. Requisition Subform"
{
    Caption = 'Purchase Requisition Lines';
    PageType = ListPart;
    SourceTable = "PR Purchase Requisition Line";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies what you are requesting (Item, G/L Account, Resource, Fixed Asset).';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item, account, or resource being requested.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item or service being requested.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity being requested.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure for the requested quantity.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the estimated unit cost in local currency.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total estimated line amount (Quantity × Unit Cost).';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delivery location for this line.';
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when these goods or services are expected.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,1';
                    ToolTip = 'Specifies the dimension 1 code for this line.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,2';
                    ToolTip = 'Specifies the dimension 2 code for this line.';
                    Visible = false;
                }
                field("Line Note"; Rec."Line Note")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any additional notes for this line.';
                }
            }
        }
    }

    procedure SetEditable(IsEditable: Boolean)
    begin
        CurrPage.Editable := IsEditable;
    end;
}
