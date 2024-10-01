codeunit 138500 "Common Demodata"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [DEMO] [Common]
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        DoNotChangeO365ProfileNameErr: Label 'Important!! DO NOT CHANGE THE NAME OF THE O365 Sales profile name!';
        IsInitialized: Boolean;
        NONTAXABLETok: Label 'NonTAXABLE';

    [Test]
    [Scope('OnPrem')]
    procedure ConfigTemplateCodeShouldStartWithTablePrefix()
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        TableNamePrefix: Text[4];
    begin
        // [FEATURE] [Config. Template]
        // [SCENARIO] Config. Template Code for Customer/Vendor/Item should start with 'CUST'/'VEND'/'ITEM' prefix.
        Initialize();

        ConfigTemplateHeader.SetFilter("Table ID", '%1|%2|%3', DATABASE::Customer, DATABASE::Vendor, DATABASE::Item);
        if ConfigTemplateHeader.FindSet then
            repeat
                ConfigTemplateHeader.CalcFields("Table Caption");
                TableNamePrefix := UpperCase(CopyStr(ConfigTemplateHeader."Table Caption", 1, 4));
                Assert.AreEqual(
                  1, StrPos(ConfigTemplateHeader.Code, TableNamePrefix),
                  StrSubstNo('Template code %1 should start with %2', ConfigTemplateHeader.Code, TableNamePrefix));
            until ConfigTemplateHeader.Next = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure InteractionTemplateSetup()
    var
        InteractionTemplateSetup: Record "Interaction Template Setup";
    begin
        // [SCENARIO] There are 4 fields filled in the Interaction Template Setup
        Initialize();

        InteractionTemplateSetup.Get();
        InteractionTemplateSetup.TestField("E-Mails");
        InteractionTemplateSetup.TestField("Cover Sheets");
        InteractionTemplateSetup.TestField("Outg. Calls");
        InteractionTemplateSetup.TestField("Meeting Invitation");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MarketingSetup()
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        // [SCENARIO] There Business Relation and Number Series fields are filled in the Marketing Setup
        Initialize();

        MarketingSetup.Get();
        MarketingSetup.TestField("Contact Nos.");
        MarketingSetup.TestField("Segment Nos.");
        MarketingSetup.TestField("Campaign Nos.");
        MarketingSetup.TestField("To-do Nos.");
        MarketingSetup.TestField("Opportunity Nos.");
        MarketingSetup.TestField("Bus. Rel. Code for Customers");
        MarketingSetup.TestField("Bus. Rel. Code for Vendors");
        MarketingSetup.TestField("Bus. Rel. Code for Bank Accs.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TaxSetupShouldBeFilled()
    var
        TaxSetup: Record "Tax Setup";
    begin
        // [SCENARIO] Tax Setup should be filled
        // [WHEN] Find "Tax Setup" record
        TaxSetup.Get();
        // [THEN] "Auto. Create Tax Details" is Yes
        Assert.IsTrue(TaxSetup."Auto. Create Tax Details", TaxSetup.FieldName("Auto. Create Tax Details"));
        // [THEN] "Non-Taxable Tax Group Code" is not blank and related to a Tax Group
        TaxSetup.TestField("Non-Taxable Tax Group Code", NONTAXABLETok);
        TaxSetup.Validate("Non-Taxable Tax Group Code");
        // [THEN] "Tax Account (Sales)","Tax Account (Purchases)", "Reverse Charge (Purchases)" are not blank
        TaxSetup.TestField("Tax Account (Sales)");
        TaxSetup.TestField("Tax Account (Purchases)");
        TaxSetup.TestField("Reverse Charge (Purchases)");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATPostingGroupsCount()
    var
        VATBusPostingGroup: Record "VAT Business Posting Group";
        VATProdPostingGroup: Record "VAT Product Posting Group";
    begin
        // [SCENARIO] VAT Bus./Prod. Posting groups do not exist
        Initialize();

        Assert.RecordCount(VATBusPostingGroup, 0);

        Assert.RecordCount(VATProdPostingGroup, 0);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VATPostingSetupCount()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [SCENARIO] There is one "Sales Tax" posting setup entry with "Tax Category" = 'E'
        Initialize();

        with VATPostingSetup do begin
            Assert.RecordCount(VATPostingSetup, 1);
            FindFirst;
            TestField("VAT Bus. Posting Group", '');
            TestField("VAT Prod. Posting Group", '');
            TestField("VAT Calculation Type", "VAT Calculation Type"::"Sales Tax");
            TestField("VAT %", 0);
            TestField("Tax Category", 'E');
        end;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmployeeSetup()
    var
        HumanResourcesSetup: Record "Human Resources Setup";
    begin
        // [SCENARIO] Human Resources Setup contains a number series
        Initialize();

        HumanResourcesSetup.Get();
        HumanResourcesSetup.TestField("Employee Nos.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure InventoryPostingSetup()
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Location: Record Location;
    begin
        // [SCENARIO] Inventory Posting Setup exists for the default location, and all locations (if any)
        Initialize();

        InventoryPostingSetup.SetRange("Location Code", '');
        Assert.RecordIsNotEmpty(InventoryPostingSetup);

        if Location.FindSet then
            repeat
                InventoryPostingSetup.SetRange("Location Code", Location.Code);
                Assert.RecordIsNotEmpty(InventoryPostingSetup);
            until Location.Next = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PaymentMethodsWithUseForInvoicing()
    var
        PaymentMethod: Record "Payment Method";
    begin
        // [FEATURE] [Invoicing]
        // [SCENARIO 184609] There should be 3 payment methods with Use for Invoicing = Yes
        Initialize();

        PaymentMethod.SetRange("Use for Invoicing", true);
        Assert.RecordCount(PaymentMethod, 5);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure EmailDraftInteractionTemplateCode()
    var
        InteractionTemplateSetup: Record "Interaction Template Setup";
    begin
        // [SCENARIO 199993] Email Draft interaction template code should be defined in Interaction Template Setup
        Initialize();

        InteractionTemplateSetup.Get();
        InteractionTemplateSetup.TestField("E-Mail Draft");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure VerifyO365ProfileNameIsNotChanged()
    var
        AllProfile: Record "All Profile";
    begin
        // Important!! DO NOT CHANGE THE O365SalesTxt string below!!!
        // If this string needs to be changed, contact the invoicing app team
        // The invoicing app client has a hard dependency on this string!
        Initialize();

        AllProfile.SetRange("Profile ID", 'O' + '3' + '6' + '5' + ' ' + 'S' + 'a' + 'l' + 'e' + 's'); // Defend again bulk rename!
        if AllProfile.Count() <> 1 then
            Error(DoNotChangeO365ProfileNameErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesInvoiceProformaReportSelectionSetup()
    var
        ReportSelections: Record "Report Selections";
    begin
        // [FEATURE] [Report Selection] [Proforma Invoice]
        // [SCENARIO 201636] There is a Report Selections setup for Usage = "Pro Forma S. Invoice" with REP 1302 "Standard Sales - Pro Forma Inv"
        Initialize();

        ReportSelections.SetRange(Usage, ReportSelections.Usage::"Pro Forma S. Invoice");
        ReportSelections.FindFirst;
        ReportSelections.TestField("Report ID", REPORT::"Standard Sales - Pro Forma Inv");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure SalesInvoiceProformaCustomReportLayoutSetup()
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        // [FEATURE] [Report Selection] [Proforma Invoice]
        // [SCENARIO 225721] There is a Word Custom Report Layout setup for REP 1302 "Standard Sales - Pro Forma Inv"
        Initialize();

        CustomReportLayout.SetRange("Report ID", REPORT::"Standard Sales - Pro Forma Inv");
        CustomReportLayout.FindFirst;
        CustomReportLayout.TestField(Type, CustomReportLayout.Type::Word);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ForwardLinksExistAndNotBlank()
    var
        NamedForwardLink: Record "Named Forward Link";
    begin
        // [FEATURE] [Forward Link]
        // [SCENARIO 284641] Named Forward Links do exist and none of fields (Name, Description, Link) are blank.
        Initialize();

        Assert.TableIsNotEmpty(DATABASE::"Named Forward Link");
        NamedForwardLink.FilterGroup(-1);
        NamedForwardLink.SetRange(Name, '');
        NamedForwardLink.SetRange(Description, '');
        NamedForwardLink.SetRange(Link, '');
        Assert.RecordIsEmpty(NamedForwardLink);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllCountriesHaveISOCodes()
    var
        CountryRegion: Record "Country/Region";
    begin
        // [FEATURE] [Country/Region] [ISO Code]
        Initialize();

        CountryRegion.SetRange("ISO Code", '');
        Assert.RecordIsEmpty(CountryRegion);
        CountryRegion.Reset();
        CountryRegion.SetRange("ISO Numeric Code", '');
        Assert.RecordIsEmpty(CountryRegion);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AllCurrenciesHaveISOCodes()
    var
        Currency: Record Currency;
    begin
        // [FEATURE] [Currency] [ISO Code]
        Initialize();

        Currency.SetRange("ISO Code", '');
        Assert.RecordIsEmpty(Currency);
        Currency.Reset();
        Currency.SetRange("ISO Numeric Code", '');
        Assert.RecordIsEmpty(Currency);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PriceCalculationSetupIsEmpty()
    var
        PriceCalculationSetup: Record "Price Calculation Setup";
        DtldPriceCalculationSetup: Record "Dtld. Price Calculation Setup";
        JobsSetup: Record "Jobs Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // [FEATURE] [Price Calculation Setup]
        Initialize();

        // [THEN] "Price Calculation Setup" and "Dtld. Price Calculation Setup" tables are empty
        Assert.RecordIsEmpty(PriceCalculationSetup);
        Assert.RecordIsEmpty(DtldPriceCalculationSetup);
        // [THEN] "Price List Nos." in Sales Setup is filled.
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Price List Nos.");
        // [THEN] "Price List Nos." in Purchase Setup is filled.
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.TestField("Price List Nos.");
        // [THEN] "Copy Vendor Name to Entries" is 'Yes' in Purchase Setup is filled.
        PurchasesPayablesSetup.TestField("Copy Vendor Name to Entries");
        // [THEN] "Price List Nos." in Jobs Setup is filled.
        JobsSetup.Get();
        JobsSetup.TestField("Price List Nos.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CountriesWithVATScheme()
    var
        CountryRegion: Record "Country/Region";
    begin
        // [FEATURE] [Currency] [VAT Scheme]
        // [SCENARIO 334415] 'VAT Scheme' in Country/Region keeps values from Electronic Address Scheme (EAS)
        Initialize();

        CountryRegion.SetFilter("VAT Scheme", '*%1', ':VAT');
        Assert.RecordIsEmpty(CountryRegion);
        CountryRegion.SetFilter("VAT Scheme", '<>%1', '');
        Assert.RecordCount(CountryRegion, 31);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Common Demodata");

        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;
}

