codeunit 50051 "PR Approval Mgt. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // -----------------------------------------------------------------------
    // SendForApproval — validation errors
    // -----------------------------------------------------------------------

    [Test]
    procedure SendForApproval_MissingDescription_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader.Description := '';     // override what CreatePRHeader set
        PRHeader.Modify();
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);

        // Act & Assert
        asserterror PRApprovalMgt.SendForApproval(PRHeader);
        if StrPos(GetLastErrorText(), 'Description') = 0 then
            Error('Expected error about Description field. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure SendForApproval_MissingRequiredByDate_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Required By Date" := 0D;
        PRHeader.Modify();
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);

        // Act & Assert
        asserterror PRApprovalMgt.SendForApproval(PRHeader);
        if StrPos(GetLastErrorText(), 'Required By Date') = 0 then
            Error('Expected error about Required By Date. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure SendForApproval_MissingDepartmentCode_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, '');   // no dept code
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);

        // Act & Assert
        asserterror PRApprovalMgt.SendForApproval(PRHeader);
        if StrPos(GetLastErrorText(), 'Department Code') = 0 then
            Error('Expected error about Department Code. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure SendForApproval_NoLines_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — complete header but no lines
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Act & Assert
        asserterror PRApprovalMgt.SendForApproval(PRHeader);
        if StrPos(GetLastErrorText(), 'no lines') = 0 then
            Error('Expected "no lines" error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure SendForApproval_WrongStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — place PR in Approved status (not Draft)
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);

        // Act & Assert
        asserterror PRApprovalMgt.SendForApproval(PRHeader);
        if StrPos(GetLastErrorText(), 'Draft') = 0 then
            Error('Expected status-Draft error. Got: %1', GetLastErrorText());
    end;

    // -----------------------------------------------------------------------
    // SendForApproval — happy paths
    // -----------------------------------------------------------------------

    [Test]
    procedure SendForApproval_DefaultApprover_SetsPendingApproval()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APPROVER01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 2, 50);

        // Act
        PRApprovalMgt.SendForApproval(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::"Pending Approval" then
            Error('Expected Status = Pending Approval. Got: %1', PRHeader.Status);
        if PRHeader."Approver ID" <> 'APPROVER01' then
            Error('Expected Approver ID = APPROVER01. Got: %1', PRHeader."Approver ID");
    end;

    [Test]
    procedure SendForApproval_DeptApprover_UsedOverDefault()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — dept-specific approver wins over the default
        PRTestLib.CreateSetup('DEFAULT-APR');
        PRTestLib.CreateDeptApproverSetup('SALES', 'DEPT-APR');
        PRTestLib.CreatePRHeader(PRHeader, 'SALES');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 200);

        // Act
        PRApprovalMgt.SendForApproval(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader."Approver ID" <> 'DEPT-APR' then
            Error('Expected dept approver DEPT-APR. Got: %1', PRHeader."Approver ID");
    end;

    [Test]
    procedure SendForApproval_NoDeptApprover_FallsBackToDefault()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — no dept mapping → default approver
        PRTestLib.CreateSetup('DEFAULT-APR');
        PRTestLib.CreatePRHeader(PRHeader, 'NODEPT');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 75);

        // Act
        PRApprovalMgt.SendForApproval(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader."Approver ID" <> 'DEFAULT-APR' then
            Error('Expected default approver DEFAULT-APR. Got: %1', PRHeader."Approver ID");
    end;

    // -----------------------------------------------------------------------
    // Approve
    // -----------------------------------------------------------------------

    [Test]
    procedure Approve_WrongStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — PR is in Draft, not Pending Approval
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Act & Assert
        asserterror PRApprovalMgt.Approve(PRHeader);
        if StrPos(GetLastErrorText(), 'Pending Approval') = 0 then
            Error('Expected Pending Approval status error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure Approve_SetsPRToApproved()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        // Act
        PRApprovalMgt.Approve(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::Approved then
            Error('Expected Status = Approved. Got: %1', PRHeader.Status);
        if PRHeader."Approval Date" <> Today() then
            Error('Expected Approval Date = today. Got: %1', PRHeader."Approval Date");
        if PRHeader."Rejection Reason" <> '' then
            Error('Rejection Reason should be cleared on approval.');
    end;

    // -----------------------------------------------------------------------
    // Reject
    // -----------------------------------------------------------------------

    [Test]
    procedure Reject_WrongStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — PR is Draft (not Pending Approval); error fires before dialog opens
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Act & Assert
        asserterror PRApprovalMgt.Reject(PRHeader);
        if StrPos(GetLastErrorText(), 'Pending Approval') = 0 then
            Error('Expected Pending Approval status error. Got: %1', GetLastErrorText());
    end;

    [Test]
    [HandlerFunctions('RejectDialogSetReasonHandler')]
    procedure Reject_SetsPRToRejectedWithReason()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");
        GlobalRejectionReason := 'Budget not available';

        // Act
        PRApprovalMgt.Reject(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::Rejected then
            Error('Expected Status = Rejected. Got: %1', PRHeader.Status);
        if PRHeader."Rejection Reason" <> GlobalRejectionReason then
            Error('Expected Rejection Reason = %1. Got: %2', GlobalRejectionReason, PRHeader."Rejection Reason");
    end;

    // -----------------------------------------------------------------------
    // CancelRequisition
    // -----------------------------------------------------------------------

    [Test]
    procedure CancelRequisition_WrongStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — Approved PRs cannot be cancelled
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        // Act & Assert
        asserterror PRApprovalMgt.CancelRequisition(PRHeader);
        if StrPos(GetLastErrorText(), 'Draft or Rejected') = 0 then
            Error('Expected status error. Got: %1', GetLastErrorText());
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure CancelRequisition_FromDraft_SetsCancelled()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');   // Status = Draft

        // Act
        PRApprovalMgt.CancelRequisition(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::Cancelled then
            Error('Expected Status = Cancelled. Got: %1', PRHeader.Status);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure CancelRequisition_FromRejected_SetsCancelled()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Rejected);

        // Act
        PRApprovalMgt.CancelRequisition(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::Cancelled then
            Error('Expected Status = Cancelled. Got: %1', PRHeader.Status);
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler')]
    procedure CancelRequisition_UserDeclines_StatusUnchanged()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');   // Status = Draft

        // Act — user clicks No in the confirmation dialog
        PRApprovalMgt.CancelRequisition(PRHeader);

        // Assert
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::Draft then
            Error('Expected Status = Draft after decline. Got: %1', PRHeader.Status);
    end;

    // -----------------------------------------------------------------------
    // CopyPR
    // -----------------------------------------------------------------------

    [Test]
    procedure CopyPR_CopiesHeaderAndLines()
    var
        SourcePRHeader: Record "PR Purchase Requisition Header";
        NewPRHeader: Record "PR Purchase Requisition Header";
        NewPRLine: Record "PR Purchase Requisition Line";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — source PR with two lines
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(SourcePRHeader, 'DEPT01');
        SourcePRHeader.Justification := 'Demo justification';
        SourcePRHeader.Modify();
        PRTestLib.CreatePRLine(SourcePRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 3, 100);
        PRTestLib.CreatePRLine(SourcePRHeader."PR No.", 20000, "PR Line Type"::"G/L Account", '', 5, 200);

        // Act
        PRApprovalMgt.CopyPR(SourcePRHeader, NewPRHeader);

        // Assert — header
        if NewPRHeader."PR No." = '' then
            Error('New PR No. should not be empty.');
        if NewPRHeader."PR No." = SourcePRHeader."PR No." then
            Error('Copy must have a different PR No.');
        if NewPRHeader.Description <> SourcePRHeader.Description then
            Error('Description not copied correctly.');
        if NewPRHeader.Status <> NewPRHeader.Status::Draft then
            Error('Copied PR must be in Draft status.');

        // Assert — lines
        NewPRLine.SetRange("PR No.", NewPRHeader."PR No.");
        if NewPRLine.Count() <> 2 then
            Error('Expected 2 lines on the copied PR. Found: %1', NewPRLine.Count());
    end;

    // -----------------------------------------------------------------------
    // SendForApproval — no approver configured
    // -----------------------------------------------------------------------

    [Test]
    procedure SendForApproval_NoApproverConfigured_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — setup with no default approver and no dept mapping for the dept used
        PRTestLib.CreateSetup('');    // empty default approver
        PRTestLib.CreatePRHeader(PRHeader, 'NODEPT99');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);

        // Act & Assert
        asserterror PRApprovalMgt.SendForApproval(PRHeader);
        if StrPos(GetLastErrorText(), 'No approver') = 0 then
            Error('Expected no-approver-configured error. Got: %1', GetLastErrorText());
    end;

    // -----------------------------------------------------------------------
    // Approve — approver ID stamped
    // -----------------------------------------------------------------------

    [Test]
    procedure Approve_SetsApproverIDToCurrentUser()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        // Act
        PRApprovalMgt.Approve(PRHeader);

        // Assert — Approver ID is stamped with the current user
        PRHeader.Find();
        if PRHeader."Approver ID" = '' then
            Error('Approver ID should be set to the current user after approval.');
    end;

    // -----------------------------------------------------------------------
    // Reject — dialog cancelled / empty reason
    // -----------------------------------------------------------------------

    [Test]
    [HandlerFunctions('RejectDialogCancelHandler')]
    procedure Reject_UserCancelsDialog_StatusUnchanged()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        // Act — user dismisses the dialog (Cancel)
        PRApprovalMgt.Reject(PRHeader);

        // Assert — status must remain Pending Approval (Reject exited without change)
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::"Pending Approval" then
            Error('Expected Status to remain Pending Approval after cancel. Got: %1', PRHeader.Status);
    end;

    [Test]
    [HandlerFunctions('RejectDialogEmptyReasonHandler')]
    procedure Reject_EmptyReason_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        // Act & Assert — OK clicked with an empty reason → ReasonRequired error
        asserterror PRApprovalMgt.Reject(PRHeader);
        if StrPos(GetLastErrorText(), 'rejection reason') = 0 then
            Error('Expected rejection-reason-required error. Got: %1', GetLastErrorText());
    end;

    // -----------------------------------------------------------------------
    // CancelRequisition — additional wrong-status branches
    // -----------------------------------------------------------------------

    [Test]
    procedure CancelRequisition_PendingApproval_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — Pending Approval PRs cannot be cancelled
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        // Act & Assert
        asserterror PRApprovalMgt.CancelRequisition(PRHeader);
        if StrPos(GetLastErrorText(), 'Draft or Rejected') = 0 then
            Error('Expected status error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure CancelRequisition_Converted_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — Converted PRs cannot be cancelled
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Converted);

        // Act & Assert
        asserterror PRApprovalMgt.CancelRequisition(PRHeader);
        if StrPos(GetLastErrorText(), 'Draft or Rejected') = 0 then
            Error('Expected status error. Got: %1', GetLastErrorText());
    end;

    // -----------------------------------------------------------------------
    // CopyPR — edge case: source has no lines
    // -----------------------------------------------------------------------

    [Test]
    procedure CopyPR_WithNoLines_NewPRHasNoLines()
    var
        SourcePRHeader: Record "PR Purchase Requisition Header";
        NewPRHeader: Record "PR Purchase Requisition Header";
        NewPRLine: Record "PR Purchase Requisition Line";
        PRApprovalMgt: Codeunit "PR Approval Management";
    begin
        // Arrange — source PR has no lines
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(SourcePRHeader, 'DEPT01');

        // Act
        PRApprovalMgt.CopyPR(SourcePRHeader, NewPRHeader);

        // Assert — copied PR also has no lines
        NewPRLine.SetRange("PR No.", NewPRHeader."PR No.");
        if not NewPRLine.IsEmpty() then
            Error('Expected 0 lines on the copied PR (source had none).');
    end;

    // -----------------------------------------------------------------------
    // Handlers
    // -----------------------------------------------------------------------

    [ModalPageHandler]
    procedure RejectDialogSetReasonHandler(var RejectionDlg: TestPage "PR Rejection Reason Dialog")
    begin
        RejectionDlg.RejectionReasonField.SetValue(GlobalRejectionReason);
        RejectionDlg.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure RejectDialogCancelHandler(var RejectionDlg: TestPage "PR Rejection Reason Dialog")
    begin
        RejectionDlg.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure RejectDialogEmptyReasonHandler(var RejectionDlg: TestPage "PR Rejection Reason Dialog")
    begin
        RejectionDlg.RejectionReasonField.SetValue('');
        RejectionDlg.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    // -----------------------------------------------------------------------
    // Fixtures
    // -----------------------------------------------------------------------
    var
        PRTestLib: Codeunit "PR Test Library";
        GlobalRejectionReason: Text[250];
}
