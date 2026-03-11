enum 50000 "PR Status"
{
    Extensible = true;
    Caption = 'PR Status';

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }
    value(2; Approved)
    {
        Caption = 'Approved';
    }
    value(3; Rejected)
    {
        Caption = 'Rejected';
    }
    value(4; Converted)
    {
        Caption = 'Converted';
    }
    value(5; Cancelled)
    {
        Caption = 'Cancelled';
    }
}
