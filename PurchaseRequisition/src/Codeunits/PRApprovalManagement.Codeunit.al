codeunit 50000 "PR Approval Management"
{
    /// <summary>
    /// Submits the PR for approval. Validates completeness, sets status to Pending Approval,
    /// assigns the approver, and sends a notification.
    /// </summary>
    procedure SendForApproval(var PRHeader: Record "PR Purchase Requisition Header")
    var
        PRLine: Record "PR Purchase Requisition Line";
        PRNotificationMgt: Codeunit "PR Notification Management";
        ApproverID: Code[50];
        NoLinesErr: Label 'You cannot send Purchase Requisition %1 for approval because it has no lines.', Comment = '%1=PR No.';
        MissingDescErr: Label 'You must fill in the Description field before sending Purchase Requisition %1 for approval.', Comment = '%1=PR No.';
        MissingDateErr: Label 'You must fill in the Required By Date field before sending Purchase Requisition %1 for approval.', Comment = '%1=PR No.';
        MissingDeptErr: Label 'You must fill in the Department Code field before sending Purchase Requisition %1 for approval.', Comment = '%1=PR No.';
        WrongStatusErr: Label 'You can only send a Purchase Requisition with status Draft for approval. Current status is %1.', Comment = '%1=Status';
    begin
        PRHeader.TestField("PR No.");
        if PRHeader.Status <> PRHeader.Status::Draft then
            Error(WrongStatusErr, PRHeader.Status);

        if PRHeader.Description = '' then
            Error(MissingDescErr, PRHeader."PR No.");
        if PRHeader."Required By Date" = 0D then
            Error(MissingDateErr, PRHeader."PR No.");
        if PRHeader."Department Code" = '' then
            Error(MissingDeptErr, PRHeader."PR No.");

        PRLine.SetRange("PR No.", PRHeader."PR No.");
        if PRLine.IsEmpty() then
            Error(NoLinesErr, PRHeader."PR No.");

        ApproverID := GetApproverID(PRHeader);

        PRHeader.Status := PRHeader.Status::"Pending Approval";
        PRHeader."Approver ID" := ApproverID;
        PRHeader.Modify(true);

        PRNotificationMgt.NotifyApprover(PRHeader);
    end;

    /// <summary>
    /// Approves the PR. Sets status to Approved and records the approver and date.
    /// </summary>
    procedure Approve(var PRHeader: Record "PR Purchase Requisition Header")
    var
        PRNotificationMgt: Codeunit "PR Notification Management";
        WrongStatusErr: Label 'You can only approve a Purchase Requisition with status Pending Approval. Current status is %1.', Comment = '%1=Status';
    begin
        if PRHeader.Status <> PRHeader.Status::"Pending Approval" then
            Error(WrongStatusErr, PRHeader.Status);

        PRHeader.Status := PRHeader.Status::Approved;
        PRHeader."Approver ID" := CopyStr(UserId(), 1, 50);
        PRHeader."Approval Date" := Today();
        PRHeader."Rejection Reason" := '';
        PRHeader.Modify(true);

        PRNotificationMgt.NotifyRequestorApproved(PRHeader);
    end;

    /// <summary>
    /// Rejects the PR. Prompts for a rejection reason, sets status back to Draft.
    /// </summary>
    procedure Reject(var PRHeader: Record "PR Purchase Requisition Header")
    var
        PRNotificationMgt: Codeunit "PR Notification Management";
        RejectionReason: Text[250];
        WrongStatusErr: Label 'You can only reject a Purchase Requisition with status Pending Approval. Current status is %1.', Comment = '%1=Status';
        ReasonRequiredErr: Label 'You must enter a rejection reason.';
    begin
        if PRHeader.Status <> PRHeader.Status::"Pending Approval" then
            Error(WrongStatusErr, PRHeader.Status);

        if not GetRejectionReason(RejectionReason) then
            exit;

        if RejectionReason = '' then
            Error(ReasonRequiredErr);

        PRHeader.Status := PRHeader.Status::Rejected;
        PRHeader."Rejection Reason" := RejectionReason;
        PRHeader.Modify(true);

        PRNotificationMgt.NotifyRequestorRejected(PRHeader);
    end;

    /// <summary>
    /// Cancels the PR after user confirmation. Allowed from Draft or Rejected status only.
    /// </summary>
    procedure CancelRequisition(var PRHeader: Record "PR Purchase Requisition Header")
    var
        WrongStatusErr: Label 'You can only cancel a Purchase Requisition with status Draft or Rejected. Current status is %1.', Comment = '%1=Status';
        ConfirmCancelQst: Label 'Are you sure you want to cancel Purchase Requisition %1?', Comment = '%1=PR No.';
    begin
        if not (PRHeader.Status in [PRHeader.Status::Draft, PRHeader.Status::Rejected]) then
            Error(WrongStatusErr, PRHeader.Status);

        if not Confirm(ConfirmCancelQst, false, PRHeader."PR No.") then
            exit;

        PRHeader.Status := PRHeader.Status::Cancelled;
        PRHeader.Modify(true);
    end;

    /// <summary>
    /// Copies the header and lines of the given PR into a new Draft PR.
    /// </summary>
    procedure CopyPR(SourcePRHeader: Record "PR Purchase Requisition Header"; var NewPRHeader: Record "PR Purchase Requisition Header")
    var
        SourcePRLine: Record "PR Purchase Requisition Line";
        NewPRLine: Record "PR Purchase Requisition Line";
        NewLineNo: Integer;
    begin
        NewPRHeader.Init();
        NewPRHeader.Insert(true);
        NewPRHeader.Description := SourcePRHeader.Description;
        NewPRHeader."Required By Date" := SourcePRHeader."Required By Date";
        NewPRHeader."Department Code" := SourcePRHeader."Department Code";
        NewPRHeader."Cost Centre" := SourcePRHeader."Cost Centre";
        NewPRHeader.Validate("Preferred Vendor No.", SourcePRHeader."Preferred Vendor No.");
        NewPRHeader.Justification := SourcePRHeader.Justification;
        NewPRHeader."Currency Code" := SourcePRHeader."Currency Code";
        NewPRHeader.Modify(true);

        NewLineNo := 10000;
        SourcePRLine.SetRange("PR No.", SourcePRHeader."PR No.");
        if SourcePRLine.FindSet() then
            repeat
                NewPRLine.Init();
                NewPRLine."PR No." := NewPRHeader."PR No.";
                NewPRLine."Line No." := NewLineNo;
                NewPRLine.Type := SourcePRLine.Type;
                NewPRLine."No." := SourcePRLine."No.";
                NewPRLine.Description := SourcePRLine.Description;
                NewPRLine.Quantity := SourcePRLine.Quantity;
                NewPRLine."Unit of Measure Code" := SourcePRLine."Unit of Measure Code";
                NewPRLine."Unit Cost (LCY)" := SourcePRLine."Unit Cost (LCY)";
                NewPRLine."Line Amount (LCY)" := SourcePRLine."Line Amount (LCY)";
                NewPRLine."Location Code" := SourcePRLine."Location Code";
                NewPRLine."Expected Receipt Date" := SourcePRLine."Expected Receipt Date";
                NewPRLine."Line Note" := SourcePRLine."Line Note";
                NewPRLine."Shortcut Dimension 1 Code" := SourcePRLine."Shortcut Dimension 1 Code";
                NewPRLine."Shortcut Dimension 2 Code" := SourcePRLine."Shortcut Dimension 2 Code";
                NewPRLine.Insert(true);
                NewLineNo += 10000;
            until SourcePRLine.Next() = 0;
    end;

    /// <summary>
    /// Determines the approver for a PR based on department rules, then the default.
    /// </summary>
    local procedure GetApproverID(PRHeader: Record "PR Purchase Requisition Header"): Code[50]
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        DeptApprover: Record "PR Dept. Approver Setup";
        NoApproverErr: Label 'No approver is configured for Department Code %1 and no Default Approver is set in Purchase Requisition Setup.', Comment = '%1=Department Code';
    begin
        if PRHeader."Department Code" <> '' then
            if DeptApprover.Get(PRHeader."Department Code") then
                if DeptApprover."Approver User ID" <> '' then
                    exit(DeptApprover."Approver User ID");

        PRSetup.GetRecordOnce();
        if PRSetup."Default Approver ID" <> '' then
            exit(PRSetup."Default Approver ID");

        Error(NoApproverErr, PRHeader."Department Code");
    end;

    local procedure GetRejectionReason(var RejectionReason: Text[250]): Boolean
    var
        RejectionPage: Page "PR Rejection Reason Dialog";
    begin
        RejectionPage.LookupMode(true);
        if RejectionPage.RunModal() = Action::LookupOK then begin
            RejectionReason := RejectionPage.GetRejectionReason();
            exit(true);
        end;
        exit(false);
    end;
}
