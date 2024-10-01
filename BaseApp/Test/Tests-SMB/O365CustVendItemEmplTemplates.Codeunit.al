codeunit 138008 "Cust/Vend/Item/Empl Templates"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [New Templates]
    end;

    var
        Assert: Codeunit Assert;
        LibraryTemplates: Codeunit "Library - Templates";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        IsInitialized: Boolean;
        TemplateFeatureEnabled: Boolean;
        GlobalDimCodeTemplateErr: Label 'Value of template Global Dimension Code is wrong';
        CopyTemplateDataErr: Label 'Data in copied template is wrong';
        CopyTemplateDimensionsErr: Label 'Dimensions in copied template are wrong';
        InsertedVendorErr: Label 'Vendor inserted with wrong data';
        InsertedCustomerErr: Label 'Customer inserted with wrong data';
        InsertedItemErr: Label 'Item inserted with wrong data';
        InsertedEmployeeErr: Label 'Employee inserted with wrong data';
        InsertedTemplateErr: Label 'Template inserted with wrong data';

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplValidateTemplateGlobalDimensionCodeUT()
    var
        VendorTempl: Record "Vendor Templ.";
        DimensionValue: Record "Dimension Value";
    begin
        // [SCENARIO 353440] Validate "Global Dimension X Code" template field inserts Default Dimension
        Initialize();

        // [GIVEN] Template
        LibraryTemplates.CreateVendorTemplate(VendorTempl);

        // [WHEN] Validate "Global Dimension 1 Code" with "DV1"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        VendorTempl.Validate("Global Dimension 1 Code", DimensionValue.Code);

        // [WHEN] Validate "Global Dimension 2 Code" with "DV2"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        VendorTempl.Validate("Global Dimension 2 Code", DimensionValue.Code);
        VendorTempl.Modify(true);

        // [THEN] Default dimensions "DV1" and "DV2" are inserted
        VerifyTemplateGlobalDimensionIsDefaultDimension(Database::"Vendor Templ.", VendorTempl.Code, VendorTempl."Global Dimension 1 Code", VendorTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplInsertDefaultDimensionWithGlobalDimensionCodeUT()
    var
        VendorTempl: Record "Vendor Templ.";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        // [SCENARIO 353440] Inserting "Global Dimension X Code" Default Dimension updates "Global Dimension X Code" template field
        Initialize();

        // [GIVEN] Template with empty "Global Dimension 1 Code" and "Global Dimension 2 Code"
        LibraryTemplates.CreateVendorTemplate(VendorTempl);

        // [WHEN] Insert "DV1" Default Dimension related to "Global Dimension 1 Code"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Vendor Templ.", VendorTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [WHEN] Insert "DV2" Default Dimension related to "Global Dimension 2 Code"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Vendor Templ.", VendorTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [THEN] Template "Global Dimension 1 Code" = "DV1"
        // [THEN] Template "Global Dimension 2 Code" = "DV2"
        VendorTempl.Get(VendorTempl.Code);
        VerifyTemplateGlobalDimensionCodeValue(Database::"Vendor Templ.", VendorTempl.Code, VendorTempl."Global Dimension 1 Code", VendorTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplCopyTemplateUT()
    var
        SourceVendorTempl: Record "Vendor Templ.";
        DestVendorTempl: Record "Vendor Templ.";
    begin
        // [SCENARIO 353440] Copy one template from the other one
        Initialize();

        // [GIVEN] Source template "ST" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(SourceVendorTempl);

        // [GIVEN] Destination empty template "DT"
        LibraryTemplates.CreateVendorTemplate(DestVendorTempl);

        // [WHEN] Copy "DT" from "ST"
        DestVendorTempl.CopyFromTemplate(SourceVendorTempl);

        // [THEN] "DT" data copied from "ST"
        VerifyCopiedVendorTemplateData(DestVendorTempl, SourceVendorTempl);
        // [THEN] "DT" dimensions copied from "ST" dimensions
        VerifyDimensions(Database::"Vendor Templ.", DestVendorTempl.Code, Database::"Vendor Templ.", SourceVendorTempl.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplCreateVendorOneTemplateUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new vendor with one template
        Initialize();
        VendorTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl);

        // [WHEN] Create new vendor
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor inserted with data from "T"
        VerifyVendor(Vendor, VendorTempl);
        // [THEN] Vendor dimensions inserted from "T" dimensions
        VerifyDimensions(Database::Vendor, Vendor."No.", Database::"Vendor Templ.", VendorTempl.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectVendorTemplListHandler')]
    procedure VendorTemplCreateVendorTwoTemplatesUT()
    var
        Vendor: Record Vendor;
        VendorTempl1: Record "Vendor Templ.";
        VendorTempl2: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new vendor with two templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl2);
        LibraryVariableStorage.Enqueue(VendorTempl2.Code);

        // [WHEN] Create new vendor from "T2" (VendorTemplListHandler)
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor filled with data from "T2"
        VerifyVendor(Vendor, VendorTempl2);
        // [THEN] Vendor dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Vendor, Vendor."No.", Database::"Vendor Templ.", VendorTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplCreateBlockedVendorTemplateUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 363951] Create new vendor from template with filled "Blocked"
        Initialize();
        VendorTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template with "Blocked" = "Payment"
        LibraryTemplates.CreateVendorTemplate(VendorTempl);
        VendorTempl.Blocked := VendorTempl.Blocked::Payment;
        VendorTempl.Modify(true);

        // [WHEN] Create new vendor
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor "Blocked" = "Payment"
        Assert.IsTrue(Vendor.Blocked = Vendor.Blocked::Payment, InsertedVendorErr);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplAdditionalFields()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        Location: Record Location;
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        VendorTemplCard: TestPage "Vendor Templ. Card";
        PartnerType: Enum "Partner Type";
        ShipmentMethodCode: Code[10];
    begin
        // [SCENARIO 406122] Additional fields copied between Vendor and Vendor Templ.
        Initialize();
        VendorTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);
        // [GIVEN] Template with "Partner Type","Location Code", "Shipment Method Code"
        LibraryTemplates.CreateVendorTemplate(VendorTempl);
        VendorTemplCard.OpenEdit();
        VendorTemplCard.Filter.SetFilter(Code, VendorTempl.Code);
        VendorTemplCard."Partner Type".SetValue(PartnerType::Person);
        LibraryWarehouse.CreateLocation(Location);
        VendorTemplCard."Location Code".SetValue(Location.Code);
        ShipmentMethodCode := CreateShipmentMethodCode();
        VendorTemplCard."Shipment Method Code".SetValue(ShipmentMethodCode);
        VendorTemplCard.Close();

        // [WHEN] Create new Vendor
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor contains fields: "Partner Type","Location Code", "Shipment Method Code"
        Vendor.TestField("Partner Type", PartnerType::Person);
        Vendor.TestField("Location Code", Location.Code);
        Vendor.TestField("Shipment Method Code", ShipmentMethodCode);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplValidateTemplateGlobalDimensionCodeUT()
    var
        CustomerTempl: Record "Customer Templ.";
        DimensionValue: Record "Dimension Value";
    begin
        // [SCENARIO 353440] Validate "Global Dimension X Code" template field inserts Default Dimension
        Initialize();

        // [GIVEN] Template
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);

        // [WHEN] Validate "Global Dimension 1 Code" with "DV1"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        CustomerTempl.Validate("Global Dimension 1 Code", DimensionValue.Code);

        // [WHEN] Validate "Global Dimension 2 Code" with "DV2"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        CustomerTempl.Validate("Global Dimension 2 Code", DimensionValue.Code);
        CustomerTempl.Modify(true);

        // [THEN] Default dimensions "DV1" and "DV2" are inserted
        VerifyTemplateGlobalDimensionIsDefaultDimension(Database::"Customer Templ.", CustomerTempl.Code, CustomerTempl."Global Dimension 1 Code", CustomerTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplInsertDefaultDimensionWithGlobalDimensionCodeUT()
    var
        CustomerTempl: Record "Customer Templ.";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        // [SCENARIO 353440] Inserting "Global Dimension X Code" Default Dimension updates "Global Dimension X Code" template field
        Initialize();

        // [GIVEN] Template with empty "Global Dimension 1 Code" and "Global Dimension 2 Code"
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);

        // [WHEN] Insert "DV1" Default Dimension related to "Global Dimension 1 Code"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Customer Templ.", CustomerTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [WHEN] Insert "DV2" Default Dimension related to "Global Dimension 2 Code"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Customer Templ.", CustomerTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [THEN] Template "Global Dimension 1 Code" = "DV1"
        // [THEN] Template "Global Dimension 2 Code" = "DV2"
        CustomerTempl.Get(CustomerTempl.Code);
        VerifyTemplateGlobalDimensionCodeValue(Database::"Customer Templ.", CustomerTempl.Code, CustomerTempl."Global Dimension 1 Code", CustomerTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCopyTemplateUT()
    var
        SourceCustomerTempl: Record "Customer Templ.";
        DestCustomerTempl: Record "Customer Templ.";
    begin
        // [SCENARIO 353440] Copy one template from the other one
        Initialize();

        // [GIVEN] Source template "ST" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(SourceCustomerTempl);

        // [GIVEN] Destination empty template "DT"
        LibraryTemplates.CreateCustomerTemplate(DestCustomerTempl);

        // [WHEN] Copy "DT" from "ST"
        DestCustomerTempl.CopyFromTemplate(SourceCustomerTempl);

        // [THEN] "DT" data copied from "ST"
        VerifyCopiedCustomerTemplateData(DestCustomerTempl, SourceCustomerTempl);
        // [THEN] "DT" dimensions copied from "ST" dimensions
        VerifyDimensions(Database::"Customer Templ.", DestCustomerTempl.Code, Database::"Customer Templ.", SourceCustomerTempl.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateCustomerOneTemplateUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new customer with one template
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl);

        // [WHEN] Create new customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer inserted with data from "T"
        VerifyCustomer(Customer, CustomerTempl);
        // [THEN] Customer dimensions inserted from "T" dimensions
        VerifyDimensions(Database::Customer, Customer."No.", Database::"Customer Templ.", CustomerTempl.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateCustomerOneTemplateDocSendingProfileUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        DocumentSendingProfile: Record "Document Sending Profile";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 389638] Create new customer with one template and filled in "Document Sending Profile"
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl);
        UpdateDocSendingProfile(DocumentSendingProfile, CustomerTempl);

        // [WHEN] Create new customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer inserted with data from "T"
        VerifyCustomer(Customer, CustomerTempl);
        // [THEN] Customer dimensions inserted from "T" dimensions
        VerifyDimensions(Database::Customer, Customer."No.", Database::"Customer Templ.", CustomerTempl.Code);
        // [THEN] "Document Sending Profile" filled in customer
        Assert.AreEqual(DocumentSendingProfile.Code, Customer."Document Sending Profile", 'Wrong document sending profile');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectCustomerTemplListHandler')]
    procedure CustomerTemplCreateCustomerTwoTemplatesUT()
    var
        Customer: Record Customer;
        CustomerTempl1: Record "Customer Templ.";
        CustomerTempl2: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new customer with two templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl2);
        LibraryVariableStorage.Enqueue(CustomerTempl2.Code);

        // [WHEN] Create new customer from "T2" (CustomerTemplListHandler)
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Vendor filled with data from "T2"
        VerifyCustomer(Customer, CustomerTempl2);
        // [THEN] Vendor dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Customer, Customer."No.", Database::"Customer Templ.", CustomerTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateBlockedCustomerTemplateUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 363951] Create new customer from template with filled "Blocked"
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template with "Blocked" = "All"
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);
        CustomerTempl.Blocked := CustomerTempl.Blocked::All;
        CustomerTempl.Modify(true);

        // [WHEN] Create new customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer "Blocked" = "All"
        Assert.IsTrue(Customer.Blocked = Customer.Blocked::All, InsertedCustomerErr);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplAdditionalFields()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        Location: Record Location;
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        CustomerTemplCard: TestPage "Customer Templ. Card";
        PartnerType: Enum "Partner Type";
    begin
        // [SCENARIO 406122] Additional fields copied between Customer and Customer Templ.
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);
        // [GIVEN] Template with "Partner Type","Location Code"
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);
        CustomerTemplCard.OpenEdit();
        CustomerTemplCard.Filter.SetFilter(Code, CustomerTempl.Code);
        CustomerTemplCard."Partner Type".SetValue(PartnerType::Company);
        LibraryWarehouse.CreateLocation(Location);
        CustomerTemplCard."Location Code".SetValue(Location.Code);
        CustomerTemplCard.Close();

        // [WHEN] Create new Customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer contains fields: "Partner Type","Location Code"
        Customer.TestField("Partner Type", PartnerType::Company);
        Customer.TestField("Location Code", Location.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplValidateTemplateGlobalDimensionCodeUT()
    var
        ItemTempl: Record "Item Templ.";
        DimensionValue: Record "Dimension Value";
    begin
        // [SCENARIO 353440] Validate "Global Dimension X Code" template field inserts Default Dimension
        Initialize();

        // [GIVEN] Template
        LibraryTemplates.CreateItemTemplate(ItemTempl);

        // [WHEN] Validate "Global Dimension 1 Code" with "DV1"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        ItemTempl.Validate("Global Dimension 1 Code", DimensionValue.Code);

        // [WHEN] Validate "Global Dimension 2 Code" with "DV2"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        ItemTempl.Validate("Global Dimension 2 Code", DimensionValue.Code);
        ItemTempl.Modify(true);

        // [THEN] Default dimensions "DV1" and "DV2" are inserted
        VerifyTemplateGlobalDimensionIsDefaultDimension(Database::"Item Templ.", ItemTempl.Code, ItemTempl."Global Dimension 1 Code", ItemTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplInsertDefaultDimensionWithGlobalDimensionCodeUT()
    var
        ItemTempl: Record "Item Templ.";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        // [SCENARIO 353440] Inserting "Global Dimension X Code" Default Dimension updates "Global Dimension X Code" template field
        Initialize();

        // [GIVEN] Template with empty "Global Dimension 1 Code" and "Global Dimension 2 Code"
        LibraryTemplates.CreateItemTemplate(ItemTempl);

        // [WHEN] Insert "DV1" Default Dimension related to "Global Dimension 1 Code"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Item Templ.", ItemTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [WHEN] Insert "DV2" Default Dimension related to "Global Dimension 2 Code"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Item Templ.", ItemTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [THEN] Template "Global Dimension 1 Code" = "DV1"
        // [THEN] Template "Global Dimension 2 Code" = "DV2"
        ItemTempl.Get(ItemTempl.Code);
        VerifyTemplateGlobalDimensionCodeValue(Database::"Item Templ.", ItemTempl.Code, ItemTempl."Global Dimension 1 Code", ItemTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCopyTemplateUT()
    var
        SourceItemTempl: Record "Item Templ.";
        DestItemTempl: Record "Item Templ.";
    begin
        // [SCENARIO 353440] Copy one template from the other one
        Initialize();

        // [GIVEN] Source template "ST" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(SourceItemTempl);

        // [GIVEN] Destination empty template "DT"
        LibraryTemplates.CreateItemTemplate(DestItemTempl);

        // [WHEN] Copy "DT" from "ST"
        DestItemTempl.CopyFromTemplate(SourceItemTempl);

        // [THEN] "DT" data copied from "ST"
        VerifyCopiedItemTemplateData(DestItemTempl, SourceItemTempl);
        // [THEN] "DT" dimensions copied from "ST" dimensions
        VerifyDimensions(Database::"Item Templ.", DestItemTempl.Code, Database::"Item Templ.", SourceItemTempl.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemOneTemplateUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new item with one template
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl);

        // [WHEN] Create new Item
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item inserted with data from template
        VerifyItem(Item, ItemTempl);
        // [THEN] Item dimensions inserted from template dimensions
        VerifyDimensions(Database::Item, Item."No.", Database::"Item Templ.", ItemTempl.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectItemTemplListHandler')]
    procedure ItemTemplCreateItemTwoTemplatesUT()
    var
        Item: Record Item;
        ItemTempl1: Record "Item Templ.";
        ItemTempl2: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new item with two templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl2);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);

        // [WHEN] Create new Item from "T2" (ItemTemplListHandler)
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item filled with data from "T2"
        VerifyItem(Item, ItemTempl2);
        // [THEN] Item dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Item, Item."No.", Database::"Item Templ.", ItemTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateBlockedItemTemplateUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 363951] Create new item from template with filled "Blocked"
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template with "Blocked" = true, "Sales Blocked" = true, "Purchasing Blocked" = true
        LibraryTemplates.CreateItemTemplate(ItemTempl);
        ItemTempl.Blocked := true;
        ItemTempl."Sales Blocked" := true;
        ItemTempl."Purchasing Blocked" := true;
        ItemTempl.Modify(true);

        // [WHEN] Create new Item
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item "Blocked" = true
        // [THEN] Item "Sales Blocked" = true
        // [THEN] Item "Purchasing Blocked" = true
        Assert.IsTrue(Item.Blocked, InsertedItemErr);
        Assert.IsTrue(Item."Sales Blocked", InsertedItemErr);
        Assert.IsTrue(Item."Purchasing Blocked", InsertedItemErr);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplAdditionalFields()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        ItemTemplCard: TestPage "Item Templ. Card";
        ItemTrackingCode: Record "Item Tracking Code";
        SerialNosCode: Code[20];
        LotNosCode: Code[20];
    begin
        // [SCENARIO 406122] Additional fields copied between Item and Item Templ.
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);
        // [GIVEN] Template with "Item Tracking Code", "Serial Nos.", "Lot Nos."
        LibraryTemplates.CreateItemTemplate(ItemTempl);
        ItemTemplCard.OpenEdit();
        ItemTemplCard.Filter.SetFilter(Code, ItemTempl.Code);
        LibraryInventory.CreateItemTrackingCode(ItemTrackingCode);
        ItemTemplCard."Item Tracking Code".SetValue(ItemTrackingCode.Code);
        SerialNosCode := LibraryERM.CreateNoSeriesCode();
        ItemTemplCard."Serial Nos.".SetValue(SerialNosCode);
        LotNosCode := LibraryERM.CreateNoSeriesCode();
        ItemTemplCard."Lot Nos.".SetValue(LotNosCode);
        ItemTemplCard.Close();

        // [WHEN] Create new Item
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item contains fields: "Item Tracking Code", "Serial Nos.", "Lot Nos." 
        Item.TestField("Item Tracking Code", ItemTrackingCode.Code);
        Item.TestField("Serial Nos.", SerialNosCode);
        Item.TestField("Lot Nos.", LotNosCode);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeTemplValidateTemplateGlobalDimensionCodeUT()
    var
        EmployeeTempl: Record "Employee Templ.";
        DimensionValue: Record "Dimension Value";
    begin
        // [SCENARIO 353440] Validate "Global Dimension X Code" template field inserts Default Dimension
        Initialize();

        // [GIVEN] Template
        LibraryTemplates.CreateEmployeeTemplate(EmployeeTempl);

        // [WHEN] Validate "Global Dimension 1 Code" with "DV1"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        EmployeeTempl.Validate("Global Dimension 1 Code", DimensionValue.Code);

        // [WHEN] Validate "Global Dimension 2 Code" with "DV2"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        EmployeeTempl.Validate("Global Dimension 2 Code", DimensionValue.Code);
        EmployeeTempl.Modify(true);

        // [THEN] Default dimensions "DV1" and "DV2" are inserted
        VerifyTemplateGlobalDimensionIsDefaultDimension(Database::"Employee Templ.", EmployeeTempl.Code, EmployeeTempl."Global Dimension 1 Code", EmployeeTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeTemplInsertDefaultDimensionWithGlobalDimensionCodeUT()
    var
        EmployeeTempl: Record "Employee Templ.";
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        // [SCENARIO 353440] Inserting "Global Dimension X Code" Default Dimension updates "Global Dimension X Code" template field
        Initialize();

        // [GIVEN] Template with empty "Global Dimension 1 Code" and "Global Dimension 2 Code"
        LibraryTemplates.CreateEmployeeTemplate(EmployeeTempl);

        // [WHEN] Insert "DV1" Default Dimension related to "Global Dimension 1 Code"
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Employee Templ.", EmployeeTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [WHEN] Insert "DV2" Default Dimension related to "Global Dimension 2 Code"
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"Employee Templ.", EmployeeTempl.Code, DimensionValue."Dimension Code", DimensionValue.Code);

        // [THEN] Template "Global Dimension 1 Code" = "DV1"
        // [THEN] Template "Global Dimension 2 Code" = "DV2"
        EmployeeTempl.Get(EmployeeTempl.Code);
        VerifyTemplateGlobalDimensionCodeValue(Database::"Employee Templ.", EmployeeTempl.Code, EmployeeTempl."Global Dimension 1 Code", EmployeeTempl."Global Dimension 2 Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeTemplCopyTemplateUT()
    var
        SourceEmployeeTempl: Record "Employee Templ.";
        DestEmployeeTempl: Record "Employee Templ.";
    begin
        // [SCENARIO 353440] Copy one template from the other one
        Initialize();

        // [GIVEN] Source template "ST" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(SourceEmployeeTempl);

        // [GIVEN] Destination empty template "DT"
        LibraryTemplates.CreateEmployeeTemplate(DestEmployeeTempl);

        // [WHEN] Copy "DT" from "ST"
        DestEmployeeTempl.CopyFromTemplate(SourceEmployeeTempl);

        // [THEN] "DT" data copied from "ST"
        VerifyCopiedEmployeeTemplateData(DestEmployeeTempl, SourceEmployeeTempl);
        // [THEN] "DT" dimensions copied from "ST" dimensions
        VerifyDimensions(Database::"Employee Templ.", DestEmployeeTempl.Code, Database::"Employee Templ.", SourceEmployeeTempl.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeTemplCreateEmployeeOneTemplateUT()
    var
        Employee: Record Employee;
        EmployeeTempl: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new employee with one template
        Initialize();
        EmployeeTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetEmplTemplateFeatureEnabled(true);

        // [GIVEN] Template with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl);

        // [WHEN] Create new employee
        EmployeeTemplMgt.InsertEmployeeFromTemplate(Employee);

        // [THEN] Employee inserted with data from template
        VerifyEmployee(Employee, EmployeeTempl);
        // [THEN] Employee dimensions inserted from template dimensions
        VerifyDimensions(Database::Employee, Employee."No.", Database::"Employee Templ.", EmployeeTempl.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectEmployeeTemplListHandler')]
    procedure EmployeeTemplCreateEmployeeTwoTemplatesUT()
    var
        Employee: Record Employee;
        EmployeeTempl1: Record "Employee Templ.";
        EmployeeTempl2: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new employee with two templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetEmplTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl2);
        LibraryVariableStorage.Enqueue(EmployeeTempl2.Code);

        // [WHEN] Create new employee from "T2" (EmployeeTemplListHandler)
        EmployeeTemplMgt.InsertEmployeeFromTemplate(Employee);

        // [THEN] Employee filled with data from "T2"
        VerifyEmployee(Employee, EmployeeTempl2);
        // [THEN] Employee dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Employee, Employee."No.", Database::"Employee Templ.", EmployeeTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TemplatesFeatureKeyUT()
    var
        FeatureKey: Record "Feature Key";
    begin
        // [SCENARIO] Get feature key for new templates
        FeatureKey.Get('NewTemplates');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectEmployeeTemplListHandler')]
    procedure EmployeeTemplCreateEmployeeFromContactTwoTemplatesUT()
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Employee: Record Employee;
        EmployeeTempl1: Record "Employee Templ.";
        EmployeeTempl2: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Create new employee from person contact with two templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetEmplTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl2);
        LibraryVariableStorage.Enqueue(EmployeeTempl2.Code);

        // [GIVEN] Person contact "C"
        LibraryMarketing.CreatePersonContact(Contact);

        // [WHEN] Create new employee from "C" using "T2" (EmployeeTemplListHandler)
        Contact.SetHideValidationDialog(true);
        Contact.CreateEmployee();

        // [THEN] Employee filled with data from "C" and "T2"
        ContBusRel.FindByContact(ContBusRel."Link to Table"::Employee, Contact."No.");
        Employee.Get(ContBusRel."No.");
        Assert.IsTrue(Employee."First Name" = Contact.Name, InsertedEmployeeErr);
        VerifyEmployee(Employee, EmployeeTempl2);

        // [THEN] Employee dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Employee, Employee."No.", Database::"Employee Templ.", EmployeeTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectEmployeeTemplListInvokeCancelHandler')]
    procedure EmployeeTemplCreateEmployeeFromContactTwoTemplatesInvokeCancelUT()
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Employee: Record Employee;
        EmployeeTempl: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        i: Integer;
    begin
        // [SCENARIO 365727] Create new employee from person contact with two templates and invoke cancel the on the template list
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetEmplTemplateFeatureEnabled(true);

        // [GIVEN] Two templates
        for i := 1 to 2 do
            LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl);

        // [GIVEN] Person contact "C"
        LibraryMarketing.CreatePersonContact(Contact);

        // [WHEN] Create new employee from "C" and invoke cancel on the template list (SelectEmployeeTemplListInvokeCancelHandler)
        Contact.SetHideValidationDialog(true);
        Contact.CreateEmployee();

        // [THEN] Employee was not created
        Assert.IsFalse(ContBusRel.FindByContact(ContBusRel."Link to Table"::Employee, Contact."No."), 'Employee should not be created');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectVendorTemplListHandler')]
    procedure VendorTemplCreateVendorFromContactTwoTemplatesUT()
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Vendor: Record Vendor;
        VendorTempl1: Record "Vendor Templ.";
        VendorTempl2: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Create new vendor from company contact with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl2);
        VendorTempl2.Get(VendorTempl2.Code);
        LibraryVariableStorage.Enqueue(VendorTempl2.Code);

        // [GIVEN] Company contact "C"
        LibraryMarketing.CreateCompanyContact(Contact);

        // [WHEN] Create new vendor from "C" using "T2" (VendorTemplListHandler)
        Contact.SetHideValidationDialog(true);
        Contact.CreateVendor();

        // [THEN] Vendor filled with data from "C" and "T2"
        ContBusRel.FindByContact(ContBusRel."Link to Table"::Vendor, Contact."No.");
        Vendor.Get(ContBusRel."No.");
        Assert.IsTrue(Vendor.Name = Contact.Name, InsertedVendorErr);
        VerifyVendor(Vendor, VendorTempl2);

        // [THEN] Vendor dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Vendor, Vendor."No.", Database::"Vendor Templ.", VendorTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectVendorTemplListInvokeCancelHandler')]
    procedure VendorTemplCreateVendorFromContactTwoTemplatesInvokeCancelUT()
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        i: Integer;
    begin
        // [SCENARIO 365727] Create new vendor from company contact with two existing templates and invoke cancel the on the template list
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Two templates
        for i := 1 to 2 do
            LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl);

        // [GIVEN] Company contact "C"
        LibraryMarketing.CreateCompanyContact(Contact);

        // [WHEN] Create new vendor from "C" and invoke cancel on the template list (SelectVendorTemplListInvokeCancelHandler)
        Contact.SetHideValidationDialog(true);
        Contact.CreateVendor();

        // [THEN] Vendor was not created
        Assert.IsFalse(ContBusRel.FindByContact(ContBusRel."Link to Table"::Vendor, Contact."No."), 'Vendor should not be created');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectVendorTemplListInvokeCancelHandler')]
    procedure CustomerTemplCreateCustomerFromContactTwoTemplatesInvokeCancelUT()
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        i: Integer;
    begin
        // [SCENARIO 365727] Create new customer from company contact with two existing templates and invoke cancel the on the template list
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Two templates
        for i := 1 to 2 do
            LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl);

        // [GIVEN] Company contact "C"
        LibraryMarketing.CreateCompanyContact(Contact);

        // [WHEN] Create new customer from "C" and invoke cancel on the employee template list (SelectVendorTemplListInvokeCancelHandler)
        Contact.SetHideValidationDialog(true);
        Contact.CreateVendor();

        // [THEN] Vendor was not created
        Assert.IsFalse(ContBusRel.FindByContact(ContBusRel."Link to Table"::Customer, Contact."No."), 'Customer should not be created');
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectCustomerTemplListHandler')]
    procedure CustomerTemplApplyTemplateFromCustomerTwoTemplatesUT()
    var
        Customer: Record Customer;
        CustomerTempl1: Record "Customer Templ.";
        CustomerTempl2: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Apply template to customer with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl2);
        CustomerTempl2.Get(CustomerTempl2.Code);
        LibraryVariableStorage.Enqueue(CustomerTempl2.Code);

        // [GIVEN] Customer "C"
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Apply "T2" to "C"
        CustomerTemplMgt.UpdateCustomerFromTemplate(Customer);

        // [THEN] "C" filled with data from "T2"
        Customer.Get(Customer."No.");
        VerifyCustomer(Customer, CustomerTempl2);

        // [THEN] Customer dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Customer, Customer."No.", Database::"Customer Templ.", CustomerTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectVendorTemplListHandler')]
    procedure VendorTemplApplyTemplateFromVendorTwoTemplatesUT()
    var
        Vendor: Record Vendor;
        VendorTempl1: Record "Vendor Templ.";
        VendorTempl2: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Apply template to vendor with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl2);
        VendorTempl2.Get(VendorTempl2.Code);
        LibraryVariableStorage.Enqueue(VendorTempl2.Code);

        // [GIVEN] Vendor "V"
        LibraryPurchase.CreateVendor(Vendor);

        // [WHEN] Apply "T2" to "V"
        VendorTemplMgt.UpdateVendorFromTemplate(Vendor);

        // [THEN] "V" filled with data from "T2"
        Vendor.Get(Vendor."No.");
        VerifyVendor(Vendor, VendorTempl2);

        // [THEN] Vendor dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Vendor, Vendor."No.", Database::"Vendor Templ.", VendorTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectItemTemplListHandler')]
    procedure ItemTemplApplyTemplateFromItemTwoTemplatesUT()
    var
        Item: Record Item;
        ItemTempl1: Record "Item Templ.";
        ItemTempl2: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Apply template to item with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl2);
        ItemTempl2.Get(ItemTempl2.Code);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);

        // [GIVEN] Item "I"
        LibraryInventory.CreateItem(Item);

        // [WHEN] Apply "T2" to "I"
        ItemTemplMgt.UpdateItemFromTemplate(Item);

        // [THEN] "I" filled with data from "T2"
        Item.Get(Item."No.");
        VerifyItem(Item, ItemTempl2);

        // [THEN] Item dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Item, Item."No.", Database::"Item Templ.", ItemTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectCustomerTemplListHandler')]
    procedure CustomerTemplApplyTemplateForTwoCustomersTwoTemplatesUT()
    var
        Customer: array[3] of Record Customer;
        CustomerTempl1: Record "Customer Templ.";
        CustomerTempl2: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Apply template for two customers with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl2);
        CustomerTempl2.Get(CustomerTempl2.Code);
        LibraryVariableStorage.Enqueue(CustomerTempl2.Code);

        // [GIVEN] Tow customers "C1" and "C2"
        LibrarySales.CreateCustomer(Customer[1]);
        LibrarySales.CreateCustomer(Customer[2]);
        Customer[3].SetFilter("No.", '%1|%2', Customer[1]."No.", Customer[2]."No.");

        // [WHEN] Apply "T2" for "C1" and "C2" at one time
        CustomerTemplMgt.UpdateCustomersFromTemplate(Customer[3]);

        // [THEN] "C1" filled with data from "T2"
        Customer[1].Get(Customer[1]."No.");
        VerifyCustomer(Customer[1], CustomerTempl2);

        // [THEN] "C1" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Customer, Customer[1]."No.", Database::"Customer Templ.", CustomerTempl2.Code);

        // [THEN] "C2" filled with data from "T2"
        Customer[2].Get(Customer[2]."No.");
        VerifyCustomer(Customer[2], CustomerTempl2);

        // [THEN] "C2" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Customer, Customer[2]."No.", Database::"Customer Templ.", CustomerTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectVendorTemplListHandler')]
    procedure VendorTemplApplyTemplateForTwoVendorsTwoTemplatesUT()
    var
        Vendor: array[3] of Record Vendor;
        VendorTempl1: Record "Vendor Templ.";
        VendorTempl2: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Apply template for two vendors with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl2);
        VendorTempl2.Get(VendorTempl2.Code);
        LibraryVariableStorage.Enqueue(VendorTempl2.Code);

        // [GIVEN] Two vendors "V1" and "V2"
        LibraryPurchase.CreateVendor(Vendor[1]);
        LibraryPurchase.CreateVendor(Vendor[2]);
        Vendor[3].SetFilter("No.", '%1|%2', Vendor[1]."No.", Vendor[2]."No.");

        // [WHEN] Apply "T2" for "V1" and "V2" at one time
        VendorTemplMgt.UpdateVendorsFromTemplate(Vendor[3]);

        // [THEN] "V1" filled with data from "T2"
        Vendor[1].Get(Vendor[1]."No.");
        VerifyVendor(Vendor[1], VendorTempl2);

        // [THEN] "V1" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Vendor, Vendor[1]."No.", Database::"Vendor Templ.", VendorTempl2.Code);

        // [THEN] "V2" filled with data from "T2"
        Vendor[2].Get(Vendor[2]."No.");
        VerifyVendor(Vendor[2], VendorTempl2);

        // [THEN] "V2" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Vendor, Vendor[2]."No.", Database::"Vendor Templ.", VendorTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectItemTemplListHandler')]
    procedure ItemTemplApplyTemplateForTwoItemsTwoTemplatesUT()
    var
        Item: array[3] of Record Item;
        ItemTempl1: Record "Item Templ.";
        ItemTempl2: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 365727] Apply template for two items with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl2);
        ItemTempl2.Get(ItemTempl2.Code);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);

        // [GIVEN] Two items "I1" and "I2"
        LibraryInventory.CreateItem(Item[1]);
        LibraryInventory.CreateItem(Item[2]);
        Item[3].SetFilter("No.", '%1|%2', Item[1]."No.", Item[2]."No.");

        // [WHEN] Apply "T2" for "I1" and "I2" at one time
        ItemTemplMgt.UpdateItemsFromTemplate(Item[3]);

        // [THEN] "I1" filled with data from "T2"
        Item[1].Get(Item[1]."No.");
        VerifyItem(Item[1], ItemTempl2);

        // [THEN] "I1" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Item, Item[1]."No.", Database::"Item Templ.", ItemTempl2.Code);

        // [THEN] "I2" filled with data from "T2"
        Item[2].Get(Item[2]."No.");
        VerifyItem(Item[1], ItemTempl2);

        // [THEN] "I2" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Item, Item[2]."No.", Database::"Item Templ.", ItemTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemPriceIncludesVATVATPostingSetupExistsUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new item via template with "Price Includes VAT" = true
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template with data and dimensions, "Price Includes VAT" = true
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl);
        ItemTempl."Price Includes VAT" := true;
        ItemTempl.Modify(true);

        // [GIVEN] Sales setup "VAT Bus. Posting Gr. (Price)" filled with data in order "Price Includes VAT" can be enabled
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."VAT Bus. Posting Gr. (Price)" := VATBusinessPostingGroup.Code;
        SalesReceivablesSetup.Modify();
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, ItemTempl."VAT Prod. Posting Group");

        // [WHEN] Create new Item
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item inserted with data from template
        VerifyItem(Item, ItemTempl);
        // [THEN] Item dimensions inserted from template dimensions
        VerifyDimensions(Database::Item, Item."No.", Database::"Item Templ.", ItemTempl.Code);
        // [THEN] Item "Price Includes VAT" = true
        Assert.IsTrue(Item."Price Includes VAT", 'Price Includes VAT should be true');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemPriceIncludesVATVATPostingSetupDoesNotExistUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new item via template with "Price Includes VAT" = true
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template with data and dimensions, "Price Includes VAT" = true
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl);
        ItemTempl."Price Includes VAT" := true;
        ItemTempl.Modify(true);

        // [GIVEN] Sales setup "VAT Bus. Posting Gr. (Price)" filled with data in order "Price Includes VAT" cannot be enabled
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."VAT Bus. Posting Gr. (Price)" := VATBusinessPostingGroup.Code;
        SalesReceivablesSetup.Modify();

        // [WHEN] Create new Item
        asserterror ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item is not created, error message thrown by system
        Assert.ExpectedError('VAT Posting Setup does not exist');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CreateItemOptionStrMenuHandler,SelectItemTemplListHandler,ItemCardHandler')]
    procedure ItemTemplCreateItemFromSalesLine()
    var
        Item: Record Item;
        ItemTempl1: Record "Item Templ.";
        ItemTempl2: Record "Item Templ.";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new item using template when validate "No." in the sales line
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Create Item from Item No." := true;
        SalesReceivablesSetup.Modify(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl2);
        UpdateItemTemplateGenAndVatGroups(ItemTempl2, 1);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);

        // [GIVEN] Sales Invoice with line Type = Item
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", 10000);
        SalesLine.Insert(true);

        // [WHEN] Validate "No." field in the sales line with non-existing value
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", LibraryUtility.GenerateGUID());

        // [THEN] Item inserted with data from "T2" and item card is shown (verified in ItemCardHandler)

        Item.Get(SalesLine."No.");
        Item.Delete(false);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('CreateItemOptionStrMenuHandler,SelectItemTemplListHandler,ItemCardHandler')]
    procedure ItemTemplCreateItemFromPurchaseLine()
    var
        Item: Record Item;
        ItemTempl1: Record "Item Templ.";
        ItemTempl2: Record "Item Templ.";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new item using template when validate "No." in the purchase line
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Create Item from Item No." := true;
        PurchasesPayablesSetup.Modify(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl2);
        UpdateItemTemplateGenAndVatGroups(ItemTempl2, 2);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);
        LibraryVariableStorage.Enqueue(ItemTempl2.Code);

        // [GIVEN] Purchase Invoice with line Type = Item
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("Line No.", 10000);
        PurchaseLine.Insert(true);

        // [WHEN] Validate "No." field in the purchase line with non-existing value
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", LibraryUtility.GenerateGUID());

        // [THEN] Item inserted with data from "T2" and item card is shown (verified in ItemCardHandler)

        Item.Get(PurchaseLine."No.");
        Item.Delete(false);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('CustomerTemplCardHandler')]
    [Scope('OnPrem')]
    procedure CustomerTemplSaveCustomerAsTemplate()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        DimensionValue: Record "Dimension Value";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 384191] Save customer as a template
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Customer with dimensions
        LibrarySales.CreateCustomer(Customer);
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        Customer.Validate("Global Dimension 1 Code", DimensionValue.Code);
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        Customer.Validate("Global Dimension 2 Code", DimensionValue.Code);
        Customer.Modify(true);
        LibraryVariableStorage.Enqueue(Customer."No.");

        // [WHEN] Save customer as template
        CustomerTemplMgt.SaveAsTemplate(Customer);

        // [THEN] New customer template with dimensions is created (UI part verified in CustomerTemplCardHandler)
        CustomerTempl.Get(LibraryVariableStorage.DequeueText());
        Assert.AreEqual(Customer."Customer Posting Group", CustomerTempl."Customer Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Customer."Gen. Bus. Posting Group", CustomerTempl."Gen. Bus. Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Customer."VAT Bus. Posting Group", CustomerTempl."VAT Bus. Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Customer."Global Dimension 1 Code", CustomerTempl."Global Dimension 1 Code", InsertedTemplateErr);
        Assert.AreEqual(Customer."Global Dimension 2 Code", CustomerTempl."Global Dimension 2 Code", InsertedTemplateErr);
        VerifyDimensions(Database::"Customer Templ.", CustomerTempl.Code, Database::Customer, Customer."No.");
    end;

    [Test]
    [HandlerFunctions('VendorTemplCardHandler')]
    [Scope('OnPrem')]
    procedure VendorTemplSaveVendorAsTemplate()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        DimensionValue: Record "Dimension Value";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 384191] Save vendor as a template
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Vendor with dimensions
        LibraryPurchase.CreateVendor(Vendor);
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        Vendor.Validate("Global Dimension 1 Code", DimensionValue.Code);
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        Vendor.Validate("Global Dimension 2 Code", DimensionValue.Code);
        Vendor.Modify(true);
        LibraryVariableStorage.Enqueue(Vendor."No.");

        // [WHEN] Save vendor as template
        VendorTemplMgt.SaveAsTemplate(Vendor);

        // [THEN] New vendor template with dimensions is created (UI part verified in VendorTemplCardHandler)
        VendorTempl.Get(LibraryVariableStorage.DequeueText());
        Assert.AreEqual(Vendor."Vendor Posting Group", VendorTempl."Vendor Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Vendor."Gen. Bus. Posting Group", VendorTempl."Gen. Bus. Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Vendor."VAT Bus. Posting Group", VendorTempl."VAT Bus. Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Vendor."Global Dimension 1 Code", VendorTempl."Global Dimension 1 Code", InsertedTemplateErr);
        Assert.AreEqual(Vendor."Global Dimension 2 Code", VendorTempl."Global Dimension 2 Code", InsertedTemplateErr);
        VerifyDimensions(Database::"Vendor Templ.", VendorTempl.Code, Database::Vendor, Vendor."No.");
    end;

    [Test]
    [HandlerFunctions('ItemTemplCardHandler')]
    [Scope('OnPrem')]
    procedure ItemTemplSaveItemAsTemplate()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        DimensionValue: Record "Dimension Value";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 384191] Save item as a template
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Item with dimensions
        LibraryInventory.CreateItem(Item);
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        Item.Validate("Global Dimension 1 Code", DimensionValue.Code);
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        Item.Validate("Global Dimension 2 Code", DimensionValue.Code);
        Item.Modify(true);
        LibraryVariableStorage.Enqueue(Item."No.");

        // [WHEN] Save item as template
        ItemTemplMgt.SaveAsTemplate(Item);

        // [THEN] New item template with dimensions is created (UI part verified in ItemTemplCardHandler)
        ItemTempl.Get(LibraryVariableStorage.DequeueText());
        Assert.AreEqual(Item."Inventory Posting Group", ItemTempl."Inventory Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Item."Gen. Prod. Posting Group", ItemTempl."Gen. Prod. Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Item."VAT Prod. Posting Group", ItemTempl."VAT Prod. Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Item."Global Dimension 1 Code", ItemTempl."Global Dimension 1 Code", InsertedTemplateErr);
        Assert.AreEqual(Item."Global Dimension 2 Code", ItemTempl."Global Dimension 2 Code", InsertedTemplateErr);
        VerifyDimensions(Database::"Item Templ.", ItemTempl.Code, Database::Item, Item."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplCreateVendorWithNoSeriesUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 388434] Create new vendor with "No. Series" assigned in template
        Initialize();
        VendorTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template with "No. Series" ("NS") filled in
        LibraryTemplates.CreateVendorTemplate(VendorTempl);
        VendorTempl.Validate("No. Series", LibraryERM.CreateNoSeriesCode('VT'));
        VendorTempl.Modify(true);

        // [WHEN] Create new vendor
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor inserted with "No." assigned from "NS"
        VerifyCustVendItemEmplNo(VendorTempl."No. Series", Vendor."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplCreateVendorWithoutNoSeriesUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        // [SCENARIO 388434] Create new vendor with empty "No. Series" in template
        Initialize();
        VendorTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] "Vendor Nos." filled in "Purchases & Payables Setup"
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Vendor Nos." := LibraryERM.CreateNoSeriesCode('PPS');
        PurchasesPayablesSetup.Modify();

        // [GIVEN] Template with empty "No. Series"
        LibraryTemplates.CreateVendorTemplate(VendorTempl);

        // [WHEN] Create new vendor
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor inserted with "No." assigned from "Purchases & Payables Setup"
        VerifyCustVendItemEmplNo(PurchasesPayablesSetup."Vendor Nos.", Vendor."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateCustomerWithNoSeriesUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 388434] Create new Customer with "No. Series" assigned in template
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template with "No. Series" ("NS") filled in
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);
        CustomerTempl.Validate("No. Series", LibraryERM.CreateNoSeriesCode('CT'));
        CustomerTempl.Modify(true);

        // [WHEN] Create new Customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer inserted with "No." assigned from "NS"
        VerifyCustVendItemEmplNo(CustomerTempl."No. Series", Customer."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateCustomerWithoutNoSeriesUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // [SCENARIO 388434] Create new Customer with empty "No. Series" in template
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] "Customer Nos." filled in "Sales & Receivables Setup"
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Customer Nos." := LibraryERM.CreateNoSeriesCode('SRS');
        SalesReceivablesSetup.Modify();

        // [GIVEN] Template with empty "No. Series"
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);

        // [WHEN] Create new Customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer inserted with "No." assigned from "Sales & Receivables Setup"
        VerifyCustVendItemEmplNo(SalesReceivablesSetup."Customer Nos.", Customer."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemWithNoSeriesUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        NoSeriesLine: Record "No. Series Line";
    begin
        // [SCENARIO 388434] Create new Item with "No. Series" assigned in template
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template with "No. Series" ("NS") filled in
        LibraryTemplates.CreateItemTemplate(ItemTempl);
        ItemTempl.Validate("No. Series", LibraryERM.CreateNoSeriesCode('IT'));
        ItemTempl.Modify(true);

        // [WHEN] Create new Item
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item inserted with "No." assigned from "NS"
        VerifyCustVendItemEmplNo(ItemTempl."No. Series", Item."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemWithoutNoSeriesUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        InventorySetup: Record "Inventory Setup";
        SavedItemNosCode: Code[20];
    begin
        // [SCENARIO 388434] Create new Item with empty "No. Series" in template
        Initialize();
        ItemTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] "Item Nos." filled in "Inventory Setup"
        InventorySetup.Get();
        SavedItemNosCode := InventorySetup."Item Nos.";
        InventorySetup."Item Nos." := LibraryERM.CreateNoSeriesCode('IS');
        InventorySetup.Modify();

        // [GIVEN] Template with empty "No. Series"
        LibraryTemplates.CreateItemTemplate(ItemTempl);

        // [WHEN] Create new Item
        ItemTemplMgt.InsertItemFromTemplate(Item);

        // [THEN] Item inserted with "No." assigned from "Inventory Setup"
        VerifyCustVendItemEmplNo(InventorySetup."Item Nos.", Item."No.");

        InventorySetup."Item Nos." := SavedItemNosCode;
        InventorySetup.Modify();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeTemplCreateEmployeeWithNoSeriesUT()
    var
        Employee: Record Employee;
        EmployeeTempl: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendEmployeeEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 388434] Create new Employee with "No. Series" assigned in template
        Initialize();
        EmployeeTempl.DeleteAll();
        BindSubscription(CustVendEmployeeEmplTemplates);
        CustVendEmployeeEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template with "No. Series" ("NS") filled in
        LibraryTemplates.CreateEmployeeTemplate(EmployeeTempl);
        EmployeeTempl.Validate("No. Series", LibraryERM.CreateNoSeriesCode('ET'));
        EmployeeTempl.Modify(true);

        // [WHEN] Create new Employee
        EmployeeTemplMgt.InsertEmployeeFromTemplate(Employee);

        // [THEN] Employee inserted with "No." assigned from "NS"
        VerifyCustVendItemEmplNo(EmployeeTempl."No. Series", Employee."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeTemplCreateEmployeeWithoutNoSeriesUT()
    var
        Employee: Record Employee;
        EmployeeTempl: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendEmployeeEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        HumanResourcesSetup: Record "Human Resources Setup";
        SavedEmployeeNosCode: code[20];
    begin
        // [SCENARIO 388434] Create new Employee with empty "No. Series" in template
        Initialize();
        EmployeeTempl.DeleteAll();
        BindSubscription(CustVendEmployeeEmplTemplates);
        CustVendEmployeeEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] "Employee Nos." filled in "Human Resources Setup"
        HumanResourcesSetup.Get();
        SavedEmployeeNosCode := HumanResourcesSetup."Employee Nos.";
        HumanResourcesSetup."Employee Nos." := LibraryERM.CreateNoSeriesCode('HRS');
        HumanResourcesSetup.Modify();

        // [GIVEN] Template with empty "No. Series"
        LibraryTemplates.CreateEmployeeTemplate(EmployeeTempl);

        // [WHEN] Create new Employee
        EmployeeTemplMgt.InsertEmployeeFromTemplate(Employee);

        // [THEN] Employee inserted with "No." assigned from "Human Resources Setup"
        VerifyCustVendItemEmplNo(HumanResourcesSetup."Employee Nos.", Employee."No.");

        HumanResourcesSetup."Employee Nos." := SavedEmployeeNosCode;
        HumanResourcesSetup.Modify();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectEmployeeTemplListHandler')]
    procedure EmployeeTemplApplyTemplateFromEmployeeTwoTemplatesUT()
    var
        Employee: Record Employee;
        EmployeeTempl1: Record "Employee Templ.";
        EmployeeTempl2: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 384920] Apply template to Employee with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl2);
        EmployeeTempl2.Get(EmployeeTempl2.Code);
        LibraryVariableStorage.Enqueue(EmployeeTempl2.Code);

        // [GIVEN] Employee "E"
        LibraryHumanResource.CreateEmployee(Employee);

        // [WHEN] Apply "T2" to "E"
        EmployeeTemplMgt.UpdateEmployeeFromTemplate(Employee);

        // [THEN] "E" filled with data from "T2"
        Employee.Get(Employee."No.");
        VerifyEmployee(Employee, EmployeeTempl2);

        // [THEN] Employee dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Employee, Employee."No.", Database::"Employee Templ.", EmployeeTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    [HandlerFunctions('SelectEmployeeTemplListHandler')]
    procedure EmployeeTemplApplyTemplateForTwoEmployeesTwoTemplatesUT()
    var
        Employee: array[3] of Record Employee;
        EmployeeTempl1: Record "Employee Templ.";
        EmployeeTempl2: Record "Employee Templ.";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 384920] Apply template for two Employees with two existing templates
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T1" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl1);

        // [GIVEN] Template "T2" with data and dimensions
        LibraryTemplates.CreateEmployeeTemplateWithDataAndDimensions(EmployeeTempl2);
        EmployeeTempl2.Get(EmployeeTempl2.Code);
        LibraryVariableStorage.Enqueue(EmployeeTempl2.Code);

        // [GIVEN] Tow Employees "E1" and "E2"
        LibraryHumanResource.CreateEmployee(Employee[1]);
        LibraryHumanResource.CreateEmployee(Employee[2]);
        Employee[3].SetFilter("No.", '%1|%2', Employee[1]."No.", Employee[2]."No.");

        // [WHEN] Apply "T2" for "E1" and "E2" at one time
        EmployeeTemplMgt.UpdateEmployeesFromTemplate(Employee[3]);

        // [THEN] "E1" filled with data from "T2"
        Employee[1].Get(Employee[1]."No.");
        VerifyEmployee(Employee[1], EmployeeTempl2);

        // [THEN] "E1" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Employee, Employee[1]."No.", Database::"Employee Templ.", EmployeeTempl2.Code);

        // [THEN] "E2" filled with data from "T2"
        Employee[2].Get(Employee[2]."No.");
        VerifyEmployee(Employee[2], EmployeeTempl2);

        // [THEN] "E2" dimensions inserted from "T2" dimensions
        VerifyDimensions(Database::Employee, Employee[2]."No.", Database::"Employee Templ.", EmployeeTempl2.Code);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('EmployeeTemplCardHandler')]
    [Scope('OnPrem')]
    procedure EmployeeTemplSaveEmployeeAsTemplate()
    var
        Employee: Record Employee;
        EmployeeTempl: Record "Employee Templ.";
        DimensionValue: Record "Dimension Value";
        EmployeeTemplMgt: Codeunit "Employee Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 384920] Save Employee as a template
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Employee with dimensions
        CreateEmployeeWithData(Employee);

        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);
        Employee.Validate("Global Dimension 1 Code", DimensionValue.Code);
        LibraryDimension.GetGlobalDimCodeValue(2, DimensionValue);
        Employee.Validate("Global Dimension 2 Code", DimensionValue.Code);
        Employee.Modify(true);
        LibraryVariableStorage.Enqueue(Employee."No.");

        // [WHEN] Save Employee as template
        EmployeeTemplMgt.SaveAsTemplate(Employee);

        // [THEN] New Employee template with dimensions is created (UI part verified in EmployeeTemplCardHandler)
        EmployeeTempl.Get(LibraryVariableStorage.DequeueText());
        Assert.AreEqual(Employee."Employee Posting Group", EmployeeTempl."Employee Posting Group", InsertedTemplateErr);
        Assert.AreEqual(Employee."Statistics Group Code", EmployeeTempl."Statistics Group Code", InsertedTemplateErr);
        Assert.AreEqual(Employee."Global Dimension 1 Code", EmployeeTempl."Global Dimension 1 Code", InsertedTemplateErr);
        Assert.AreEqual(Employee."Global Dimension 2 Code", EmployeeTempl."Global Dimension 2 Code", InsertedTemplateErr);
        VerifyDimensions(Database::"Employee Templ.", EmployeeTempl.Code, Database::Employee, Employee."No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemNonstockAutoItemUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        NonstockItem: Record "Nonstock Item";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        CatalogItemManagement: Codeunit "Catalog Item Management";
    begin
        // [SCENARIO 383147] Create new item from non stock item with template using NonstockAutoItem() procedure from "Catalog Item Management" codeunit
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl);
        // [GIVEN] Nonstock item
        CreateNonstockItem(NonstockItem, ItemTempl.Code);

        // [WHEN] Create new Item
        CatalogItemManagement.NonstockAutoItem(NonstockItem);

        // [THEN] Item inserted with data from template
        Item.Get(NonstockItem."Vendor Item No.");
        VerifyItem(Item, ItemTempl);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ItemTemplCreateItemFromNonstockUT()
    var
        Item: Record Item;
        ItemTempl: Record "Item Templ.";
        NonstockItem: Record "Nonstock Item";
        ItemTemplMgt: Codeunit "Item Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        CatalogItemManagement: Codeunit "Catalog Item Management";
    begin
        // [SCENARIO 383147] Create new item from non stock item with template using CreateItemFromNonstock() procedure from "Catalog Item Management" codeunit
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetItemTemplateFeatureEnabled(true);

        // [GIVEN] Template with data and dimensions
        LibraryTemplates.CreateItemTemplateWithDataAndDimensions(ItemTempl);
        // [GIVEN] Nonstock item
        CreateNonstockItem(NonstockItem, ItemTempl.Code);

        // [WHEN] Create new Item
        CatalogItemManagement.CreateItemFromNonstock(NonstockItem);

        // [THEN] Item inserted with data from template
        Item.Get(NonstockItem."Vendor Item No.");
        VerifyItem(Item, ItemTempl);
    end;

    [Test]
    [HandlerFunctions('CreateCustVendStrMenuHandler,SelectVendorTemplListHandler,VendorCardHandler')]
    [Scope('OnPrem')]
    procedure VendorTemplCreateVendorGetVendorNoUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        VendorNo: Code[20];
    begin
        // [SCENARIO 383147] Create new vendor with template using GetVendorNo() procedure from "Vendor" record
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetVendTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl);
        LibraryVariableStorage.Enqueue(VendorTempl.Code);

        // [WHEN] Create new vendor
        VendorNo := Vendor.GetVendorNo(LibraryUtility.GenerateGUID());

        // [THEN] Vendor inserted with data from "T"
        Vendor.Get(LibraryVariableStorage.DequeueText());
        Assert.AreEqual(VendorNo, Vendor."No.", 'Wrong vendor card shown');
        VerifyVendor(Vendor, VendorTempl);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('CreateCustVendStrMenuHandler,SelectCustomerTemplListHandler,CustomerCardHandler')]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateCustomerGetCustNoUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
        CustomerNo: Code[20];
    begin
        // [SCENARIO 383147] Create new Customer with template using GetCustNo() procedure from "Customer" record
        Initialize();
        Customer.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl);
        LibraryVariableStorage.Enqueue(CustomerTempl.Code);

        // [WHEN] Create new Customer
        CustomerNo := Customer.GetCustNo(LibraryUtility.GenerateGUID());

        // [THEN] Customer inserted with data from "T"
        Customer.Get(LibraryVariableStorage.DequeueText());
        Assert.AreEqual(CustomerNo, Customer."No.", 'Wrong Customer card shown');
        VerifyCustomer(Customer, CustomerTempl);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplCreateCustomerWithAdditionalFields()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 353440] Create new customer with additional fields ("Customer Discount Group", "Customer Price Group" and others)
        Initialize();
        CustomerTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with additional data and dimensions
        LibraryTemplates.CreateCustomerTemplateWithDataAndDimensions(CustomerTempl);
        UpdateCustomerTemplateAdditionalFields(CustomerTempl);

        // [WHEN] Create new customer
        CustomerTemplMgt.InsertCustomerFromTemplate(Customer);

        // [THEN] Customer inserted with data from "T"
        VerifyCustomer(Customer, CustomerTempl);
        // [THEN] Customer dimensions inserted from "T" dimensions
        VerifyDimensions(Database::Customer, Customer."No.", Database::"Customer Templ.", CustomerTempl.Code);
        // [THEN] Customer contains data from "T" additional fields
        VerifyCustomerAdditionalFields(Customer, CustomerTempl);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplCreateVendorOneTemplateDocSendingProfileUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        DocumentSendingProfile: Record "Document Sending Profile";
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 389638] Create new Vendor with one template and filled in "Document Sending Profile"
        Initialize();
        VendorTempl.DeleteAll();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Template "T" with data and dimensions
        LibraryTemplates.CreateVendorTemplateWithDataAndDimensions(VendorTempl);
        UpdateVendorTemplDocSendingProfile(DocumentSendingProfile, VendorTempl);

        // [WHEN] Create new Vendor
        VendorTemplMgt.InsertVendorFromTemplate(Vendor);

        // [THEN] Vendor inserted with data from "T"
        VerifyVendor(Vendor, VendorTempl);
        // [THEN] Vendor dimensions inserted from "T" dimensions
        VerifyDimensions(Database::Vendor, Vendor."No.", Database::"Vendor Templ.", VendorTempl.Code);
        // [THEN] "Document Sending Profile" filled in Vendor
        Assert.AreEqual(DocumentSendingProfile.Code, Vendor."Document Sending Profile", 'Wrong document sending profile');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CustomerTemplateApplyAddressFieldsUT()
    var
        Customer: Record Customer;
        CustomerTempl: Record "Customer Templ.";
        PostCode: Record "Post Code";
        Currency: Record Currency;
        CustomerTemplMgt: Codeunit "Customer Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 395533] Address fields should not be cleared by template if they are not empty
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Customer template with empty address fields
        LibraryTemplates.CreateCustomerTemplate(CustomerTempl);

        // [GIVEN] Customer with filled "Post Code", "City" and "Country/Region Code"
        LibrarySales.CreateCustomer(Customer);
        LibraryERM.CreatePostCode(PostCode);
        LibraryERM.CreateCurrency(Currency);
        Customer."Post Code" := PostCode.Code;
        Customer.City := PostCode.City;
        Customer."Country/Region Code" := PostCode."Country/Region Code";
        Customer.County := LibraryUtility.GenerateRandomText(MaxStrLen(Customer.County));
        Customer."Language Code" := LibraryERM.GetAnyLanguageDifferentFromCurrent();
        Customer."Currency Code" := Currency.Code;
        Customer.Modify();

        // [WHEN] Apply customer template
        CustomerTemplMgt.ApplyCustomerTemplate(Customer, CustomerTempl);

        // [THEN] "Post Code", "City" and "Country/Region Code" are not changed
        Assert.AreEqual(PostCode.Code, Customer."Post Code", 'Wrong Post Code after apply template');
        Assert.AreEqual(PostCode.City, Customer.City, 'Wrong City after apply template');
        Assert.AreEqual(PostCode."Country/Region Code", Customer."Country/Region Code", 'Wrong Country after apply template');
        Customer.TestField(County);
        Customer.TestField("Language Code");
        Customer.TestField("Currency Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VendorTemplateApplyAddressFieldsUT()
    var
        Vendor: Record Vendor;
        VendorTempl: Record "Vendor Templ.";
        PostCode: Record "Post Code";
        Currency: Record Currency;
        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
        CustVendItemEmplTemplates: Codeunit "Cust/Vend/Item/Empl Templates";
    begin
        // [SCENARIO 395533] Address fields should not be cleared by template if they are not empty
        Initialize();
        BindSubscription(CustVendItemEmplTemplates);
        CustVendItemEmplTemplates.SetCustTemplateFeatureEnabled(true);

        // [GIVEN] Vendor template with empty address fields
        LibraryTemplates.CreateVendorTemplate(VendorTempl);

        // [GIVEN] Vendor with filled "Post Code", "City" and "Country/Region Code"
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreatePostCode(PostCode);
        LibraryERM.CreateCurrency(Currency);
        Vendor."Post Code" := PostCode.Code;
        Vendor.City := PostCode.City;
        Vendor."Country/Region Code" := PostCode."Country/Region Code";
        Vendor.County := LibraryUtility.GenerateRandomText(MaxStrLen(Vendor.County));
        Vendor."Language Code" := LibraryERM.GetAnyLanguageDifferentFromCurrent();
        Vendor."Currency Code" := Currency.Code;
        Vendor.Modify();

        // [WHEN] Apply Vendor template
        VendorTemplMgt.ApplyVendorTemplate(Vendor, VendorTempl);

        // [THEN] "Post Code", "City" and "Country/Region Code" are not changed
        Assert.AreEqual(PostCode.Code, Vendor."Post Code", 'Wrong Post Code after apply template');
        Assert.AreEqual(PostCode.City, Vendor.City, 'Wrong City after apply template');
        Assert.AreEqual(PostCode."Country/Region Code", Vendor."Country/Region Code", 'Wrong Country after apply template');
        Vendor.TestField(County);
        Vendor.TestField("Language Code");
        Vendor.TestField("Currency Code");
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cust/Vend/Item/Empl Templates");
        LibraryVariableStorage.Clear();
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;

        LibrarySetupStorage.SaveSalesSetup();
        LibrarySetupStorage.SavePurchasesSetup();

        IsInitialized := true;
        Commit();
    end;

    procedure SetCustTemplateFeatureEnabled(NewTemplateFeatureEnabled: Boolean)
    begin
        TemplateFeatureEnabled := NewTemplateFeatureEnabled;
    end;

    procedure SetVendTemplateFeatureEnabled(NewTemplateFeatureEnabled: Boolean)
    begin
        TemplateFeatureEnabled := NewTemplateFeatureEnabled;
    end;

    procedure SetItemTemplateFeatureEnabled(NewTemplateFeatureEnabled: Boolean)
    begin
        TemplateFeatureEnabled := NewTemplateFeatureEnabled;
    end;

    procedure SetEmplTemplateFeatureEnabled(NewTemplateFeatureEnabled: Boolean)
    begin
        TemplateFeatureEnabled := NewTemplateFeatureEnabled;
    end;

    local procedure UpdateCustomerTemplateAdditionalFields(var CustomerTempl: Record "Customer Templ.")
    var
        ShipmentMethod: Record "Shipment Method";
        ReminderTerms: Record "Reminder Terms";
        CustomerPriceGroup: Record "Customer Price Group";
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        CustomerTempl."Shipment Method Code" := LibraryUtility.GenerateRandomCode(ShipmentMethod.FieldNo(Code), Database::"Shipment Method");
        LibraryERM.CreateReminderTerms(ReminderTerms);
        CustomerTempl."Reminder Terms Code" := ReminderTerms.Code;
        CustomerTempl."Print Statements" := true;
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        CustomerTempl."Customer Price Group" := CustomerPriceGroup.Code;
        LibraryERM.CreateCustomerDiscountGroup(CustomerDiscountGroup);
        CustomerTempl."Customer Disc. Group" := CustomerDiscountGroup.Code;

        CustomerTempl.Modify(true);
    end;

    local procedure UpdateItemTemplateGenAndVatGroups(var ItemTempl: Record "Item Templ."; SearchGenPostingType: Integer)
    var
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        case SearchGenPostingType of
            1:
                LibraryERM.SetSearchGenPostingTypeSales;
            2:
                LibraryERM.SetSearchGenPostingTypePurch();
        end;
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);

        ItemTempl."Gen. Prod. Posting Group" := GeneralPostingSetup."Gen. Prod. Posting Group";
        ItemTempl."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        ItemTempl.Modify(true);
    end;

    local procedure CreateEmployeeWithData(var Employee: Record Employee)
    var
        EmployeePostingGroup: Record "Employee Posting Group";
        EmployeeStatisticsGroup: Record "Employee Statistics Group";
    begin
        LibraryHumanResource.CreateEmployee(Employee);

        EmployeePostingGroup.Init();
        EmployeePostingGroup.Validate(Code, LibraryUtility.GenerateRandomCode(EmployeePostingGroup.FieldNo(Code), Database::"Employee Posting Group"));
        EmployeePostingGroup.Insert();

        EmployeeStatisticsGroup.Init();
        EmployeeStatisticsGroup.Validate(Code, LibraryUtility.GenerateRandomCode(EmployeeStatisticsGroup.FieldNo(Code), Database::"Employee Statistics Group"));
        EmployeeStatisticsGroup.Insert();

        Employee.Validate("Employee Posting Group", EmployeePostingGroup.Code);
        Employee.Validate("Statistics Group Code", EmployeeStatisticsGroup.Code);
        Employee.Modify(true);
    end;

    local procedure UpdateDocSendingProfile(var DocumentSendingProfile: Record "Document Sending Profile"; var CustomerTempl: Record "Customer Templ.")
    begin
        DocumentSendingProfile.Init();
        DocumentSendingProfile.Validate(Code, LibraryUtility.GenerateRandomCode(DocumentSendingProfile.FieldNo(Code), Database::"Document Sending Profile"));
        DocumentSendingProfile.Insert();

        CustomerTempl."Document Sending Profile" := DocumentSendingProfile.Code;
        CustomerTempl.Modify(true);
    end;

    local procedure UpdateVendorTemplDocSendingProfile(var DocumentSendingProfile: Record "Document Sending Profile"; var VendorTempl: Record "Vendor Templ.")
    begin
        DocumentSendingProfile.Init();
        DocumentSendingProfile.Validate(Code, LibraryUtility.GenerateRandomCode(DocumentSendingProfile.FieldNo(Code), Database::"Document Sending Profile"));
        DocumentSendingProfile.Insert();

        VendorTempl."Document Sending Profile" := DocumentSendingProfile.Code;
        VendorTempl.Modify(true);
    end;

    local procedure CreateNonstockItem(var NonstockItem: Record "Nonstock Item"; ItemTemplCode: Code[20])
    begin
        LibraryInventory.CreateNonStock(NonstockItem);
        NonstockItem.Validate("Vendor No.", LibraryPurchase.CreateVendorNo);
        NonstockItem.Validate("Vendor Item No.", LibraryUtility.GenerateRandomCode(NonstockItem.FieldNo("Vendor Item No."), Database::"Nonstock Item"));
        NonstockItem.Validate("Item Templ. Code", ItemTemplCode);
        NonstockItem.Validate(Description, NonstockItem."Entry No.");
        NonstockItem.Modify(true);
    end;

    local procedure CreateShipmentMethodCode(): Code[10]
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.Init();
        ShipmentMethod.Code := LibraryUtility.GenerateRandomCode(ShipmentMethod.FieldNo(Code), DATABASE::"Shipment Method");
        ShipmentMethod.Insert();
        exit(ShipmentMethod.Code);
    end;

    local procedure VerifyTemplateGlobalDimensionIsDefaultDimension(TemplateTableId: Integer; TemplateCode: Code[20]; GlobalDim1CodeValue: Code[20]; GlobalDim2CodeValue: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DefaultDimension: Record "Default Dimension";
    begin
        GeneralLedgerSetup.Get();
        DefaultDimension.SetRange("Table ID", TemplateTableId);
        DefaultDimension.SetRange("No.", TemplateCode);

        DefaultDimension.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        DefaultDimension.SetRange("Dimension Value Code", GlobalDim1CodeValue);
        Assert.RecordIsNotEmpty(DefaultDimension);

        DefaultDimension.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 2 Code");
        DefaultDimension.SetRange("Dimension Value Code", GlobalDim2CodeValue);
        Assert.RecordIsNotEmpty(DefaultDimension);
    end;

    local procedure VerifyTemplateGlobalDimensionCodeValue(TemplateTableId: Integer; TemplateCode: Code[20]; GlobalDim1CodeValue: Code[20]; GlobalDim2CodeValue: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DefaultDimension: Record "Default Dimension";
    begin
        GeneralLedgerSetup.Get();

        DefaultDimension.Get(TemplateTableId, TemplateCode, GeneralLedgerSetup."Global Dimension 1 Code");
        Assert.AreEqual(DefaultDimension."Dimension Value Code", GlobalDim1CodeValue, GlobalDimCodeTemplateErr);

        DefaultDimension.Get(TemplateTableId, TemplateCode, GeneralLedgerSetup."Global Dimension 2 Code");
        Assert.AreEqual(DefaultDimension."Dimension Value Code", GlobalDim2CodeValue, GlobalDimCodeTemplateErr);
    end;

    local procedure VerifyCopiedVendorTemplateData(DestVendorTempl: Record "Vendor Templ."; SourceVendorTempl: Record "Vendor Templ.")
    begin
        Assert.IsTrue(DestVendorTempl."Vendor Posting Group" = SourceVendorTempl."Vendor Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestVendorTempl."Gen. Bus. Posting Group" = SourceVendorTempl."Gen. Bus. Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestVendorTempl."VAT Bus. Posting Group" = SourceVendorTempl."VAT Bus. Posting Group", CopyTemplateDataErr);

        Assert.IsTrue(DestVendorTempl."Global Dimension 1 Code" = SourceVendorTempl."Global Dimension 1 Code", CopyTemplateDataErr);
        Assert.IsTrue(DestVendorTempl."Global Dimension 2 Code" = SourceVendorTempl."Global Dimension 2 Code", CopyTemplateDataErr);
    end;

    local procedure VerifyCopiedCustomerTemplateData(DestCustomerTempl: Record "Customer Templ."; SourceCustomerTempl: Record "Customer Templ.")
    begin
        Assert.IsTrue(DestCustomerTempl."Customer Posting Group" = SourceCustomerTempl."Customer Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestCustomerTempl."Gen. Bus. Posting Group" = SourceCustomerTempl."Gen. Bus. Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestCustomerTempl."VAT Bus. Posting Group" = SourceCustomerTempl."VAT Bus. Posting Group", CopyTemplateDataErr);

        Assert.IsTrue(DestCustomerTempl."Global Dimension 1 Code" = SourceCustomerTempl."Global Dimension 1 Code", CopyTemplateDataErr);
        Assert.IsTrue(DestCustomerTempl."Global Dimension 2 Code" = SourceCustomerTempl."Global Dimension 2 Code", CopyTemplateDataErr);
    end;

    local procedure VerifyCopiedItemTemplateData(DestItemTempl: Record "Item Templ."; SourceItemTempl: Record "Item Templ.")
    begin
        Assert.IsTrue(DestItemTempl."Inventory Posting Group" = SourceItemTempl."Inventory Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestItemTempl."Gen. Prod. Posting Group" = SourceItemTempl."Gen. Prod. Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestItemTempl."VAT Prod. Posting Group" = SourceItemTempl."VAT Prod. Posting Group", CopyTemplateDataErr);

        Assert.IsTrue(DestItemTempl."Global Dimension 1 Code" = SourceItemTempl."Global Dimension 1 Code", CopyTemplateDataErr);
        Assert.IsTrue(DestItemTempl."Global Dimension 2 Code" = SourceItemTempl."Global Dimension 2 Code", CopyTemplateDataErr);
    end;

    local procedure VerifyCopiedEmployeeTemplateData(DestEmployeeTempl: Record "Employee Templ."; SourceEmployeeTempl: Record "Employee Templ.")
    begin
        Assert.IsTrue(DestEmployeeTempl."Employee Posting Group" = SourceEmployeeTempl."Employee Posting Group", CopyTemplateDataErr);
        Assert.IsTrue(DestEmployeeTempl."Statistics Group Code" = SourceEmployeeTempl."Statistics Group Code", CopyTemplateDataErr);

        Assert.IsTrue(DestEmployeeTempl."Global Dimension 1 Code" = SourceEmployeeTempl."Global Dimension 1 Code", CopyTemplateDataErr);
        Assert.IsTrue(DestEmployeeTempl."Global Dimension 2 Code" = SourceEmployeeTempl."Global Dimension 2 Code", CopyTemplateDataErr);
    end;

    local procedure VerifyVendor(Vendor: Record Vendor; VendorTempl: Record "Vendor Templ.")
    begin
        Assert.IsTrue(Vendor."Vendor Posting Group" = VendorTempl."Vendor Posting Group", InsertedVendorErr);
        Assert.IsTrue(Vendor."Gen. Bus. Posting Group" = VendorTempl."Gen. Bus. Posting Group", InsertedVendorErr);
        Assert.IsTrue(Vendor."VAT Bus. Posting Group" = VendorTempl."VAT Bus. Posting Group", InsertedVendorErr);

        Assert.IsTrue(Vendor."Global Dimension 1 Code" = VendorTempl."Global Dimension 1 Code", InsertedVendorErr);
        Assert.IsTrue(Vendor."Global Dimension 2 Code" = VendorTempl."Global Dimension 2 Code", InsertedVendorErr);
    end;

    local procedure VerifyCustomer(Customer: Record Customer; CustomerTempl: Record "Customer Templ.")
    begin
        Assert.IsTrue(Customer."Customer Posting Group" = CustomerTempl."Customer Posting Group", InsertedCustomerErr);
        Assert.IsTrue(Customer."Gen. Bus. Posting Group" = CustomerTempl."Gen. Bus. Posting Group", InsertedCustomerErr);
        Assert.IsTrue(Customer."VAT Bus. Posting Group" = CustomerTempl."VAT Bus. Posting Group", InsertedCustomerErr);

        Assert.IsTrue(Customer."Global Dimension 1 Code" = CustomerTempl."Global Dimension 1 Code", CopyTemplateDataErr);
        Assert.IsTrue(Customer."Global Dimension 2 Code" = CustomerTempl."Global Dimension 2 Code", CopyTemplateDataErr);
    end;

    local procedure VerifyItem(Item: Record Item; ItemTempl: Record "Item Templ.")
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        Assert.IsTrue(Item."Inventory Posting Group" = ItemTempl."Inventory Posting Group", InsertedItemErr);
        Assert.IsTrue(Item."Gen. Prod. Posting Group" = ItemTempl."Gen. Prod. Posting Group", InsertedItemErr);
        Assert.IsTrue(Item."VAT Prod. Posting Group" = ItemTempl."VAT Prod. Posting Group", InsertedItemErr);

        Assert.IsTrue(Item."Global Dimension 1 Code" = ItemTempl."Global Dimension 1 Code", InsertedItemErr);
        Assert.IsTrue(Item."Global Dimension 2 Code" = ItemTempl."Global Dimension 2 Code", InsertedItemErr);

        ItemUnitofMeasure.SetRange(Code, Item."Base Unit of Measure");
        ItemUnitofMeasure.SetRange("Item No.", Item."No.");
        Assert.RecordCount(ItemUnitofMeasure, 1);
    end;

    local procedure VerifyEmployee(Employee: Record Employee; EmployeeTempl: Record "Employee Templ.")
    begin
        Assert.IsTrue(Employee."Employee Posting Group" = EmployeeTempl."Employee Posting Group", InsertedEmployeeErr);
        Assert.IsTrue(Employee."Statistics Group Code" = EmployeeTempl."Statistics Group Code", InsertedEmployeeErr);
    end;

    local procedure VerifyDimensions(DestTableId: Integer; DestNo: Code[20]; SourceTableid: Integer; SourceNo: Code[20])
    var
        SourceDefaultDimension: Record "Default Dimension";
        DestDefaultDimension: Record "Default Dimension";
    begin
        DestDefaultDimension.SetRange("Table ID", DestTableId);
        DestDefaultDimension.SetRange("No.", DestNo);

        SourceDefaultDimension.SetRange("Table ID", SourceTableid);
        SourceDefaultDimension.SetRange("No.", SourceNo);
        SourceDefaultDimension.FindSet();
        repeat
            DestDefaultDimension.SetRange("Dimension Code", SourceDefaultDimension."Dimension Code");
            DestDefaultDimension.SetRange("Dimension Value Code", SourceDefaultDimension."Dimension Value Code");
            Assert.RecordIsNotEmpty(DestDefaultDimension);
        until SourceDefaultDimension.Next() = 0;
    end;

    local procedure VerifyCustomerAdditionalFields(Customer: Record Customer; CustomerTempl: Record "Customer Templ.")
    begin
        Assert.IsTrue(Customer."Shipment Method Code" = CustomerTempl."Shipment Method Code", InsertedCustomerErr);
        Assert.IsTrue(Customer."Reminder Terms Code" = CustomerTempl."Reminder Terms Code", InsertedCustomerErr);
        Assert.IsTrue(Customer."Print Statements" = CustomerTempl."Print Statements", InsertedCustomerErr);
        Assert.IsTrue(Customer."Customer Price Group" = CustomerTempl."Customer Price Group", CopyTemplateDataErr);
        Assert.IsTrue(Customer."Customer Disc. Group" = CustomerTempl."Customer Disc. Group", CopyTemplateDataErr);
    end;

    local procedure VerifyCustVendItemEmplNo(NoSeriesCode: Code[20]; CustVendItemEmplNo: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        NoSeriesLine.FindFirst();
        Assert.AreEqual(NoSeriesLine."Last No. Used", CustVendItemEmplNo, 'Wrong number assigned.');
    end;

    [ModalPageHandler]
    procedure SelectVendorTemplListHandler(var SelectVendorTemplList: TestPage "Select Vendor Templ. List")
    var
        VendorTempl: Record "Vendor Templ.";
    begin
        VendorTempl.Get(LibraryVariableStorage.DequeueText());
        SelectVendorTemplList.GoToRecord(VendorTempl);
        SelectVendorTemplList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectCustomerTemplListHandler(var SelectCustomerTemplList: TestPage "Select Customer Templ. List")
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        CustomerTempl.Get(LibraryVariableStorage.DequeueText());
        SelectCustomerTemplList.GoToRecord(CustomerTempl);
        SelectCustomerTemplList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectItemTemplListHandler(var SelectItemTemplList: TestPage "Select Item Templ. List")
    var
        ItemTempl: Record "Item Templ.";
    begin
        ItemTempl.Get(LibraryVariableStorage.DequeueText());
        SelectItemTemplList.GoToRecord(ItemTempl);
        SelectItemTemplList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectEmployeeTemplListHandler(var SelectEmployeeTemplList: TestPage "Select Employee Templ. List")
    var
        EmployeeTempl: Record "Employee Templ.";
    begin
        EmployeeTempl.Get(LibraryVariableStorage.DequeueText());
        SelectEmployeeTemplList.GoToRecord(EmployeeTempl);
        SelectEmployeeTemplList.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectEmployeeTemplListInvokeCancelHandler(var SelectEmployeeTemplList: TestPage "Select Employee Templ. List")
    begin
        SelectEmployeeTemplList.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectVendorTemplListInvokeCancelHandler(var SelectVendorTemplList: TestPage "Select Vendor Templ. List")
    begin
        SelectVendorTemplList.Cancel().Invoke();
    end;

    [ModalPageHandler]
    procedure SelectCustomerTemplListInvokeCancelHandler(var SelectCustomerTemplList: TestPage "Select Customer Templ. List")
    begin
        SelectCustomerTemplList.Cancel().Invoke();
    end;

    [StrMenuHandler]
    procedure CreateItemOptionStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    [ModalPageHandler]
    procedure ItemCardHandler(var ItemCard: TestPage "Item Card")
    var
        ItemTempl: Record "Item Templ.";
    begin
        ItemTempl.Get(LibraryVariableStorage.DequeueText());

        Assert.IsTrue(ItemCard."Inventory Posting Group".Value = ItemTempl."Inventory Posting Group", InsertedItemErr);
        Assert.IsTrue(ItemCard."Gen. Prod. Posting Group".Value = ItemTempl."Gen. Prod. Posting Group", InsertedItemErr);
        Assert.IsTrue(ItemCard."VAT Prod. Posting Group".Value = ItemTempl."VAT Prod. Posting Group", InsertedItemErr);
    end;

    [ModalPageHandler]
    procedure CustomerTemplCardHandler(var CustomerTemplCard: TestPage "Customer Templ. Card")
    var
        Customer: Record Customer;
    begin
        Customer.Get(LibraryVariableStorage.DequeueText());

        CustomerTemplCard."Customer Posting Group".AssertEquals(Customer."Customer Posting Group");
        CustomerTemplCard."Gen. Bus. Posting Group".AssertEquals(Customer."Gen. Bus. Posting Group");
        CustomerTemplCard."VAT Bus. Posting Group".AssertEquals(Customer."VAT Bus. Posting Group");

        LibraryVariableStorage.Enqueue(CustomerTemplCard.Code.Value);

        CustomerTemplCard.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure VendorTemplCardHandler(var VendorTemplCard: TestPage "Vendor Templ. Card")
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(LibraryVariableStorage.DequeueText());

        VendorTemplCard."Vendor Posting Group".AssertEquals(Vendor."Vendor Posting Group");
        VendorTemplCard."Gen. Bus. Posting Group".AssertEquals(Vendor."Gen. Bus. Posting Group");
        VendorTemplCard."VAT Bus. Posting Group".AssertEquals(Vendor."VAT Bus. Posting Group");

        LibraryVariableStorage.Enqueue(VendorTemplCard.Code.Value);

        VendorTemplCard.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ItemTemplCardHandler(var ItemTemplCard: TestPage "Item Templ. Card")
    var
        Item: Record Item;
    begin
        Item.Get(LibraryVariableStorage.DequeueText());

        ItemTemplCard."Inventory Posting Group".AssertEquals(Item."Inventory Posting Group");
        ItemTemplCard."Gen. Prod. Posting Group".AssertEquals(Item."Gen. Prod. Posting Group");
        ItemTemplCard."VAT Prod. Posting Group".AssertEquals(Item."VAT Prod. Posting Group");

        LibraryVariableStorage.Enqueue(ItemTemplCard.Code.Value);

        ItemTemplCard.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure EmployeeTemplCardHandler(var EmployeeTemplCard: TestPage "Employee Templ. Card")
    var
        Employee: Record Employee;
    begin
        Employee.Get(LibraryVariableStorage.DequeueText());

        EmployeeTemplCard."Employee Posting Group".AssertEquals(Employee."Employee Posting Group");
        EmployeeTemplCard."Statistics Group Code".AssertEquals(Employee."Statistics Group Code");

        LibraryVariableStorage.Enqueue(EmployeeTemplCard.Code.Value);

        EmployeeTemplCard.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [StrMenuHandler]
    procedure CreateCustVendStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 1;
    end;

    [ModalPageHandler]
    procedure VendorCardHandler(var VendorCard: TestPage "Vendor Card")
    begin
        LibraryVariableStorage.Enqueue(VendorCard."No.".Value);
        VendorCard.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure CustomerCardHandler(var CustomerCard: TestPage "Customer Card")
    begin
        LibraryVariableStorage.Enqueue(CustomerCard."No.".Value);
        CustomerCard.OK().Invoke();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Templ. Mgt.", 'OnAfterIsEnabled', '', false, false)]
    local procedure CustOnAfterIsEnabledHandler(var Result: Boolean)
    begin
        Result := TemplateFeatureEnabled;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Templ. Mgt.", 'OnAfterIsEnabled', '', false, false)]
    local procedure VendOnAfterIsEnabledHandler(var Result: Boolean)
    begin
        Result := TemplateFeatureEnabled;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Templ. Mgt.", 'OnAfterIsEnabled', '', false, false)]
    local procedure ItemOnAfterIsEnabledHandler(var Result: Boolean)
    begin
        Result := TemplateFeatureEnabled;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Employee Templ. Mgt.", 'OnAfterIsEnabled', '', false, false)]
    local procedure EmplOnAfterIsEnabledHandler(var Result: Boolean)
    begin
        Result := TemplateFeatureEnabled;
    end;
}