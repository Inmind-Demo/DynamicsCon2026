page 50007 "PR Rejection Reason Dialog"
{
    Caption = 'Rejection Reason';
    PageType = StandardDialog;
    Editable = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = '';

                field(RejectionReasonField; RejectionReasonValue)
                {
                    ApplicationArea = All;
                    Caption = 'Rejection Reason';
                    ToolTip = 'Specifies the reason for rejecting this purchase requisition.';
                    MultiLine = true;
                    ShowCaption = true;
                }
            }
        }
    }

    var
        RejectionReasonValue: Text[250];

    procedure GetRejectionReason(): Text[250]
    begin
        exit(RejectionReasonValue);
    end;
}
