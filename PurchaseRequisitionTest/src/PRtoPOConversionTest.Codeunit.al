codeunit 50052 "PR to PO Conversion Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // -----------------------------------------------------------------------
    // CreatePurchaseOrder — validation errors
    // -----------------------------------------------------------------------

    [Test]
    procedure CreatePO_WrongStatus_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRtoPOConversion: Codeunit "PR to PO Conversion";
    begin
        // Arrange — PR is still Draft, not Approved
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        // Act & Assert
        asserterror PRtoPOConversion.CreatePurchaseOrder(PRHeader);
        if StrPos(GetLastErrorText(), 'Approved') = 0 then
            Error('Expected status-Approved error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure CreatePO_NoLines_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRtoPOConversion: Codeunit "PR to PO Conversion";
    begin
        // Arrange — Approved PR with zero lines
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRHeader."Preferred Vendor No." := PRTestLib.GetAnyVendorNo();
        PRHeader.Modify();
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        // Act & Assert
        asserterror PRtoPOConversion.CreatePurchaseOrder(PRHeader);
        if StrPos(GetLastErrorText(), 'no lines') = 0 then
            Error('Expected "no lines" error. Got: %1', GetLastErrorText());
    end;

    [Test]
    procedure CreatePO_NoVendor_AllowChangeDisabled_Error()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRtoPOConversion: Codeunit "PR to PO Conversion";
    begin
        // Arrange — Approved PR, no vendor, no allow-change flag
        PRTestLib.CreateSetup('APR01');       // Allow Vendor Chg on Conversion = false
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');
        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", '', 1, 100);
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);
        // "Preferred Vendor No." left blank

        // Act & Assert
        asserterror PRtoPOConversion.CreatePurchaseOrder(PRHeader);
        if StrPos(GetLastErrorText(), 'Preferred Vendor') = 0 then
            Error('Expected missing vendor error. Got: %1', GetLastErrorText());
    end;

    // -----------------------------------------------------------------------
    // CreatePurchaseOrder — happy path
    // -----------------------------------------------------------------------

    [Test]
    [HandlerFunctions('POCreatedMessageHandler')]
    procedure CreatePO_WithVendorAndGLLine_CreatesPO()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PRtoPOConversion: Codeunit "PR to PO Conversion";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
        CreatedPONo: Code[20];
    begin
        // Arrange
        VendorNo := PRTestLib.GetAnyVendorNo();
        GLAccountNo := PRTestLib.GetAnyDirectPostingGLAccountNo();

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, '');
        PRHeader."Preferred Vendor No." := VendorNo;
        PRHeader."Required By Date" := CalcDate('<+30D>', Today());
        PRHeader.Modify();

        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", GLAccountNo, 5, 150);
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        // Act
        PRtoPOConversion.CreatePurchaseOrder(PRHeader);

        // Assert — PR is now Converted and carries the PO No.
        PRHeader.Find();
        if PRHeader.Status <> PRHeader.Status::Converted then
            Error('Expected Status = Converted. Got: %1', PRHeader.Status);
        if PRHeader."Created PO No." = '' then
            Error('"Created PO No." should be filled after conversion.');

        // Assert — Purchase Header exists with correct vendor
        CreatedPONo := PRHeader."Created PO No.";
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, CreatedPONo) then
            Error('Purchase Order %1 not found after conversion.', CreatedPONo);
        if PurchaseHeader."Buy-from Vendor No." <> VendorNo then
            Error('PO vendor mismatch. Expected %1 got %2.', VendorNo, PurchaseHeader."Buy-from Vendor No.");
        if PurchaseHeader."Your Reference" <> PRHeader."PR No." then
            Error('PO "Your Reference" should carry the PR No.');

        // Assert — at least one purchase line was created (non-Blank type)
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", CreatedPONo);
        if PurchaseLine.IsEmpty() then
            Error('No purchase lines were created for PO %1.', CreatedPONo);

        // Assert — quantity and unit cost transferred correctly
        PurchaseLine.FindFirst();
        if PurchaseLine.Quantity <> 5 then
            Error('Expected PO line Quantity = 5. Got: %1', PurchaseLine.Quantity);
        if PurchaseLine."Direct Unit Cost" <> 150 then
            Error('Expected PO line Direct Unit Cost = 150. Got: %1', PurchaseLine."Direct Unit Cost");
    end;

    [Test]
    [HandlerFunctions('POCreatedMessageHandler')]
    procedure CreatePO_BlankTypeLinesSkipped()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PurchaseLine: Record "Purchase Line";
        PRtoPOConversion: Codeunit "PR to PO Conversion";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
    begin
        // Arrange — mix of one G/L Account line and one Blank line
        VendorNo := PRTestLib.GetAnyVendorNo();
        GLAccountNo := PRTestLib.GetAnyDirectPostingGLAccountNo();

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, '');
        PRHeader."Preferred Vendor No." := VendorNo;
        PRHeader.Modify();

        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", GLAccountNo, 2, 50);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 20000, "PR Line Type"::Blank, '', 0, 0);   // Blank → skipped
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        // Act
        PRtoPOConversion.CreatePurchaseOrder(PRHeader);

        // Assert — exactly 1 PO line (the Blank line was not converted)
        PRHeader.Find();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PRHeader."Created PO No.");
        if PurchaseLine.Count() <> 1 then
            Error('Expected exactly 1 PO line (Blank skipped). Found: %1', PurchaseLine.Count());
    end;

    [Test]
    [HandlerFunctions('POCreatedMessageHandler')]
    procedure CreatePO_MultipleGLLines_AllConvertedToPOLines()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PurchaseLine: Record "Purchase Line";
        PRtoPOConversion: Codeunit "PR to PO Conversion";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
    begin
        // Arrange — three G/L Account lines; all must appear on the PO
        VendorNo := PRTestLib.GetAnyVendorNo();
        GLAccountNo := PRTestLib.GetAnyDirectPostingGLAccountNo();

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, '');
        PRHeader."Preferred Vendor No." := VendorNo;
        PRHeader.Modify();

        PRTestLib.CreatePRLine(PRHeader."PR No.", 10000, "PR Line Type"::"G/L Account", GLAccountNo, 1, 100);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 20000, "PR Line Type"::"G/L Account", GLAccountNo, 2, 200);
        PRTestLib.CreatePRLine(PRHeader."PR No.", 30000, "PR Line Type"::"G/L Account", GLAccountNo, 3, 300);
        PRTestLib.SetPRStatus(PRHeader, PRHeader.Status::Approved);

        // Act
        PRtoPOConversion.CreatePurchaseOrder(PRHeader);

        // Assert — all three lines converted (no Blank lines to skip)
        PRHeader.Find();
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", PRHeader."Created PO No.");
        if PurchaseLine.Count() <> 3 then
            Error('Expected 3 PO lines. Found: %1', PurchaseLine.Count());
    end;

    // -----------------------------------------------------------------------
    // Handlers
    // -----------------------------------------------------------------------

    [MessageHandler]
    procedure POCreatedMessageHandler(Msg: Text[1024])
    begin
        // Consume the "Purchase Order %1 has been created successfully." message.
    end;

    // -----------------------------------------------------------------------
    // Fixtures
    // -----------------------------------------------------------------------
    var
        PRTestLib: Codeunit "PR Test Library";
}
