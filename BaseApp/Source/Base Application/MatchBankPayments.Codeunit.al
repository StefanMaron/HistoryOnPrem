codeunit 1255 "Match Bank Payments"
{
    Permissions = TableData "Cust. Ledger Entry" = rm,
                  TableData "Vendor Ledger Entry" = rm;
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.Copy(Rec);

        Code(BankAccReconciliationLine);

        Rec := BankAccReconciliationLine;
    end;

    var
        MatchSummaryMsg: Label '%1 payment lines out of %2 are applied.\\';
        BankAccount: Record "Bank Account";
        TempBankPmtApplRule: Record "Bank Pmt. Appl. Rule" temporary;
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        TextMapperRulesOverridenTxt: Label '%1 text mapper rules could be applied. They were overridden because a record with the %2 match confidence was found.';
        MultipleEntriesWithSilarConfidenceFoundTxt: Label 'There are %1 ledger entries that this statement line could be applied to with the same confidence.';
        MultipleStatementLinesWithSameConfidenceFoundTxt: Label 'There are %1 alternative statement lines that could be applied to the same ledger entry with the same confidence.';
        OneToManyTempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        TempBankStmtMultipleMatchLine: Record "Bank Stmt Multiple Match Line" temporary;
        TempCustomerLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        TempVendorLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        TempGeneralLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        TempSalesAdvanceLetterMatchingBuffer: Record "Advance Letter Matching Buffer" temporary;
        TempPurchAdvanceLetterMatchingBuffer: Record "Advance Letter Matching Buffer" temporary;
        TempBankAccLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
        TempCustomerLedgerEntryMatchingBufferStore: Record "Ledger Entry Matching Buffer" temporary;
        TempVendorLedgerEntryMatchingBufferStore: Record "Ledger Entry Matching Buffer" temporary;
        TempSalesAdvanceLetterMatchingBufferStore: Record "Advance Letter Matching Buffer" temporary;
        TempPurchAdvanceLetterMatchingBufferStore: Record "Advance Letter Matching Buffer" temporary;
        TempDirectDebitCollectionEntryBuffer: Record "Direct Debit Collection Entry" temporary;
        ApplyEntries: Boolean;
        CannotApplyDocumentNoOneToManyApplicationTxt: Label 'Document No. %1 was not applied because the transaction amount was insufficient.';
        UsePaymentDiscounts: Boolean;
        MinimumMatchScore: Integer;
        MatchingStmtLinesMsg: Label 'The matching of statement lines to open ledger entries is in progress.\\Please wait while the operation is being completed.\\#1####### @2@@@@@@@@@@@@@';
        MatchingStmtLinesToAdvanceLettersMsg: Label 'The matching of statement lines to advance letters is in progress.\\Please wait while the operation is being completed.\\#1####### @2@@@@@@@@@@@@@';
        ProcessedStmtLinesMsg: Label 'Processed %1 out of %2 lines.';
        CreatingAppliedEntriesMsg: Label 'The application of statement lines to open ledger entries is in progress. Please wait while the operation is being completed.';
        ProgressBarMsg: Label 'Please wait while the operation is being completed.';
        MustChooseAccountErr: Label 'You must choose an account to transfer the difference to.';
        LineSplitTxt: Label 'The value in the Transaction Amount field has been reduced by %1. A new line with %1 in the Transaction Amount field has been created.', Comment = '%1 - Difference';
        MatchingStmtLinesToRelatedPartyMsg: Label 'The matching of statement lines to related party is in progress.\\Please wait while the operation is being completed.\\#1####### @2@@@@@@@@@@@@@', Comment = '%1 = number of lines, %2 = progress bar';
        BankAccountRecCategoryLbl: Label 'AL Bank Account Rec', Locked = true;
        BankAccountRecTotalAndMatchedLinesLbl: Label 'Total Bank Statement Lines: %1, of those applied: %2, and text-matched: %3', Locked = true;
	MatchRelatedParty: Boolean;
        UseExtSetup: Boolean;
        NotApplyCustLedgerEntries: Boolean;
        NotApplyVendLedgerEntries: Boolean;
        NotAplBankAccLedgEntries: Boolean;
        NotApplyGenLedgerEntries: Boolean;
        NotApplySalesAdvances: Boolean;
        NotApplyPurchaseAdvances: Boolean;
        NotUseTextToAccMappingCode: Boolean;
        BankPmtApplRuleCode: Code[10];
        TextToAccMappingCode: Code[10];
        OnlyNotAppliedLines: Boolean;
        TempCustLedgMatchingBufferInitialized: Boolean;
        TempVendLedgMatchingBufferInitialized: Boolean;
        TempSalesAdvLedgMatchingBufferInitialized: Boolean;
        TempPurchAdvLedgMatchingBufferInitialized: Boolean;

    procedure "Code"(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        BankPmtApplRuleCode2: Record "Bank Pmt. Appl. Rule Code";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        if BankAccReconciliationLine.IsEmpty then
            exit;

        // NAVCZ
        CheckBankAccountSetup(BankAccReconciliationLine);
        BankAccount.Get(BankAccReconciliationLine."Bank Account No.");
        GetApplyParam;
        MatchRelatedParty := false;
        if UseExtSetup then begin
            if BankPmtApplRuleCode2.Get(BankPmtApplRuleCode) then
                MatchRelatedParty := BankPmtApplRuleCode2."Match Related Party Only";
            if OnlyNotAppliedLines then
                BankAccReconciliationLine.SetFilter("Applied Amount", '0')
        end else
            if BankPmtApplRuleCode2.Get(BankAccReconciliationLine.GetBankPmtApplRuleCode) then
                MatchRelatedParty := BankPmtApplRuleCode2."Match Related Party Only";
        // NAVCZ
        MapLedgerEntriesToStatementLines(BankAccReconciliationLine);
        // NAVCZ
        MapAdvanceLetterToStatementLines(BankAccReconciliationLine);
        UpdateOneToManyMatches(BankAccReconciliationLine);
        // NAVCZ

        if ApplyEntries then
            ApplyLedgerEntriesToStatementLines(BankAccReconciliationLine);

        // NAVCZ
        if MatchRelatedParty then begin
            MapRelatedPartyToStatementtLines(BankAccReconciliationLine);
            BankAccReconciliation.Get(
              BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.",
              BankAccReconciliationLine."Statement No.");
            ShowMatchSummary(BankAccReconciliation);
        end;
        // NAVCZ
    end;

    local procedure ApplyLedgerEntriesToStatementLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Window: Dialog;
    begin
        Window.Open(CreatingAppliedEntriesMsg);
        BankAccReconciliation.Get(
          BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.",
          BankAccReconciliationLine."Statement No.");

        // NAVCZ
        if OnlyNotAppliedLines then begin
            DeleteAppliedPaymentEntries2(BankAccReconciliationLine);
            DeletePaymentMatchDetails2(BankAccReconciliationLine);
        end else begin
            DeleteAppliedPaymentEntries(BankAccReconciliation);
            DeletePaymentMatchDetails(BankAccReconciliation);
        end;

        CreateAppliedEntries(BankAccReconciliation);
        UpdatePaymentMatchDetails(BankAccReconciliationLine);
        UpdateBankAccReconciliationLine(BankAccReconciliation); // NAVCZ
        Window.Close;

        if MatchRelatedParty then
            exit; // NAVCZ

        ShowMatchSummary(BankAccReconciliation);
    end;

    local procedure MapLedgerEntriesToStatementLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        Window: Dialog;
        TotalNoOfLines: Integer;
        ProcessedLines: Integer;
        CurrencyCode: Code[10];
    begin
        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.DeleteAll;

        TempBankAccLedgerEntryMatchingBuffer.Reset;
        TempBankAccLedgerEntryMatchingBuffer.DeleteAll;
        TempCustomerLedgerEntryMatchingBuffer.Reset;
        TempCustomerLedgerEntryMatchingBuffer.DeleteAll;
        TempVendorLedgerEntryMatchingBuffer.Reset;
        TempVendorLedgerEntryMatchingBuffer.DeleteAll;
        TempDirectDebitCollectionEntryBuffer.DeleteAll;
        // NAVCZ
        ClearLedgEntryStoreBuffers;
        BankAccReconciliationLine.FindFirst;
        if UseExtSetup then
            TempBankPmtApplRule.LoadRules(BankPmtApplRuleCode)
        else
            TempBankPmtApplRule.LoadRules(BankAccReconciliationLine.GetBankPmtApplRuleCode);
        // NAVCZ

        MinimumMatchScore := GetLowestMatchScore;

        BankAccReconciliationLine.SetFilter("Statement Amount", '<>0');
        if BankAccReconciliationLine.FindSet then begin
            InitializeCustomerLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempCustomerLedgerEntryMatchingBuffer);
            InitializeVendorLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempVendorLedgerEntryMatchingBuffer);
            InitializeBankAccLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer);
            InitializeDirectDebitCollectionEntriesMatchingBuffer(TempDirectDebitCollectionEntryBuffer);
            CurrencyCode := BankAccReconciliationLine."Currency Code";

            BankAccount.Get(BankAccReconciliationLine."Bank Account No.");

            TotalNoOfLines := BankAccReconciliationLine.Count;
            ProcessedLines := 0;

            if ApplyEntries then
                Window.Open(MatchingStmtLinesMsg)
            else
                Window.Open(ProgressBarMsg);

            repeat
                // NAVCZ
                if BankAccReconciliationLine."Currency Code" <> CurrencyCode then begin
                    TempCustomerLedgerEntryMatchingBuffer.Reset;
                    TempCustomerLedgerEntryMatchingBuffer.DeleteAll;
                    TempVendorLedgerEntryMatchingBuffer.Reset;
                    TempVendorLedgerEntryMatchingBuffer.DeleteAll;
                    InitializeCustomerLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempCustomerLedgerEntryMatchingBuffer);
                    InitializeVendorLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempVendorLedgerEntryMatchingBuffer);
                end;
                CurrencyCode := BankAccReconciliationLine."Currency Code";

                TempGeneralLedgerEntryMatchingBuffer.Reset;
                TempGeneralLedgerEntryMatchingBuffer.DeleteAll;
                InitializeGeneralLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempGeneralLedgerEntryMatchingBuffer);
                // NAVCZ

                FindMatchingEntries(
                  BankAccReconciliationLine, TempCustomerLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer."Account Type"::Customer);
                FindMatchingEntries(
                  BankAccReconciliationLine, TempVendorLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer."Account Type"::Vendor);
                // NAVCZ
                FindMatchingEntries(
                  BankAccReconciliationLine, TempGeneralLedgerEntryMatchingBuffer,
                  TempBankStatementMatchingBuffer."Account Type"::"G/L Account");
                // NAVCZ
                FindMatchingEntries(
                  BankAccReconciliationLine,
                  TempBankAccLedgerEntryMatchingBuffer, TempBankStatementMatchingBuffer."Account Type"::"Bank Account");
                FindTextMappings(BankAccReconciliationLine);
                ProcessedLines += 1;

                if ApplyEntries then begin
                    Window.Update(1, StrSubstNo(ProcessedStmtLinesMsg, ProcessedLines, TotalNoOfLines));
                    Window.Update(2, Round(ProcessedLines / TotalNoOfLines * 10000, 1));
                end;
            until BankAccReconciliationLine.Next = 0;

            Window.Close;
        end;
    end;

    local procedure MapAdvanceLetterToStatementLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        Window: Dialog;
        TotalNoOfLines: Integer;
        ProcessedLines: Integer;
        CurrencyCode: Code[10];
    begin
        // NAVCZ
        if not ApplyEntries then
            exit;

        TempBankStatementMatchingBuffer.Reset;

        TempSalesAdvanceLetterMatchingBuffer.Reset;
        TempSalesAdvanceLetterMatchingBuffer.DeleteAll;
        TempPurchAdvanceLetterMatchingBuffer.Reset;
        TempPurchAdvanceLetterMatchingBuffer.DeleteAll;
        ClearAdvLetterStoreBuffers;

        BankAccount.Get(BankAccReconciliationLine."Bank Account No.");
        BankAccReconciliationLine.SetFilter("Statement Amount", '<>0');
        if BankAccReconciliationLine.FindSet then begin
            InitializeSalesAdvanceLettersMatchingBuffer(BankAccReconciliationLine, TempSalesAdvanceLetterMatchingBuffer);
            InitializePurchaseAdvanceLettersMatchingBuffer(BankAccReconciliationLine, TempPurchAdvanceLetterMatchingBuffer);
            CurrencyCode := BankAccReconciliationLine."Currency Code";

            TotalNoOfLines := BankAccReconciliationLine.Count;
            ProcessedLines := 0;

            Window.Open(MatchingStmtLinesToAdvanceLettersMsg);

            repeat
                if BankAccReconciliationLine."Currency Code" <> CurrencyCode then begin
                    TempSalesAdvanceLetterMatchingBuffer.Reset;
                    TempSalesAdvanceLetterMatchingBuffer.DeleteAll;
                    TempPurchAdvanceLetterMatchingBuffer.Reset;
                    TempPurchAdvanceLetterMatchingBuffer.DeleteAll;

                    InitializeSalesAdvanceLettersMatchingBuffer(BankAccReconciliationLine, TempSalesAdvanceLetterMatchingBuffer);
                    InitializePurchaseAdvanceLettersMatchingBuffer(BankAccReconciliationLine, TempPurchAdvanceLetterMatchingBuffer);
                end;
                CurrencyCode := BankAccReconciliationLine."Currency Code";

                FindMatchingAdvanceLetters(
                  BankAccReconciliationLine, TempSalesAdvanceLetterMatchingBuffer, TempBankStatementMatchingBuffer."Account Type"::Customer);
                FindMatchingAdvanceLetters(
                  BankAccReconciliationLine, TempPurchAdvanceLetterMatchingBuffer, TempBankStatementMatchingBuffer."Account Type"::Vendor);

                ProcessedLines += 1;
                Window.Update(1, StrSubstNo(ProcessedStmtLinesMsg, ProcessedLines, TotalNoOfLines));
                Window.Update(2, Round(ProcessedLines / TotalNoOfLines * 10000, 1));
            until BankAccReconciliationLine.Next = 0;

            Window.Close;
        end;
    end;

    procedure RerunTextMapper(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        if BankAccReconciliationLine.IsEmpty then
            exit;

        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliationLine."Statement Type"::"Payment Application");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliationLine."Statement No.");
        BankAccReconciliationLine.SetFilter("Match Confidence", '<>%1 & <>%2',
          BankAccReconciliationLine."Match Confidence"::Accepted, BankAccReconciliationLine."Match Confidence"::High);

        if BankAccReconciliationLine.FindSet then begin
            BankAccReconciliation.Get(
              BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.",
              BankAccReconciliationLine."Statement No.");
            repeat
                SetFilterToBankAccReconciliation(AppliedPaymentEntry, BankAccReconciliationLine);
                if FindTextMappings(BankAccReconciliationLine) then begin
                    BankAccReconciliationLine.RejectAppliedPayment;
                    CreateAppliedEntries(BankAccReconciliation);
                end;
            until BankAccReconciliationLine.Next = 0;

            // Update match details for lines matched by text mapper
            BankAccReconciliationLine.SetRange(
              "Match Confidence", BankAccReconciliationLine."Match Confidence"::"High - Text-to-Account Mapping");
            UpdatePaymentMatchDetails(BankAccReconciliationLine);
        end;
    end;

    procedure TransferDiffToAccount(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        TempBankPmtApplRule: Record "Bank Pmt. Appl. Rule" temporary;
        Score: Integer;
        Difference: Decimal;
        TransactionDate: Date;
        LineSplitMsg: Text;
        ParentLineNo: Integer;
        TransactionID: Text[50];
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
    begin
        if BankAccReconciliationLine.IsEmpty or (BankAccReconciliationLine.Difference = 0) then
            exit;

        TempGenJournalLine.Amount := BankAccReconciliationLine.Difference;
        TempGenJournalLine.Description := BankAccReconciliationLine.Description;
        if not TempGenJournalLine.Insert then
            TempGenJournalLine.Modify;

        if PAGE.RunModal(PAGE::"Transfer Difference to Account", TempGenJournalLine) = ACTION::LookupOK then begin
            if TempGenJournalLine."Account No." = '' then
                Error(MustChooseAccountErr);

            if BankAccReconciliationLine."Statement Amount" <> BankAccReconciliationLine.Difference then begin
                ParentLineNo := GetParentLineNo(BankAccReconciliationLine);
                Difference := BankAccReconciliationLine.Difference;
                LineSplitMsg := StrSubstNo(LineSplitTxt, Difference);
                TransactionDate := BankAccReconciliationLine."Transaction Date";
                TransactionID := BankAccReconciliationLine."Transaction ID";
                // NAVCZ
                CurrencyCode := BankAccReconciliationLine."Currency Code";
                CurrencyFactor := BankAccReconciliationLine."Currency Factor";
                // NAVCZ
                RevertAcceptedPmtToleranceFromAppliedEntries(BankAccReconciliationLine, Abs(Difference));
                BankAccReconciliationLine.Validate("Statement Amount", BankAccReconciliationLine."Applied Amount"); // NAVCZ
                BankAccReconciliationLine.Difference := 0;
                BankAccReconciliationLine.Modify;

                BankAccReconciliationLine.Init;
                BankAccReconciliationLine."Statement Line No." := GetAvailableSplitLineNo(BankAccReconciliationLine, ParentLineNo);
                BankAccReconciliationLine."Parent Line No." := ParentLineNo;
                BankAccReconciliationLine.Description := TempGenJournalLine.Description;
                BankAccReconciliationLine."Transaction Text" := TempGenJournalLine.Description;
                BankAccReconciliationLine."Transaction Date" := TransactionDate;
                // NAVCZ
                BankAccReconciliationLine."Currency Code" := CurrencyCode;
                BankAccReconciliationLine."Currency Factor" := CurrencyFactor;
                BankAccReconciliationLine.Validate("Statement Amount", Difference);
                // NAVCZ
                BankAccReconciliationLine.Type := BankAccReconciliationLine.Type::Difference;
                BankAccReconciliationLine."Transaction ID" := TransactionID;
                BankAccReconciliationLine.Insert;
            end;

            BankAccReconciliation.Get(
              BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.",
              BankAccReconciliationLine."Statement No.");

            Score := TempBankPmtApplRule.GetTextMapperScore;
            TempBankStatementMatchingBuffer.AddMatchCandidate(
              BankAccReconciliationLine."Statement Line No.", -1,
              Score, TempGenJournalLine."Account Type", TempGenJournalLine."Account No.");
            CreateAppliedEntries(BankAccReconciliation);

            BankAccReconciliationLine.SetManualApplication;
            BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliationLine."Statement Type"::"Payment Application");
            BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
            BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliationLine."Statement No.");
            BankAccReconciliationLine.SetRange("Statement Line No.", BankAccReconciliationLine."Statement Line No.");
            UpdatePaymentMatchDetails(BankAccReconciliationLine);
            if LineSplitMsg <> '' then
                Message(LineSplitMsg);
        end;
    end;

    procedure MatchSingleLineCustomer(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AppliesToEntryNo: Integer; var NoOfLedgerEntriesWithinTolerance: Integer; var NoOfLedgerEntriesOutsideTolerance: Integer)
    var
        MinAmount: Decimal;
        MaxAmount: Decimal;
        AccountNo: Code[20];
    begin
        ApplyEntries := false;
        InitializeCustomerLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempCustomerLedgerEntryMatchingBuffer);
        InitializeDirectDebitCollectionEntriesMatchingBuffer(TempDirectDebitCollectionEntryBuffer);
        if TempCustomerLedgerEntryMatchingBuffer.Get(AppliesToEntryNo, TempCustomerLedgerEntryMatchingBuffer."Account Type"::Customer) then;

        FindMatchingEntry(
          TempCustomerLedgerEntryMatchingBuffer, BankAccReconciliationLine, TempBankStatementMatchingBuffer."Account Type"::Customer,
          BankPmtApplRule);

        AccountNo := TempCustomerLedgerEntryMatchingBuffer."Account No.";
        BankAccReconciliationLine.GetAmountRangeForTolerance(MinAmount, MaxAmount);
        TempCustomerLedgerEntryMatchingBuffer.Reset;
        TempCustomerLedgerEntryMatchingBuffer.SetRange("Account No.", AccountNo);
        NoOfLedgerEntriesWithinTolerance :=
          TempCustomerLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
        NoOfLedgerEntriesOutsideTolerance :=
          TempCustomerLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesOutsideRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
    end;

    procedure MatchSingleLineVendor(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AppliesToEntryNo: Integer; var NoOfLedgerEntriesWithinTolerance: Integer; var NoOfLedgerEntriesOutsideTolerance: Integer)
    var
        MinAmount: Decimal;
        MaxAmount: Decimal;
        AccountNo: Code[20];
    begin
        ApplyEntries := false;
        InitializeVendorLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempVendorLedgerEntryMatchingBuffer);
        if not TempVendorLedgerEntryMatchingBuffer.Get(AppliesToEntryNo, TempVendorLedgerEntryMatchingBuffer."Account Type"::Vendor) then;

        FindMatchingEntry(
          TempVendorLedgerEntryMatchingBuffer, BankAccReconciliationLine, TempBankStatementMatchingBuffer."Account Type"::Vendor,
          BankPmtApplRule);

        AccountNo := TempVendorLedgerEntryMatchingBuffer."Account No.";
        BankAccReconciliationLine.GetAmountRangeForTolerance(MinAmount, MaxAmount);
        TempVendorLedgerEntryMatchingBuffer.Reset;
        TempVendorLedgerEntryMatchingBuffer.SetRange("Account No.", AccountNo);

        NoOfLedgerEntriesWithinTolerance :=
          TempVendorLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
        NoOfLedgerEntriesOutsideTolerance :=
          TempVendorLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesOutsideRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
    end;

    [Scope('OnPrem')]
    procedure MatchSingleLineGLAccount(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AppliesToEntryNo: Integer; var NoOfLedgerEntriesWithinTolerance: Integer; var NoOfLedgerEntriesOutsideTolerance: Integer)
    var
        MinAmount: Decimal;
        MaxAmount: Decimal;
        AccountNo: Code[20];
    begin
        // NAVCZ
        ApplyEntries := false;
        InitializeGeneralLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempGeneralLedgerEntryMatchingBuffer);
        if not TempGeneralLedgerEntryMatchingBuffer.Get(
             AppliesToEntryNo, TempGeneralLedgerEntryMatchingBuffer."Account Type"::"G/L Account")
        then
            ;

        FindMatchingEntry(
          TempGeneralLedgerEntryMatchingBuffer, BankAccReconciliationLine, TempBankStatementMatchingBuffer."Account Type"::"G/L Account",
          BankPmtApplRule);

        AccountNo := TempGeneralLedgerEntryMatchingBuffer."Account No.";
        BankAccReconciliationLine.GetAmountRangeForTolerance(MinAmount, MaxAmount);
        TempGeneralLedgerEntryMatchingBuffer.Reset;
        TempGeneralLedgerEntryMatchingBuffer.SetRange("Account No.", AccountNo);

        NoOfLedgerEntriesWithinTolerance :=
          TempGeneralLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", false);
        NoOfLedgerEntriesOutsideTolerance :=
          TempGeneralLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesOutsideRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", false);
    end;

    procedure MatchSingleLineBankAccountLedgerEntry(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AppliesToEntryNo: Integer; var NoOfLedgerEntriesWithinTolerance: Integer; var NoOfLedgerEntriesOutsideTolerance: Integer)
    var
        MinAmount: Decimal;
        MaxAmount: Decimal;
        AccountNo: Code[20];
    begin
        ApplyEntries := false;
        InitializeBankAccLedgerEntriesMatchingBuffer(BankAccReconciliationLine, TempBankAccLedgerEntryMatchingBuffer);
        with TempBankAccLedgerEntryMatchingBuffer do
            if not Get(AppliesToEntryNo, "Account Type"::"Bank Account") then;

        FindMatchingEntry(
          TempBankAccLedgerEntryMatchingBuffer, BankAccReconciliationLine, TempBankStatementMatchingBuffer."Account Type"::"Bank Account",
          BankPmtApplRule);

        AccountNo := TempBankAccLedgerEntryMatchingBuffer."Account No.";
        BankAccReconciliationLine.GetAmountRangeForTolerance(MinAmount, MaxAmount);
        TempBankAccLedgerEntryMatchingBuffer.Reset;
        TempBankAccLedgerEntryMatchingBuffer.SetRange("Account No.", AccountNo);

        NoOfLedgerEntriesWithinTolerance :=
          TempBankAccLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", false);
        NoOfLedgerEntriesOutsideTolerance :=
          TempBankAccLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesOutsideRange(
            MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", false);
    end;

    local procedure FindMatchingEntries(var TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary; var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; AccountType: Option)
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
    begin
        TempLedgerEntryMatchingBuffer.Reset;
        if TempLedgerEntryMatchingBuffer.FindFirst then
            repeat
                FindMatchingEntry(TempLedgerEntryMatchingBuffer, TempBankAccReconciliationLine, AccountType, BankPmtApplRule);
            until TempLedgerEntryMatchingBuffer.Next = 0;
    end;

    local procedure FindMatchingEntry(TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option; var BankPmtApplRule: Record "Bank Pmt. Appl. Rule")
    var
        Score: Integer;
        RemainingAmount: Decimal;
        IsHandled: Boolean;
    begin
        if CanEntriesMatch(
             BankAccReconciliationLine, TempLedgerEntryMatchingBuffer."Remaining Amount", TempLedgerEntryMatchingBuffer."Posting Date")
        then begin
            if AccountType = TempBankStatementMatchingBuffer."Account Type"::Customer then
                DirectDebitCollectionMatching(BankPmtApplRule, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer);

            RelatedPartyMatching(BankPmtApplRule, TempLedgerEntryMatchingBuffer, BankAccReconciliationLine, AccountType);

            IsHandled := false;
            OnFindMatchingEntryOnBeforeDocumentMatching(BankPmtApplRule, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer, IsHandled);
            if not IsHandled then
                if AccountType <> TempBankStatementMatchingBuffer."Account Type"::"Bank Account" then
                    DocumentMatching(BankPmtApplRule, BankAccReconciliationLine,
                    TempLedgerEntryMatchingBuffer."Document No.", TempLedgerEntryMatchingBuffer."External Document No.")
                else
                    DocumentMatchingForBankLedgerEntry(BankPmtApplRule, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer);

            RemainingAmount := TempLedgerEntryMatchingBuffer.GetApplicableRemainingAmount(BankAccReconciliationLine, UsePaymentDiscounts);
            AmountInclToleranceMatching(
              BankPmtApplRule, BankAccReconciliationLine, AccountType, RemainingAmount);

            // NAVCZ
            VariableSymbolMatching(BankPmtApplRule, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer."Variable Symbol");
            SpecificSymbolMatching(BankPmtApplRule, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer."Specific Symbol");
            ConstantSymbolMatching(BankPmtApplRule, BankAccReconciliationLine, TempLedgerEntryMatchingBuffer."Constant Symbol");
            BankPmtApplRule."Bank Transaction Type" := BankPmtApplRule.GetBankTransactionType(RemainingAmount);
            // NAVCZ

            Score := TempBankPmtApplRule.GetBestMatchScore(BankPmtApplRule);

            if Score >= MinimumMatchScore then
                TempBankStatementMatchingBuffer.AddMatchCandidate(
                  BankAccReconciliationLine."Statement Line No.", TempLedgerEntryMatchingBuffer."Entry No.",
                  Score, AccountType,
                  TempLedgerEntryMatchingBuffer."Account No.");

            // NAVCZ
            if (BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" = BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes) or
               (BankPmtApplRule."Variable Symbol Matched" = BankPmtApplRule."Variable Symbol Matched"::Yes) or
               (BankPmtApplRule."Specific Symbol Matched" = BankPmtApplRule."Specific Symbol Matched"::Yes) or
               (BankPmtApplRule."Constant Symbol Matched" = BankPmtApplRule."Constant Symbol Matched"::Yes)
            then begin
                // NAVCZ
                TempBankStatementMatchingBuffer.InsertOrUpdateOneToManyRule(
                  TempLedgerEntryMatchingBuffer,
                  BankAccReconciliationLine."Statement Line No.",
                  BankPmtApplRule."Related Party Matched", AccountType,
                  RemainingAmount,
                  BankPmtApplRule); // NAVCZ

                TempBankStmtMultipleMatchLine.InsertLine(
                  TempLedgerEntryMatchingBuffer,
                  BankAccReconciliationLine."Statement Line No.", AccountType);
            end;
        end;
    end;

    local procedure FindMatchingAdvanceLetters(var TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary; var TempAdvanceLetterMatchingBuffer: Record "Advance Letter Matching Buffer" temporary; AccountType: Option)
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
    begin
        // NAVCZ
        TempAdvanceLetterMatchingBuffer.Reset;
        TempAdvanceLetterMatchingBuffer.SetAscending("Letter No.", false);
        if TempAdvanceLetterMatchingBuffer.FindSet then
            repeat
                FindMatchingAdvanceLetter(TempAdvanceLetterMatchingBuffer, TempBankAccReconciliationLine, AccountType, BankPmtApplRule);
            until TempAdvanceLetterMatchingBuffer.Next = 0;
    end;

    local procedure FindMatchingAdvanceLetter(var TempAdvanceLetterMatchingBuffer: Record "Advance Letter Matching Buffer" temporary; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option; var BankPmtApplRule: Record "Bank Pmt. Appl. Rule")
    var
        Score: Integer;
    begin
        // NAVCZ
        if CanEntriesMatch(
             BankAccReconciliationLine, TempAdvanceLetterMatchingBuffer."Remaining Amount", TempAdvanceLetterMatchingBuffer."Posting Date")
        then begin
            RelatedPartyMatchingForAdvanceLetter(BankPmtApplRule, TempAdvanceLetterMatchingBuffer, BankAccReconciliationLine, AccountType);
            DocumentMatching(BankPmtApplRule, BankAccReconciliationLine,
              TempAdvanceLetterMatchingBuffer."Letter No.", TempAdvanceLetterMatchingBuffer."External Document No.");

            AmountInclToleranceMatchingForAdvanceLetter(
              BankPmtApplRule, BankAccReconciliationLine, AccountType, TempAdvanceLetterMatchingBuffer."Remaining Amount");

            VariableSymbolMatching(BankPmtApplRule, BankAccReconciliationLine, TempAdvanceLetterMatchingBuffer."Variable Symbol");
            SpecificSymbolMatching(BankPmtApplRule, BankAccReconciliationLine, TempAdvanceLetterMatchingBuffer."Specific Symbol");
            ConstantSymbolMatching(BankPmtApplRule, BankAccReconciliationLine, TempAdvanceLetterMatchingBuffer."Constant Symbol");
            BankPmtApplRule."Bank Transaction Type" :=
              BankPmtApplRule.GetBankTransactionType(TempAdvanceLetterMatchingBuffer."Remaining Amount");

            Score := TempBankPmtApplRule.GetBestMatchScore(BankPmtApplRule);

            if Score >= MinimumMatchScore then
                TempBankStatementMatchingBuffer.AddMatchCandidateForAdvanceLetter(
                  BankAccReconciliationLine."Statement Line No.", Score, AccountType,
                  TempAdvanceLetterMatchingBuffer."Account No.",
                  TempAdvanceLetterMatchingBuffer."Letter No.");

            if (BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" = BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes) or
               (BankPmtApplRule."Variable Symbol Matched" = BankPmtApplRule."Variable Symbol Matched"::Yes) or
               (BankPmtApplRule."Specific Symbol Matched" = BankPmtApplRule."Specific Symbol Matched"::Yes) or
               (BankPmtApplRule."Constant Symbol Matched" = BankPmtApplRule."Constant Symbol Matched"::Yes)
            then begin
                TempBankStatementMatchingBuffer.InsertOrUpdateOneToManyRuleForAdvanceLetter(
                  TempAdvanceLetterMatchingBuffer,
                  BankPmtApplRule,
                  BankAccReconciliationLine."Statement Line No.",
                  AccountType,
                  TempAdvanceLetterMatchingBuffer."Remaining Amount");

                TempBankStmtMultipleMatchLine.InsertLineForAdvanceLetter(
                  TempAdvanceLetterMatchingBuffer,
                  BankAccReconciliationLine."Statement Line No.", AccountType);
            end;
        end;
    end;

    local procedure InitializeCustomerLedgerEntriesMatchingBuffer(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // NAVCZ
        if NotApplyCustLedgerEntries then
            exit;

        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           TempCustLedgMatchingBufferInitialized
        then begin
            CopyLedgEntryMatchingBuffer(TempCustomerLedgerEntryMatchingBufferStore, TempLedgerEntryMatchingBuffer);
            exit;
        end;

        SalesReceivablesSetup.Get;

        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Prepayment, false); // NAVCZ

        OnInitCustomerLedgerEntriesMatchingBufferSetFilter(CustLedgerEntry, BankAccReconciliationLine);

        if BankAccReconciliationLine.IsInLocalCurrency then begin // NAVCZ
            CustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
            if SalesReceivablesSetup."Appln. between Currencies" = SalesReceivablesSetup."Appln. between Currencies"::None then begin
                GeneralLedgerSetup.Get;
                CustLedgerEntry.SetFilter("Currency Code", '=%1|=%2', '', GeneralLedgerSetup.GetCurrencyCode(''));
            end;
        end else begin
            CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
            CustLedgerEntry.SetRange("Currency Code", BankAccReconciliationLine."Currency Code"); // NAVCZ
        end;

        if CustLedgerEntry.FindSet then
            repeat
                TempLedgerEntryMatchingBuffer.InsertFromCustomerLedgerEntry(
                  CustLedgerEntry, BankAccReconciliationLine.IsInLocalCurrency, UsePaymentDiscounts); // NAVCZ
            until CustLedgerEntry.Next = 0;

        // NAVCZ
        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           not TempCustLedgMatchingBufferInitialized
        then begin
            CopyLedgEntryMatchingBuffer(TempLedgerEntryMatchingBuffer, TempCustomerLedgerEntryMatchingBufferStore);
            TempCustLedgMatchingBufferInitialized := true;
        end;
    end;

    local procedure InitializeVendorLedgerEntriesMatchingBuffer(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        // NAVCZ
        if NotApplyVendLedgerEntries then
            exit;

        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           TempVendLedgMatchingBufferInitialized
        then begin
            CopyLedgEntryMatchingBuffer(TempVendorLedgerEntryMatchingBufferStore, TempLedgerEntryMatchingBuffer);
            exit;
        end;
        // NAVCZ

        PurchasesPayablesSetup.Get;

        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.SetRange(Prepayment, false); // NAVCZ

        OnInitVendorLedgerEntriesMatchingBufferSetFilter(VendorLedgerEntry, BankAccReconciliationLine);

        if BankAccReconciliationLine.IsInLocalCurrency then begin // NAVCZ
            VendorLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
            if PurchasesPayablesSetup."Appln. between Currencies" = PurchasesPayablesSetup."Appln. between Currencies"::None then begin
                GeneralLedgerSetup.Get;
                VendorLedgerEntry.SetFilter("Currency Code", '=%1|=%2', '', GeneralLedgerSetup.GetCurrencyCode(''));
            end;
        end else begin
            VendorLedgerEntry.SetAutoCalcFields("Remaining Amount");
            VendorLedgerEntry.SetRange("Currency Code", BankAccReconciliationLine."Currency Code"); // NAVCZ
        end;

        if VendorLedgerEntry.FindSet then
            repeat
                TempLedgerEntryMatchingBuffer.InsertFromVendorLedgerEntry(
                  VendorLedgerEntry, BankAccReconciliationLine.IsInLocalCurrency, UsePaymentDiscounts); // NAVCZ
            until VendorLedgerEntry.Next = 0;

        // NAVCZ
        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           not TempVendLedgMatchingBufferInitialized
        then begin
            CopyLedgEntryMatchingBuffer(TempLedgerEntryMatchingBuffer, TempVendorLedgerEntryMatchingBufferStore);
            TempVendLedgMatchingBufferInitialized := true;
        end;
    end;

    local procedure InitializeGeneralLedgerEntriesMatchingBuffer(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary)
    var
        GLEntry: Record "G/L Entry";
    begin
        // NAVCZ
        if NotApplyGenLedgerEntries then
            exit;

        if ApplyEntries or not BankAccReconciliationLine.IsInLocalCurrency or
           (BankAccReconciliationLine."Account Type" <> BankAccReconciliationLine."Account Type"::"G/L Account") or
           (BankAccReconciliationLine."Account No." = '')
        then
            exit;

        GLEntry.SetRange(Closed, false);
        GLEntry.SetRange("G/L Account No.", BankAccReconciliationLine."Account No.");

        if GLEntry.FindSet then
            repeat
                TempLedgerEntryMatchingBuffer.InsertFromGeneralLedgerEntry(GLEntry);
            until GLEntry.Next = 0;
    end;

    local procedure InitializeSalesAdvanceLettersMatchingBuffer(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempSalesAdvanceMatchingBuffer: Record "Advance Letter Matching Buffer" temporary)
    var
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // NAVCZ
        if NotApplySalesAdvances then
            exit;

        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           TempSalesAdvLedgMatchingBufferInitialized
        then begin
            CopyAdvLetterMatchingBuffer(TempSalesAdvanceLetterMatchingBufferStore, TempSalesAdvanceMatchingBuffer);
            exit;
        end;

        SalesAdvanceLetterHeader.SetRange(Closed, false);
        SalesAdvanceLetterHeader.SetRange(Status, SalesAdvanceLetterHeader.Status::"Pending Payment");

        if not BankAccReconciliationLine.IsInLocalCurrency then
            SalesAdvanceLetterHeader.SetRange("Currency Code", BankAccReconciliationLine."Currency Code")
        else begin
            GeneralLedgerSetup.Get;
            SalesAdvanceLetterHeader.SetFilter("Currency Code", '=%1|=%2', '', GeneralLedgerSetup.GetCurrencyCode(''));
        end;

        if SalesAdvanceLetterHeader.FindSet then
            repeat
                TempSalesAdvanceMatchingBuffer.InsertFromSalesAdvanceLetterHeader(
                  SalesAdvanceLetterHeader, BankAccReconciliationLine.IsInLocalCurrency);
            until SalesAdvanceLetterHeader.Next = 0;

        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           not TempSalesAdvLedgMatchingBufferInitialized
        then begin
            CopyAdvLetterMatchingBuffer(TempSalesAdvanceMatchingBuffer, TempSalesAdvanceLetterMatchingBufferStore);
            TempSalesAdvLedgMatchingBufferInitialized := true;
        end;
    end;

    local procedure InitializePurchaseAdvanceLettersMatchingBuffer(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempPurchAdvanceLetterMatchingBuffer: Record "Advance Letter Matching Buffer" temporary)
    var
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // NAVCZ
        if NotApplyPurchaseAdvances then
            exit;

        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           TempPurchAdvLedgMatchingBufferInitialized
        then begin
            CopyAdvLetterMatchingBuffer(TempPurchAdvanceLetterMatchingBufferStore, TempPurchAdvanceLetterMatchingBuffer);
            exit;
        end;

        PurchAdvanceLetterHeader.SetRange(Closed, false);
        PurchAdvanceLetterHeader.SetRange(Status, PurchAdvanceLetterHeader.Status::"Pending Payment");

        if not BankAccReconciliationLine.IsInLocalCurrency then
            PurchAdvanceLetterHeader.SetRange("Currency Code", BankAccReconciliationLine."Currency Code")
        else begin
            GeneralLedgerSetup.Get;
            PurchAdvanceLetterHeader.SetFilter("Currency Code", '=%1|=%2', '', GeneralLedgerSetup.GetCurrencyCode(''));
        end;

        if PurchAdvanceLetterHeader.FindSet then
            repeat
                TempPurchAdvanceLetterMatchingBuffer.InsertFromPurchaseAdvanceLetterHeader(
                  PurchAdvanceLetterHeader, BankAccReconciliationLine.IsInLocalCurrency);
            until PurchAdvanceLetterHeader.Next = 0;

        if (BankAccount."Currency Code" = BankAccReconciliationLine."Currency Code") and
           not TempPurchAdvLedgMatchingBufferInitialized
        then begin
            CopyAdvLetterMatchingBuffer(TempPurchAdvanceLetterMatchingBuffer, TempPurchAdvanceLetterMatchingBufferStore);
            TempPurchAdvLedgMatchingBufferInitialized := true;
        end;
    end;

    local procedure InitializeBankAccLedgerEntriesMatchingBuffer(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; var TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary)
    var
        BankAccLedgerEntry: Record "Bank Account Ledger Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        // NAVCZ
        if NotAplBankAccLedgEntries then
            exit;

        BankAccount.Get(BankAccReconciliationLine."Bank Account No.");
        PurchasesPayablesSetup.Get;

        BankAccLedgerEntry.SetRange(Open, true);
        BankAccLedgerEntry.SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");

        OnInitBankAccLedgerEntriesMatchingBufferSetFilter(BankAccLedgerEntry, BankAccReconciliationLine);

        if BankAccount.IsInLocalCurrency then
            if PurchasesPayablesSetup."Appln. between Currencies" = PurchasesPayablesSetup."Appln. between Currencies"::None then begin
                GeneralLedgerSetup.Get;
                BankAccLedgerEntry.SetFilter("Currency Code", '=%1|=%2', '', GeneralLedgerSetup.GetCurrencyCode(''));
            end else
                BankAccLedgerEntry.SetRange("Currency Code", BankAccount."Currency Code");

        if BankAccLedgerEntry.FindSet then
            repeat
                TempLedgerEntryMatchingBuffer.InsertFromBankAccLedgerEntry(BankAccLedgerEntry);
            until BankAccLedgerEntry.Next = 0;
    end;

    local procedure InitializeDirectDebitCollectionEntriesMatchingBuffer(var TempDirectDebitCollectionEntryBuffer: Record "Direct Debit Collection Entry" temporary)
    var
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
    begin
        if DirectDebitCollectionEntry.FindSet then begin
            repeat
                TempDirectDebitCollectionEntryBuffer := DirectDebitCollectionEntry;
                TempDirectDebitCollectionEntryBuffer.Insert;
            until DirectDebitCollectionEntry.Next = 0;
        end;
    end;

    local procedure FindTextMappings(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"): Boolean
    var
        TextToAccMapping: Record "Text-to-Account Mapping";
        BankAccLedgerEntry: Record "Bank Account Ledger Entry";
        RecordMatchMgt: Codeunit "Record Match Mgt.";
        Nearness: Integer;
        Score: Integer;
        AccountType: Option;
        AccountNo: Code[20];
        EntryNo: Integer;
        TextMapperMatched: Boolean;
        ExtendedTextMapperMatched: Boolean;
    begin
        TextMapperMatched := false;
        // NAVCZ
        if NotUseTextToAccMappingCode then
            exit(TextMapperMatched);

        if UseExtSetup then
            TextToAccMapping.SetRange("Text-to-Account Mapping Code", TextToAccMappingCode)
        else
            TextToAccMapping.FilterTextToAccountMapping(BankAccReconciliationLine);
        TextToAccMapping.SetFilter("Bank Transaction Type", '%1|%2',
          TextToAccMapping."Bank Transaction Type"::Both,
          TextToAccMapping.GetBankTransactionType(BankAccReconciliationLine."Statement Amount"));
        // NAVCZ
        if TextToAccMapping.FindSet then
            repeat
                Nearness := GetExactMatchTreshold; // NAVCZ
                if TextToAccMapping."Mapping Text" <> '' then // NAVCZ
                    Nearness := RecordMatchMgt.CalculateStringNearness(RecordMatchMgt.Trim(TextToAccMapping."Mapping Text"),
                        BankAccReconciliationLine."Transaction Text", StrLen(TextToAccMapping."Mapping Text"), GetNormalizingFactor);

                ExtendedTextMapperMatched := TextToAccMapping.ExtendedMatching(BankAccReconciliationLine); // NAVCZ

                case TextToAccMapping."Bal. Source Type" of
                    TextToAccMapping."Bal. Source Type"::"G/L Account":
                        if BankAccReconciliationLine."Statement Amount" >= 0 then
                            AccountNo := TextToAccMapping."Debit Acc. No."
                        else
                            AccountNo := TextToAccMapping."Credit Acc. No.";
                    else // Customer or Vendor
                        AccountNo := TextToAccMapping."Bal. Source No.";
                end;

                if (Nearness >= GetExactMatchTreshold) and ExtendedTextMapperMatched then begin // NAVCZ
                    if FindBankAccLedgerEntry(BankAccLedgerEntry, BankAccReconciliationLine, TextToAccMapping, AccountNo) then begin
                        EntryNo := BankAccLedgerEntry."Entry No.";
                        AccountType := TempBankStatementMatchingBuffer."Account Type"::"Bank Account";
                        AccountNo := BankAccLedgerEntry."Bank Account No.";
                    end else begin
                        EntryNo := -TextToAccMapping."Line No."; // mark negative to identify text-mapper
                        AccountType := TextToAccMapping."Bal. Source Type";
                    end;

                    TempBankPmtApplRule.Priority := TextToAccMapping.Priority; // NAVCZ
                    Score := TempBankPmtApplRule.GetTextMapperScore;
                    TempBankStatementMatchingBuffer.AddMatchCandidate(
                      BankAccReconciliationLine."Statement Line No.", EntryNo,
                      Score, AccountType, AccountNo);
                    TextMapperMatched := true;
                end;
            until TextToAccMapping.Next = 0;
        exit(TextMapperMatched)
    end;

    local procedure FindBankAccLedgerEntry(var BankAccLedgerEntry: Record "Bank Account Ledger Entry"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TextToAccountMapping: Record "Text-to-Account Mapping"; BalAccountNo: Code[20]): Boolean
    begin
        // NAVCZ
        if NotAplBankAccLedgEntries then
            exit(false);
        // NAVCZ
        with BankAccLedgerEntry do begin
            SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
            SetRange(Open, true);
            SetRange("Bal. Account Type", TextToAccountMapping."Bal. Source Type");
            SetRange("Bal. Account No.", BalAccountNo);
            SetRange("Remaining Amount", BankAccReconciliationLine."Statement Amount");
            exit(FindFirst);
        end;
    end;

    local procedure CreateAppliedEntries(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.SetCurrentKey(Quality, "No. of Entries");
        TempBankStatementMatchingBuffer.Ascending(false);

        TempBankStmtMultipleMatchLine.SetCurrentKey("Due Date");

        if TempBankStatementMatchingBuffer.FindSet then
            repeat
                BankAccReconciliationLine.Get(
                  BankAccReconciliation."Statement Type", BankAccReconciliation."Bank Account No.", BankAccReconciliation."Statement No.",
                  TempBankStatementMatchingBuffer."Line No.");

                if not StatementLineAlreadyApplied(TempBankStatementMatchingBuffer, BankAccReconciliationLine) then begin
                    PrepareLedgerEntryForApplication(BankAccReconciliationLine);
                    ApplyRecords(BankAccReconciliationLine, TempBankStatementMatchingBuffer);
                end;
            until TempBankStatementMatchingBuffer.Next = 0;
    end;

    local procedure ApplyRecords(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Boolean
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        if TempBankStatementMatchingBuffer.Quality = 0 then
            exit(false);

        if TempBankStatementMatchingBuffer."One to Many Match" then
            ApplyOneToMany(BankAccReconciliationLine, TempBankStatementMatchingBuffer)
        else
            // NAVCZ
            if TempBankStatementMatchingBuffer."Letter No." <> '' then
                ApplyAdvanceLetter(BankAccReconciliationLine, TempBankStatementMatchingBuffer,
                  TempBankStatementMatchingBuffer."Letter Type", TempBankStatementMatchingBuffer."Letter No.")
            else begin
                // NAVCZ
                if EntryAlreadyApplied(TempBankStatementMatchingBuffer, BankAccReconciliationLine, TempBankStatementMatchingBuffer."Entry No.")
                then
                    if not CanApplyManyToOne(TempBankStatementMatchingBuffer, BankAccReconciliationLine) then
                        exit(false);

                AppliedPaymentEntry.ApplyFromBankStmtMatchingBuf(BankAccReconciliationLine, TempBankStatementMatchingBuffer,
                  BankAccReconciliationLine."Statement Amount", TempBankStatementMatchingBuffer."Entry No.");
            end; // NAVCZ

        exit(true);
    end;

    local procedure ApplyOneToMany(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary)
    var
        PaymentMatchingDetails: Record "Payment Matching Details";
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        TempBankStmtMultipleMatchLine.SetRange("Letter No."); // NAVCZ
        TempBankStmtMultipleMatchLine.SetRange("Line No.", TempBankStatementMatchingBuffer."Line No.");
        TempBankStmtMultipleMatchLine.SetRange("Account Type", TempBankStatementMatchingBuffer."Account Type");
        TempBankStmtMultipleMatchLine.SetRange("Account No.", TempBankStatementMatchingBuffer."Account No.");
        TempBankStmtMultipleMatchLine.FindSet;

        repeat
            // NAVCZ
            if TempBankStmtMultipleMatchLine."Letter No." <> '' then
                TempBankStmtMultipleMatchLine.SetFilter("Letter No.", '<>%1', '')
            else
                TempBankStmtMultipleMatchLine.SetRange("Letter No.", '');
            // NAVCZ
            AppliedPaymentEntry.TransferFromBankAccReconLine(BankAccReconciliationLine);
            if AppliedPaymentEntry.GetStmtLineRemAmtToApply = 0 then
                PaymentMatchingDetails.CreatePaymentMatchingDetail(BankAccReconciliationLine,
                  StrSubstNo(CannotApplyDocumentNoOneToManyApplicationTxt, TempBankStmtMultipleMatchLine."Document No."))
            else begin
                Clear(AppliedPaymentEntry);
                // NAVCZ
                if TempBankStmtMultipleMatchLine."Letter No." <> '' then
                    ApplyAdvanceLetter(BankAccReconciliationLine, TempBankStatementMatchingBuffer,
                      TempBankStmtMultipleMatchLine."Letter Type", TempBankStmtMultipleMatchLine."Letter No.")
                else
                    // NAVCZ
                    if not EntryAlreadyApplied(
                         TempBankStatementMatchingBuffer, BankAccReconciliationLine, TempBankStmtMultipleMatchLine."Entry No.")
                    then
                        AppliedPaymentEntry.ApplyFromBankStmtMatchingBuf(BankAccReconciliationLine, TempBankStatementMatchingBuffer,
                          BankAccReconciliationLine."Statement Amount", TempBankStmtMultipleMatchLine."Entry No.")
            end;
        until TempBankStmtMultipleMatchLine.Next = 0;
    end;

    local procedure ApplyAdvanceLetter(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; LetterType: Option; LetterNo: Code[20])
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
        AppliedAmount: Decimal;
        AdvanceLetterLinkCode: Code[30];
    begin
        // NAVCZ
        if not BankAccReconciliationLine.Get(
             BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.",
             BankAccReconciliationLine."Statement No.", TempBankStatementMatchingBuffer."Line No.")
        then
            BankAccReconciliationLine.Init;
        AdvanceLetterLinkCode :=
          StrSubstNo('%1 %2', BankAccReconciliationLine."Statement No.", BankAccReconciliationLine."Statement Line No.");
        AppliedAmount :=
          ApplyAdvanceLetterLines(
            LetterType, LetterNo,
            BankAccReconciliationLine.Difference,
            AdvanceLetterLinkCode);

        if AppliedAmount <> 0 then begin
            if BankAccReconciliationLine."Advance Letter Link Code" <> AdvanceLetterLinkCode then begin
                case TempBankStatementMatchingBuffer."Account Type" of
                    TempBankStatementMatchingBuffer."Account Type"::Customer:
                        BankAccReconciliationLine.Validate("Account Type", BankAccReconciliationLine."Account Type"::Customer);
                    TempBankStatementMatchingBuffer."Account Type"::Vendor:
                        BankAccReconciliationLine.Validate("Account Type", BankAccReconciliationLine."Account Type"::Vendor);
                end;

                BankAccReconciliationLine.Validate("Account No.", TempBankStatementMatchingBuffer."Account No.");
                BankAccReconciliationLine."Advance Letter Link Code" := AdvanceLetterLinkCode;
                BankAccReconciliationLine."Posting Group" := GetPostingGroupFromAdvanceLetter(LetterType, LetterNo);
                BankAccReconciliationLine.Prepayment := true;
            end;

            BankAccReconciliationLine."Applied Amount" += AppliedAmount;
            BankAccReconciliationLine.Validate("Applied Amount");
            BankAccReconciliationLine.Modify;

            AppliedPaymentEntry.Reset;
            AppliedPaymentEntry.FilterAppliedPmtEntry(BankAccReconciliationLine);
            if not AppliedPaymentEntry.FindFirst then begin
                AppliedPaymentEntry.Init;
                AppliedPaymentEntry.TransferFromBankAccReconLine(BankAccReconciliationLine);
                AppliedPaymentEntry."Account Type" := BankAccReconciliationLine."Account Type";
                AppliedPaymentEntry."Account No." := BankAccReconciliationLine."Account No.";
                AppliedPaymentEntry."Match Confidence" :=
                  TempBankPmtApplRule.GetMatchConfidence(TempBankStatementMatchingBuffer.Quality, false);
                AppliedPaymentEntry.Quality := TempBankStatementMatchingBuffer.Quality;
                AppliedPaymentEntry."Applies-to Entry No." := -1;
                AppliedPaymentEntry.Validate("Applied Amount", AppliedAmount);
                AppliedPaymentEntry.Insert;
            end else begin
                AppliedPaymentEntry."Applied Amount" += AppliedAmount;
                AppliedPaymentEntry.Validate("Applied Amount");
                AppliedPaymentEntry.Modify;
            end;
        end;
    end;

    local procedure ApplyAdvanceLetterLines(LetterType: Option; LetterNo: Code[20]; Amount: Decimal; AdvanceLetterLinkCode: Code[30]): Decimal
    var
        SalesAdvanceLetterLine: Record "Sales Advance Letter Line";
        PurchAdvanceLetterLine: Record "Purch. Advance Letter Line";
        SourceAmount: Decimal;
        RemainingAmount: Decimal;
        Exp: Decimal;
    begin
        // NAVCZ
        SourceAmount := Abs(Amount);
        case LetterType of
            TempBankStatementMatchingBuffer."Letter Type"::Sales:
                begin
                    SalesAdvanceLetterLine.SetRange("Letter No.", LetterNo);
                    SalesAdvanceLetterLine.SetRange("Link Code", '');
                    SalesAdvanceLetterLine.SetRange("Amount To Link", SourceAmount);
                    if SalesAdvanceLetterLine.IsEmpty then
                        SalesAdvanceLetterLine.SetFilter("Amount To Link", '<>%1', 0);
                    if SalesAdvanceLetterLine.FindSet then
                        repeat
                            SalesAdvanceLetterLine."Link Code" := AdvanceLetterLinkCode;
                            RemainingAmount := Abs(SalesAdvanceLetterLine."Amount To Link");
                            if RemainingAmount >= SourceAmount then begin
                                SalesAdvanceLetterLine."Amount Linked To Journal Line" := SourceAmount;
                                SourceAmount := 0;
                            end else begin
                                SalesAdvanceLetterLine."Amount Linked To Journal Line" := RemainingAmount;
                                SourceAmount -= RemainingAmount;
                            end;
                            SalesAdvanceLetterLine.Modify;
                        until (SalesAdvanceLetterLine.Next = 0) or (SourceAmount <= 0);
                end;
            TempBankStatementMatchingBuffer."Letter Type"::Purchase:
                begin
                    PurchAdvanceLetterLine.SetRange("Letter No.", LetterNo);
                    PurchAdvanceLetterLine.SetRange("Link Code", '');
                    PurchAdvanceLetterLine.SetRange("Amount To Link", SourceAmount);
                    if PurchAdvanceLetterLine.IsEmpty then
                        PurchAdvanceLetterLine.SetFilter("Amount To Link", '<>%1', 0);
                    if PurchAdvanceLetterLine.FindSet then
                        repeat
                            PurchAdvanceLetterLine."Link Code" := AdvanceLetterLinkCode;
                            RemainingAmount := Abs(PurchAdvanceLetterLine."Amount To Link");
                            if RemainingAmount >= SourceAmount then begin
                                PurchAdvanceLetterLine."Amount Linked To Journal Line" := -SourceAmount;
                                SourceAmount := 0;
                            end else begin
                                PurchAdvanceLetterLine."Amount Linked To Journal Line" := -RemainingAmount;
                                SourceAmount -= RemainingAmount;
                            end;
                            PurchAdvanceLetterLine.Modify;
                        until (PurchAdvanceLetterLine.Next = 0) or (SourceAmount <= 0);
                end;
        end;

        Exp := Amount / Abs(Amount);
        exit(Exp * (Abs(Amount) - SourceAmount));
    end;

    local procedure GetPostingGroupFromAdvanceLetter(LetterType: Option; LetterNo: Code[20]): Code[10]
    var
        SalesAdvanceLetterHeader: Record "Sales Advance Letter Header";
        PurchAdvanceLetterHeader: Record "Purch. Advance Letter Header";
    begin
        // NAVCZ
        case LetterType of
            TempBankStatementMatchingBuffer."Letter Type"::Sales:
                begin
                    SalesAdvanceLetterHeader.Get(LetterNo);
                    exit(SalesAdvanceLetterHeader."Customer Posting Group");
                end;
            TempBankStatementMatchingBuffer."Letter Type"::Purchase:
                begin
                    PurchAdvanceLetterHeader.Get(LetterNo);
                    exit(PurchAdvanceLetterHeader."Vendor Posting Group");
                end;
        end;
    end;

    local procedure CanEntriesMatch(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; Amount: Decimal; EntryPostingDate: Date): Boolean
    begin
        if not ApplyEntries then
            exit(true);

        if BankAccReconciliationLine."Statement Amount" * Amount < 0 then
            exit(false);

        if ApplyEntries then begin
            if BankAccReconciliationLine."Transaction Date" < EntryPostingDate then
                exit(false);
        end;

        exit(true);
    end;

    local procedure CanApplyManyToOne(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary): Boolean
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
        HasPositiveApplications: Boolean;
        HasNegativeApplications: Boolean;
    begin
        // Many to one application is possbile if previous applied are for same Account
        SetFilterToRelatedApplications(AppliedPaymentEntry, TempBankStatementMatchingBuffer,
          TempBankAccReconciliationLine);
        if AppliedPaymentEntry.IsEmpty then
            exit(false);

        // Not possible if positive and negative applications already exists
        AppliedPaymentEntry.SetFilter("Applied Amount", '>0');
        HasPositiveApplications := not AppliedPaymentEntry.IsEmpty;
        AppliedPaymentEntry.SetFilter("Applied Amount", '<0');
        HasNegativeApplications := not AppliedPaymentEntry.IsEmpty;
        if HasPositiveApplications and HasNegativeApplications then
            exit(false);

        // Remaining amount should not be 0
        exit(GetRemainingAmount(TempBankStatementMatchingBuffer, TempBankAccReconciliationLine) <> 0);
    end;

    local procedure RelatedPartyMatchingForAdvanceLetter(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; TempAdvanceLetterMatchingBuffer: Record "Advance Letter Matching Buffer" temporary; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option)
    var
        TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary;
    begin
        // NAVCZ
        TempLedgerEntryMatchingBuffer."Account No." := TempAdvanceLetterMatchingBuffer."Account No.";
        RelatedPartyMatching(BankPmtApplRule, TempLedgerEntryMatchingBuffer, BankAccReconciliationLine, AccountType);
    end;

    local procedure RelatedPartyMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option)
    begin
        case AccountType of
            TempBankStatementMatchingBuffer."Account Type"::Customer:
                CustomerMatching(BankPmtApplRule, TempLedgerEntryMatchingBuffer."Account No.", BankAccReconciliationLine, AccountType);
            TempBankStatementMatchingBuffer."Account Type"::Vendor:
                VendorMatching(BankPmtApplRule, TempLedgerEntryMatchingBuffer."Account No.", BankAccReconciliationLine, AccountType);
            TempBankStatementMatchingBuffer."Account Type"::"Bank Account":
                RelatedPartyMatchingForBankAccLedgEntry(BankPmtApplRule, TempLedgerEntryMatchingBuffer, BankAccReconciliationLine, AccountType);
        end;
    end;

    local procedure CustomerMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; AccountNo: Code[20]; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option)
    var
        Customer: Record Customer;
    begin
        if IsCustomerBankAccountMatching(
             BankAccReconciliationLine."Related-Party Bank Acc. No.", AccountNo)
        then begin
            BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
            exit;
        end;

        Customer.Get(AccountNo);
        RelatedPartyInfoMatching(
          BankPmtApplRule, BankAccReconciliationLine, Customer.Name, Customer.Address, Customer.City, AccountType);
    end;

    local procedure VendorMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; AccountNo: Code[20]; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option)
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(AccountNo);
        if IsVendorBankAccountMatching(BankAccReconciliationLine."Related-Party Bank Acc. No.", Vendor."No.") then begin
            BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
            exit;
        end;

        RelatedPartyInfoMatching(
          BankPmtApplRule, BankAccReconciliationLine, Vendor.Name, Vendor.Address, Vendor.City, AccountType);
    end;

    local procedure RelatedPartyMatchingForBankAccLedgEntry(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option)
    begin
        case TempLedgerEntryMatchingBuffer."Bal. Account Type" of
            TempLedgerEntryMatchingBuffer."Bal. Account Type"::Customer:
                CustomerMatching(BankPmtApplRule, TempLedgerEntryMatchingBuffer."Bal. Account No.", BankAccReconciliationLine, AccountType);
            TempLedgerEntryMatchingBuffer."Bal. Account Type"::Vendor:
                VendorMatching(BankPmtApplRule, TempLedgerEntryMatchingBuffer."Bal. Account No.", BankAccReconciliationLine, AccountType);
            TempLedgerEntryMatchingBuffer."Bal. Account Type"::"Bank Account",
          TempLedgerEntryMatchingBuffer."Bal. Account Type"::"G/L Account":
                BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::No;
        end;
    end;

    local procedure RelatedPartyInfoMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; Name: Text[100]; Address: Text[100]; City: Text[30]; AccountType: Option)
    var
        USTRNameNearness: Integer;
        STRNameNearness: Integer;
    begin
        BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::No;

        // If Strutured text present don't look at unstructured text
        if BankAccReconciliationLine."Related-Party Name" <> '' then begin
            // Use string nearness as names can be reversed, wrongly capitalized, etc
            STRNameNearness := GetStringNearness(BankAccReconciliationLine."Related-Party Name", Name);
            if STRNameNearness >= GetExactMatchTreshold then begin
                BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Partially;

                // City and address should fully match
                if (BankAccReconciliationLine."Related-Party City" = City) and
                   (BankAccReconciliationLine."Related-Party Address" = Address)
                then begin
                    BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
                    exit;
                end;

                if IsNameUnique(Name, AccountType) then begin
                    BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
                    exit;
                end;
            end;

            exit;
        end;

        // Unstructured text is using string nearness since user may shorten the name or mistype
        USTRNameNearness := GetStringNearness(BankAccReconciliationLine."Transaction Text", Name);

        if USTRNameNearness >= GetExactMatchTreshold then begin
            BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Partially;
            if IsNameUnique(Name, AccountType) then begin
                BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
                exit;
            end;

            exit;
        end;

        if USTRNameNearness >= GetCloseMatchTreshold then
            BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Partially;
    end;

    local procedure DocumentMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; DocNo: Code[20]; ExtDocNo: Code[35])
    var
        SearchText: Text;
    begin
        BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No;

        SearchText := UpperCase(BankAccReconciliationLine."Transaction Text" + ' ' +
            BankAccReconciliationLine."Additional Transaction Info");

        if DocNoMatching(SearchText, DocNo) then begin
            BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes;
            exit;
        end;

        if DocNoMatching(SearchText, ExtDocNo) then
            BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes;
    end;

    procedure DocumentMatchingForBankLedgerEntry(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendLedgerEntry2: Record "Vendor Ledger Entry";
        SearchText: Text;
    begin
        BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No;

        SearchText := UpperCase(BankAccReconciliationLine."Transaction Text" + ' ' +
            BankAccReconciliationLine."Additional Transaction Info");

        if DocNoMatching(SearchText, TempLedgerEntryMatchingBuffer."Document No.") then begin
            BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes;
            exit;
        end;

        if DocNoMatching(SearchText, TempLedgerEntryMatchingBuffer."External Document No.") then begin
            BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes;
            exit;
        end;

        OnDocumentMatchingForBankLedgerEntryOnBeforeMatch(SearchText, TempLedgerEntryMatchingBuffer, BankPmtApplRule);
        if BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" = BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes then
            exit;

        CustLedgerEntry.SetRange("Document Type", TempLedgerEntryMatchingBuffer."Document Type");
        CustLedgerEntry.SetRange("Document No.", TempLedgerEntryMatchingBuffer."Document No.");
        CustLedgerEntry.SetRange("Posting Date", TempLedgerEntryMatchingBuffer."Posting Date");
        if CustLedgerEntry.FindSet then
            repeat
                CustLedgerEntry2.SetRange(Open, false);
                CustLedgerEntry2.SetRange("Closed by Entry No.", CustLedgerEntry."Entry No.");
                if CustLedgerEntry2.FindFirst then
                    if DocNoMatching(SearchText, CustLedgerEntry2."Document No.") then begin
                        BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes;
                        exit;
                    end;
            until CustLedgerEntry.Next = 0;

        VendLedgerEntry.SetRange("Document Type", TempLedgerEntryMatchingBuffer."Document Type");
        VendLedgerEntry.SetRange("Document No.", TempLedgerEntryMatchingBuffer."Document No.");
        VendLedgerEntry.SetRange("Posting Date", TempLedgerEntryMatchingBuffer."Posting Date");
        if VendLedgerEntry.FindSet then
            repeat
                VendLedgerEntry2.SetRange(Open, false);
                VendLedgerEntry2.SetRange("Closed by Entry No.", VendLedgerEntry."Entry No.");
                if VendLedgerEntry2.FindFirst then
                    if DocNoMatching(SearchText, VendLedgerEntry2."Document No.") then begin
                        BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::Yes;
                        exit;
                    end;
            until VendLedgerEntry.Next = 0;
    end;

    procedure DocNoMatching(SearchText: Text; DocNo: Code[35]): Boolean
    var
        Position: Integer;
    begin
        if StrLen(DocNo) < GetMatchLengthTreshold then
            exit(false);

        Position := StrPos(SearchText, DocNo);

        case Position of
            0:
                exit(false);
            1:
                begin
                    if StrLen(SearchText) = StrLen(DocNo) then
                        exit(true);

                    exit(not IsAlphanumeric(SearchText[Position + StrLen(DocNo)]));
                end;
            else begin
                    if StrLen(SearchText) < Position + StrLen(DocNo) then
                        exit(not IsAlphanumeric(SearchText[Position - 1]));

                    exit((not IsAlphanumeric(SearchText[Position - 1])) and
                      (not IsAlphanumeric(SearchText[Position + StrLen(DocNo)])));
                end;
        end;

        exit(true);
    end;

    local procedure AmountInclToleranceMatchingForAdvanceLetter(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option; RemainingAmount: Decimal)
    begin
        // NAVCZ
        case AccountType of
            TempBankStatementMatchingBuffer."Account Type"::Customer:
                AmountInclToleranceMatching(BankPmtApplRule, BankAccReconciliationLine, -1, RemainingAmount);
            TempBankStatementMatchingBuffer."Account Type"::Vendor:
                AmountInclToleranceMatching(BankPmtApplRule, BankAccReconciliationLine, -2, RemainingAmount);
        end;
    end;

    local procedure AmountInclToleranceMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; AccountType: Option; RemainingAmount: Decimal)
    var
        NoOfEntries: Integer;
        MinAmount: Decimal;
        MaxAmount: Decimal;
    begin
        BankAccReconciliationLine.GetAmountRangeForTolerance(MinAmount, MaxAmount);
        BankPmtApplRule."Amount Incl. Tolerance Matched" := BankPmtApplRule."Amount Incl. Tolerance Matched"::"No Matches";

        if (RemainingAmount < MinAmount) or
           (RemainingAmount > MaxAmount)
        then
            exit;

        NoOfEntries := 0;
        BankPmtApplRule."Amount Incl. Tolerance Matched" := BankPmtApplRule."Amount Incl. Tolerance Matched"::"Multiple Matches";

        // Check for Multiple Hits for One To Many  matches
        // NAVCZ
        if (BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" =
            BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::"Yes - Multiple") or
           (BankPmtApplRule."Variable Symbol Matched" = BankPmtApplRule."Variable Symbol Matched"::"Yes - Multiple") or
           (BankPmtApplRule."Specific Symbol Matched" = BankPmtApplRule."Specific Symbol Matched"::"Yes - Multiple") or
           (BankPmtApplRule."Constant Symbol Matched" = BankPmtApplRule."Constant Symbol Matched"::"Yes - Multiple")
        // NAVCZ
        then begin
            OneToManyTempBankStatementMatchingBuffer.SetFilter("Total Remaining Amount", '>=%1&<=%2', MinAmount, MaxAmount);
            NoOfEntries += OneToManyTempBankStatementMatchingBuffer.Count;

            if NoOfEntries > 1 then
                exit;
        end;

        // Check is a single match for One to One Matches
        case AccountType of
            TempBankStatementMatchingBuffer."Account Type"::Customer:
                NoOfEntries +=
                  TempCustomerLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
                    MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
            TempBankStatementMatchingBuffer."Account Type"::Vendor:
                NoOfEntries +=
                  TempVendorLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
                    MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
            TempBankStatementMatchingBuffer."Account Type"::"Bank Account":
                NoOfEntries +=
                  TempBankAccLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
                    MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", false);
            // NAVCZ
            TempBankStatementMatchingBuffer."Account Type"::"G/L Account":
                NoOfEntries +=
                  TempGeneralLedgerEntryMatchingBuffer.GetNoOfLedgerEntriesWithinRange(
                    MinAmount, MaxAmount, BankAccReconciliationLine."Transaction Date", UsePaymentDiscounts);
            -1: // Sales Advance Letter
                NoOfEntries +=
                  TempSalesAdvanceLetterMatchingBuffer.GetNoOfAdvanceLettersWithinRange(MinAmount, MaxAmount);
            -2: // Purchase Advance Letter
                NoOfEntries +=
                  TempPurchAdvanceLetterMatchingBuffer.GetNoOfAdvanceLettersWithinRange(MinAmount, MaxAmount);
                // NAVCZ
        end;

        if NoOfEntries = 1 then
            BankPmtApplRule."Amount Incl. Tolerance Matched" := BankPmtApplRule."Amount Incl. Tolerance Matched"::"One Match"
    end;

    local procedure DirectDebitCollectionMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary)
    var
        DirectDebitCollection: Record "Direct Debit Collection";
    begin
        BankPmtApplRule."Direct Debit Collect. Matched" := BankPmtApplRule."Direct Debit Collect. Matched"::"Not Considered";

        if BankAccReconciliationLine."Transaction ID" = '' then
            exit;

        TempDirectDebitCollectionEntryBuffer.Reset;
        TempDirectDebitCollectionEntryBuffer.SetRange("Transaction ID", BankAccReconciliationLine."Transaction ID");
        TempDirectDebitCollectionEntryBuffer.SetFilter(Status, '%1|%2',
          TempDirectDebitCollectionEntryBuffer.Status::"File Created", TempDirectDebitCollectionEntryBuffer.Status::Posted);

        if TempDirectDebitCollectionEntryBuffer.IsEmpty then
            exit;

        BankPmtApplRule."Direct Debit Collect. Matched" := BankPmtApplRule."Direct Debit Collect. Matched"::No;

        TempDirectDebitCollectionEntryBuffer.SetRange("Applies-to Entry No.", TempLedgerEntryMatchingBuffer."Entry No.");
        if TempDirectDebitCollectionEntryBuffer.FindFirst then
            if DirectDebitCollection.Get(TempDirectDebitCollectionEntryBuffer."Direct Debit Collection No.") then
                if (DirectDebitCollection.Status in
                    [DirectDebitCollection.Status::"File Created",
                     DirectDebitCollection.Status::Posted,
                     DirectDebitCollection.Status::Closed])
                then
                    BankPmtApplRule."Direct Debit Collect. Matched" := BankPmtApplRule."Direct Debit Collect. Matched"::Yes;
    end;

    local procedure GetStringNearness(Description: Text; CustVendValue: Text): Integer
    var
        RecordMatchMgt: Codeunit "Record Match Mgt.";
    begin
        Description := RecordMatchMgt.Trim(Description);

        exit(RecordMatchMgt.CalculateStringNearness(CustVendValue, Description, GetMatchLengthTreshold, GetNormalizingFactor));
    end;

    local procedure IsCustomerBankAccountMatching(ValueFromBankStatement: Text; CustomerNo: Code[20]): Boolean
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        ValueFromBankStatement := BankAccountNoWithoutSpecialChars(ValueFromBankStatement);
        if ValueFromBankStatement = '' then
            exit(false);

        CustomerBankAccount.SetRange("Customer No.", CustomerNo);
        if CustomerBankAccount.FindSet then
            repeat
                // NAVCZ
                if BankAccountNoWithoutSpecialChars(CustomerBankAccount.IBAN) = ValueFromBankStatement then
                    exit(true);
                if BankAccountNoWithoutSpecialChars(CustomerBankAccount."Bank Account No.") = ValueFromBankStatement then
                    exit(true);
                // NAVCZ
            until CustomerBankAccount.Next = 0;

        exit(false);
    end;

    local procedure IsVendorBankAccountMatching(ValueFromBankStatement: Text; VendorNo: Code[20]): Boolean
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        ValueFromBankStatement := BankAccountNoWithoutSpecialChars(ValueFromBankStatement);
        if ValueFromBankStatement = '' then
            exit(false);

        VendorBankAccount.SetRange("Vendor No.", VendorNo);
        if VendorBankAccount.FindSet then
            repeat
                // NAVCZ
                if BankAccountNoWithoutSpecialChars(VendorBankAccount.IBAN) = ValueFromBankStatement then
                    exit(true);
                if BankAccountNoWithoutSpecialChars(VendorBankAccount."Bank Account No.") = ValueFromBankStatement then
                    exit(true);
                // NAVCZ
            until VendorBankAccount.Next = 0;

        exit(false);
    end;

    local procedure BankAccountNoWithoutSpecialChars(Input: Text): Text
    begin
        exit(UpperCase(DelChr(Input, '=', DelChr(UpperCase(Input), '=', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'))));
    end;

    local procedure StatementLineAlreadyApplied(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary): Boolean
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        SetFilterToBankAccReconciliation(AppliedPaymentEntry, TempBankAccReconciliationLine);
        AppliedPaymentEntry.SetRange("Statement Line No.", TempBankStatementMatchingBuffer."Line No.");

        exit(not AppliedPaymentEntry.IsEmpty or (TempBankAccReconciliationLine."Advance Letter Link Code" <> '')); // NAVCZ
    end;

    local procedure EntryAlreadyApplied(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary; EntryNo: Integer): Boolean
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        IsAdvancePaymentEntry: Boolean;
    begin
        SetFilterToBankAccReconciliation(AppliedPaymentEntry, TempBankAccReconciliationLine);
        AppliedPaymentEntry.SetRange("Account Type", TempBankStatementMatchingBuffer."Account Type");
        AppliedPaymentEntry.SetRange("Applies-to Entry No.", EntryNo);
        // NAVCZ
        if EntryNo < 0 then
            if AppliedPaymentEntry.FindSet then begin
                IsAdvancePaymentEntry := true;
                repeat
                    BankAccReconciliationLine.SetRange("Statement Type", AppliedPaymentEntry."Statement Type");
                    BankAccReconciliationLine.SetRange("Bank Account No.", AppliedPaymentEntry."Bank Account No.");
                    BankAccReconciliationLine.SetRange("Statement No.", AppliedPaymentEntry."Statement No.");
                    BankAccReconciliationLine.SetRange("Statement Line No.", AppliedPaymentEntry."Statement Line No.");
                    BankAccReconciliationLine.SetFilter("Advance Letter Link Code", '<>%1', '');
                    IsAdvancePaymentEntry := IsAdvancePaymentEntry and not BankAccReconciliationLine.IsEmpty;
                until (AppliedPaymentEntry.Next = 0) or not IsAdvancePaymentEntry;
            end;

        exit(not AppliedPaymentEntry.IsEmpty and not IsAdvancePaymentEntry);
        // NAVCZ
    end;

    local procedure SetFilterToBankAccReconciliation(var AppliedPaymentEntry: Record "Applied Payment Entry"; TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary)
    begin
        AppliedPaymentEntry.FilterAppliedPmtEntry(TempBankAccReconciliationLine);
        AppliedPaymentEntry.SetRange("Statement Line No.");
    end;

    local procedure SetFilterToRelatedApplications(var AppliedPaymentEntry: Record "Applied Payment Entry"; TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary)
    begin
        SetFilterToBankAccReconciliation(AppliedPaymentEntry, TempBankAccReconciliationLine);
        AppliedPaymentEntry.SetRange("Account Type", TempBankStatementMatchingBuffer."Account Type");
        AppliedPaymentEntry.SetRange("Account No.", TempBankStatementMatchingBuffer."Account No.");
        AppliedPaymentEntry.SetRange("Applies-to Entry No.", TempBankStatementMatchingBuffer."Entry No.");
    end;

    local procedure GetRemainingAmount(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary): Decimal
    var
        TempAppliedPaymentEntry: Record "Applied Payment Entry" temporary;
    begin
        TempAppliedPaymentEntry.TransferFromBankAccReconLine(TempBankAccReconciliationLine);
        TempAppliedPaymentEntry."Account Type" := TempBankStatementMatchingBuffer."Account Type";
        TempAppliedPaymentEntry."Account No." := TempBankStatementMatchingBuffer."Account No.";
        TempAppliedPaymentEntry."Applies-to Entry No." := TempBankStatementMatchingBuffer."Entry No.";

        exit(TempAppliedPaymentEntry.GetRemAmt - TempAppliedPaymentEntry.GetAmtAppliedToOtherStmtLines);
    end;

    local procedure ShowMatchSummary(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchedCount: Integer;
        TotalCount: Integer;
        TextMatchCount: Integer;
        FinalText: Text;
    begin
        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        TotalCount := BankAccReconciliationLine.Count;

        BankAccReconciliationLine.SetFilter("Applied Entries", '>0');
        MatchedCount := BankAccReconciliationLine.Count;

        FinalText := StrSubstNo(MatchSummaryMsg, MatchedCount, TotalCount);
        Message(FinalText);

        BankAccReconciliationLine.SetRange("Match Confidence", BankAccReconciliationLine."Match Confidence"::"High - Text-to-Account Mapping");

        SendTraceTag('0000AIA', BankAccountRecCategoryLbl, Verbosity::Normal,
          StrSubstNo(BankAccountRecTotalAndMatchedLinesLbl, TotalCount, MatchedCount, TextMatchCount), DataClassification::SystemMetadata);
    end;

    local procedure UpdateOneToManyMatches(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        RemoveInvalidOneToManyMatches;
        GetOneToManyMatches;
        ScoreOneToManyMatches(BankAccReconciliationLine);
    end;

    local procedure ScoreOneToManyMatches(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        Score: Integer;
    begin
        if TempBankStatementMatchingBuffer.FindSet then begin
            repeat
                BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::"Yes - Multiple";
                BankPmtApplRule.UpdateFromBankStmtMatchingBuffer(TempBankStatementMatchingBuffer); // NAVCZ
                BankPmtApplRule."Related Party Matched" := TempBankStatementMatchingBuffer."Related Party Matched";
                BankAccReconciliationLine.Get(
                  BankAccReconciliationLine."Statement Type", BankAccReconciliationLine."Bank Account No.",
                  BankAccReconciliationLine."Statement No.", TempBankStatementMatchingBuffer."Line No.");
                AmountInclToleranceMatching(
                  BankPmtApplRule, BankAccReconciliationLine, TempBankStatementMatchingBuffer."Account Type",
                  TempBankStatementMatchingBuffer."Total Remaining Amount");

                Score := TempBankPmtApplRule.GetBestMatchScore(BankPmtApplRule);
                TempBankStatementMatchingBuffer.Quality := Score;
                TempBankStatementMatchingBuffer.Modify;
            until TempBankStatementMatchingBuffer.Next = 0;
        end;

        TempBankStatementMatchingBuffer.Reset;
    end;

    local procedure RemoveInvalidOneToManyMatches()
    begin
        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.SetRange("One to Many Match", true);
        TempBankStatementMatchingBuffer.SetFilter("No. of Entries", '=1');
        TempBankStatementMatchingBuffer.DeleteAll(true);

        // NAVCZ
        TempBankStatementMatchingBuffer.SetRange("No. of Entries");
        TempBankStatementMatchingBuffer.SetFilter("No. of Match to Doc. No.", '<=1');
        TempBankStatementMatchingBuffer.SetFilter("No. of Match to V. Symbol", '<=1');
        TempBankStatementMatchingBuffer.SetFilter("No. of Match to S. Symbol", '<=1');
        TempBankStatementMatchingBuffer.SetFilter("No. of Match to C. Symbol", '<=1');
        TempBankStatementMatchingBuffer.DeleteAll(true);
        // NAVCZ

        TempBankStatementMatchingBuffer.Reset;
    end;

    local procedure GetOneToManyMatches()
    begin
        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.SetRange("One to Many Match", true);
        TempBankStatementMatchingBuffer.SetFilter("No. of Entries", '>1');

        if TempBankStatementMatchingBuffer.FindSet then
            repeat
                OneToManyTempBankStatementMatchingBuffer := TempBankStatementMatchingBuffer;
                OneToManyTempBankStatementMatchingBuffer.Insert(true);
            until TempBankStatementMatchingBuffer.Next = 0;
    end;

    local procedure GetExactMatchTreshold(): Decimal
    begin
        exit(0.95 * GetNormalizingFactor);
    end;

    procedure GetCloseMatchTreshold(): Decimal
    begin
        exit(0.65 * GetNormalizingFactor);
    end;

    local procedure GetMatchLengthTreshold(): Decimal
    begin
        exit(4);
    end;

    procedure GetNormalizingFactor(): Decimal
    begin
        exit(100);
    end;

    local procedure GetLowestMatchScore(): Integer
    var
        Score: Integer;
    begin
        if not ApplyEntries then
            exit(0);

        TempBankPmtApplRule.SetFilter("Match Confidence", '<>%1', TempBankPmtApplRule."Match Confidence"::None);
        TempBankPmtApplRule.SetCurrentKey(Score);
        TempBankPmtApplRule.Ascending(false);
        Score := 0;
        if TempBankPmtApplRule.FindLast then
            Score := TempBankPmtApplRule.Score;

        TempBankPmtApplRule.Reset;
        exit(Score);
    end;

    local procedure IsNameUnique(Name: Text[100]; AccountType: Option): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        case AccountType of
            TempBankStatementMatchingBuffer."Account Type"::Customer:
                begin
                    Customer.SetFilter(Name, '%1', '@*' + Name + '*');
                    exit(Customer.Count = 1);
                end;
            TempBankStatementMatchingBuffer."Account Type"::Vendor:
                begin
                    Vendor.SetFilter(Name, '%1', '@*' + Name + '*');
                    exit(Vendor.Count = 1);
                end;
        end;
    end;

    local procedure IsAlphanumeric(Character: Char): Boolean
    begin
        exit((Character in ['0' .. '9']) or (Character in ['A' .. 'Z']) or (Character in ['a' .. 'z']));
    end;

    procedure GetBankStatementMatchingBuffer(var TempBankStatementMatchingBuffer2: Record "Bank Statement Matching Buffer" temporary)
    begin
        TempBankStatementMatchingBuffer2.Copy(TempBankStatementMatchingBuffer, true);
        TempBankStatementMatchingBuffer2.Reset;
    end;

    local procedure UpdatePaymentMatchDetails(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        BankAccReconciliationLine2: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine2.CopyFilters(BankAccReconciliationLine);

        if BankAccReconciliationLine2.FindSet then
            repeat
                BankAccReconciliationLine2.CalcFields("Match Confidence", "Match Quality");
                AddWarningsForTextMapperOverriden(BankAccReconciliationLine2);
                AddWarningsForStatementCanBeAppliedToMultipleEntries(BankAccReconciliationLine2);
                AddWarningsForMultipleStatementLinesCouldBeAppliedToEntry(BankAccReconciliationLine2);
                if BankAccReconciliationLine2.Type <> BankAccReconciliationLine2.Type::Difference then
                    UpdateType(BankAccReconciliationLine2);
            until BankAccReconciliationLine2.Next = 0;
    end;

    local procedure DeletePaymentMatchDetails(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        PaymentMatchingDetails: Record "Payment Matching Details";
    begin
        PaymentMatchingDetails.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        PaymentMatchingDetails.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        PaymentMatchingDetails.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        PaymentMatchingDetails.DeleteAll(true);
    end;

    local procedure DeleteAppliedPaymentEntries(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        AppliedPaymentEntry.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        AppliedPaymentEntry.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        AppliedPaymentEntry.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        AppliedPaymentEntry.DeleteAll(true);
    end;

    local procedure AddWarningsForTextMapperOverriden(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        PaymentMatchingDetails: Record "Payment Matching Details";
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
    begin
        if BankAccReconciliationLine."Match Quality" <= BankPmtApplRule.GetTextMapperScore then
            exit;

        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.SetRange("Line No.", BankAccReconciliationLine."Statement Line No.");
        TempBankStatementMatchingBuffer.SetRange(Quality, BankPmtApplRule.GetTextMapperScore);

        if TempBankStatementMatchingBuffer.Count > 0 then
            PaymentMatchingDetails.CreatePaymentMatchingDetail(BankAccReconciliationLine,
              StrSubstNo(TextMapperRulesOverridenTxt, TempBankStatementMatchingBuffer.Count,
                BankAccReconciliationLine."Match Confidence"));
    end;

    local procedure AddWarningsForStatementCanBeAppliedToMultipleEntries(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        PaymentMatchingDetails: Record "Payment Matching Details";
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        MinRangeValue: Integer;
        MaxRangeValue: Integer;
    begin
        if BankAccReconciliationLine."Match Confidence" = BankAccReconciliationLine."Match Confidence"::None then
            exit;

        if BankAccReconciliationLine."Match Quality" = BankPmtApplRule.GetTextMapperScore then
            exit;

        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.SetRange("Line No.", BankAccReconciliationLine."Statement Line No.");

        MinRangeValue := BankPmtApplRule.GetLowestScoreInRange(BankAccReconciliationLine."Match Quality");
        MaxRangeValue := BankPmtApplRule.GetHighestScoreInRange(BankAccReconciliationLine."Match Quality");
        TempBankStatementMatchingBuffer.SetRange(Quality, MinRangeValue, MaxRangeValue);

        if TempBankStatementMatchingBuffer.Count > 1 then
            PaymentMatchingDetails.CreatePaymentMatchingDetail(BankAccReconciliationLine,
              StrSubstNo(MultipleEntriesWithSilarConfidenceFoundTxt, TempBankStatementMatchingBuffer.Count));
    end;

    local procedure AddWarningsForMultipleStatementLinesCouldBeAppliedToEntry(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        PaymentMatchingDetails: Record "Payment Matching Details";
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        EntryNo: Integer;
        MinRangeValue: Integer;
        MaxRangeValue: Integer;
    begin
        if BankAccReconciliationLine."Match Confidence" = BankAccReconciliationLine."Match Confidence"::None then
            exit;

        if BankAccReconciliationLine."Match Quality" = BankPmtApplRule.GetTextMapperScore then
            exit;

        TempBankStatementMatchingBuffer.Reset;

        // Get Entry No.
        TempBankStatementMatchingBuffer.SetRange("Line No.", BankAccReconciliationLine."Statement Line No.");
        TempBankStatementMatchingBuffer.SetRange(Quality, BankAccReconciliationLine."Match Quality");
        TempBankStatementMatchingBuffer.FindFirst;
        EntryNo := TempBankStatementMatchingBuffer."Entry No.";

        MinRangeValue := BankPmtApplRule.GetLowestScoreInRange(BankAccReconciliationLine."Match Quality");
        MaxRangeValue := BankPmtApplRule.GetHighestScoreInRange(BankAccReconciliationLine."Match Quality");

        TempBankStatementMatchingBuffer.Reset;
        TempBankStatementMatchingBuffer.SetRange("Entry No.", EntryNo);
        TempBankStatementMatchingBuffer.SetRange(Quality, MinRangeValue, MaxRangeValue);
        TempBankStatementMatchingBuffer.SetFilter("Line No.", '<>%1', BankAccReconciliationLine."Statement Line No.");
        if TempBankStatementMatchingBuffer.Count > 1 then
            PaymentMatchingDetails.CreatePaymentMatchingDetail(BankAccReconciliationLine,
              StrSubstNo(MultipleStatementLinesWithSameConfidenceFoundTxt, TempBankStatementMatchingBuffer.Count));
    end;

    procedure SetApplyEntries(NewApplyEntries: Boolean)
    begin
        ApplyEntries := NewApplyEntries;
    end;

    local procedure CheckBankAccountSetup(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        BankAcc: Record "Bank Account";
    begin
        // NAVCZ
        BankAccReconciliationLine.FindFirst;
        BankAcc.Get(BankAccReconciliationLine."Bank Account No.");
        if UseExtSetup then
            exit;
        BankAcc.TestField("Bank Pmt. Appl. Rule Code");
        BankAcc.TestField("Text-to-Account Mapping Code");
    end;

    local procedure VariableSymbolMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; VariableSymbol: Code[10])
    begin
        // NAVCZ
        BankPmtApplRule."Variable Symbol Matched" := BankPmtApplRule."Variable Symbol Matched"::No;

        if SymbolMatching(BankAccReconciliationLine."Variable Symbol", VariableSymbol) then
            BankPmtApplRule."Variable Symbol Matched" := BankPmtApplRule."Variable Symbol Matched"::Yes;
    end;

    local procedure SpecificSymbolMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; SpecificSymbol: Code[10])
    begin
        // NAVCZ
        BankPmtApplRule."Specific Symbol Matched" := BankPmtApplRule."Specific Symbol Matched"::No;

        if SymbolMatching(BankAccReconciliationLine."Specific Symbol", SpecificSymbol) then
            BankPmtApplRule."Specific Symbol Matched" := BankPmtApplRule."Specific Symbol Matched"::Yes;
    end;

    local procedure ConstantSymbolMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; ConstantSymbol: Code[10])
    begin
        // NAVCZ
        BankPmtApplRule."Constant Symbol Matched" := BankPmtApplRule."Constant Symbol Matched"::No;

        if SymbolMatching(BankAccReconciliationLine."Constant Symbol", ConstantSymbol) then
            BankPmtApplRule."Constant Symbol Matched" := BankPmtApplRule."Constant Symbol Matched"::Yes;
    end;

    local procedure SymbolMatching(SearchSymbol: Code[10]; Symbol: Code[10]): Boolean
    begin
        // NAVCZ
        exit((SearchSymbol <> '') and (SearchSymbol = Symbol));
    end;

    local procedure UpdateBankAccReconciliationLine(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        IssuedBankStatementLine: Record "Issued Bank Statement Line";
    begin
        // NAVCZ
        BankAccount.Get(BankAccReconciliation."Bank Account No.");

        BankAccReconciliationLine.FilterBankRecLines(BankAccReconciliation);
        BankAccReconciliationLine.SetRange("Advance Letter Link Code", '');
        BankAccReconciliationLine.SetRange("Applied Entries", 0);
        if BankAccReconciliationLine.FindSet then
            repeat
                IssuedBankStatementLine.SetRange("Bank Statement No.", BankAccReconciliationLine."Statement No.");
                IssuedBankStatementLine.SetRange("Line No.", BankAccReconciliationLine."Statement Line No.");
                IssuedBankStatementLine.SetFilter("No.", '<>%1', '');
                if IssuedBankStatementLine.FindFirst then begin
                    BankAccReconciliationLine."Account Type" := IssuedBankStatementLine.ConvertTypeToBankAccReconLineAccountType;
                    BankAccReconciliationLine."Account No." := IssuedBankStatementLine."No.";
                end;

                if (BankAccReconciliationLine."Account No." = '') and
                   (BankAccount."Non Associated Payment Account" <> '')
                then begin
                    BankAccReconciliationLine."Account Type" := BankAccReconciliationLine."Account Type"::"G/L Account";
                    BankAccReconciliationLine."Account No." := BankAccount."Non Associated Payment Account";
                end;

                if BankAccReconciliationLine."Account No." <> '' then
                    BankAccReconciliationLine.TransferRemainingAmountToAccount;
            until BankAccReconciliationLine.Next = 0;
    end;

    local procedure GetAvailableSplitLineNo(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; ParentLineNo: Integer): Integer
    var
        SplitLineNo: Integer;
    begin
        SplitLineNo := BankAccReconciliationLine."Statement Line No." + 1;
        BankAccReconciliationLine.SetRange("Parent Line No.", ParentLineNo);
        if BankAccReconciliationLine.FindLast then
            SplitLineNo := BankAccReconciliationLine."Statement Line No." + 1;
        exit(SplitLineNo)
    end;

    local procedure GetParentLineNo(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"): Integer
    begin
        if BankAccReconciliationLine."Parent Line No." <> 0 then
            exit(BankAccReconciliationLine."Parent Line No.");
        exit(BankAccReconciliationLine."Statement Line No.");
    end;

    procedure UpdateType(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        AppliedPaymentEntry.SetRange("Statement Type", BankAccReconciliationLine."Statement Type");
        AppliedPaymentEntry.SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
        AppliedPaymentEntry.SetRange("Statement No.", BankAccReconciliationLine."Statement No.");
        AppliedPaymentEntry.SetRange("Statement Line No.", BankAccReconciliationLine."Statement Line No.");
        if AppliedPaymentEntry.FindFirst then begin
            if AppliedPaymentEntry."Applies-to Entry No." = 0 then
                exit;

            CheckLedgerEntry.SetRange("Bank Account Ledger Entry No.", AppliedPaymentEntry."Applies-to Entry No.");
            if CheckLedgerEntry.FindFirst then
                BankAccReconciliationLine.Type := BankAccReconciliationLine.Type::"Check Ledger Entry"
            else
                BankAccReconciliationLine.Type := BankAccReconciliationLine.Type::"Bank Account Ledger Entry";

            BankAccReconciliationLine.Modify;
        end;
    end;

    local procedure MapRelatedPartyToStatementtLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        Window: Dialog;
        TotalNoOfLines: Integer;
        ProcessedLines: Integer;
    begin
        // NAVCZ
        BankAccReconciliationLine.SetFilter("Statement Amount", '<>0');
        BankAccReconciliationLine.SetRange("Match Confidence", BankAccReconciliationLine."Match Confidence"::None);
        BankAccReconciliationLine.SetFilter("Account No.", '%1', '');
        if BankAccReconciliationLine.FindSet then begin
            TotalNoOfLines := BankAccReconciliationLine.Count;
            ProcessedLines := 0;
            Window.Open(MatchingStmtLinesToRelatedPartyMsg);

            repeat
                FindMatchingRelatedParty(BankAccReconciliationLine);
                ProcessedLines += 1;
                Window.Update(1, StrSubstNo(ProcessedStmtLinesMsg, ProcessedLines, TotalNoOfLines));
                Window.Update(2, Round(ProcessedLines / TotalNoOfLines * 10000, 1));
            until BankAccReconciliationLine.Next = 0;

            Window.Close;
        end;
    end;

    local procedure FindMatchingRelatedParty(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        TempBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line" temporary;
    begin
        // NAVCZ
        TempBankAccReconciliationLine := BankAccReconciliationLine;
        RelatedPartyMatching2(BankPmtApplRule, TempBankAccReconciliationLine);
        if BankPmtApplRule."Related Party Matched" = BankPmtApplRule."Related Party Matched"::Fully then begin
            BankAccReconciliationLine.Validate("Account Type", TempBankAccReconciliationLine."Account Type");
            BankAccReconciliationLine.Validate("Account No.", TempBankAccReconciliationLine."Account No.");
            BankAccReconciliationLine.Modify(true);
            if BankAccReconciliationLine.Difference <> 0 then
                BankAccReconciliationLine.TransferRemainingAmountToAccount;
        end;
    end;

    local procedure RelatedPartyMatching2(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        CustomerBankAccount: Record "Customer Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        ValueFromBankStatement: Text;
    begin
        // NAVCZ
        ValueFromBankStatement := BankAccountNoWithoutSpecialChars(BankAccReconciliationLine."Related-Party Bank Acc. No.");
        if ValueFromBankStatement = '' then
            exit;

        if CustomerBankAccount.FindSet then
            repeat
                if BankAccountNoWithoutSpecialChars(CustomerBankAccount.GetBankAccountNo) = ValueFromBankStatement then begin
                    BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
                    BankAccReconciliationLine."Account Type" := BankAccReconciliationLine."Account Type"::Customer;
                    BankAccReconciliationLine."Account No." := CustomerBankAccount."Customer No.";
                    exit;
                end;
            until CustomerBankAccount.Next = 0;
        if VendorBankAccount.FindSet then
            repeat
                if BankAccountNoWithoutSpecialChars(VendorBankAccount.GetBankAccountNo) = ValueFromBankStatement then begin
                    BankPmtApplRule."Related Party Matched" := BankPmtApplRule."Related Party Matched"::Fully;
                    BankAccReconciliationLine."Account Type" := BankAccReconciliationLine."Account Type"::Vendor;
                    BankAccReconciliationLine."Account No." := VendorBankAccount."Vendor No.";
                    exit;
                end;
            until VendorBankAccount.Next = 0;
    end;

    local procedure PrepareLedgerEntryForApplication(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        if TempBankStatementMatchingBuffer."Entry No." <= 0 then // text mapping has "Entry No." = -10000
            exit;

        // NAVCZ
        // advance application has "Entry No." with special offset
        if TempBankStatementMatchingBuffer."Entry No." >= TempBankStatementMatchingBuffer.AdvanceLetterOffset then
            exit;
        // NAVCZ

        SetApplicationDataInCVLedgEntry(
          TempBankStatementMatchingBuffer."Account Type", TempBankStatementMatchingBuffer."Entry No.",
          BankAccReconciliationLine.GetAppliesToID);
    end;

    procedure SetApplicationDataInCVLedgEntry(AccountType: Option; EntryNo: Integer; AppliesToID: Code[50])
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
    begin
        if EntryNo = 0 then
            exit;

        case AccountType of
            BankAccReconLine."Account Type"::Customer:
                SetCustAppicationData(EntryNo, AppliesToID);
            BankAccReconLine."Account Type"::Vendor:
                SetVendAppicationData(EntryNo, AppliesToID);
        end;
    end;

    local procedure SetCustAppicationData(EntryNo: Integer; AppliesToID: Code[50])
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgEntry.Get(EntryNo);
        CustLedgEntry.CalcFields("Remaining Amount");
        CustLedgEntry."Applies-to ID" := AppliesToID;
        CustLedgEntry."Amount to Apply" := CustLedgEntry."Remaining Amount";
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit", CustLedgEntry);
    end;

    local procedure SetVendAppicationData(EntryNo: Integer; AppliesToID: Code[50])
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.Get(EntryNo);
        VendLedgEntry.CalcFields("Remaining Amount");
        VendLedgEntry."Applies-to ID" := AppliesToID;
        VendLedgEntry."Amount to Apply" := VendLedgEntry."Remaining Amount";
        CODEUNIT.Run(CODEUNIT::"Vend. Entry-Edit", VendLedgEntry);
    end;

    local procedure RevertAcceptedPmtToleranceFromAppliedEntries(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; Difference: Decimal)
    var
        AppliedPmtEntry: Record "Applied Payment Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if Difference = 0 then
            exit;

        // NAVCZ
        if BankAccReconciliationLine."Advance Letter Link Code" <> '' then
            exit;
        // NAVCZ

        AppliedPmtEntry.FilterAppliedPmtEntry(BankAccReconciliationLine);
        AppliedPmtEntry.SetFilter("Applies-to Entry No.", '<>%1', 0);
        if not AppliedPmtEntry.FindSet then
            exit;

        repeat
            case AppliedPmtEntry."Account Type" of
                AppliedPmtEntry."Account Type"::Customer:
                    begin
                        CustLedgerEntry.Get(AppliedPmtEntry."Applies-to Entry No.");
                        if CustLedgerEntry."Accepted Payment Tolerance" <> 0 then begin
                            if -CustLedgerEntry."Accepted Payment Tolerance" > Difference then begin
                                CustLedgerEntry."Accepted Payment Tolerance" += Difference;
                                Difference := 0;
                            end else begin
                                Difference += CustLedgerEntry."Accepted Payment Tolerance";
                                CustLedgerEntry."Accepted Payment Tolerance" := 0;
                            end;
                            CustLedgerEntry.Modify;
                        end;
                    end;
                AppliedPmtEntry."Account Type"::Vendor:
                    begin
                        VendorLedgerEntry.Get(AppliedPmtEntry."Applies-to Entry No.");
                        if VendorLedgerEntry."Accepted Payment Tolerance" <> 0 then begin
                            if VendorLedgerEntry."Accepted Payment Tolerance" > Difference then begin
                                VendorLedgerEntry."Accepted Payment Tolerance" -= Difference;
                                Difference := 0;
                            end else begin
                                Difference -= VendorLedgerEntry."Accepted Payment Tolerance";
                                VendorLedgerEntry."Accepted Payment Tolerance" := 0;
                            end;
                            VendorLedgerEntry.Modify;
                        end;
                    end;
            end;
        until (AppliedPmtEntry.Next = 0) or (Difference = 0);
    end;

    [Scope('OnPrem')]
    procedure SetValuesForApp(NotApplyCustLedgerEntriesNew: Boolean; NotApplyVendLedgerEntriesNew: Boolean; NotApplySalesAdvancesNew: Boolean; NotApplyPurchaseAdvancesNew: Boolean; NotApplyGenLedgerEntriesNew: Boolean; NotAplBankAccLedgEntriesNew: Boolean; UsePaymentAppRulesNew: Boolean; UseTextToAccMappingCodeNew: Boolean; BankPmtApplRuleCodeNew: Code[10]; TextToAccMappingCodeNew: Code[10]; OnlyNotAppliedLinesNew: Boolean)
    begin
        // NAVCZ
        UsePaymentAppRulesNew := false;

        NotApplyCustLedgerEntries := NotApplyCustLedgerEntriesNew;
        NotApplyVendLedgerEntries := NotApplyVendLedgerEntriesNew;
        NotApplySalesAdvances := NotApplySalesAdvancesNew;
        NotApplyPurchaseAdvances := NotApplyPurchaseAdvancesNew;
        NotApplyGenLedgerEntries := NotApplyGenLedgerEntriesNew;
        NotAplBankAccLedgEntries := NotAplBankAccLedgEntriesNew;
        NotUseTextToAccMappingCode := not UseTextToAccMappingCodeNew;
        BankPmtApplRuleCode := BankPmtApplRuleCodeNew;
        TextToAccMappingCode := TextToAccMappingCodeNew;
        OnlyNotAppliedLines := OnlyNotAppliedLinesNew;

        UseExtSetup := true;
    end;

    local procedure GetApplyParam()
    begin
        // NAVCZ
        if UseExtSetup then
            exit;

        NotApplyCustLedgerEntries := BankAccount."Not Apply Cust. Ledger Entries";
        NotApplyVendLedgerEntries := BankAccount."Not Apply Vend. Ledger Entries";
        NotApplySalesAdvances := BankAccount."Not Apply Sales Advances";
        NotApplyPurchaseAdvances := BankAccount."Not Apply Purchase Advances";
        NotAplBankAccLedgEntries := BankAccount."Not Apl. Bank Acc.Ledg.Entries";
        NotApplyGenLedgerEntries := BankAccount."Not Apply Gen. Ledger Entries";
    end;

    local procedure CopyLedgEntryMatchingBuffer(var LedgerEntryMatchingBufferFrom: Record "Ledger Entry Matching Buffer"; var LedgerEntryMatchingBufferTo: Record "Ledger Entry Matching Buffer")
    begin
        // NAVCZ
        LedgerEntryMatchingBufferTo.Reset;
        LedgerEntryMatchingBufferTo.DeleteAll;
        with LedgerEntryMatchingBufferFrom do begin
            if FindSet then
                repeat
                    LedgerEntryMatchingBufferTo := LedgerEntryMatchingBufferFrom;
                    LedgerEntryMatchingBufferTo.Insert;
                until Next = 0
        end;
    end;

    local procedure CopyAdvLetterMatchingBuffer(var AdvanceLetterMatchingBufferFrom: Record "Advance Letter Matching Buffer"; var AdvanceLetterMatchingBufferTo: Record "Advance Letter Matching Buffer")
    begin
        // NAVCZ
        AdvanceLetterMatchingBufferTo.Reset;
        AdvanceLetterMatchingBufferTo.DeleteAll;
        with AdvanceLetterMatchingBufferFrom do begin
            if FindSet then
                repeat
                    AdvanceLetterMatchingBufferTo := AdvanceLetterMatchingBufferFrom;
                    AdvanceLetterMatchingBufferTo.Insert;
                until Next = 0;
        end;
    end;

    local procedure DeletePaymentMatchDetails2(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        PaymentMatchingDetails: Record "Payment Matching Details";
    begin
        // NAVCZ
        if BankAccReconciliationLine.FindSet then
            repeat
                PaymentMatchingDetails.SetRange("Statement Type", BankAccReconciliationLine."Statement Type");
                PaymentMatchingDetails.SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
                PaymentMatchingDetails.SetRange("Statement No.", BankAccReconciliationLine."Statement No.");
                PaymentMatchingDetails.SetRange("Statement Line No.", BankAccReconciliationLine."Statement Line No.");
                PaymentMatchingDetails.DeleteAll(true);
            until BankAccReconciliationLine.Next = 0;
    end;

    local procedure DeleteAppliedPaymentEntries2(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        AppliedPaymentEntry: Record "Applied Payment Entry";
    begin
        // NAVCZ
        if BankAccReconciliationLine.FindSet then
            repeat
                AppliedPaymentEntry.SetRange("Statement Type", BankAccReconciliationLine."Statement Type");
                AppliedPaymentEntry.SetRange("Bank Account No.", BankAccReconciliationLine."Bank Account No.");
                AppliedPaymentEntry.SetRange("Statement No.", BankAccReconciliationLine."Statement No.");
                AppliedPaymentEntry.SetRange("Statement Line No.", BankAccReconciliationLine."Statement Line No.");
                AppliedPaymentEntry.DeleteAll(true);
            until BankAccReconciliationLine.Next = 0;
    end;

    local procedure ClearLedgEntryStoreBuffers()
    begin
        // NAVCZ
        TempCustLedgMatchingBufferInitialized := false;
        TempVendLedgMatchingBufferInitialized := false;
        TempCustomerLedgerEntryMatchingBufferStore.Reset;
        TempCustomerLedgerEntryMatchingBufferStore.DeleteAll;
        TempVendorLedgerEntryMatchingBufferStore.Reset;
        TempVendorLedgerEntryMatchingBufferStore.DeleteAll;
    end;

    local procedure ClearAdvLetterStoreBuffers()
    begin
        // NAVCZ
        TempSalesAdvLedgMatchingBufferInitialized := false;
        TempPurchAdvLedgMatchingBufferInitialized := false;
        TempSalesAdvanceLetterMatchingBufferStore.Reset;
        TempSalesAdvanceLetterMatchingBufferStore.DeleteAll;
        TempPurchAdvanceLetterMatchingBufferStore.Reset;
        TempPurchAdvanceLetterMatchingBufferStore.DeleteAll;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDocumentMatchingForBankLedgerEntryOnBeforeMatch(SearchText: Text; TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; var BankPmtApplRule: Record "Bank Pmt. Appl. Rule")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindMatchingEntryOnBeforeDocumentMatching(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; TempLedgerEntryMatchingBuffer: Record "Ledger Entry Matching Buffer" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitBankAccLedgerEntriesMatchingBufferSetFilter(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitCustomerLedgerEntriesMatchingBufferSetFilter(var CustLedgerEntry: Record "Cust. Ledger Entry"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitVendorLedgerEntriesMatchingBufferSetFilter(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
    end;
}

