codeunit 50054 "PR Line No. Field Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // -----------------------------------------------------------------------
    // OnValidate("No.") — auto-populate Description and Unit of Measure
    // -----------------------------------------------------------------------

    [Test]
    procedure ValidateNo_ItemType_PopulatesDescriptionAndUoM()
    var
        Item: Record Item;
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — find a real item from demo data
        Item.SetFilter("Base Unit of Measure", '<>%1', '');
        if not Item.FindFirst() then
            Error('No item with a Base Unit of Measure found. Load demo data before running this test.');

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::Item;
        PRLine.Insert(true);

        // Act — Validate triggers OnValidate → LookupItem()
        PRLine.Validate("No.", Item."No.");
        PRLine.Modify(true);

        // Assert
        if PRLine.Description <> Item.Description then
            Error('Description should be auto-populated from Item. Expected: %1  Got: %2',
                Item.Description, PRLine.Description);
        if PRLine."Unit of Measure Code" <> Item."Base Unit of Measure" then
            Error('Unit of Measure Code should be auto-populated from Item. Expected: %1  Got: %2',
                Item."Base Unit of Measure", PRLine."Unit of Measure Code");
    end;

    [Test]
    procedure ValidateNo_GLAccountType_PopulatesDescription()
    var
        GLAccount: Record "G/L Account";
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — find a direct-posting G/L account
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        if not GLAccount.FindFirst() then
            Error('No direct-posting G/L Account found. Load demo data before running this test.');

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::"G/L Account";
        PRLine.Insert(true);

        // Act
        PRLine.Validate("No.", GLAccount."No.");
        PRLine.Modify(true);

        // Assert
        if PRLine.Description <> GLAccount.Name then
            Error('Description should be auto-populated from G/L Account Name. Expected: %1  Got: %2',
                GLAccount.Name, PRLine.Description);
    end;

    [Test]
    procedure ValidateType_Change_ClearsNoAndDescription()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — line with Type = Item and a No. already set
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::Item;
        PRLine."No." := 'SOMEITEM';
        PRLine.Description := 'Some description';
        PRLine."Unit of Measure Code" := 'PCS';
        PRLine.Insert(true);

        // Act — change Type; OnValidate for Type should clear No., Description, UoM
        PRLine.Validate(Type, "PR Line Type"::"G/L Account");
        PRLine.Modify(true);

        // Assert
        if PRLine."No." <> '' then
            Error('"No." should be cleared when Type changes. Got: %1', PRLine."No.");
        if PRLine.Description <> '' then
            Error('Description should be cleared when Type changes. Got: %1', PRLine.Description);
        if PRLine."Unit of Measure Code" <> '' then
            Error('"Unit of Measure Code" should be cleared when Type changes. Got: %1',
                PRLine."Unit of Measure Code");
    end;

    [Test]
    procedure ValidateNo_ResourceType_PopulatesDescriptionAndUoM()
    var
        Resource: Record Resource;
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — find a real resource from demo data
        Resource.SetFilter("Base Unit of Measure", '<>%1', '');
        if not Resource.FindFirst() then
            Error('No Resource with Base Unit of Measure found. Load demo data before running this test.');

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::Resource;
        PRLine.Insert(true);

        // Act
        PRLine.Validate("No.", Resource."No.");
        PRLine.Modify(true);

        // Assert
        if PRLine.Description <> Resource.Name then
            Error('Description should be auto-populated from Resource. Expected: %1  Got: %2',
                Resource.Name, PRLine.Description);
        if PRLine."Unit of Measure Code" <> Resource."Base Unit of Measure" then
            Error('Unit of Measure should be auto-populated from Resource. Expected: %1  Got: %2',
                Resource."Base Unit of Measure", PRLine."Unit of Measure Code");
    end;

    [Test]
    procedure ValidateNo_FixedAssetType_PopulatesDescription()
    var
        FixedAsset: Record "Fixed Asset";
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — find a real fixed asset from demo data
        if not FixedAsset.FindFirst() then
            Error('No Fixed Asset found. Load demo data before running this test.');

        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::"Fixed Asset";
        PRLine.Insert(true);

        // Act
        PRLine.Validate("No.", FixedAsset."No.");
        PRLine.Modify(true);

        // Assert
        if PRLine.Description <> FixedAsset.Description then
            Error('Description should be auto-populated from Fixed Asset. Expected: %1  Got: %2',
                FixedAsset.Description, PRLine.Description);
    end;

    [Test]
    procedure ValidateNo_BlankType_LeavesDescriptionUnchanged()
    var
        PRHeader: Record "PR Purchase Requisition Header";
        PRLine: Record "PR Purchase Requisition Line";
    begin
        // Arrange — Blank type line; setting No. should not error and should not
        // auto-populate anything (no LookupXxx branch is hit for Blank type)
        PRTestLib.CreateSetup('APR01');
        PRTestLib.CreatePRHeader(PRHeader, 'DEPT01');

        PRLine.Init();
        PRLine."PR No." := PRHeader."PR No.";
        PRLine."Line No." := 10000;
        PRLine.Type := "PR Line Type"::Blank;
        PRLine.Description := 'Free-text note';
        PRLine.Insert(true);

        // Act — Validate "No." on a Blank line; no lookup branch fires
        PRLine.Validate("No.", '');
        PRLine.Modify(true);

        // Assert — description unchanged
        if PRLine.Description <> 'Free-text note' then
            Error('Description should remain unchanged for Blank type. Got: %1', PRLine.Description);
    end;

    // -----------------------------------------------------------------------
    // Fixtures
    // -----------------------------------------------------------------------
    var
        PRTestLib: Codeunit "PR Test Library";
}
