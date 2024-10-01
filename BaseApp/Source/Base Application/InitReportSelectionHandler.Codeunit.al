codeunit 11774 "Init Report Selection Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Selection Mgt.", 'OnBeforeInitReportSelectionSales', '', false, false)]
    local procedure InitReportSelectionSalesOnAfterInitReportSelectionSales()
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do begin
            InitReportUsage(Usage::"S.Quote");
            InitReportUsage(Usage::"S.Order");
            InitReportUsage(Usage::"S.Invoice");
            InitReportUsage(Usage::"S.Return");
            InitReportUsage(Usage::"S.Cr.Memo");
            InitReportUsage(Usage::"S.Shipment");
            InitReportUsage(Usage::"S.Ret.Rcpt.");
            InitReportUsage(Usage::"S.Adv.Let");
            InitReportUsage(Usage::"S.Adv.Inv");
            InitReportUsage(Usage::"S.Adv.CrM");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Selection Mgt.", 'OnBeforeInitReportSelectionPurch', '', false, false)]
    local procedure InitReportSelectionPurchOnAfterInitReportSelectionPurch()
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do begin
            InitReportUsage(Usage::"P.Quote");
            InitReportUsage(Usage::"P.Order");
            InitReportUsage(Usage::"P.Adv.Let");
            InitReportUsage(Usage::"P.Adv.Inv");
            InitReportUsage(Usage::"P.Adv.CrM");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Selection Mgt.", 'OnBeforeInitReportSelectionServ', '', false, false)]
    local procedure InitReportSelectionServOnAfterInitReportSelectionServ()
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do begin
            InitReportUsage(Usage::"SM.Quote");
            InitReportUsage(Usage::"SM.Order");
            InitReportUsage(Usage::"SM.Invoice");
            InitReportUsage(Usage::"SM.Credit Memo");
            InitReportUsage(Usage::"SM.Shipment");
            InitReportUsage(Usage::"SM.Contract Quote");
            InitReportUsage(Usage::"SM.Contract");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Selection Mgt.", 'OnBeforeInitReportSelectionCust', '', false, false)]
    local procedure InitReportSelectionCustOnAfterInitReportSelectionCust()
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do begin
            InitReportUsage(Usage::Reminder);
            InitReportUsage(Usage::"Fin.Charge");
        end;
    end;

    local procedure InitReportUsage(ReportUsage: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        with ReportSelections do
            case ReportUsage of
                Usage::"S.Quote":
                    InsertRepSelection(Usage::"S.Quote", '1', Report::"Sales - Quote CZ");
                Usage::"S.Order":
                    InsertRepSelection(Usage::"S.Order", '1', Report::"Order Confirmation CZ");
                Usage::"S.Invoice":
                    InsertRepSelection(Usage::"S.Invoice", '1', Report::"Sales - Invoice CZ");
                Usage::"S.Return":
                    InsertRepSelection(Usage::"S.Return", '1', Report::"Return Order Confirmation CZ");
                Usage::"S.Cr.Memo":
                    InsertRepSelection(Usage::"S.Cr.Memo", '1', Report::"Sales - Credit Memo CZ");
                Usage::"S.Shipment":
                    InsertRepSelection(Usage::"S.Shipment", '1', Report::"Sales - Shipment CZ");
                Usage::"S.Ret.Rcpt.":
                    InsertRepSelection(Usage::"S.Ret.Rcpt.", '1', Report::"Sales - Return Reciept CZ");
                Usage::"P.Quote":
                    InsertRepSelection(Usage::"P.Quote", '1', Report::"Purchase - Quote CZ");
                Usage::"P.Order":
                    InsertRepSelection(Usage::"P.Order", '1', Report::"Order CZ");
                Usage::"SM.Quote":
                    InsertRepSelection(Usage::"SM.Quote", '1', Report::"Service Quote CZ");
                Usage::"SM.Order":
                    InsertRepSelection(Usage::"SM.Order", '1', Report::"Service Order CZ");
                Usage::"SM.Invoice":
                    InsertRepSelection(Usage::"SM.Invoice", '1', Report::"Service - Invoice CZ");
                Usage::"SM.Credit Memo":
                    InsertRepSelection(Usage::"SM.Credit Memo", '1', Report::"Service - Credit Memo CZ");
                Usage::"SM.Shipment":
                    InsertRepSelection(Usage::"SM.Shipment", '1', Report::"Service - Shipment CZ");
                Usage::"SM.Contract Quote":
                    InsertRepSelection(Usage::"SM.Contract Quote", '1', Report::"Service Contract Quote CZ");
                Usage::"SM.Contract":
                    InsertRepSelection(Usage::"SM.Contract", '1', Report::"Service Contract CZ");
                Usage::Reminder:
                    InsertRepSelection(Usage::Reminder, '1', Report::"Reminder CZ");
                Usage::"Fin.Charge":
                    InsertRepSelection(Usage::"Fin.Charge", '1', Report::"Finance Charge Memo CZ");
                Usage::"S.Adv.Let":
                    InsertRepSelection(Usage::"S.Adv.Let", '1', Report::"Sales - Advance Letter CZ");
                Usage::"S.Adv.Inv":
                    InsertRepSelection(Usage::"S.Adv.Inv", '1', Report::"Sales - Advance Invoice CZ");
                Usage::"S.Adv.CrM":
                    InsertRepSelection(Usage::"S.Adv.CrM", '1', Report::"Sales - Advance Credit Memo CZ");
                Usage::"P.Adv.Let":
                    InsertRepSelection(Usage::"P.Adv.Let", '1', Report::"Purchase - Advance Letter CZ");
                Usage::"P.Adv.Inv":
                    InsertRepSelection(Usage::"P.Adv.Inv", '1', Report::"Purchase - Advance Invoice CZ");
                Usage::"P.Adv.CrM":
                    InsertRepSelection(Usage::"P.Adv.CrM", '1', Report::"Purchase - Advance Cr. Memo CZ");
            end;
    end;

    local procedure InsertRepSelection(ReportUsage: Integer; Sequence: Code[10]; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        if not ReportSelections.Get(ReportUsage, Sequence) then begin
            ReportSelections.Init;
            ReportSelections.Usage := ReportUsage;
            ReportSelections.Sequence := Sequence;
            ReportSelections."Report ID" := ReportID;
            ReportSelections.Insert();
        end;
    end;
}