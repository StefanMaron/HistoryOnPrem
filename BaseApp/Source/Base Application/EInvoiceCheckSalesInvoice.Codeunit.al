codeunit 10615 "E-Invoice Check Sales Invoice"
{
    TableNo = "Sales Invoice Header";

    trigger OnRun()
    var
        EInvoiceCheckCommon: Codeunit "E-Invoice Check Common";
    begin
        CheckCompanyInfo;
        CheckSalesSetup;
        EInvoiceCheckCommon.CheckCurrencyCode("Currency Code", "No.", "Posting Date");
    end;

    var
        InvalidPathErr: Label 'does not contain a valid path';

    [Scope('OnPrem')]
    procedure CheckCompanyInfo()
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get;
        CompanyInfo.TestField(Name);
        CompanyInfo.TestField(Address);
        CompanyInfo.TestField(City);
        CompanyInfo.TestField("Post Code");
        CompanyInfo.TestField("Country/Region Code");
        CompanyInfo.TestField("VAT Registration No.");
        CompanyInfo.TestField("SWIFT Code");
        if CompanyInfo.IBAN = '' then
            CompanyInfo.TestField("Bank Account No.");
        CompanyInfo.TestField("Bank Branch No.");
    end;

    local procedure CheckSalesSetup()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        FileManagement: Codeunit "File Management";
    begin
        // If it's RTC, is there a location for storing the file? If not, don't create the e-invoice
        SalesSetup.Get;
        SalesSetup.TestField("E-Invoice Sales Invoice Path");
        if not FileManagement.DirectoryExistsOnDotNetClient(SalesSetup."E-Invoice Sales Invoice Path") then
            SalesSetup.FieldError("E-Invoice Sales Invoice Path", InvalidPathErr);
    end;
}

