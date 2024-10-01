codeunit 12435 "Sales Cr.Memo Header - Edit"
{
    Permissions = TableData "Sales Cr.Memo Header" = rm;
    TableNo = "Sales Cr.Memo Header";

    trigger OnRun()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader := Rec;
        SalesCrMemoHeader.LockTable;
        SalesCrMemoHeader.Find;
        SalesCrMemoHeader."Consignor No." := "Consignor No.";
        SalesCrMemoHeader.TestField("No.", "No.");
        SalesCrMemoHeader.Modify;
        Rec := SalesCrMemoHeader;
    end;
}

