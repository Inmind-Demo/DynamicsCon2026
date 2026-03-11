codeunit 50050 "PR Test Library"
{
    /// <summary>
    /// Creates a No. Series (code 'PR-TST') and inserts / updates the PR Setup record.
    /// Email Notifications and Allow Vendor Change are intentionally left false to
    /// avoid side-effects during tests.
    /// </summary>
    procedure CreateSetup(DefaultApproverID: Code[50])
    var
        NoSeriesRec: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        PRSetup: Record "PR Purchase Requisition Setup";
    begin
        if not NoSeriesRec.Get('PR-TST') then begin
            NoSeriesRec.Init();
            NoSeriesRec.Code := 'PR-TST';
            NoSeriesRec.Description := 'PR Test No. Series';
            NoSeriesRec."Default Nos." := true;
            NoSeriesRec."Manual Nos." := true;
            NoSeriesRec.Insert();

            NoSeriesLine.Init();
            NoSeriesLine."Series Code" := 'PR-TST';
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting No." := 'PRTEST00001';
            NoSeriesLine."Ending No." := 'PRTEST99999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert();
        end;

        PRSetup.GetRecordOnce();
        PRSetup."PR No. Series" := 'PR-TST';
        PRSetup."Default Approver ID" := DefaultApproverID;
        PRSetup."Email Notifications" := false;
        PRSetup."Allow Vendor Chg on Conversion" := false;
        PRSetup.Modify();
    end;

    /// <summary>
    /// Inserts a PR header with all mandatory fields populated.
    /// Department Code is assigned directly (no Validate) to avoid
    /// requiring a matching Dimension Value in the test environment.
    /// </summary>
    procedure CreatePRHeader(var PRHeader: Record "PR Purchase Requisition Header"; DeptCode: Code[20])
    begin
        PRHeader.Init();
        PRHeader.Insert(true);  // OnInsert assigns PR No., Request Date, Requested By, Status = Draft
        PRHeader.Description := 'Test Purchase Requisition';
        PRHeader."Required By Date" := CalcDate('<+30D>', Today());
        PRHeader."Department Code" := DeptCode;
        PRHeader.Modify();
    end;

    /// <summary>
    /// Inserts a PR line with the specified type, item/account No., quantity, and unit cost.
    /// Line Amount (LCY) is calculated as Qty x Unit Cost.
    /// </summary>
    procedure CreatePRLine(
        PRNo: Code[20];
        LineNo: Integer;
        LineType: Enum "PR Line Type";
        ItemNo: Code[20];
        Qty: Decimal;
        UnitCost: Decimal)
    var
        PRLine: Record "PR Purchase Requisition Line";
    begin
        PRLine.Init();
        PRLine."PR No." := PRNo;
        PRLine."Line No." := LineNo;
        PRLine.Type := LineType;
        PRLine."No." := ItemNo;
        PRLine.Description := 'Test Line ' + Format(LineNo);
        PRLine.Quantity := Qty;
        PRLine."Unit Cost (LCY)" := UnitCost;
        PRLine."Line Amount (LCY)" := Qty * UnitCost;
        PRLine.Insert(true);
    end;

    /// <summary>
    /// Inserts a department-level approver mapping.
    /// Department Code is assigned directly to avoid requiring a live Dimension Value.
    /// </summary>
    procedure CreateDeptApproverSetup(DeptCode: Code[20]; ApproverID: Code[50])
    var
        DeptApprover: Record "PR Dept. Approver Setup";
    begin
        if DeptApprover.Get(DeptCode) then begin
            DeptApprover."Approver User ID" := ApproverID;
            DeptApprover.Modify();
        end else begin
            DeptApprover.Init();
            DeptApprover."Department Code" := DeptCode;
            DeptApprover."Approver User ID" := ApproverID;
            DeptApprover.Insert();
        end;
    end;

    /// <summary>
    /// Directly sets the PR Status field and calls Modify — bypasses all business-rule
    /// checks so test arrange-steps can place a PR into any state without going through
    /// the full workflow.
    /// </summary>
    procedure SetPRStatus(var PRHeader: Record "PR Purchase Requisition Header"; NewStatus: Enum "PR Status")
    begin
        PRHeader.Status := NewStatus;
        PRHeader.Modify();
    end;

    /// <summary>
    /// Returns the No. of the first unblocked vendor found in the database.
    /// Requires at least one vendor to exist (e.g. Cronus demo data).
    /// </summary>
    procedure GetAnyVendorNo(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetRange(Blocked, Vendor.Blocked::" ");
        if Vendor.FindFirst() then
            exit(Vendor."No.");
        Error('No unblocked vendor found. Load demo data before running this test.');
    end;

    /// <summary>
    /// Returns the No. of the first G/L Account that is a Posting account with
    /// Direct Posting enabled.  Used when building PR lines of type G/L Account.
    /// </summary>
    procedure GetAnyDirectPostingGLAccountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        if GLAccount.FindFirst() then
            exit(GLAccount."No.");
        Error('No direct-posting G/L Account found. Load demo data before running this test.');
    end;

    /// <summary>
    /// Ensures a Dimension Value record exists for the specified Global Dimension
    /// number (1 or 2) and code.  Inserts it if absent so Validate calls on
    /// "Department Code" / "Cost Centre" header fields do not fail on the
    /// TableRelation check.
    /// </summary>
    procedure EnsureDimensionValue(GlobalDimNo: Integer; DimCode: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimValue: Record "Dimension Value";
        DimensionCode: Code[20];
    begin
        GeneralLedgerSetup.Get();
        case GlobalDimNo of
            1:
                DimensionCode := GeneralLedgerSetup."Global Dimension 1 Code";
            2:
                DimensionCode := GeneralLedgerSetup."Global Dimension 2 Code";
            else
                Error('EnsureDimensionValue only supports Global Dimension 1 or 2. Got: %1', GlobalDimNo);
        end;
        if DimensionCode = '' then
            Error('Global Dimension %1 is not configured in G/L Setup.', GlobalDimNo);
        if not DimValue.Get(DimensionCode, DimCode) then begin
            DimValue.Init();
            DimValue."Dimension Code" := DimensionCode;
            DimValue.Code := DimCode;
            DimValue.Name := DimCode;
            DimValue."Dimension Value Type" := DimValue."Dimension Value Type"::Standard;
            DimValue."Global Dimension No." := GlobalDimNo;
            DimValue.Insert();
        end;
    end;
}
