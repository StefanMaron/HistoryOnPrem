codeunit 144012 "ERM RU Sales Unrealized VAT"
{
    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        EntryDoesNotExist: Label 'Cannot find entry in table %1 with filters %2.';
        NothingToAdjustTxt: Label 'There is nothing to adjust.';

    local procedure UpdateGLSetup(NewSummarizeGainsLosses: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        with GLSetup do begin
            Get;
            Validate("Enable Russian Accounting", true);
            Validate("Summarize Gains/Losses", NewSummarizeGainsLosses);
            Validate("Currency Adjmt with Correction", false);
            Modify(true);
        end;
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedGainApply()
    begin
        // Pass TRUE for Raise Exch. Rate, FALSE for Unapply, FALSE for Summarize Gains/Losses
        SetupPostGainLossEntries(true, false, false);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealiedGainUnapply()
    begin
        SetupPostGainLossEntries(true, true, false);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedLossApply()
    begin
        SetupPostGainLossEntries(false, false, false);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedLossUnapply()
    begin
        SetupPostGainLossEntries(false, true, false);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedGainApplySumm()
    begin
        SetupPostGainLossEntries(true, false, true);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedGainUnapplySumm()
    begin
        SetupPostGainLossEntries(true, true, true);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedLossApplySumm()
    begin
        SetupPostGainLossEntries(false, false, true);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedLossUnapplySumm()
    begin
        SetupPostGainLossEntries(false, true, true);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedGainApplySummDiffAcc()
    begin
        // Pass TRUE for Raise Exch. Rate, FALSE for Unapply
        SetupPostGainLossEntriesDiffAc(true, false);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedGainUnapplySummDiffAcc()
    begin
        SetupPostGainLossEntriesDiffAc(true, true);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedLossApplySummDiffAcc()
    begin
        SetupPostGainLossEntriesDiffAc(false, false);
    end;

    [Test]
    [HandlerFunctions('NothingAdjustedMessageHandler')]
    [Scope('OnPrem')]
    procedure RealizedLossUnapplySummDiffAcc()
    begin
        SetupPostGainLossEntriesDiffAc(false, true);
    end;

    local procedure SetupPostGainLossEntries(IsRaise: Boolean; IsUnapply: Boolean; IsSummarizeGainsLosses: Boolean)
    var
        PostingDate: Date;
        CurrencyCode: Code[10];
        ExchRateAmount: array[3] of Decimal;
    begin
        // Check that Summarize Gain/Loss option works correctly in case of the same accounts for gain/losses
        UpdateGLSetup(IsSummarizeGainsLosses);
        SetupExchRateAmount(ExchRateAmount, IsRaise);
        PostingDate := WorkDate;
        CurrencyCode := CreateCurrencyWithExchRates(PostingDate, ExchRateAmount, false);

        PostGainLossEntries(PostingDate, CurrencyCode, IsRaise, IsUnapply, IsSummarizeGainsLosses);
    end;

    local procedure SetupPostGainLossEntriesDiffAc(IsRaise: Boolean; IsUnapply: Boolean)
    var
        PostingDate: Date;
        CurrencyCode: Code[10];
        ExchRateAmount: array[3] of Decimal;
    begin
        // Check that Summarize Gain/Loss option does not work in case of different accounts for real/unreal gain/losses
        UpdateGLSetup(true);
        SetupExchRateAmount(ExchRateAmount, IsRaise);
        PostingDate := WorkDate;
        CurrencyCode := CreateCurrencyWithExchRates(PostingDate, ExchRateAmount, true);

        PostGainLossEntries(PostingDate, CurrencyCode, IsRaise, IsUnapply, false);
    end;

    local procedure PostGainLossEntries(PostingDate: Date; CurrencyCode: Code[10]; IsRaise: Boolean; IsUnapply: Boolean; IsSummarizeGainsLosses: Boolean)
    var
        SalesLine: Record "Sales Line";
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustNo: Code[20];
        InvNo: array[2] of Code[20];
        PmtNo: Code[20];
        PmtAmount: Decimal;
        i: Integer;
    begin
        CustNo := LibrarySales.CreateCustomerNo;
        for i := 1 to ArrayLen(InvNo) do begin
            InvNo[i] := CreatePostInvoice(SalesLine, CustNo, PostingDate, CurrencyCode);
            PmtAmount += SalesLine."Amount Including VAT";
            PostingDate := CalcDate('<1M>', PostingDate);
        end;
        PmtNo :=
          CreatePostPayment(PostingDate, SalesLine."Sell-to Customer No.", CurrencyCode, -PmtAmount);
        Commit;
        RunAdjExchRates(CurrencyCode, WorkDate, GetInvPostingDate(SalesLine."Document No."), SalesLine."Sell-to Customer No.");
        ApplyPaymentToPairedInvoice(PmtNo, InvNo);
        if IsUnapply then begin
            UnapplyLedgerEntries(CustLedgEntry."Document Type"::Payment, PmtNo);
            // All unapplied entries goes with pmt. doc. no.
            for i := 1 to ArrayLen(InvNo) do
                InvNo[i] := PmtNo;
        end;
        VerifyGainLossAppEntries(InvNo, IsRaise, IsSummarizeGainsLosses, CurrencyCode);
    end;

    local procedure SetupExchRateAmount(var ExchRateAmount: array[3] of Decimal; IsRaise: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        Factor: Decimal;
    begin
        GLSetup.Get;
        ExchRateAmount[1] := 1 + LibraryRandom.RandDec(10, 2);
        if IsRaise then
            Factor := 1.3
        else
            Factor := 0.7;
        ExchRateAmount[2] :=
          Round(ExchRateAmount[1] * Factor, GLSetup."Amount Rounding Precision");
        ExchRateAmount[3] := ExchRateAmount[1];
    end;

    local procedure CreateCurrencyWithExchRates(StartingDate: Date; ExchRateAmount: array[3] of Decimal; IsDiffAccounts: Boolean) CurrencyCode: Code[10]
    var
        i: Integer;
    begin
        CurrencyCode := CreateCurrency(IsDiffAccounts);
        for i := 1 to ArrayLen(ExchRateAmount) do begin
            CreateCurrExchRates(CurrencyCode, StartingDate, ExchRateAmount[i]);
            StartingDate := CalcDate('<1M>', StartingDate);
        end;
        exit(CurrencyCode);
    end;

    local procedure CreateCurrency(IsDiffAccounts: Boolean): Code[10]
    var
        Currency: Record Currency;
    begin
        with Currency do begin
            LibraryERM.CreateCurrency(Currency);
            Validate("Unrealized Gains Acc.", LibraryERM.CreateGLAccountNo);
            Validate("Unrealized Losses Acc.", LibraryERM.CreateGLAccountNo);
            if IsDiffAccounts then begin
                Validate("Realized Gains Acc.", LibraryERM.CreateGLAccountNo);
                Validate("Realized Losses Acc.", LibraryERM.CreateGLAccountNo);
            end else begin
                Validate("Realized Gains Acc.", "Unrealized Gains Acc.");
                Validate("Realized Losses Acc.", "Unrealized Losses Acc.");
            end;
            Validate("Sales PD Gains Acc. (TA)", LibraryERM.CreateGLAccountNo);
            Validate("Sales PD Losses Acc. (TA)", LibraryERM.CreateGLAccountNo);
            Validate("PD Bal. Gain/Loss Acc. (TA)", LibraryERM.CreateGLAccountNo);
            Modify(true);
            exit(Code);
        end;
    end;

    local procedure CreateCurrExchRates(CurrencyCode: Code[10]; StartingDate: Date; RelationalAmount: Decimal)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        with CurrencyExchangeRate do begin
            LibraryERM.CreateExchRate(CurrencyExchangeRate, CurrencyCode, StartingDate);
            Validate("Exchange Rate Amount", 1);
            Validate("Adjustment Exch. Rate Amount", 1);
            Validate("Relational Exch. Rate Amount", RelationalAmount);
            Validate("Relational Adjmt Exch Rate Amt", RelationalAmount);
            Modify(true);
        end;
    end;

    local procedure CreatePostInvoice(var SalesLine: Record "Sales Line"; CustNo: Code[20]; PostingDate: Date; CurrencyCode: Code[10]): Code[20]
    begin
        CreateInvoice(SalesLine, CustNo, PostingDate, CurrencyCode);
        exit(PostInvoice(SalesLine));
    end;

    local procedure CreateInvoice(var SalesLine: Record "Sales Line"; CustNo: Code[20]; PostingDate: Date; CurrencyCode: Code[10])
    var
        SalesHeader: Record "Sales Header";
        AccNo: Code[20];
    begin
        AccNo := LibraryERM.CreateGLAccountWithSalesSetup;
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", AccNo, LibraryRandom.RandInt(100));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(true);
    end;

    local procedure PostInvoice(SalesLine: Record "Sales Line"): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePostPayment(PostingDate: Date; CustNo: Code[20]; CurrencyCode: Code[10]; PmtAmount: Decimal): Code[20]
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        InitGenJnlLine(GenJnlLine);
        with GenJnlLine do begin
            LibraryERM.CreateGeneralJnlLine(
              GenJnlLine, "Journal Template Name", "Journal Batch Name", "Document Type"::Payment, "Account Type"::Customer, CustNo, PmtAmount);
            Validate("Posting Date", PostingDate);
            Validate("Currency Code", CurrencyCode);
            Validate(Amount, PmtAmount);
            Validate("Bal. Account Type", "Bal. Account Type"::"G/L Account");
            Validate("Bal. Account No.", LibraryERM.CreateGLAccountNo);
            Modify(true);
            LibraryERM.PostGeneralJnlLine(GenJnlLine);
            exit("Document No.");
        end;
    end;

    local procedure InitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
    begin
        GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::General);
        LibraryERM.FindGenJournalTemplate(GenJnlTemplate);
        GenJnlBatch.SetRange(Recurring, false);
        LibraryERM.FindGenJournalBatch(GenJnlBatch, GenJnlTemplate.Name);
        LibraryERM.ClearGenJournalLines(GenJnlBatch);
        GenJnlLine.Init;
        GenJnlLine."Journal Template Name" := GenJnlBatch."Journal Template Name";
        GenJnlLine."Journal Batch Name" := GenJnlBatch.Name;
    end;

    local procedure ApplyPaymentToPairedInvoice(PmtNo: Code[20]; InvNo: array[2] of Code[20])
    var
        CustLedgerEntryFrom: Record "Cust. Ledger Entry";
        CustLedgerEntryTo: Record "Cust. Ledger Entry";
    begin
        LibraryERM.FindCustomerLedgerEntry(
          CustLedgerEntryFrom, CustLedgerEntryFrom."Document Type"::Payment, PmtNo);
        CustLedgerEntryFrom.CalcFields("Remaining Amount");
        LibraryERM.SetApplyCustomerEntry(CustLedgerEntryFrom, CustLedgerEntryFrom."Remaining Amount");

        with CustLedgerEntryTo do begin
            SetRange("Document Type", "Document Type"::Invoice);
            SetFilter("Document No.", '%1|%2', InvNo[1], InvNo[2]);
            FindSet;
            repeat
                CalcFields("Remaining Amount");
                Validate("Amount to Apply", "Remaining Amount");
                Modify(true);
            until Next = 0;
        end;

        LibraryERM.SetAppliestoIdCustomer(CustLedgerEntryTo);
        LibraryERM.PostCustLedgerApplication(CustLedgerEntryFrom);
    end;

    local procedure UnapplyLedgerEntries(DocType: Option; DocNo: Code[20])
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        LibraryERM.FindCustomerLedgerEntry(CustLedgEntry, DocType, DocNo);
        DtldCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntry."Entry No.");
        DtldCustLedgEntry.SetRange("Entry Type", DtldCustLedgEntry."Entry Type"::Application);
        DtldCustLedgEntry.FindFirst;
        CustEntryApplyPostedEntries.PostUnApplyCustomer(
          DtldCustLedgEntry, CustLedgEntry."Document No.", DtldCustLedgEntry."Posting Date");
    end;

    local procedure FindDtldCustLedgEntry(var DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; EntryType: Option; DocNo: Code[20])
    begin
        with DtldCustLedgEntry do begin
            SetRange("Entry Type", EntryType);
            SetRange("Document Type", "Document Type"::Invoice);
            SetRange("Document No.", DocNo);
            FindLast;
        end;
    end;

    local procedure GetInvPostingDate(OrderNo: Code[20]): Date
    var
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        SalesInvHeader.SetRange("Pre-Assigned No.", OrderNo);
        SalesInvHeader.FindLast;
        exit(SalesInvHeader."Posting Date");
    end;

    local procedure CalcGainLossParameters(var EntryType: array[2] of Option; var AccNo: array[2] of Code[20]; CurrencyCode: Code[10]; IsRaise: Boolean; IsSummarizeGainsLosses: Boolean)
    var
        Currency: Record Currency;
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        Currency.Get(CurrencyCode);
        if IsRaise then begin
            EntryType[1] := DtldCustLedgEntry."Entry Type"::"Unrealized Gain";
            EntryType[2] := DtldCustLedgEntry."Entry Type"::"Realized Loss";
            if IsSummarizeGainsLosses then
                AccNo[1] := Currency."Realized Losses Acc."
            else
                AccNo[1] := Currency."Unrealized Gains Acc.";
            AccNo[2] := Currency."Realized Losses Acc.";
        end else begin
            EntryType[1] := DtldCustLedgEntry."Entry Type"::"Unrealized Loss";
            EntryType[2] := DtldCustLedgEntry."Entry Type"::"Realized Gain";
            if IsSummarizeGainsLosses then
                AccNo[1] := Currency."Realized Gains Acc."
            else
                AccNo[1] := Currency."Unrealized Losses Acc.";
            AccNo[2] := Currency."Realized Gains Acc.";
        end;
    end;

    local procedure RunAdjExchRates(CurrencyCode: Code[10]; StartDate: Date; EndDate: Date; CustNo: Code[20])
    var
        Currency: Record Currency;
        Customer: Record Customer;
        AdjustExchangeRates: Report "Adjust Exchange Rates";
    begin
        Currency.SetRange(Code, CurrencyCode);
        Customer.SetRange("No.", CustNo);
        AdjustExchangeRates.SetTableView(Currency);
        AdjustExchangeRates.SetTableView(Customer);
        AdjustExchangeRates.InitializeRequest2(
          StartDate, EndDate, '', EndDate, LibraryUtility.GenerateGUID, true, false);
        AdjustExchangeRates.UseRequestPage(false);
        AdjustExchangeRates.Run;
    end;

    local procedure VerifyGainLossAppEntries(InvNo: array[2] of Code[20]; IsRaise: Boolean; IsSummarizeGainsLosses: Boolean; CurrencyCode: Code[10])
    var
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
        EntryType: array[2] of Option;
        AccNo: array[2] of Code[20];
        i: Integer;
    begin
        CalcGainLossParameters(EntryType, AccNo, CurrencyCode, IsRaise, IsSummarizeGainsLosses);
        for i := 1 to ArrayLen(InvNo) do begin
            FindDtldCustLedgEntry(DtldCustLedgEntry, EntryType[i], InvNo[i]);
            with GLEntry do begin
                SetRange("G/L Account No.", AccNo[i]);
                SetRange("Document Type", "Document Type"::Invoice);
                SetRange("Document No.", DtldCustLedgEntry."Document No.");
                SetRange("Transaction No.", DtldCustLedgEntry."Transaction No.");
                Assert.IsTrue(
                  FindLast, StrSubstNo(EntryDoesNotExist, TableCaption, GetFilters));
            end;
        end;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure NothingAdjustedMessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage(NothingToAdjustTxt, Message);
    end;
}

