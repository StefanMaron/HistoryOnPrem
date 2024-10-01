table 12453 "Item Document Line"
{
    Caption = 'Item Document Line';
    DrillDownPageID = "Item Document Lines";
    LookupPageID = "Item Document Lines";

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Receipt,Shipment';
            OptionMembers = Receipt,Shipment;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;

                CheckItemAvailable(FieldNo("Item No."));

                ReserveItemDocLine.VerifyChange(Rec, xRec);
                CalcFields("Reserved Qty. Inbnd. (Base)");
                TestField("Reserved Qty. Inbnd. (Base)", 0);

                GetItemDocHeader;
                "Posting Date" := ItemDocHeader."Posting Date";
                "Document Date" := ItemDocHeader."Document Date";
                "Location Code" := ItemDocHeader."Location Code";
                "Gen. Bus. Posting Group" := ItemDocHeader."Gen. Bus. Posting Group";

                GetItem;
                Item.TestField(Blocked, false);
                Validate(Description, Item.Description);
                Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                Validate("Inventory Posting Group", Item."Inventory Posting Group");
                Validate("Unit Volume", Item."Unit Volume");
                Validate("Units per Parcel", Item."Units per Parcel");
                "Item Category Code" := Item."Item Category Code";
                "Indirect Cost %" := Item."Indirect Cost %";
                RetrieveCosts;
                "Unit Cost" := UnitCost;

                case "Document Type" of
                    "Document Type"::Receipt:
                        PurchPriceCalcMgt.FindItemDocLinePrice(Rec, FieldNo("Item No."));
                    "Document Type"::Shipment:
                        "Unit Amount" := UnitCost;
                end;

                case "Document Type" of
                    "Document Type"::Receipt:
                        "Unit of Measure Code" := Item."Purch. Unit of Measure";
                    "Document Type"::Shipment:
                        "Unit of Measure Code" := Item."Sales Unit of Measure";
                    else
                        "Unit of Measure Code" := Item."Base Unit of Measure";
                end;

                Validate("Unit of Measure Code");
                if "Variant Code" <> '' then
                    Validate("Variant Code");

                if "Item No." <> xRec."Item No." then begin
                    "Variant Code" := '';
                    "Bin Code" := '';
                    if ("Location Code" <> '') and ("Item No." <> '') then begin
                        GetLocation("Location Code");
                        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code")
                    end;
                end;

                if "Bin Code" <> '' then
                    Validate("Bin Code");

                CreateDim(
                  DATABASE::Item, "Item No.",
                  DATABASE::"Salesperson/Purchaser", "Salespers./Purch. Code");
            end;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';

            trigger OnValidate()
            begin
                CheckDateConflict.ItemDocLineCheck(Rec, CurrFieldNo <> 0); // Inbound
            end;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                GetUnitAmount(FieldNo("Location Code"));
                "Unit Cost" := UnitCost;
                Validate("Unit Amount");
                CheckItemAvailable(FieldNo("Location Code"));

                if "Location Code" <> xRec."Location Code" then begin
                    "Bin Code" := '';
                    if ("Location Code" <> '') and ("Item No." <> '') then begin
                        GetLocation("Location Code");
                        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code");
                    end;
                end;

                ReserveItemDocLine.VerifyChange(Rec, xRec);
            end;
        }
        field(10; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            Editable = false;
            TableRelation = "Inventory Posting Group";
        }
        field(13; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if CurrFieldNo <> 0 then
                    TestStatusOpen;
                if Quantity <> 0 then
                    TestField("Item No.");
                "Quantity (Base)" := CalcBaseQty(Quantity);

                UpdateAmount;

                CheckItemAvailable(FieldNo(Quantity));
                ReserveItemDocLine.VerifyQuantity(Rec, xRec);
            end;
        }
        field(16; "Unit Amount"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Amount';

            trigger OnValidate()
            begin
                UpdateAmount;
                if ("Item No." <> '') and ("Document Type" = "Document Type"::Receipt) then begin
                    ReadGLSetup;
                    "Unit Cost" :=
                      Round(
                        "Unit Amount" * (1 + "Indirect Cost %" / 100), GLSetup."Unit-Amount Rounding Precision");
                    Validate("Unit Cost");
                end;
            end;
        }
        field(17; "Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost';

            trigger OnValidate()
            begin
                TestField("Item No.");
                RetrieveCosts;
                if ("Document Type" = "Document Type"::Receipt) and (Item."Costing Method" = Item."Costing Method"::Standard) then
                    if CurrFieldNo <> FieldNo("Unit Cost") then
                        "Unit Cost" := Round(UnitCost * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision")
                    else
                        Error(Text002,
                          FieldCaption("Unit Cost"), Item."Costing Method");
            end;
        }
        field(18; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';

            trigger OnValidate()
            begin
                TestField(Quantity);
                "Unit Amount" := Amount / Quantity;
                Validate("Unit Amount");
                ReadGLSetup;
                "Unit Amount" := Round("Unit Amount", GLSetup."Unit-Amount Rounding Precision");
            end;
        }
        field(23; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser";

            trigger OnValidate()
            begin
                CreateDim(
                  DATABASE::"Salesperson/Purchaser", "Salespers./Purch. Code",
                  DATABASE::Item, "Item No.");
            end;
        }
        field(26; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            TableRelation = "Source Code";
        }
        field(29; "Applies-to Entry"; Integer)
        {
            Caption = 'Applies-to Entry';

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Applies-to Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                ItemTrackingLinesForm: Page "Item Tracking Lines";
            begin
                if "Applies-to Entry" <> 0 then begin
                    ItemLedgEntry.Get("Applies-to Entry");

                    TestField(Quantity);
                    ItemLedgEntry.TestField(Open, true);

                    "Location Code" := ItemLedgEntry."Location Code";
                    "Variant Code" := ItemLedgEntry."Variant Code";
                    "Unit Cost" := CalcUnitCost(ItemLedgEntry."Entry No.");
                    "Unit Amount" := "Unit Cost";
                    UpdateAmount;

                    if (ItemLedgEntry."Lot No." <> '') or (ItemLedgEntry."Serial No." <> '') then
                        Error(Text031, ItemTrackingLinesForm.Caption, FieldCaption("Applies-from Entry"));
                end else begin
                    RetrieveCosts;
                    "Unit Cost" := UnitCost;
                end;
            end;
        }
        field(32; "Item Shpt. Entry No."; Integer)
        {
            Caption = 'Item Shpt. Entry No.';
            Editable = false;
        }
        field(34; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(37; "Indirect Cost %"; Decimal)
        {
            Caption = 'Indirect Cost %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Item No.");
                TestField("Item Charge No.", '');

                GetItem;
                if Item."Costing Method" = Item."Costing Method"::Standard then
                    Error(
                      Text002,
                      FieldCaption("Indirect Cost %"), Item."Costing Method");

                "Unit Cost" :=
                  Round(
                    "Unit Amount" * (1 + "Indirect Cost %" / 100), GLSetup."Unit-Amount Rounding Precision");
            end;
        }
        field(38; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DecimalPlaces = 0 : 5;
        }
        field(39; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
        }
        field(40; "Units per Parcel"; Decimal)
        {
            Caption = 'Units per Parcel';
            DecimalPlaces = 0 : 5;
        }
        field(41; "Unit Volume"; Decimal)
        {
            Caption = 'Unit Volume';
            DecimalPlaces = 0 : 5;
        }
        field(42; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(55; "Last Item Ledger Entry No."; Integer)
        {
            Caption = 'Last Item Ledger Entry No.';
            Editable = false;
            TableRelation = "Item Ledger Entry";
            //This property is currently not supported
            //TestTableRelation = false;
        }
        field(57; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";
        }
        field(58; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
        }
        field(65; "Posting No. Series"; Code[20])
        {
            Caption = 'Posting No. Series';
            TableRelation = "No. Series";
        }
        field(72; "Unit Cost (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Unit Cost (ACY)';
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions;
            end;

            trigger OnValidate()
            begin
                DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
        field(5402; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                if "Variant Code" <> xRec."Variant Code" then begin
                    "Bin Code" := '';
                    if ("Location Code" <> '') and ("Item No." <> '') then begin
                        GetLocation("Location Code");
                        if Location."Bin Mandatory" and not Location."Directed Put-away and Pick" then
                            WMSManagement.GetDefaultBin("Item No.", "Variant Code", "Location Code", "Bin Code")
                    end;
                end;
                GetUnitAmount(FieldNo("Variant Code"));
                "Unit Cost" := UnitCost;
                Validate("Unit Amount");
                ReserveItemDocLine.VerifyChange(Rec, xRec);

                if "Variant Code" = '' then
                    exit;

                ItemVariant.Get("Item No.", "Variant Code");
                Description := ItemVariant.Description;
            end;
        }
        field(5403; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';

            trigger OnLookup()
            var
                BinCode: Code[20];
            begin
                if (("Document Type" = "Document Type"::Shipment) and (Quantity >= 0)) or
                   (("Document Type" = "Document Type"::Receipt) and (Quantity < 0))
                then
                    BinCode := WMSManagement.BinContentLookUp("Location Code", "Item No.", "Variant Code", '', "Bin Code")
                else
                    BinCode := WMSManagement.BinLookUp("Location Code", "Item No.", "Variant Code", '');

                if BinCode <> '' then
                    Validate("Bin Code", BinCode);
            end;

            trigger OnValidate()
            begin
                if ("Bin Code" <> xRec."Bin Code") and ("Bin Code" <> '') then begin
                    if (("Document Type" = "Document Type"::Shipment) and (Quantity >= 0)) or
                       (("Document Type" = "Document Type"::Receipt) and (Quantity < 0))
                    then
                        WMSManagement.FindBinContent("Location Code", "Bin Code", "Item No.", "Variant Code", '')
                    else
                        WMSManagement.FindBin("Location Code", "Bin Code", '');

                    TestField("Location Code");
                    if "Bin Code" <> '' then begin
                        GetLocation("Location Code");
                        Location.TestField("Bin Mandatory");
                        Location.TestField("Directed Put-away and Pick", false);
                        GetBin("Location Code", "Bin Code");
                        TestField("Location Code", Bin."Location Code");
                    end;
                end;

                ReserveItemDocLine.VerifyChange(Rec, xRec);
            end;
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            Editable = false;
            InitValue = 1;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                GetItem;
                "Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");

                GetUnitAmount(FieldNo("Unit of Measure Code"));

                ReadGLSetup;
                "Unit Cost" := Round(UnitCost * "Qty. per Unit of Measure", GLSetup."Unit-Amount Rounding Precision");

                Validate("Unit Amount");
                Validate(Quantity);
                "Net Weight" := Item."Net Weight" * "Qty. per Unit of Measure";
                "Gross Weight" := Item."Gross Weight" * "Qty. per Unit of Measure";
            end;
        }
        field(5413; "Quantity (Base)"; Decimal)
        {
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                TestField("Qty. per Unit of Measure", 1);
                Validate(Quantity, "Quantity (Base)");
            end;
        }
        field(5470; "Reserved Quantity Inbnd."; Decimal)
        {
            CalcFormula = Sum ("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                  "Source Ref. No." = FIELD("Line No."),
                                                                  "Source Type" = CONST(12453),
                                                                  "Source Subtype" = FILTER("0" | "3"),
                                                                  "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Inbnd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5471; "Reserved Quantity Outbnd."; Decimal)
        {
            CalcFormula = - Sum ("Reservation Entry".Quantity WHERE("Source ID" = FIELD("Document No."),
                                                                   "Source Ref. No." = FIELD("Line No."),
                                                                   "Source Type" = CONST(12453),
                                                                   "Source Subtype" = FILTER("1" | "2"),
                                                                   "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Quantity Outbnd.';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5472; "Reserved Qty. Inbnd. (Base)"; Decimal)
        {
            CalcFormula = Sum ("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                           "Source Ref. No." = FIELD("Line No."),
                                                                           "Source Type" = CONST(12453),
                                                                           "Source Subtype" = FILTER("0" | "3"),
                                                                           "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Inbnd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5473; "Reserved Qty. Outbnd. (Base)"; Decimal)
        {
            CalcFormula = - Sum ("Reservation Entry"."Quantity (Base)" WHERE("Source ID" = FIELD("Document No."),
                                                                            "Source Ref. No." = FIELD("Line No."),
                                                                            "Source Type" = CONST(12453),
                                                                            "Source Subtype" = FILTER("1" | "2"),
                                                                            "Reservation Status" = CONST(Reservation)));
            Caption = 'Reserved Qty. Outbnd. (Base)';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(5600; "FA Writeoff No."; Code[20])
        {
            Caption = 'FA Writeoff No.';
            TableRelation = "FA Document Header"."No." WHERE("Document Type" = CONST(Writeoff));
        }
        field(5601; "FA Writeoff Line No."; Integer)
        {
            Caption = 'FA Writeoff Line No.';
            TableRelation = "FA Document Line"."Line No." WHERE("Document Type" = CONST(Writeoff),
                                                                 "Document No." = FIELD("FA Writeoff No."));
        }
        field(5704; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            TableRelation = "Item Category";
        }
        field(5706; "Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            TableRelation = Purchasing;
        }
        field(5707; "Product Group Code"; Code[10])
        {
            Caption = 'Product Group Code';
            ObsoleteReason = 'Product Groups became first level children of Item Categories.';
            ObsoleteState = Removed;
        }
        field(5801; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            TableRelation = "Item Charge";
        }
        field(5807; "Applies-from Entry"; Integer)
        {
            Caption = 'Applies-from Entry';
            MinValue = 0;

            trigger OnLookup()
            begin
                SelectItemEntry(FieldNo("Applies-from Entry"));
            end;

            trigger OnValidate()
            var
                ItemLedgEntry: Record "Item Ledger Entry";
                ItemTrackingLinesForm: Page "Item Tracking Lines";
            begin
                if "Applies-from Entry" <> 0 then begin
                    TestField(Quantity);
                    ItemLedgEntry.Get("Applies-from Entry");
                    "Location Code" := ItemLedgEntry."Location Code";
                    "Variant Code" := ItemLedgEntry."Variant Code";
                    "Unit Cost" := CalcUnitCost(ItemLedgEntry."Entry No.");
                    "Unit Amount" := "Unit Cost";
                    UpdateAmount;

                    if (ItemLedgEntry."Lot No." <> '') or (ItemLedgEntry."Serial No." <> '') or
                       (ItemLedgEntry."CD No." <> '')
                    then
                        Error(Text031, ItemTrackingLinesForm.Caption, FieldCaption("Applies-from Entry"));
                end;
            end;
        }
        field(5811; "Applied Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Applied Amount';
            Editable = false;
        }
        field(5812; "Update Standard Cost"; Boolean)
        {
            Caption = 'Update Standard Cost';

            trigger OnValidate()
            begin
                GetItem;
                Item.TestField("Costing Method", Item."Costing Method"::Standard);
            end;
        }
        field(5813; "Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (ACY)';
        }
        field(5819; "Applies-to Value Entry"; Integer)
        {
            Caption = 'Applies-to Value Entry';
        }
        field(12450; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            TableRelation = "Fixed Asset";
        }
        field(12451; "FA Entry No."; Integer)
        {
            Caption = 'FA Entry No.';
            TableRelation = "FA Ledger Entry" WHERE("Entry No." = FIELD("FA Entry No."));
        }
        field(12452; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            TableRelation = "FA Depreciation Book"."Depreciation Book Code" WHERE("FA No." = FIELD("FA No."));
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
        key(Key2; "Location Code")
        {
        }
        key(Key3; "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestStatusOpen;

        CalcFields("Reserved Qty. Inbnd. (Base)", "Reserved Qty. Outbnd. (Base)");
        TestField("Reserved Qty. Inbnd. (Base)", 0);
        TestField("Reserved Qty. Outbnd. (Base)", 0);

        ReserveItemDocLine.DeleteLine(Rec);
    end;

    trigger OnInsert()
    begin
        TestStatusOpen;
        ReserveItemDocLine.VerifyQuantity(Rec, xRec);
        LockTable;
        ItemDocHeader."No." := '';
    end;

    trigger OnModify()
    begin
        ReserveItemDocLine.VerifyChange(Rec, xRec);
    end;

    trigger OnRename()
    begin
        Error(Text001, TableCaption);
    end;

    var
        Text001: Label '%1 must be reduced.';
        Text002: Label 'You cannot change %1 when Costing Method is %2.';
        ItemDocHeader: Record "Item Document Header";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        GLSetup: Record "General Ledger Setup";
        SKU: Record "Stockkeeping Unit";
        Location: Record Location;
        Bin: Record Bin;
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        ReserveItemDocLine: Codeunit "Item Doc. Line-Reserve";
        UOMMgt: Codeunit "Unit of Measure Management";
        DimMgt: Codeunit DimensionManagement;
        PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
        WMSManagement: Codeunit "WMS Management";
        CheckDateConflict: Codeunit "Reservation-Check Date Confl.";
        Reservation: Page Reservation;
        GLSetupRead: Boolean;
        UnitCost: Decimal;
        StatusCheckSuspended: Boolean;
        Text031: Label 'You must use page %1 to enter %2, if item tracking is used.';
        Text12402: Label 'Quantity %1 in line %2 cannot be reserved automatically.';

    [Scope('OnPrem')]
    procedure EmptyLine(): Boolean
    begin
        exit(
          (Quantity = 0) and
          ("Item No." = ''));
    end;

    local procedure CalcBaseQty(Qty: Decimal): Decimal
    begin
        TestField("Qty. per Unit of Measure");
        exit(Round(Qty * "Qty. per Unit of Measure", 0.00001));
    end;

    [Scope('OnPrem')]
    procedure UpdateAmount()
    begin
        Amount := Round(Quantity * "Unit Amount");
    end;

    local procedure SelectItemEntry(CurrentFieldNo: Integer)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ItemDocLine2: Record "Item Document Line";
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code");
        ItemLedgEntry.SetRange("Item No.", "Item No.");
        ItemLedgEntry.SetRange(Correction, false);
        if "Location Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", "Location Code");

        if CurrentFieldNo = FieldNo("Applies-to Entry") then begin
            ItemLedgEntry.SetRange(Positive, true);
            ItemLedgEntry.SetRange(Open, true);
        end else
            ItemLedgEntry.SetRange(Positive, false);

        if PAGE.RunModal(PAGE::"Item Ledger Entries", ItemLedgEntry) = ACTION::LookupOK then begin
            ItemDocLine2 := Rec;
            if CurrentFieldNo = FieldNo("Applies-to Entry") then
                ItemDocLine2.Validate("Applies-to Entry", ItemLedgEntry."Entry No.")
            else
                ItemDocLine2.Validate("Applies-from Entry", ItemLedgEntry."Entry No.");
            CheckItemAvailable(CurrentFieldNo);
            Rec := ItemDocLine2;
        end;
    end;

    local procedure CheckItemAvailable(CalledByFieldNo: Integer)
    begin
        if (CurrFieldNo = 0) or (CurrFieldNo <> CalledByFieldNo) then // Prevent two checks on quantity
            exit;

        if (CurrFieldNo <> 0) and ("Item No." <> '') and (Quantity <> 0) then
            ItemCheckAvail.ItemDocCheckLine(Rec);
    end;

    [Scope('OnPrem')]
    procedure GetItemDocHeader()
    begin
        TestField("Document No.");
        if ("Document Type" <> ItemDocHeader."Document Type") or ("Document No." <> ItemDocHeader."No.") then
            ItemDocHeader.Get("Document Type", "Document No.");
    end;

    local procedure GetItem()
    begin
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;

    [Scope('OnPrem')]
    procedure GetUnitAmount(CalledByFieldNo: Integer)
    begin
        RetrieveCosts;

        case "Document Type" of
            "Document Type"::Receipt:
                PurchPriceCalcMgt.FindItemDocLinePrice(Rec, CalledByFieldNo);
            "Document Type"::Shipment:
                "Unit Amount" := UnitCost * "Qty. per Unit of Measure";
        end;
    end;

    local procedure TestStatusOpen()
    begin
        if StatusCheckSuspended then
            exit;

        GetItemDocHeader;
        ItemDocHeader.TestField(Status, ItemDocHeader.Status::Open);
    end;

    [Scope('OnPrem')]
    procedure ShowReservation()
    begin
        TestField("Item No.");
        Clear(Reservation);
        Reservation.SetItemDocLine(Rec);
        Reservation.RunModal;
    end;

    [Scope('OnPrem')]
    procedure OpenItemTrackingLines()
    begin
        ReserveItemDocLine.CallItemTracking(Rec);
    end;

    [Scope('OnPrem')]
    procedure CreateDim(Type1: Integer; No1: Code[20]; Type2: Integer; No2: Code[20])
    var
        SourceCodeSetup: Record "Source Code Setup";
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        SourceCodeSetup.Get;
        TableID[1] := Type1;
        No[1] := No1;
        TableID[2] := Type2;
        No[2] := No2;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        GetItemDocHeader;
        "Dimension Set ID" :=
          DimMgt.GetDefaultDimID(
            TableID, No, "Source Code", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code",
            ItemDocHeader."Dimension Set ID", DATABASE::"Item Document Header");
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    [Scope('OnPrem')]
    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", StrSubstNo('%1 %2 %3', "Document Type", "Document No.", "Line No."));
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    [Scope('OnPrem')]
    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    [Scope('OnPrem')]
    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    [Scope('OnPrem')]
    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimMgt.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    local procedure ReadGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get;
            GLSetupRead := true;
        end;
    end;

    local procedure GetSKU(): Boolean
    begin
        if (SKU."Location Code" = "Location Code") and
           (SKU."Item No." = "Item No.") and
           (SKU."Variant Code" = "Variant Code")
        then
            exit(true);

        if SKU.Get("Location Code", "Item No.", "Variant Code") then
            exit(true);

        exit(false);
    end;

    local procedure RetrieveCosts()
    begin
        ReadGLSetup;
        GetItem;
        if GetSKU then
            UnitCost := SKU."Unit Cost"
        else
            UnitCost := Item."Unit Cost";

        if Item."Costing Method" <> Item."Costing Method"::Standard then
            UnitCost := Round(UnitCost, GLSetup."Unit-Amount Rounding Precision");
    end;

    local procedure CalcUnitCost(ItemLedgEntryNo: Integer): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset;
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
        ValueEntry.CalcSums("Invoiced Quantity", "Cost Amount (Actual)");
        if ValueEntry."Invoiced Quantity" <> 0 then
            exit(ValueEntry."Cost Amount (Actual)" / ValueEntry."Invoiced Quantity" * "Qty. per Unit of Measure");

        exit(0);
    end;

    [Scope('OnPrem')]
    procedure RowID1(): Text[250]
    var
        ItemTrackingMgt: Codeunit "Item Tracking Management";
    begin
        exit(ItemTrackingMgt.ComposeRowID(DATABASE::"Item Document Line", "Document Type",
            "Document No.", '', 0, "Line No."));
    end;

    local procedure GetLocation(LocationCode: Code[10])
    begin
        if LocationCode = '' then
            Clear(Location)
        else
            if Location.Code <> LocationCode then
                Location.Get(LocationCode);
    end;

    local procedure GetBin(LocationCode: Code[10]; BinCode: Code[20])
    begin
        if BinCode = '' then
            Clear(Bin)
        else
            if Bin.Code <> BinCode then
                Bin.Get(LocationCode, BinCode);
    end;

    [Scope('OnPrem')]
    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspended := Suspend;
    end;

    [Scope('OnPrem')]
    procedure Signed(Value: Decimal): Decimal
    begin
        case "Document Type" of
            "Document Type"::Receipt:
                exit(Value);
            "Document Type"::Shipment:
                exit(-Value);
        end;
    end;

    [Scope('OnPrem')]
    procedure ReserveFromInventory(var ItemDocLine: Record "Item Document Line")
    var
        ReservMgt: Codeunit "Reservation Management";
        AutoReserv: Boolean;
    begin
        if ItemDocLine.FindSet then
            repeat
                ReservMgt.SetItemDocLine(ItemDocLine);
                ItemDocLine.TestField("Posting Date");
                ItemDocLine.CalcFields("Reserved Qty. Outbnd. (Base)");
                ReservMgt.AutoReserveToShip(
                  AutoReserv, '', ItemDocLine."Posting Date",
                  ItemDocLine.Quantity - ItemDocLine."Reserved Quantity Outbnd.",
                  ItemDocLine."Quantity (Base)" - ItemDocLine."Reserved Qty. Outbnd. (Base)");
                if not AutoReserv then
                    Error(Text12402, ItemDocLine."Quantity (Base)", ItemDocLine."Line No.");
            until ItemDocLine.Next = 0;
    end;
}

