codeunit 144544 "ERM G/L Account Where-Used RU"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [G/L Account Where-Used]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
        isInitialized: Boolean;
        InvalidTableCaptionErr: Label 'Invalid table caption.';
        InvalidFieldCaptionErr: Label 'Invalid field caption.';
        InvalidLineValueErr: Label 'Invalid Line value.';

    [Test]
    [HandlerFunctions('WhereUsedHandler')]
    [Scope('OnPrem')]
    procedure CheckFACharge()
    var
        FACharge: Record "FA Charge";
    begin
        // [SCENARIO 263861] FA Charge should be shown on Where-Used page
        Initialize;

        // [GIVEN] FA Charge with "G/L Acc. for Released FA" = "G"
        CreateFACharge(FACharge);

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        CalcGLAccWhereUsed.CheckGLAcc(FACharge."G/L Acc. for Released FA");

        // [THEN] G/L Account "G" is shown on "G/L Account Where-Used List"
        ValidateWhereUsedRecord(
          FACharge.TableCaption,
          FACharge.FieldCaption("G/L Acc. for Released FA"),
          StrSubstNo('%1=%2', FACharge.FieldCaption("No."), FACharge."No."));
    end;

    [Test]
    [HandlerFunctions('WhereUsedShowDetailsHandler')]
    [Scope('OnPrem')]
    procedure ShowDetailsWhereUsedFACharge()
    var
        FACharge: Record "FA Charge";
        FAChargeList: TestPage "FA Charge List";
    begin
        // [SCENARIO 263861] FA Charge List page should be open on Show Details action from Where-Used page
        Initialize;

        // [GIVEN] FA Charge "FC" with "G/L Acc. for Released FA" = "G"
        CreateFACharge(FACharge);

        // [WHEN] Run Where-Used function for G/L Accoun "G" and choose Show Details action
        FAChargeList.Trap;
        CalcGLAccWhereUsed.CheckGLAcc(FACharge."G/L Acc. for Released FA");

        // [THEN] FA Charge List opened with "No." = "FC"
        FAChargeList."No.".AssertEquals(FACharge."No.");
    end;

    [Test]
    [HandlerFunctions('WhereUsedHandler')]
    [Scope('OnPrem')]
    procedure CheckPayrollPostingGroup()
    var
        PayrollPostingGroup: Record "Payroll Posting Group";
    begin
        // [SCENARIO 263861] Payroll Posting Group should be shown on Where-Used page
        Initialize;

        // [GIVEN] Payroll Posting Group with "Future Vacation G/L Acc. No." = "G"
        CreatePayrollPostingGroup(PayrollPostingGroup);

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        CalcGLAccWhereUsed.CheckGLAcc(PayrollPostingGroup."Future Vacation G/L Acc. No.");

        // [THEN] G/L Account "G" is shown on "G/L Account Where-Used List"
        ValidateWhereUsedRecord(
          PayrollPostingGroup.TableCaption,
          PayrollPostingGroup.FieldCaption("Future Vacation G/L Acc. No."),
          StrSubstNo('%1=%2', PayrollPostingGroup.FieldCaption(Code), PayrollPostingGroup.Code));
    end;

    [Test]
    [HandlerFunctions('WhereUsedShowDetailsHandler')]
    [Scope('OnPrem')]
    procedure ShowDetailsWhereUsedPayrollPostingGroup()
    var
        PayrollPostingGroup: Record "Payroll Posting Group";
        PayrollPostingGroups: TestPage "Payroll Posting Groups";
    begin
        // [SCENARIO 263861] Payroll Posting Groups page should be open on Show Details action from Where-Used page
        Initialize;

        // [GIVEN] Payroll Posting Group "Code" = "PPG" with "Future Vacation G/L Acc. No." = "G"
        CreatePayrollPostingGroup(PayrollPostingGroup);

        // [WHEN] Run Where-Used function for G/L Accoun "G"
        PayrollPostingGroups.Trap;
        CalcGLAccWhereUsed.CheckGLAcc(PayrollPostingGroup."Future Vacation G/L Acc. No.");

        // [THEN] Payroll Posting Groups page opened with "Code" = "PPG"
        PayrollPostingGroups.Code.AssertEquals(PayrollPostingGroup.Code);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear;
        if isInitialized then
            exit;

        isInitialized := true;
    end;

    local procedure CreateFACharge(var FACharge: Record "FA Charge")
    begin
        with FACharge do begin
            Init;
            "No." := LibraryUtility.GenerateRandomCode(FieldNo("No."), DATABASE::"FA Charge");
            "G/L Acc. for Released FA" := LibraryERM.CreateGLAccountNo;
            Insert;
        end;
    end;

    [Scope('OnPrem')]
    procedure CreatePayrollPostingGroup(var PayrollPostingGroup: Record "Payroll Posting Group")
    begin
        with PayrollPostingGroup do begin
            Init;
            Code := LibraryUtility.GenerateRandomCode(FieldNo(Code), DATABASE::"Payroll Posting Group");
            "Future Vacation G/L Acc. No." := LibraryERM.CreateGLAccountNo;
            Insert;
        end;
    end;

    local procedure ValidateWhereUsedRecord(ExpectedTableCaption: Text; ExpectedFieldCaption: Text; ExpectedLineValue: Text)
    begin
        Assert.AreEqual(ExpectedTableCaption, LibraryVariableStorage.DequeueText, InvalidTableCaptionErr);
        Assert.AreEqual(ExpectedFieldCaption, LibraryVariableStorage.DequeueText, InvalidFieldCaptionErr);
        Assert.AreEqual(ExpectedLineValue, LibraryVariableStorage.DequeueText, InvalidLineValueErr);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure WhereUsedHandler(var GLAccountWhereUsedList: TestPage "G/L Account Where-Used List")
    begin
        GLAccountWhereUsedList.First;
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList."Table Name".Value);
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList."Field Name".Value);
        LibraryVariableStorage.Enqueue(GLAccountWhereUsedList.Line.Value);
        GLAccountWhereUsedList.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure WhereUsedShowDetailsHandler(var GLAccountWhereUsedList: TestPage "G/L Account Where-Used List")
    begin
        GLAccountWhereUsedList.First;
        GLAccountWhereUsedList.ShowDetails.Invoke;
    end;
}

