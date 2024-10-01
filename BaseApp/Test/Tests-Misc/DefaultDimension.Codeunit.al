codeunit 134487 "Default Dimension"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Default Dimension]
    end;

    var
        Assert: Codeunit Assert;
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        NoValidateErr: Label 'The field No. of table Default Dimension contains a value (%1) that cannot be found in the related table (%2)';
        RenameErr: Label 'You cannot rename %1.';

    [Test]
    [HandlerFunctions('DefaultDimensionsMPH')]
    [Scope('OnPrem')]
    procedure T001_SetDefaultDimForMockMasterWithDimsTable()
    var
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        TableWithDefaultDim: Record "Table With Default Dim";
        MockMasterWithDimsCard: TestPage "Mock Master With Dims Card";
    begin
        // [FEATURE] [UI] [UT]
        // [GIVEN] Master table record 'A', where are Global Dimension fields.
        TableWithDefaultDim."No." := LibraryUtility.GenerateGUID;
        TableWithDefaultDim.Insert;
        // [GIVEN] Run 'Dimension - Single' action on the card page
        MockMasterWithDimsCard.OpenView;
        MockMasterWithDimsCard.Dimensions.Invoke;

        // [WHEN] Define the Default Dimension 'Department'-'ADM' for 'A' in the page
        DimensionValue.Get(LibraryVariableStorage.DequeueText, LibraryVariableStorage.DequeueText); // by DefaultDimensionsMPH

        // [THEN] Default Dimension 'Department'-'ADM' for 'A' does exist
        DefaultDimension.Get(
          DATABASE::"Table With Default Dim", TableWithDefaultDim."No.", DimensionValue."Dimension Code");
        DefaultDimension.TestField("Dimension Value Code", DimensionValue.Code);
    end;

    [Test]
    [HandlerFunctions('DefaultDimensionsMPH')]
    [Scope('OnPrem')]
    procedure T002_SetDefaultDimForMockMasterWithOutDimsTable()
    var
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        MockMasterTable: Record "Mock Master Table";
        DefaultDimensionCodeunit: Codeunit "Default Dimension";
        MockMasterWithoutDimsCard: TestPage "Mock Master Without Dims Card";
    begin
        // [FEATURE] [UI] [UT]
        // [GIVEN] Master table record 'A', where are no Global Dimension fields.
        MockMasterTable."No." := LibraryUtility.GenerateGUID;
        MockMasterTable.Insert;
        // [GIVEN] Subscribed to COD408.OnAfterSetupObjectNoList to add table to the allowed table ID list
        BindSubscription(DefaultDimensionCodeunit);
        // [GIVEN] Run 'Dimension - Single' action on the card page
        MockMasterWithoutDimsCard.OpenView;
        MockMasterWithoutDimsCard.Dimensions.Invoke;

        // [WHEN] Define the Default Dimension 'Department'-'ADM' for 'A' in the page
        DimensionValue.Get(LibraryVariableStorage.DequeueText, LibraryVariableStorage.DequeueText); // by DefaultDimensionsMPH

        // [THEN] Default Dimension 'Department'-'ADM' for 'A' does exist
        DefaultDimension.Get(
          DATABASE::"Mock Master Table", MockMasterTable."No.", DimensionValue."Dimension Code");
        DefaultDimension.TestField("Dimension Value Code", DimensionValue.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure T009_DefaultDimObjListIncludesOneFieldPKeyTables()
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        TableMetadata: Record "Table Metadata";
        DimensionManagement: Codeunit DimensionManagement;
    begin
        // [FEATURE] [UT]
        // [SCENARIO] All tables returned by COD408.DefaultDimObjectNoList() have captions, are not obsolete, and Primary Key of one field.
        DimensionManagement.DefaultDimObjectNoList(TempAllObjWithCaption);
        TempAllObjWithCaption.SetFilter("Object ID", '<>%1&<>%2', DATABASE::"Vendor Agreement", DATABASE::"Customer Agreement");
        with TempAllObjWithCaption do
            if FindSet then
                repeat
                    TableMetadata.Get("Object ID");
                    TableMetadata.TestField(ObsoleteState, TableMetadata.ObsoleteState::No);
                    TestField("Object Caption");
                    Assert.IsTrue(PKContainsOneField("Object ID"), 'PK contains not one field:' + Format("Object ID"));
                until Next = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure T010_DefaultDimForAllAllowedTables()
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        // [FEATURE] [UT]
        // [SCENARIO] All tables returned by COD408.DefaultDimObjectNoList support Rename and Delete.
        // [SCENARIO] (Except RU local tables "Vendor Agreement" and "Customer Agreement")
        DimensionManagement.DefaultDimObjectNoList(TempAllObjWithCaption);
        TempAllObjWithCaption.SetFilter("Object ID", '<>%1&<>%2', DATABASE::"Vendor Agreement", DATABASE::"Customer Agreement");
        if TempAllObjWithCaption.FindSet then
            repeat
                ValidateNotExistingNo(TempAllObjWithCaption."Object ID", RenameMasterRecord(TempAllObjWithCaption."Object ID"));
            until TempAllObjWithCaption.Next = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TRU001_DefaultDimListIncludesCustVendAgreements()
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        DimensionManagement: Codeunit DimensionManagement;
    begin
        // [FEATURE] [Country:RU] [Agreement]
        // [SCENARIO] COD408.DefaultDimObjectNoList includes Customer/Vendor Agreement tables, though they have 2 fields in PKey.
        DimensionManagement.DefaultDimObjectNoList(TempAllObjWithCaption);
        TempAllObjWithCaption.SetRange("Object ID", DATABASE::"Vendor Agreement", DATABASE::"Customer Agreement");
        Assert.RecordCount(TempAllObjWithCaption, 2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TRU002_VendorAgreementCannotBeRenamed()
    var
        VendorAgreement: Record "Vendor Agreement";
    begin
        // [FEATURE] [Country:RU] [Agreement]
        // [SCENARIO] "Vendor Agreement" cannot be renamed (no need to rename Default Dimensions)
        VendorAgreement.Init;
        VendorAgreement."No." := LibraryUtility.GenerateGUID;
        VendorAgreement.Insert;
        asserterror VendorAgreement.Rename('', LibraryUtility.GenerateGUID);
        Assert.ExpectedError(StrSubstNo(RenameErr, VendorAgreement.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TRU003_CustomerAgreementCannotBeRenamed()
    var
        CustomerAgreement: Record "Customer Agreement";
    begin
        // [FEATURE] [Country:RU] [Agreement]
        // [SCENARIO] "Customer Agreement" cannot be renamed (no need to rename Default Dimensions)
        CustomerAgreement.Init;
        CustomerAgreement."No." := LibraryUtility.GenerateGUID;
        CustomerAgreement.Insert;
        asserterror CustomerAgreement.Rename('', LibraryUtility.GenerateGUID);
        Assert.ExpectedError(StrSubstNo(RenameErr, CustomerAgreement.TableCaption));
    end;

    local procedure RenameMasterRecord(TableID: Integer) PK: Code[20]
    var
        DefaultDimension: array[2] of Record "Default Dimension";
        NewPK: Code[20];
    begin
        // [GIVEN] SalespersonPurchaser 'A' with Default Dimensions 'Department' and 'Project'
        PK := NewRecord(TableID);
        CreateDefaultDimension(TableID, PK, DefaultDimension[1]);
        CreateDefaultDimension(TableID, PK, DefaultDimension[2]);
        // [WHEN] rename 'A' to 'B'
        NewPK := RenameRecord(TableID, PK);
        // [THEN] Record 'B' has Default Dimensions 'Department' and 'Project'
        VerifyRenamedDefaultDimensions(DefaultDimension, TableID, PK, NewPK);
    end;

    local procedure ValidateNotExistingNo(TableID: Integer; PK: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        // [GIVEN] Record 'X' does not exist
        // [WHEN] Default Dimension, where validate "No." as 'X'
        asserterror CreateDefaultDimension(TableID, PK, DefaultDimension);
        // [THEN] Error message 'Value X cannot be found in the related table'
        Assert.ExpectedError(StrSubstNo(NoValidateErr, PK, GetTableCaption(TableID)));
    end;

    local procedure CreateDefaultDimension(TableNo: Integer; PK: Code[20]; var DefaultDimension: Record "Default Dimension")
    var
        DimensionValue: Record "Dimension Value";
    begin
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, TableNo, PK, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure GetTableCaption(TableID: Integer) TableCaption: Text
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableID);
        TableCaption := RecRef.Caption;
        RecRef.Close;
    end;

    local procedure NewRecord(TableID: Integer) PK: Code[20]
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        RecRef: RecordRef;
    begin
        PK := LibraryUtility.GenerateGUID;
        RecRef.Open(TableID);
        KeyRef := RecRef.KeyIndex(1);
        FieldRef := KeyRef.FieldIndex(1);
        FieldRef.Value := PK;
        Assert.IsTrue(RecRef.Insert, 'INSERT has failed');
        RecRef.Close;
    end;

    local procedure RenameRecord(TableID: Integer; PK: Code[20]) NewPK: Code[20]
    var
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        RecRef: RecordRef;
    begin
        NewPK := LibraryUtility.GenerateGUID;
        RecRef.Open(TableID);
        KeyRef := RecRef.KeyIndex(1);
        FieldRef := KeyRef.FieldIndex(1);
        FieldRef.SetRange(PK);
        RecRef.FindFirst;
        Assert.IsTrue(RecRef.Rename(NewPK), 'RENAME has failed');
        RecRef.Close;
    end;

    local procedure PKContainsOneField(TableID: Integer) Result: Boolean
    var
        KeyRef: KeyRef;
        RecRef: RecordRef;
    begin
        RecRef.Open(TableID);
        KeyRef := RecRef.KeyIndex(1);
        Result := KeyRef.FieldCount = 1;
        RecRef.Close;
    end;

    local procedure VerifyRenamedDefaultDimensions(DefaultDimension: array[2] of Record "Default Dimension"; TableID: Integer; PK: Code[20]; NewPK: Code[20])
    begin
        Assert.IsTrue(DefaultDimension[1].Get(TableID, NewPK, DefaultDimension[1]."Dimension Code"), 'New#1 ' + Format(TableID));
        Assert.IsFalse(DefaultDimension[1].Get(TableID, PK, DefaultDimension[1]."Dimension Code"), 'Old#1 ' + Format(TableID));
        Assert.IsTrue(DefaultDimension[2].Get(TableID, NewPK, DefaultDimension[2]."Dimension Code"), 'New#2 ' + Format(TableID));
        Assert.IsFalse(DefaultDimension[2].Get(TableID, PK, DefaultDimension[2]."Dimension Code"), 'Old#2 ' + Format(TableID));
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure DefaultDimensionsMPH(var DefaultDimensionsPage: TestPage "Default Dimensions")
    var
        DimensionValue: Record "Dimension Value";
    begin
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryVariableStorage.Enqueue(DimensionValue."Dimension Code");
        LibraryVariableStorage.Enqueue(DimensionValue.Code);
        DefaultDimensionsPage.New;
        DefaultDimensionsPage."Dimension Code".SetValue(DimensionValue."Dimension Code");
        DefaultDimensionsPage."Dimension Value Code".SetValue(DimensionValue.Code);
        DefaultDimensionsPage.OK.Invoke;
    end;

    [EventSubscriber(ObjectType::Codeunit, 408, 'OnAfterSetupObjectNoList', '', false, false)]
    local procedure OnAfterSetupObjectNoListHandler(var TempAllObjWithCaption: Record AllObjWithCaption temporary)
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.InsertObject(TempAllObjWithCaption, DATABASE::"Mock Master Table");
    end;
}

