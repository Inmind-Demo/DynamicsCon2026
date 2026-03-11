codeunit 50001 "PR to PO Conversion"
{
    /// <summary>
    /// Converts an Approved Purchase Requisition into a Purchase Order.
    /// Maps all header and line fields per the specification.
    /// </summary>
    procedure CreatePurchaseOrder(var PRHeader: Record "PR Purchase Requisition Header")
    var
        PurchaseHeader: Record "Purchase Header";
        PRLine: Record "PR Purchase Requisition Line";
        PRNotificationMgt: Codeunit "PR Notification Management";
        VendorNo: Code[20];
        WrongStatusErr: Label 'Purchase Requisition %1 must have status Approved before it can be converted to a Purchase Order.', Comment = '%1=PR No.';
        NoLinesErr: Label 'Purchase Requisition %1 has no lines and cannot be converted.', Comment = '%1=PR No.';
    begin
        if PRHeader.Status <> PRHeader.Status::Approved then
            Error(WrongStatusErr, PRHeader."PR No.");

        PRLine.SetRange("PR No.", PRHeader."PR No.");
        if PRLine.IsEmpty() then
            Error(NoLinesErr, PRHeader."PR No.");

        VendorNo := ResolveVendor(PRHeader);

        CreatePurchaseHeader(PRHeader, PurchaseHeader, VendorNo);
        CreatePurchaseLines(PRHeader, PurchaseHeader);

        PRHeader."Created PO No." := PurchaseHeader."No.";
        PRHeader.Status := PRHeader.Status::Converted;
        PRHeader.Modify(true);

        PRNotificationMgt.NotifyConvertedToPO(PRHeader);

        Message(POCreatedMsg, PurchaseHeader."No.");
    end;

    local procedure ResolveVendor(PRHeader: Record "PR Purchase Requisition Header"): Code[20]
    var
        PRSetup: Record "PR Purchase Requisition Setup";
        Vendor: Record Vendor;
        NoVendorErr: Label 'Purchase Requisition %1 has no Preferred Vendor. Please set a vendor before converting to a Purchase Order.', Comment = '%1=PR No.';
    begin
        if PRHeader."Preferred Vendor No." <> '' then
            exit(PRHeader."Preferred Vendor No.");

        PRSetup.GetRecordOnce();

        if PRSetup."Allow Vendor Chg on Conversion" then
            if Page.RunModal(Page::"Vendor List", Vendor) = Action::LookupOK then
                exit(Vendor."No.")
            else
                Error('');

        Error(NoVendorErr, PRHeader."PR No.");
    end;

    local procedure CreatePurchaseHeader(PRHeader: Record "PR Purchase Requisition Header"; var PurchaseHeader: Record "Purchase Header"; VendorNo: Code[20])
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        if PRHeader."Currency Code" <> '' then
            PurchaseHeader.Validate("Currency Code", PRHeader."Currency Code");
        PurchaseHeader.Validate("Expected Receipt Date", PRHeader."Required By Date");
        PurchaseHeader.Validate("Shortcut Dimension 1 Code", PRHeader."Department Code");
        PurchaseHeader.Validate("Shortcut Dimension 2 Code", PRHeader."Cost Centre");
        PurchaseHeader."Your Reference" := PRHeader."PR No.";
        PurchaseHeader.Modify(true);
    end;

    local procedure CreatePurchaseLines(PRHeader: Record "PR Purchase Requisition Header"; PurchaseHeader: Record "Purchase Header")
    var
        PRLine: Record "PR Purchase Requisition Line";
        PurchaseLine: Record "Purchase Line";
    begin
        PRLine.SetRange("PR No.", PRHeader."PR No.");
        if not PRLine.FindSet() then
            exit;

        repeat
            if PRLine.Type <> PRLine.Type::Blank then begin
                PurchaseLine.Init();
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := PRLine."Line No.";
                PurchaseLine.Insert(true);

                PurchaseLine.Validate(Type, ConvertLineType(PRLine.Type));
                if PRLine."No." <> '' then
                    PurchaseLine.Validate("No.", PRLine."No.");
                if PRLine.Description <> '' then
                    PurchaseLine.Description := PRLine.Description;
                PurchaseLine.Validate(Quantity, PRLine.Quantity);
                if PRLine."Unit of Measure Code" <> '' then
                    PurchaseLine.Validate("Unit of Measure Code", PRLine."Unit of Measure Code");
                PurchaseLine.Validate("Direct Unit Cost", PRLine."Unit Cost (LCY)");
                if PRLine."Location Code" <> '' then
                    PurchaseLine.Validate("Location Code", PRLine."Location Code");
                if PRLine."Expected Receipt Date" <> 0D then
                    PurchaseLine.Validate("Expected Receipt Date", PRLine."Expected Receipt Date");
                PurchaseLine.Validate("Shortcut Dimension 1 Code", PRLine."Shortcut Dimension 1 Code");
                PurchaseLine.Validate("Shortcut Dimension 2 Code", PRLine."Shortcut Dimension 2 Code");
                PurchaseLine.Modify(true);
            end;
        until PRLine.Next() = 0;
    end;

    local procedure ConvertLineType(PRLineType: Enum "PR Line Type"): Enum "Purchase Line Type"
    begin
        case PRLineType of
            PRLineType::Item:
                exit("Purchase Line Type"::Item);
            PRLineType::"G/L Account":
                exit("Purchase Line Type"::"G/L Account");
            PRLineType::Resource:
                exit("Purchase Line Type"::Resource);
            PRLineType::"Fixed Asset":
                exit("Purchase Line Type"::"Fixed Asset");
            else
                exit("Purchase Line Type"::" ");
        end;
    end;

    var
        POCreatedMsg: Label 'Purchase Order %1 has been created successfully.', Comment = '%1=PO No.';
}
