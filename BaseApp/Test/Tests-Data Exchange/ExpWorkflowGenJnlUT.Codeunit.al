codeunit 132560 "Exp. Workflow Gen. Jnl. UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Data Exchange] [UT]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPaymentFormat: Codeunit "Library - Payment Format";
        LibraryRandom: Codeunit "Library - Random";
        RecordNotFoundErr: Label '%1 was not found.';

    [Test]
    [Scope('OnPrem')]
    procedure PreMappingCodeunit()
    var
        BankAcc: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        Vendor: Record Vendor;
        BankExportImportSetup: Record "Bank Export/Import Setup";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        // [SCENARIO 1] Create the Payment Export Data records.
        // [GIVEN] One or more Gen. Journal Lines, applied to Vendor Ledger Entries.
        // [WHEN] Run the codeunit.
        // [THEN] The Data Exch. record is created, and the "File Name" field is set.
        // [THEN] The Data Exch. Entry No. field is updated on the Gen. Journal Lines.
        // [THEN] The Payment Export Data records are created.

        // Pre-Setup
        LibraryPaymentExport.CreateSimpleDataExchDefWithMapping(DataExchMapping, DATABASE::"Bank Acc. Reconciliation", 1);
        DataExchDef.Get(DataExchMapping."Data Exch. Def Code");
        LibraryPaymentFormat.CreateBankExportImportSetup(BankExportImportSetup, DataExchDef);
        CreateBankAccountWithExportFormat(BankAcc, BankExportImportSetup.Code);
        CreateExportGenJournalBatch(GenJnlBatch, BankAcc."No.");

        // Setup
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Pre-Exercise
        DataExch.Init;
        DataExch.Insert;
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.Modify;

        // Exercise
        CODEUNIT.Run(CODEUNIT::"Exp. Pre-Mapping Gen. Jnl.", DataExch);

        // Verify
        PaymentExportData.SetRange("Document No.", GenJnlLine."Document No.");
        Assert.IsFalse(PaymentExportData.IsEmpty, StrSubstNo(RecordNotFoundErr, PaymentExportData.TableCaption));

        // Cleanup
        PaymentExportData.FindFirst;
        PaymentExportData.Delete(true);
        DataExch.Delete(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PostMappingCodeunit()
    var
        BankAcc: Record "Bank Account";
        CreditTransferEntry: Record "Credit Transfer Entry";
        CreditTransferRegister: Record "Credit Transfer Register";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        DataExch: Record "Data Exch.";
        Vendor: Record Vendor;
    begin
        // [SCENARIO 3] Log the exporting action.
        // [GIVEN] One or more Gen. Journal Lines.
        // [WHEN] Run the codeunit.
        // [THEN] The Credit Transfer Register is created.
        // [THEN] The Credit Transfer Entries are created, one for each Gen. Journal Line.

        // Pre-Setup
        LibraryERM.CreateBankAccount(BankAcc);
        CreateExportGenJournalBatch(GenJnlBatch, BankAcc."No.");

        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        CreditTransferRegister.CreateNew(LibraryUtility.GenerateGUID, BankAcc."No.");

        // Pre-Exercise
        DataExch.Init;
        DataExch.Insert;
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.Modify;

        // Exercise
        CODEUNIT.Run(CODEUNIT::"Exp. Post-Mapping Gen. Jnl.", DataExch);

        // Verify
        CreditTransferEntry.SetRange("Credit Transfer Register No.", CreditTransferRegister."No.");
        Assert.IsFalse(CreditTransferEntry.IsEmpty, StrSubstNo(RecordNotFoundErr, CreditTransferEntry.TableCaption));

        // Cleanup
        DataExch.Delete(true);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UserFeedbackCodeunit()
    var
        BankAcc: Record "Bank Account";
        CreditTransferEntry: Record "Credit Transfer Entry";
        CreditTransferRegister: Record "Credit Transfer Register";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        DataExch: Record "Data Exch.";
        Vendor: Record Vendor;
        CreditTransferRegisterNo: Integer;
        GenJnlLineLineNo: Integer;
    begin
        // [SCENARIO 6] Mark the Gen. Journal Lines as exported, and log the successful export status.
        // [GIVEN] One or more Gen. Journal Lines, applied to Vendor Ledger Entries.
        // [GIVEN] One Credit Transfer Register.
        // [WHEN] Run the codeunit.
        // [THEN] The status of the Credit Transfer Register is set to "File Created".
        // [THEN] The "Exported to Payment File" is set to True on the Gen. Journal Lines.

        // Pre-Setup
        LibraryERM.CreateBankAccount(BankAcc);
        CreateExportGenJournalBatch(GenJnlBatch, BankAcc."No.");

        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        CreditTransferRegister.CreateNew(LibraryUtility.GenerateGUID, BankAcc."No.");
        CreditTransferEntry.CreateNew(CreditTransferRegister."No.", 1,
          GenJnlLine."Account Type", GenJnlLine."Account No.", GenJnlLine.GetAppliesToDocEntryNo,
          GenJnlLine."Posting Date", GenJnlLine."Currency Code", GenJnlLine.Amount, '',
          GenJnlLine."Recipient Bank Account", GenJnlLine."Message to Recipient");

        // Post-Setup
        GenJnlLineLineNo := GenJnlLine."Line No.";
        CreditTransferRegisterNo := CreditTransferRegister."No.";

        // Pre-Exercise
        DataExch.Init;
        DataExch.Insert;
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.Modify;

        // Exercise
        CODEUNIT.Run(CODEUNIT::"Exp. User Feedback Gen. Jnl.", DataExch);

        // Verify
        CreditTransferRegister.Get(CreditTransferRegisterNo);
        CreditTransferRegister.TestField(Status, CreditTransferRegister.Status::"File Created");

        GenJnlLine.Get(GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLineLineNo);
        GenJnlLine.TestField("Exported to Payment File", true);

        // Cleanup
        DataExch.Delete(true);
    end;

    local procedure CreateBankAccountWithExportFormat(var BankAcc: Record "Bank Account"; PaymentExportFormat: Code[20])
    begin
        LibraryERM.CreateBankAccount(BankAcc);
        BankAcc.IBAN := LibraryUtility.GenerateGUID;
        BankAcc.Validate("Payment Export Format", PaymentExportFormat);
        BankAcc.Modify(true);
    end;

    local procedure CreateExportGenJournalBatch(var GenJnlBatch: Record "Gen. Journal Batch"; BalAccountNo: Code[20])
    begin
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, LibraryPaymentExport.SelectPaymentJournalTemplate);
        GenJnlBatch.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"Bank Account");
        GenJnlBatch.Validate("Bal. Account No.", BalAccountNo);
        GenJnlBatch.Validate("Allow Payment Export", true);
        GenJnlBatch.Modify(true);
    end;
}

