page 50006 "PR Dept Approver Setup Subform"
{
    Caption = 'Department Approvers';
    PageType = ListPart;
    SourceTable = "PR Dept. Approver Setup";
    AutoSplitKey = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Department Code"; Rec."Department Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the department code.';
                }
                field("Approver User ID"; Rec."Approver User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user ID of the approver for this department.';
                }
            }
        }
    }
}
