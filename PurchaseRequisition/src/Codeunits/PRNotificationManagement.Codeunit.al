codeunit 50002 "PR Notification Management"
{
    var
        ApproverPendingSubjectLbl: Label 'PR %1 Pending Your Approval', Locked = true;
        ApproverPendingBodyLbl: Label 'Purchase Requisition %1 is pending your approval.\nDepartment: %2\nDescription: %3\nTotal Amount: %4', Locked = true;
        RequestorApprovedSubjectLbl: Label 'PR %1 Has Been Approved', Locked = true;
        RequestorApprovedBodyLbl: Label 'Purchase Requisition %1 has been approved.\nDepartment: %2\nDescription: %3\nTotal Amount: %4', Locked = true;
        RequestorRejectedSubjectLbl: Label 'PR %1 Has Been Rejected', Locked = true;
        RequestorRejectedBodyLbl: Label 'Purchase Requisition %1 has been rejected.\nDepartment: %2\nDescription: %3\nReason: %4', Locked = true;
        ConvertedToPOSubjectLbl: Label 'PR %1 Has Been Converted to PO', Locked = true;
        ConvertedToPOBodyLbl: Label 'Purchase Requisition %1 has been converted to Purchase Order %2.\nDepartment: %3\nDescription: %4', Locked = true;

    /// <summary>
    /// Notifies the approver that a new PR is pending their approval.
    /// </summary>
    procedure NotifyApprover(PRHeader: Record "PR Purchase Requisition Header")
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        ApproverUser: Record User;
    begin
        PRSetup.GetRecordOnce();
        if not PRSetup."Email Notifications" then
            exit;
        if PRHeader."Approver ID" = '' then
            exit;
        if not FindUserByName(PRHeader."Approver ID", ApproverUser) then
            exit;

        SendEmail(
            ApproverUser."Authentication Email",
            StrSubstNo(ApproverPendingSubjectLbl, PRHeader."PR No."),
            StrSubstNo(ApproverPendingBodyLbl,
                PRHeader."PR No.", PRHeader."Department Code", PRHeader.Description, PRHeader."Total Amount (LCY)"));
    end;

    /// <summary>
    /// Notifies the requestor that their PR has been approved.
    /// </summary>
    procedure NotifyRequestorApproved(PRHeader: Record "PR Purchase Requisition Header")
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        RequestorUser: Record User;
    begin
        PRSetup.GetRecordOnce();
        if not PRSetup."Email Notifications" then
            exit;
        if PRHeader."Requested By" = '' then
            exit;
        if not FindUserByName(PRHeader."Requested By", RequestorUser) then
            exit;

        SendEmail(
            RequestorUser."Authentication Email",
            StrSubstNo(RequestorApprovedSubjectLbl, PRHeader."PR No."),
            StrSubstNo(RequestorApprovedBodyLbl,
                PRHeader."PR No.", PRHeader."Department Code", PRHeader.Description, PRHeader."Total Amount (LCY)"));
    end;

    /// <summary>
    /// Notifies the requestor that their PR has been rejected.
    /// </summary>
    procedure NotifyRequestorRejected(PRHeader: Record "PR Purchase Requisition Header")
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        RequestorUser: Record User;
    begin
        PRSetup.GetRecordOnce();
        if not PRSetup."Email Notifications" then
            exit;
        if PRHeader."Requested By" = '' then
            exit;
        if not FindUserByName(PRHeader."Requested By", RequestorUser) then
            exit;

        SendEmail(
            RequestorUser."Authentication Email",
            StrSubstNo(RequestorRejectedSubjectLbl, PRHeader."PR No."),
            StrSubstNo(RequestorRejectedBodyLbl,
                PRHeader."PR No.", PRHeader."Department Code", PRHeader.Description, PRHeader."Rejection Reason"));
    end;

    /// <summary>
    /// Notifies the requestor that their PR has been converted to a PO.
    /// </summary>
    procedure NotifyConvertedToPO(PRHeader: Record "PR Purchase Requisition Header")
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        RequestorUser: Record User;
    begin
        PRSetup.GetRecordOnce();
        if not PRSetup."Email Notifications" then
            exit;

        if (PRHeader."Requested By" <> '') and this.FindUserByName(PRHeader."Requested By", RequestorUser) then
            this.SendEmail(
                RequestorUser."Authentication Email",
                StrSubstNo(ConvertedToPOSubjectLbl, PRHeader."PR No."),
                StrSubstNo(ConvertedToPOBodyLbl,
                    PRHeader."PR No.", PRHeader."Created PO No.", PRHeader."Department Code", PRHeader.Description));
    end;

    local procedure FindUserByName(UserName: Code[50]; var FoundUser: Record User): Boolean
    begin
        FoundUser.SetRange("User Name", UserName);
        exit(FoundUser.FindFirst());
    end;

    local procedure SendEmail(RecipientEmail: Text[250]; Subject: Text; Body: Text)
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
        Recipients: List of [Text];
    begin
        if RecipientEmail = '' then
            exit;
        Recipients.Add(RecipientEmail);
        EmailMessage.Create(Recipients, Subject, Body, false);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;
}
