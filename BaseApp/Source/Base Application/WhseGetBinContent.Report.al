report 7391 "Whse. Get Bin Content"
{
    Caption = 'Whse. Get Bin Content';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Bin Content"; "Bin Content")
        {
            RequestFilterFields = "Location Code", "Zone Code", "Bin Code", "Item No.", "Variant Code", "Unit of Measure Code";

            trigger OnAfterGetRecord()
            var
                DummyItemTrackingSetup: Record "Item Tracking Setup";
                ShouldSkipReportForQty: Boolean;
            begin
                if BinType.Code <> "Bin Type Code" then
                    BinType.Get("Bin Type Code");
                if BinType.Receive and not "Cross-Dock Bin" then
                    CurrReport.Skip();

                QtyToEmptyBase := GetQtyToEmptyBase(DummyItemTrackingSetup);
                ShouldSkipReportForQty := QtyToEmptyBase <= 0;
                OnBinContenOnAfterGetRecordOnAfterCalcShouldSkipReportForQty("Bin Content", ShouldSkipReportForQty);
                if ShouldSkipReportForQty then
                    CurrReport.Skip();

                case DestinationType2 of
                    DestinationType2::MovementWorksheet:
                        InsertWhseWorksheetLine("Bin Content");
                    DestinationType2::WhseInternalPutawayHeader:
                        InsertWhseInternalPutawayLine("Bin Content");
                    DestinationType2::ItemJournalLine:
                        InsertItemJournalLine("Bin Content");
                    DestinationType2::TransferHeader:
                        begin
                            TransferHeader.TestField("Transfer-from Code", "Location Code");
                            InsertTransferLine("Bin Content");
                        end;
                    DestinationType2::InternalMovementHeader:
                        InsertIntMovementLine("Bin Content");
                end;

                GetItemTracking("Bin Content");
            end;

            trigger OnPostDataItem()
            begin
                OnAfterBinContentOnPostDataItem(ItemJournalLine, TransferHeader, InternalMovementHeader, DestinationType2);
            end;

            trigger OnPreDataItem()
            begin
                if not ReportInitialized then
                    Error(Text001);

                Location.Init();
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Posting Date';
                        Editable = PostingDateEditable;
                        ToolTip = 'Specifies the posting date that will appear on the journal lines generated by the report.';
                    }
                    field(DocNo; DocNo)
                    {
                        ApplicationArea = Warehouse;
                        Caption = 'Document No.';
                        Editable = DocNoEditable;
                        ToolTip = 'Specifies the document number that will appear on the journal lines generated by the report.';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            DocNoEditable := true;
            PostingDateEditable := true;
        end;

        trigger OnOpenPage()
        begin
            case DestinationType2 of
                DestinationType2::ItemJournalLine:
                    begin
                        PostingDateEditable := true;
                        DocNoEditable := true;
                    end;
                else begin
                        PostingDateEditable := false;
                        DocNoEditable := false;
                    end;
            end;
        end;
    }

    labels
    {
    }

    var
        WhseWorksheetLine: Record "Whse. Worksheet Line";
        WhseInternalPutawayLine: Record "Whse. Internal Put-away Line";
        ItemJournalLine: Record "Item Journal Line";
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        BinType: Record "Bin Type";
        Location: Record Location;
        InternalMovementHeader: Record "Internal Movement Header";
        InternalMovementLine: Record "Internal Movement Line";
        UOMMgt: Codeunit "Unit of Measure Management";
        QtyToEmptyBase: Decimal;
        ReportInitialized: Boolean;
        Text001: Label 'Report must be initialized.';
        DestinationType2: Option MovementWorksheet,WhseInternalPutawayHeader,ItemJournalLine,TransferHeader,InternalMovementHeader;
        PostingDate: Date;
        DocNo: Code[20];
        [InDataSet]
        PostingDateEditable: Boolean;
        [InDataSet]
        DocNoEditable: Boolean;

    procedure InitializeReport(WhseWorksheetLine2: Record "Whse. Worksheet Line"; WhseInternalPutawayHeader2: Record "Whse. Internal Put-away Header"; DestinationType: Option)
    begin
        DestinationType2 := DestinationType;
        case DestinationType2 of
            DestinationType2::MovementWorksheet:
                begin
                    WhseWorksheetLine := WhseWorksheetLine2;
                    WhseWorksheetLine.SetCurrentKey("Worksheet Template Name", Name, "Location Code", "Line No.");
                    WhseWorksheetLine.SetRange("Worksheet Template Name", WhseWorksheetLine."Worksheet Template Name");
                    WhseWorksheetLine.SetRange(Name, WhseWorksheetLine.Name);
                    WhseWorksheetLine.SetRange("Location Code", WhseWorksheetLine."Location Code");
                    if WhseWorksheetLine.FindLast() then;
                end;
            DestinationType2::WhseInternalPutawayHeader:
                begin
                    WhseInternalPutawayLine."No." := WhseInternalPutawayHeader2."No.";
                    WhseInternalPutawayLine.SetRange("No.", WhseInternalPutawayLine."No.");
                    if WhseInternalPutawayLine.FindLast() then;
                end;
        end;
        ReportInitialized := true;
    end;

    procedure InitializeItemJournalLine(ItemJournalLine2: Record "Item Journal Line")
    begin
        ItemJournalLine := ItemJournalLine2;
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalLine2."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalLine2."Journal Batch Name");
        if ItemJournalLine.FindLast then;

        PostingDate := ItemJournalLine2."Posting Date";
        DocNo := ItemJournalLine2."Document No.";

        DestinationType2 := DestinationType2::ItemJournalLine;
        ReportInitialized := true;
    end;

    procedure InitializeTransferHeader(TransferHeader2: Record "Transfer Header")
    begin
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", TransferHeader2."No.");
        if not TransferLine.FindLast then begin
            TransferLine.Init();
            TransferLine."Document No." := TransferHeader2."No.";
        end;

        TransferHeader := TransferHeader2;

        DestinationType2 := DestinationType2::TransferHeader;
        ReportInitialized := true;
    end;

    procedure InitializeInternalMovement(InternalMovementHeader2: Record "Internal Movement Header")
    begin
        InternalMovementLine.Reset();
        InternalMovementLine.SetRange("No.", InternalMovementHeader2."No.");
        if not InternalMovementLine.FindLast then begin
            InternalMovementLine.Init();
            InternalMovementLine."No." := InternalMovementHeader2."No.";
        end;
        InternalMovementHeader := InternalMovementHeader2;

        DestinationType2 := DestinationType2::InternalMovementHeader;
        ReportInitialized := true;
    end;

#if not CLEAN19
    [Obsolete('This procedure should be local.', '19.0')]
    procedure InsertWWL()
    begin
        InsertWhseWorksheetLine("Bin Content");
    end;
#endif

    local procedure InsertWhseWorksheetLine(BinContent: Record "Bin Content")
    begin
        with WhseWorksheetLine do begin
            Init();
            "Line No." := "Line No." + 10000;
            Validate("Location Code", BinContent."Location Code");
            Validate("Item No.", BinContent."Item No.");
            Validate("Variant Code", BinContent."Variant Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate("From Bin Code", BinContent."Bin Code");
            "From Zone Code" := BinContent."Zone Code";
            Validate("From Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate(Quantity, CalcQtyUOM(QtyToEmptyBase, "Qty. per From Unit of Measure"));
            if QtyToEmptyBase <> (Quantity * "Qty. per From Unit of Measure") then begin
                "Qty. (Base)" := QtyToEmptyBase;
                "Qty. Outstanding (Base)" := QtyToEmptyBase;
                "Qty. to Handle (Base)" := QtyToEmptyBase;
            end;
            "Whse. Document Type" := "Whse. Document Type"::"Whse. Mov.-Worksheet";
            "Whse. Document No." := Name;
            "Whse. Document Line No." := "Line No.";
            OnBeforeInsertWWLine(WhseWorksheetLine, BinContent);
            Insert();
        end;
    end;

#if not CLEAN19
    [Obsolete('This procedure should be local.', '19.0')]
    procedure InsertWIPL()
    begin
        InsertWhseInternalPutawayLine("Bin Content");
    end;
#endif

    local procedure InsertWhseInternalPutawayLine(BinContent: Record "Bin Content")
    begin
        with WhseInternalPutawayLine do begin
            Init();
            "Line No." := "Line No." + 10000;
            Validate("Location Code", BinContent."Location Code");
            Validate("Item No.", BinContent."Item No.");
            Validate("Variant Code", BinContent."Variant Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate("From Bin Code", BinContent."Bin Code");
            "From Zone Code" := BinContent."Zone Code";
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate(Quantity, CalcQtyUOM(QtyToEmptyBase, "Qty. per Unit of Measure"));
            if QtyToEmptyBase <> (Quantity * "Qty. per Unit of Measure") then begin
                "Qty. (Base)" := QtyToEmptyBase;
                "Qty. Outstanding (Base)" := QtyToEmptyBase;
            end;
            OnBeforeInsertWIPLine(WhseInternalPutawayLine, BinContent);
            Insert();
        end;
    end;

#if not CLEAN19
    [Obsolete('This procedure should be local.', '19.0')]
    procedure InsertItemJournalLine()
    begin
        InsertItemJournalLine("Bin Content");
    end;
#endif

    local procedure InsertItemJournalLine(BinContent: Record "Bin Content")
    var
        ItemJournalTempl: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        with ItemJournalLine do begin
            Init();
            "Line No." := "Line No." + 10000;
            Validate("Entry Type", "Entry Type"::Transfer);
            Validate("Item No.", BinContent."Item No.");
            Validate("Posting Date", PostingDate);
            Validate("Document No.", DocNo);
            Validate("Location Code", BinContent."Location Code");
            Validate("New Location Code", BinContent."Location Code");
            Validate("Variant Code", BinContent."Variant Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate("Bin Code", BinContent."Bin Code");
            Validate("New Bin Code", '');
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate(Quantity, CalcQtyUOM(QtyToEmptyBase, "Qty. per Unit of Measure"));
            ItemJournalTempl.Get("Journal Template Name");
            ItemJournalBatch.Get("Journal Template Name", "Journal Batch Name");
            "Source Code" := ItemJournalTempl."Source Code";
            "Posting No. Series" := ItemJournalBatch."Posting No. Series";
            OnInsertItemJournalLineOnBeforeInsert(ItemJournalLine, BinContent);
            Insert();
            OnAfterInsertItemJnlLine(ItemJournalLine, BinContent);
        end;
    end;

#if not CLEAN19
    [Obsolete('This procedure should be local.', '19.0')]
    procedure InsertTransferLine()
    begin
        InsertTransferLine("Bin Content");
    end;
#endif

    local procedure InsertTransferLine(BinContent: Record "Bin Content")
    begin
        with TransferLine do begin
            Init();
            "Line No." := "Line No." + 10000;
            Validate("Item No.", BinContent."Item No.");
            Validate("Variant Code", BinContent."Variant Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate("Transfer-from Bin Code", BinContent."Bin Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate(Quantity, CalcQtyUOM(QtyToEmptyBase, "Qty. per Unit of Measure"));
            OnBeforeInsertTransferLine(TransferLine, BinContent);
            Insert();
        end;
    end;

#if not CLEAN19
    [Obsolete('This procedure should be local.', '19.0')]
    procedure InsertIntMovementLine()
    begin
        InsertIntMovementLine("Bin Content");
    end;
#endif

    local procedure InsertIntMovementLine(BinContent: Record "Bin Content")
    begin
        with InternalMovementLine do begin
            Init();
            "Line No." := "Line No." + 10000;
            Validate("Location Code", BinContent."Location Code");
            Validate("Item No.", BinContent."Item No.");
            Validate("Variant Code", BinContent."Variant Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate("From Bin Code", BinContent."Bin Code");
            Validate("To Bin Code", InternalMovementHeader."To Bin Code");
            Validate("Unit of Measure Code", BinContent."Unit of Measure Code");
            Validate(Quantity, CalcQtyUOM(QtyToEmptyBase, "Qty. per Unit of Measure"));
            OnBeforeInsertInternalMovementLine(InternalMovementLine, BinContent);
            Insert();
        end;
    end;

#if not CLEAN19
    [Obsolete('Replaced by procedure GetTrackingData().', '19.0')]
    procedure GetSerialNoAndLotNo()
    begin
        GetItemTracking("Bin Content");
    end;
#endif

    local procedure GetItemTracking(BinContent: Record "Bin Content")
    var
        ItemTrackingSetup: Record "Item Tracking Setup";
        WarehouseEntry: Record "Warehouse Entry";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        ItemJnlLineReserve: Codeunit "Item Jnl. Line-Reserve";
        TransferLineReserve: Codeunit "Transfer Line-Reserve";
        Direction: Enum "Transfer Direction";
        TrackedQtyToEmptyBase: Decimal;
        TotalTrackedQtyBase: Decimal;
    begin
        Clear(ItemTrackingMgt);
        if not ItemTrackingMgt.GetWhseItemTrkgSetup(BinContent."Item No.") then
            exit;

        with WarehouseEntry do begin
            Reset();
            SetCurrentKey(
              "Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code",
              "Lot No.", "Serial No.", "Entry Type", Dedicated, "Package No.");
            SetRange("Item No.", BinContent."Item No.");
            SetRange("Bin Code", BinContent."Bin Code");
            SetRange("Location Code", BinContent."Location Code");
            SetRange("Variant Code", BinContent."Variant Code");
            SetRange("Unit of Measure Code", BinContent."Unit of Measure Code");
            if FindSet() then
                repeat
                    if TrackingExists() then begin
                        ItemTrackingSetup.CopyTrackingFromWhseEntry(WarehouseEntry);
                        SetTrackingFilterFromItemTrackingSetupIfNotBlank(ItemTrackingSetup);

                        TrackedQtyToEmptyBase := GetQtyToEmptyBase(ItemTrackingSetup);
                        TotalTrackedQtyBase += TrackedQtyToEmptyBase;

                        if TrackedQtyToEmptyBase > 0 then begin
                            GetLocation("Location Code", Location);
                            ItemTrackingMgt.GetWhseExpirationDate("Item No.", "Variant Code", Location, ItemTrackingSetup, "Expiration Date");

                            case DestinationType2 of
                                DestinationType2::MovementWorksheet:
                                    WhseWorksheetLine.SetItemTrackingLines(WarehouseEntry, TrackedQtyToEmptyBase);
                                DestinationType2::WhseInternalPutawayHeader:
                                    WhseInternalPutawayLine.SetItemTrackingLines(WarehouseEntry, TrackedQtyToEmptyBase);
                                DestinationType2::ItemJournalLine:
                                    TempTrackingSpecification.InitFromItemJnlLine(ItemJournalLine);
                                DestinationType2::TransferHeader:
                                    TempTrackingSpecification.InitFromTransLine(
                                      TransferLine, TransferLine."Shipment Date", Direction::Outbound);
                                DestinationType2::InternalMovementHeader:
                                    InternalMovementLine.SetItemTrackingLines(WarehouseEntry, TrackedQtyToEmptyBase);
                            end;
                        end;
                        Find('+');
                        ClearTrackingFilter();
                    end;
                    if DestinationType2 in [DestinationType2::ItemJournalLine, DestinationType2::TransferHeader] then
                        InsertTempTrackingSpecification(WarehouseEntry, TrackedQtyToEmptyBase, TempTrackingSpecification);
                until Next() = 0;

            if TotalTrackedQtyBase > QtyToEmptyBase then
                exit;

            case DestinationType2 of
                DestinationType2::ItemJournalLine:
                    ItemJnlLineReserve.RegisterBinContentItemTracking(ItemJournalLine, TempTrackingSpecification);
                DestinationType2::TransferHeader:
                    TransferLineReserve.RegisterBinContentItemTracking(TransferLine, TempTrackingSpecification);
            end;
        end;
    end;

    local procedure GetLocation(LocationCode: Code[10]; var Location: Record Location)
    begin
        if LocationCode = Location.Code then
            exit;

        if LocationCode = '' then
            Location.Init
        else
            Location.Get(LocationCode);
    end;

#if not CLEAN19
    [Obsolete('Replaced by local procedure InsertTempTrackingSpecification().', '19.0')]
    procedure InsertTempTrackingSpec(WarehouseEntry: Record "Warehouse Entry"; QtyOnBin: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        InsertTempTrackingSpecification(WarehouseEntry, QtyOnBin, TempTrackingSpecification);
    end;
#endif

    local procedure InsertTempTrackingSpecification(WarehouseEntry: Record "Warehouse Entry"; QtyOnBin: Decimal; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        with WarehouseEntry do begin
            TempTrackingSpecification.Init();
            TempTrackingSpecification."Item No." := "Item No.";
            TempTrackingSpecification.SetSkipSerialNoQtyValidation(true);
            TempTrackingSpecification.Validate("Serial No.", "Serial No.");
            TempTrackingSpecification.SetSkipSerialNoQtyValidation(false);
            TempTrackingSpecification."New Serial No." := "Serial No.";
            TempTrackingSpecification.Validate("Lot No.", "Lot No.");
            TempTrackingSpecification."New Lot No." := "Lot No.";
            OnInsertTempTrackingSpecOnAfterAssignTracking(TempTrackingSpecification, WarehouseEntry);
            TempTrackingSpecification."Quantity Handled (Base)" := 0;
            TempTrackingSpecification."Expiration Date" := "Expiration Date";
            TempTrackingSpecification."New Expiration Date" := "Expiration Date";
            TempTrackingSpecification.Validate("Quantity (Base)", QtyOnBin);
            TempTrackingSpecification."Entry No." += 1;
            TempTrackingSpecification.Insert();
            OnAfterInsertTempTrackingSpec(TempTrackingSpecification, WarehouseEntry);
        end;
    end;

    local procedure CalcQtyUOM(QtyBase: Decimal; QtyPerUOM: Decimal): Decimal
    begin
        if QtyPerUOM = 0 then
            exit(0);

        exit(Round(QtyBase / QtyPerUOM, UOMMgt.QtyRndPrecision));
    end;

    local procedure GetQtyToEmptyBase(ItemTrackingSetup: Record "Item Tracking Setup"): Decimal
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.Init();
        BinContent.Copy("Bin Content");
        BinContent.FilterGroup(8);
        BinContent.SetTrackingFilterFromItemTrackingSetupIfNotBlank(ItemTrackingSetup);
        if DestinationType2 = DestinationType2::TransferHeader then
            exit(BinContent.CalcQtyAvailToPick(0));
        exit(BinContent.CalcQtyAvailToTake(0));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTempTrackingSpec(var TempTrackingSpecification: Record "Tracking Specification" temporary; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterBinContentOnPostDataItem(ItemJournalLine: Record "Item Journal Line"; TransferHeader: Record "Transfer Header"; InternalMovementHeader: Record "Internal Movement Header"; DestinationType2: Option MovementWorksheet,WhseInternalPutawayHeader,ItemJournalLine,TransferHeader,InternalMovementHeader)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBinContenOnAfterGetRecordOnAfterCalcShouldSkipReportForQty(var BinContent: Record "Bin Content"; var ShouldSkipReportForQty: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertTempTrackingSpecOnAfterAssignTracking(var TempTrackingSpecification: Record "Tracking Specification" temporary; WarehouseEntry: Record "Warehouse Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInternalMovementLine(var InternalMovementLine: Record "Internal Movement Line"; BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertTransferLine(var TransferLine: Record "Transfer Line"; BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWIPLine(var WhseInternalPutAwayLine: Record "Whse. Internal Put-away Line"; BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertWWLine(var WhseWorksheetLine: Record "Whse. Worksheet Line"; BinContent: Record "Bin Content")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertItemJournalLineOnBeforeInsert(var ItemJournalLine: Record "Item Journal Line"; BinContent: Record "Bin Content")
    begin
    end;
}

