report 11 "G/L - VAT Reconciliation"
{
    DefaultLayout = RDLC;
    RDLCLayout = './GLVATReconciliation.rdlc';
    ApplicationArea = Basic, Suite;
    Caption = 'G/L - VAT Reconciliation';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("VAT Statement Name"; "VAT Statement Name")
        {
            DataItemTableView = SORTING("Statement Template Name", Name);
            column(VAT_Statement_Name_Statement_Template_Name; "Statement Template Name")
            {
            }
            column(VAT_Statement_Name_Name; Name)
            {
            }
            dataitem("VAT Statement Line"; "VAT Statement Line")
            {
                DataItemLink = "Statement Template Name" = FIELD("Statement Template Name"), "Statement Name" = FIELD(Name);
                DataItemTableView = SORTING("Statement Template Name", "Statement Name", "Line No.") WHERE(Type = FILTER("Account Totaling" | "VAT Entry Totaling"));
                PrintOnlyIfDetail = true;
                column(VAT_Statement_Name__Name; "VAT Statement Name".Name)
                {
                }
                column(VAT_Statement_Name___Statement_Template_Name_; "VAT Statement Name"."Statement Template Name")
                {
                }
                column(COMPANYNAME; COMPANYPROPERTY.DisplayName)
                {
                }
                column(USERID; UserId)
                {
                }
                column(Header; Header)
                {
                }
                column(FORMAT_TODAY_0_0______FORMAT_TIME_0_0_; Format(Today, 0, 0))
                {
                }
                column(HeaderText; HeaderText)
                {
                }
                column(Header2; Header2)
                {
                }
                column(VAT_Statement_Line__TABLECAPTION__________VATStmtLineFilter; TableCaption + ': ' + VATStmtLineFilter)
                {
                }
                column(VATStmtLineFilter; VATStmtLineFilter)
                {
                }
                column(VAT_Statement_Line__Row_No__; "Row No.")
                {
                }
                column(VAT_Statement_Line_Description; Description)
                {
                }
                column(VAT_Statement_Line_Type; Type)
                {
                }
                column(VAT_Statement_Line__Amount_Type_; "Amount Type")
                {
                }
                column(VAT_Statement_Line__VAT_Bus__Posting_Group_; "VAT Bus. Posting Group")
                {
                }
                column(VAT_Statement_Line__VAT_Prod__Posting_Group_; "VAT Prod. Posting Group")
                {
                }
                column(VAT_Statement_Line__Gen__Posting_Type_; "Gen. Posting Type")
                {
                }
                column(TypeNo; TypeNo)
                {
                }
                column(TotalAmount; TotalAmount)
                {
                }
                column(TotalVAT; TotalVAT)
                {
                }
                column(VAT_Statement_Line_Statement_Template_Name; "Statement Template Name")
                {
                }
                column(VAT_Statement_Line_Statement_Name; "Statement Name")
                {
                }
                column(VAT_Statement_Line_Line_No_; "Line No.")
                {
                }
                column(VAT_Statement_Name__NameCaption; VAT_Statement_Name__NameCaptionLbl)
                {
                }
                column(VAT_Statement_Name___Statement_Template_Name_Caption; VAT_Statement_Name___Statement_Template_Name_CaptionLbl)
                {
                }
                column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
                {
                }
                column(GL_VAT_ReconciliationCaption; GL_VAT_ReconciliationCaptionLbl)
                {
                }
                column(AmountCaption; AmountCaptionLbl)
                {
                }
                column(VATCaption; VATCaptionLbl)
                {
                }
                column(Account_No_Caption; Account_No_CaptionLbl)
                {
                }
                column(G_L_Account_Name_Control1140052Caption; "G/L Account".FieldCaption(Name))
                {
                }
                column(Account_TypeCaption; Account_TypeCaptionLbl)
                {
                }
                column(VAT_Statement_Line__VAT_Prod__Posting_Group_Caption; FieldCaption("VAT Prod. Posting Group"))
                {
                }
                column(VAT_Statement_Line__VAT_Bus__Posting_Group_Caption; FieldCaption("VAT Bus. Posting Group"))
                {
                }
                column(VAT_Statement_Line__Gen__Posting_Type_Caption; FieldCaption("Gen. Posting Type"))
                {
                }
                column(VAT_Statement_Line__Amount_Type_Caption; FieldCaption("Amount Type"))
                {
                }
                column(VAT_Statement_Line___Account_Totaling_Caption; VAT_Statement_Line___Account_Totaling_CaptionLbl)
                {
                }
                column(VAT_Statement_Line_TypeCaption; FieldCaption(Type))
                {
                }
                column(VAT_Statement_Line_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(VAT_Statement_Line__Row_No__Caption; FieldCaption("Row No."))
                {
                }
                column(Grand_TotalCaption; Grand_TotalCaptionLbl)
                {
                }
                dataitem("G/L Account"; "G/L Account")
                {
                    DataItemTableView = SORTING("No.");
                    column(VAT_Statement_Line___Amount_Type_; Format("VAT Statement Line"."Amount Type"))
                    {
                    }
                    column(VAT_Statement_Line__Description; "VAT Statement Line".Description)
                    {
                    }
                    column(VAT_Statement_Line__Type; Format("VAT Statement Line".Type))
                    {
                    }
                    column(VAT_Statement_Line___Row_No__; "VAT Statement Line"."Row No.")
                    {
                    }
                    column(VAT_Statement_Line___Account_Totaling_; "VAT Statement Line"."Account Totaling")
                    {
                    }
                    column(Number; Number)
                    {
                    }
                    column(CountTotals; CountTotals)
                    {
                    }
                    column(Identifier; Identifier)
                    {
                    }
                    column(VAT_Statement_Line___Row_No___Control1140044; "VAT Statement Line"."Row No.")
                    {
                    }
                    column(VAT_Statement_Line___Amount_Type__Control1140045; "VAT Statement Line"."Amount Type")
                    {
                    }
                    column(VAT_Statement_Line___Account_Totaling__Control1140046; "VAT Statement Line"."Account Totaling")
                    {
                    }
                    column(VAT_Statement_Line__Type_Control1140047; "VAT Statement Line".Type)
                    {
                    }
                    column(VAT; VAT)
                    {
                    }
                    column(Amount1; Amount1)
                    {
                    }
                    column(G_L_Account_Name; Name)
                    {
                    }
                    column(G_L_Account__No__; "No.")
                    {
                    }
                    column(G_L_Account_Name_Control1140052; Name)
                    {
                    }
                    column(G_L_Account__No___Control1140053; "No.")
                    {
                    }
                    column(G_L_Account__TABLECAPTION; TableCaption)
                    {
                    }
                    column(Amount1_Control1140055; Amount1)
                    {
                    }
                    column(VAT_Control1140056; VAT)
                    {
                    }
                    column(VAT_Control1140058; VAT)
                    {
                    }
                    column(Amount1_Control1140059; Amount1)
                    {
                    }
                    column(TotalCaption; TotalCaptionLbl)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        TempVATEntryTable: Record "VAT Entry" temporary;
                    begin
                        Clear(TempVATEntryTable);
                        if "VAT Statement Line".Type = "VAT Statement Line".Type::"Account Totaling" then begin
                            CalcFields("Net Change", "Additional-Currency Net Change", "VAT Amt.");
                            Amount1 := ConditionalAdd("Net Change", "Additional-Currency Net Change");
                            VAT := ConditionalAdd("VAT Amt.", ExchangeAmtLCYtoFCY("VAT Amt."));
                        end else begin
                            GLEntry.SetRange("G/L Account No.", "No.");
                            if not GLEntry.FindSet then
                                CurrReport.Skip();
                            repeat
                                GLEntryVATEntryLink.SetRange("G/L Entry No.", GLEntry."Entry No.");
                                if GLEntryVATEntryLink.FindSet then
                                    repeat
                                        VATEntry.SetRange("Entry No.", GLEntryVATEntryLink."VAT Entry No.");
                                        if VATEntry.FindFirst then begin
                                            TempVATEntryTable.TransferFields(VATEntry);
                                            TempVATEntryTable.Insert();
                                        end;
                                    until GLEntryVATEntryLink.Next = 0;
                            until GLEntry.Next = 0;

                            if TempVATEntryTable.IsEmpty then
                                CurrReport.Skip();

                            case "VAT Statement Line"."Amount Type" of
                                "VAT Statement Line"."Amount Type"::Amount, "VAT Statement Line"."Amount Type"::Base:
                                    begin
                                        TempVATEntryTable.CalcSums(Base, "Additional-Currency Base", Amount, "Additional-Currency Amount");
                                        Amount1 := ConditionalAdd(TempVATEntryTable.Base, TempVATEntryTable."Additional-Currency Base");
                                        VAT := ConditionalAdd(TempVATEntryTable.Amount, TempVATEntryTable."Additional-Currency Amount");
                                    end;
                                "VAT Statement Line"."Amount Type"::"Unrealized Amount", "VAT Statement Line"."Amount Type"::"Unrealized Base":
                                    begin
                                        TempVATEntryTable.CalcSums(
                                          "Unrealized Base", "Add.-Currency Unrealized Base", "Unrealized Amount", "Add.-Currency Unrealized Amt.");
                                        Amount1 := ConditionalAdd(TempVATEntryTable."Unrealized Base", TempVATEntryTable."Add.-Currency Unrealized Base");
                                        VAT := ConditionalAdd(TempVATEntryTable."Unrealized Amount", TempVATEntryTable."Add.-Currency Unrealized Amt.");
                                    end;
                            end;
                        end;

                        OnBeforeCalcTotalAmount("VAT Statement Line", TempVATEntryTable, Amount1, VAT);
                        TotalAmount := TotalAmount + Amount1;
                        TotalVAT := TotalVAT + VAT;
                    end;

                    trigger OnPostDataItem()
                    begin
                        if Number > 1 then
                            if (Amount1 <> 0) or (VAT <> 0) then
                                CountTotals := CountTotals + 1;
                    end;

                    trigger OnPreDataItem()
                    begin
                        if "VAT Statement Line".Type = "VAT Statement Line".Type::"Account Totaling" then begin
                            SetFilter("No.", "VAT Statement Line"."Account Totaling");
                            SetRange("Date Filter", StartDate, EndDate);
                            Number := Count;
                        end else begin
                            Number := 2;
                            VATEntry.SetCurrentKey(
                              "Posting Date", Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group", Reversed);
                            VATEntry.SetRange(Type, "VAT Statement Line"."Gen. Posting Type");
                            case Selection of
                                Selection::Open:
                                    VATEntry.SetRange(Closed, false);
                                Selection::Closed:
                                    VATEntry.SetRange(Closed, true);
                            end;
                            VATEntry.SetRange("VAT Bus. Posting Group", "VAT Statement Line"."VAT Bus. Posting Group");
                            VATEntry.SetRange("VAT Prod. Posting Group", "VAT Statement Line"."VAT Prod. Posting Group");
                            GLEntry.SetRange("VAT Bus. Posting Group", "VAT Statement Line"."VAT Bus. Posting Group");
                            GLEntry.SetRange("VAT Prod. Posting Group", "VAT Statement Line"."VAT Prod. Posting Group");
                            if (EndDateReq <> 0D) or (StartDate <> 0D) then
                                if PeriodSelection = PeriodSelection::"Before and Within Period" then begin
                                    VATEntry.SetRange("Posting Date", 0D, EndDate);
                                    GLEntry.SetRange("Posting Date", 0D, EndDate);
                                end else begin
                                    VATEntry.SetRange("Posting Date", StartDate, EndDate);
                                    GLEntry.SetRange("Posting Date", StartDate, EndDate);
                                end;
                            VATEntry.SetRange(Reversed, false);
                            GLEntry.SetRange(Reversed, false);
                        end;

                        Identifier := Identifier + 1;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if (Type = Type::"Account Totaling") and ("Account Totaling" = '') then
                        CurrReport.Skip();
                    VATStmtLine2.Get("Statement Template Name", "Statement Name", "Line No.");
                    VATStmtLine2.SetRange("Row No.", "Row No.");
                    VATStmtLine2.SetRange("VAT Bus. Posting Group", "VAT Bus. Posting Group");
                    VATStmtLine2.SetRange("VAT Prod. Posting Group", "VAT Prod. Posting Group");
                    if VATStmtLine2.Find('<') then
                        CurrReport.Skip();
                    TotalAmount := 0;
                    TotalVAT := 0;
                    CountTotals := 0;

                    TypeNo := Type.AsInteger();
                end;

                trigger OnPreDataItem()
                begin
                    VATStmtLine2.CopyFilters("VAT Statement Line");
                end;
            }

            trigger OnPreDataItem()
            begin
                if UseAmtsInAddCurr then
                    HeaderText := StrSubstNo(AllAmountsLbl, GLSetup."Additional Reporting Currency")
                else begin
                    GLSetup.TestField("LCY Code");
                    HeaderText := StrSubstNo(AllAmountsLbl, GLSetup."LCY Code");
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group("Statement Period")
                    {
                        Caption = 'Statement Period';
                        field(StartDate; StartDate)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Starting Date';
                            ToolTip = 'Specifies the date from which the report or batch job processes information.';
                        }
                        field(EndDateReq; EndDateReq)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Ending Date';
                            ToolTip = 'Specifies the last date that the report includes data for.';
                        }
                    }
                    field(Selection; Selection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT Entries';
                        ToolTip = 'Specifies if you want to include VAT entries from before the specified time period in the report.';
                    }
                    field(PeriodSelection; PeriodSelection)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Include VAT Entries';
                        ToolTip = 'Specifies if you want to include VAT entries from before the specified time period in the report.';
                    }
                    field(UseAmtsInAddCurr; UseAmtsInAddCurr)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Amounts in Add. Reporting Currency';
                        MultiLine = true;
                        ToolTip = 'Specifies if you want report amounts to be shown in the additional reporting currency.';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        if EndDateReq = 0D then
            EndDate := 99991231D
        else
            EndDate := EndDateReq;
        "VAT Statement Line".SetRange("Date Filter", StartDate, EndDate);
        VATStmtLineFilter := "VAT Statement Line".GetFilters;
        if PeriodSelection = PeriodSelection::"Before and Within Period" then
            Header := BeforeAndWithinPeriodLbl
        else
            Header := PeriodLbl + "VAT Statement Line".GetFilter("Date Filter");
        case Selection of
            Selection::Closed:
                Header2 := OnlyClosedVATEntriesLbl;
            Selection::"Open and Closed":
                Header2 := AllVATEntriesLbl;
        end;
        GLSetup.Get();
        if UseAmtsInAddCurr then begin
            GLSetup.TestField("Additional Reporting Currency");
            Currency.Get(GLSetup."Additional Reporting Currency");
            CurrencyFactor := CurrencyExchRate.ExchangeRate(WorkDate, GLSetup."Additional Reporting Currency");
        end;
    end;

    var
        BeforeAndWithinPeriodLbl: Label 'VAT entries before and within the period';
        PeriodLbl: Label 'Period: ';
        OnlyClosedVATEntriesLbl: Label 'The report includes only closed VAT entries.';
        AllVATEntriesLbl: Label 'The report includes all VAT entries.';
        AllAmountsLbl: Label 'All amounts are in %1', Comment = '%1 = currency';
        VATEntry: Record "VAT Entry";
        GLSetup: Record "General Ledger Setup";
        VATStmtLine2: Record "VAT Statement Line";
        CurrencyExchRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        GLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link";
        GLEntry: Record "G/L Entry";
        UseAmtsInAddCurr: Boolean;
        EndDate: Date;
        StartDate: Date;
        EndDateReq: Date;
        Amount1: Decimal;
        VAT: Decimal;
        CurrencyFactor: Decimal;
        TotalAmount: Decimal;
        TotalVAT: Decimal;
        CountTotals: Integer;
        Number: Integer;
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";
        VATStmtLineFilter: Text;
        Header: Text;
        Header2: Text[50];
        HeaderText: Text[50];
        TypeNo: Integer;
        Identifier: Integer;
        VAT_Statement_Name__NameCaptionLbl: Label 'VAT Statement Name';
        VAT_Statement_Name___Statement_Template_Name_CaptionLbl: Label 'VAT Statement Template';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        GL_VAT_ReconciliationCaptionLbl: Label 'G/L - VAT Reconciliation';
        AmountCaptionLbl: Label 'Amount';
        VATCaptionLbl: Label 'VAT';
        Account_No_CaptionLbl: Label 'Account No.';
        Account_TypeCaptionLbl: Label 'Account Type';
        VAT_Statement_Line___Account_Totaling_CaptionLbl: Label 'Account Totaling';
        Grand_TotalCaptionLbl: Label 'Grand Total';
        TotalCaptionLbl: Label 'Total';

    procedure ConditionalAdd(AmountToAdd: Decimal; AddCurrAmountToAdd: Decimal): Decimal
    begin
        if UseAmtsInAddCurr then
            exit(AddCurrAmountToAdd);

        exit(AmountToAdd);
    end;

    procedure ExchangeAmtLCYtoFCY(Amount: Decimal): Decimal
    begin
        if not UseAmtsInAddCurr then
            exit(Amount);

        exit(
          Round(
            CurrencyExchRate.ExchangeAmtLCYToFCY(
              WorkDate, GLSetup."Additional Reporting Currency", Amount, CurrencyFactor),
            Currency."Amount Rounding Precision"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcTotalAmount(VATStmtLine: Record "VAT Statement Line"; var TempVATEntryTable: Record "VAT Entry" temporary; var Amount1: Decimal; var VAT: Decimal)
    begin
    end;
}

