codeunit 50053 "PR Header Table Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // -----------------------------------------------------------------------
    // OnInsert defaults
    // -----------------------------------------------------------------------

    [Test]
    procedure Insert_SetsDefaultStatus_Draft()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange & Act
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Assert
        if PRHeader.Status <> PRHeader.Status::Draft then
            Error('Expected Status = Draft on insert. Got: %1', PRHeader.Status);
    end;

    [Test]
    procedure Insert_SetsRequestDateToToday()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange & Act
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Assert
        if PRHeader."Request Date" <> Today() then
            Error('Expected Request Date = today. Got: %1', PRHeader."Request Date");
    end;

    [Test]
    procedure Insert_SetsRequestedByToCurrentUser()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange & Act
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Assert — "Requested By" is set from UserId() in OnInsert
        if PRHeader."Requested By" = '' then
            Error('Requested By should be set from the current user.');
    end;

    [Test]
    procedure Insert_AssignsPRNoFromSeries()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange & Act
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Assert
        if PRHeader."PR No." = '' then
            Error('PR No. should be assigned from the No. Series.');
    end;

    // -----------------------------------------------------------------------
    // OnDelete guard
    // -----------------------------------------------------------------------

    [Test]
    procedure Delete_DraftStatus_Succeeds()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRNo: Code[20];
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRNo := PRHeader."PR No.";

        // Act
        PRHeader.Delete(true);

        // Assert
        if PRHeader.Get(PRNo) then
            Error('PR %1 should have been deleted.', PRNo);
    end;

    [Test]
    procedure Delete_PendingApprovalStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        // Act & Assert
        asserterror PRHeader.Delete(true);
        if StrPos(GetLastErrorText(), 'cannot delete') = 0 then
            Error('Expected "cannot delete" error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure Delete_ApprovedStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        // Act & Assert
        asserterror PRHeader.Delete(true);
        if StrPos(GetLastErrorText(), 'cannot delete') = 0 then
            Error('Expected "cannot delete" error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure Delete_ConvertedStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Converted);

        // Act & Assert
        asserterror PRHeader.Delete(true);
        if StrPos(GetLastErrorText(), 'cannot delete') = 0 then
            Error('Expected "cannot delete" error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure Delete_CascadesToLines()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
        PRNo: Code[20];
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRNo := PRHeader."PR No.";
        PRTestLib.CreatePRLine(PRNo, 10000, "PR Line Type"::"G/L Account", '', 1, 100);
        PRTestLib.CreatePRLine(PRNo, 20000, "PR Line Type"::"G/L Account", '', 2, 200);

        // Act
        PRHeader.Delete(true);

        // Assert — all child lines removed
        PRLine.SetRange("PR No.", PRNo);
        if not PRLine.IsEmpty() then
            Error('Lines for PR %1 should have been deleted with the header.', PRNo);
    end;

    // -----------------------------------------------------------------------
    // OnDelete guard — statuses that allow deletion
    // -----------------------------------------------------------------------

    [Test]
    procedure Delete_RejectedStatus_Succeeds()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRNo: Code[20];
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Rejected);
        PRNo := PRHeader."PR No.";

        // Act
        PRHeader.Delete(true);

        // Assert
        if PRHeader.Get(PRNo) then
            Error('PR %1 in Rejected status should have been deleted.', PRNo);
    end;

    [Test]
    procedure Delete_CancelledStatus_Succeeds()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRNo: Code[20];
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Cancelled);
        PRNo := PRHeader."PR No.";

        // Act
        PRHeader.Delete(true);

        // Assert
        if PRHeader.Get(PRNo) then
            Error('PR %1 in Cancelled status should have been deleted.', PRNo);
    end;

    // -----------------------------------------------------------------------
    // IsEditable
    // -----------------------------------------------------------------------

    [Test]
    procedure IsEditable_Draft_ReturnsTrue()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');   // Status = Draft

        if not PRHeader.IsEditable() then
            Error('IsEditable should return true for Draft status.');
    end;

    [Test]
    procedure IsEditable_Rejected_ReturnsTrue()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Rejected);

        if not PRHeader.IsEditable() then
            Error('IsEditable should return true for Rejected status.');
    end;

    [Test]
    procedure IsEditable_PendingApproval_ReturnsFalse()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::"Pending Approval");

        if PRHeader.IsEditable() then
            Error('IsEditable should return false for Pending Approval status.');
    end;

    [Test]
    procedure IsEditable_Approved_ReturnsFalse()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        if PRHeader.IsEditable() then
            Error('IsEditable should return false for Approved status.');
    end;

    [Test]
    procedure IsEditable_Converted_ReturnsFalse()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Converted);

        if PRHeader.IsEditable() then
            Error('IsEditable should return false for Converted status.');
    end;

    [Test]
    procedure IsEditable_Cancelled_ReturnsFalse()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Cancelled);

        if PRHeader.IsEditable() then
            Error('IsEditable should return false for Cancelled status.');
    end;

    // -----------------------------------------------------------------------
    // Header OnValidate — Preferred Vendor Name auto-populate
    // -----------------------------------------------------------------------

    [Test]
    procedure ValidatePreferredVendorNo_PopulatesVendorName()
    var
        Vendor: Record Vendor;
        PRHeader: Record "PR Purchase Requisition Header";
        VendorNo: Code[20];
    begin
        // Arrange
        VendorNo := PRTestLib.GetAnyVendorNo();
        Vendor.Get(VendorNo);
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Act
        PRHeader.Validate("Preferred Vendor No.", VendorNo);
        PRHeader.Modify();

        // Assert
        if PRHeader."Preferred Vendor Name" <> Vendor.Name then
            Error('Expected Preferred Vendor Name = %1. Got: %2', Vendor.Name, PRHeader."Preferred Vendor Name");
    end;

    [Test]
    procedure ValidatePreferredVendorNo_Blank_ClearsVendorName()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        VendorNo: Code[20];
    begin
        // Arrange — populate vendor name first
        VendorNo := PRTestLib.GetAnyVendorNo();
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader.Validate("Preferred Vendor No.", VendorNo);
        PRHeader.Modify();

        // Act — clear the vendor no.
        PRHeader.Validate("Preferred Vendor No.", '');
        PRHeader.Modify();

        // Assert
        if PRHeader."Preferred Vendor Name" <> '' then
            Error('Preferred Vendor Name should be cleared when Vendor No. is blank. Got: %1', PRHeader."Preferred Vendor Name");
    end;

    // -----------------------------------------------------------------------
    // Header OnValidate — dimension propagation to lines
    // -----------------------------------------------------------------------

    [Test]
    procedure ValidateDeptCode_PropagatesExistingLines()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — ensure the target dimension value exists; create header + two lines
        PRTestLib.EnsureDimensionValue(1, 'TDEPT-NEW');
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 20000, "PR Line Type"::"G/L Account", '', 1, 200);

        // Act — validate triggers PropagateHeaderDimensionToLines(1, ...)
        PRHeader.Validate("Department Code", 'TDEPT-NEW');
        PRHeader.Modify();

        // Assert — all lines updated
        PRLine.SetRange("PR No.", PRHeader."PR No.");
        PRLine.FindSet();
        repeat
            if PRLine."Shortcut Dimension 1 Code" <> 'TDEPT-NEW' then
                Error('Expected Shortcut Dimension 1 = TDEPT-NEW on line %1. Got: %2',
                    PRLine."Line No.", PRLine."Shortcut Dimension 1 Code");
        until PRLine.Next() = 0;
    end;

    [Test]
    procedure ValidateCostCentre_PropagatesExistingLines()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — ensure the target dimension value exists; create header + two lines
        PRTestLib.EnsureDimensionValue(2, 'TCC-NEW');
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 20000, "PR Line Type"::"G/L Account", '', 1, 200);

        // Act — validate triggers PropagateHeaderDimensionToLines(2, ...)
        PRHeader.Validate("Cost Centre", 'TCC-NEW');
        PRHeader.Modify();

        // Assert — all lines updated
        PRLine.SetRange("PR No.", PRHeader."PR No.");
        PRLine.FindSet();
        repeat
            if PRLine."Shortcut Dimension 2 Code" <> 'TCC-NEW' then
                Error('Expected Shortcut Dimension 2 = TCC-NEW on line %1. Got: %2',
                    PRLine."Line No.", PRLine."Shortcut Dimension 2 Code");
        until PRLine.Next() = 0;
    end;

    // -----------------------------------------------------------------------
    // Total Amount (LCY) FlowField
    // -----------------------------------------------------------------------

    [Test]
    procedure TotalAmountLCY_SumsAllLines()
    var
        PRHeader: Record "PR Purchase Requisition Header";
    begin
        // Arrange — two lines: 2 x 100 = 200 and 3 x 50 = 150 → total 350
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 2, 100);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 20000, "PR Line Type"::"G/L Account", '', 3, 50);

        // Act
        PRHeader.CalcFields("Total Amount (LCY)");

        // Assert
        if PRHeader."Total Amount (LCY)" <> 350 then
            Error('Expected Total Amount (LCY) = 350. Got: %1', PRHeader."Total Amount (LCY)");
    end;

    // -----------------------------------------------------------------------
    // PR Line — amount calculation and dimension inheritance
    // -----------------------------------------------------------------------

    [Test]
    procedure LineAmountCalc_TriggeredByQtyChange()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — set unit cost first, then validate quantity
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::"G/L Account";
        PRLine.Description := 'Qty Calc Test';
        PRLine."Unit Cost (LCY)" := 50;
        PRLine.Validate(Quantity, 3);
        PRLine.Insert(true);

        // Assert — CalcLineAmount triggered by Validate(Quantity, ...)
        if PRLine."Line Amount (LCY)" <> 150 then
            Error('Expected Line Amount = 150 (3 x 50). Got: %1', PRLine."Line Amount (LCY)");
    end;

    [Test]
    procedure LineAmountCalc_IsQtyTimesUnitCost()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::"G/L Account";
        PRLine.Description := 'Calc Test';
        PRLine.Quantity := 4;
        PRLine.Validate("Unit Cost (LCY)", 125);
        PRLine.Insert(true);

        // Assert — CalcLineAmount is triggered by Validate("Unit Cost (LCY)", ...)
        if PRLine."Line Amount (LCY)" <> 500 then
            Error('Expected Line Amount = 500 (4 x 125). Got: %1', PRLine."Line Amount (LCY)");
    end;

    [Test]
    procedure LineInsert_InheritsHeaderDepartmentCode()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — header has a department code
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'SALES');

        // Act — insert a line; OnInsert should copy the dimension
        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::"G/L Account";
        PRLine.Description := 'Dimension test';
        PRLine.Quantity := 1;
        PRLine.Insert(true);

        // Assert
        if PRLine."Shortcut Dimension 1 Code" <> 'SALES' then
            Error('Expected Shortcut Dimension 1 = SALES. Got: %1', PRLine."Shortcut Dimension 1 Code");
    end;

    [Test]
    procedure LineInsert_InheritsExpectedReceiptDateFromHeader()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
        ExpectedDate: Date;
    begin
        // Arrange
        ExpectedDate := CalcDate('<+45D>', Today());
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Required By Date" := ExpectedDate;
        PRHeader.Modify();

        // Act
        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::"G/L Account";
        PRLine.Description := 'Date test';
        PRLine.Quantity := 1;
        PRLine.Insert(true);

        // Assert — OnInsert sets Expected Receipt Date from header Required By Date
        if PRLine."Expected Receipt Date" <> ExpectedDate then
            Error('Expected Receipt Date should be %1. Got: %2', ExpectedDate, PRLine."Expected Receipt Date");
    end;

    // -----------------------------------------------------------------------
    // Fixtures
    // -----------------------------------------------------------------------
    var
        PRTestLib: Codeunit "PR Test Library";
}
