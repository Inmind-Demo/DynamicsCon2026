enum 50001 "PR Line Type"
{
    Extensible = true;
    Caption = 'PR Line Type';

    value(0; Blank)
    {
        Caption = ' ';
    }
    value(1; Item)
    {
        Caption = 'Item';
    }
    value(2; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(3; Resource)
    {
        Caption = 'Resource';
    }
    value(4; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
}
