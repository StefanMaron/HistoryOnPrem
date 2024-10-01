codeunit 5902 "Service Inv.-Printed"
{
    Permissions = TableData "Service Invoice Header" = rimd;
    TableNo = "Service Invoice Header";

    trigger OnRun()
    var
        SuppressCommit: Boolean;
    begin
        OnBeforeOnRun(Rec, SuppressCommit);
        Find;
        "No. Printed" := "No. Printed" + 1;
        OnBeforeModify(Rec);
        Modify;
        if not SuppressCommit then
            Commit();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModify(var ServiceInvoiceHeader: Record "Service Invoice Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRun(var ServiceInvoiceHeader: Record "Service Invoice Header"; var SuppressCommit: Boolean)
    begin
    end;
}

