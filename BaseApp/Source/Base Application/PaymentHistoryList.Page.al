page 11000007 "Payment History List"
{
    Caption = 'Payment History List';
    CardPageID = "Payment History Card";
    DataCaptionFields = "Our Bank";
    DeleteAllowed = true;
    Editable = true;
    InsertAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    SourceTable = "Payment History";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Our Bank"; "Our Bank")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of your bank through which you want to perform payments or collections.';
                    Visible = "Our BankVisible";
                }
                field(Control27; Export)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that this payment history will be included when you export payments by clicking Payment Hist., Export.';
                }
                field("Print Docket"; "Print Docket")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that a docket should be printed for this payment.';
                }
                field("Run No."; "Run No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the run number that was given to the entry, based on the number series that is defined in the Run No. Series field.';
                }
                field("Account No."; "Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number used by the bank for your bank account from which the payment or collection will be performed.';
                }
                field("Account Holder Name"; "Account Holder Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies your bank account owner''s name.';
                }
                field("Remaining Amount"; "Remaining Amount")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the amount that has not been reconciled. If the amount equals zero, all lines have been reconciled.';

                    trigger OnDrillDown()
                    var
                        PaymentHistory: Page "Payment History Card";
                        PaymHist: Record "Payment History";
                    begin
                        PaymHist.SetRange("Our Bank", "Our Bank");
                        PaymHist.SetRange("Run No.", "Run No.");
                        PaymentHistory.SetTableView(PaymHist);
                        PaymentHistory.RunModal;
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the status of the payment history.';
                }
                field("Export Protocol"; "Export Protocol")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the export protocol used to export the payment history.';
                }
                field("No. of Transactions"; "No. of Transactions")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of lines that the payment history contains.';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the user who created the payment history.';
                    Visible = false;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date when the proposal lines were processed into the payment history.';
                    Visible = false;
                }
                field("Sent On"; "Sent On")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date when the payment history was last exported.';
                    Visible = false;
                }
                field("Sent By"; "Sent By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the ID of the user who last exported the payment history.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Pa&yment Hist.")
            {
                Caption = 'Pa&yment Hist.';
                Image = PaymentHistory;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about the payment.';

                    trigger OnAction()
                    begin
                        OpenPaymentCard;
                    end;
                }
                action(Export)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export';
                    Ellipsis = true;
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'F9';
                    ToolTip = 'Export the payment history to a file.';

                    trigger OnAction()
                    begin
                        ExportToPaymentFile;
                        CurrPage.Update();
                    end;
                }
                action(PrintDocket)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print &Docket';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Generate a docket report to inform your vendor or customer about the individual payments that constitute the total amount paid or collected in cases where multiple ledger entries were combined in one payment or collection.';

                    trigger OnAction()
                    var
                        PaymHist: Record "Payment History";
                    begin
                        SentProtocol.Get("Export Protocol");
                        SentProtocol.TestField("Docket ID");

                        PaymHist := Rec;
                        PaymHist.SetRange("Export Protocol", "Export Protocol");
                        PaymHist.SetRange("Our Bank", "Our Bank");
                        PaymHist.SetRange("Print Docket", true);
                        OnPrintDocketOnAfterPaymHistSetFilters(Rec, SentProtocol, PaymHist);
                        REPORT.RunModal(SentProtocol."Docket ID", true, true, PaymHist);

                        CurrPage.Update();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to journal lines to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions();
                        CurrPage.SaveRecord;
                    end;
                }
                action(PrintPaymentHistory)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Payment History';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ToolTip = 'Print the payment history, such as who and when the payment history was created and exported. Export a payment history, change the status, and view or resolve any payment file errors.';

                    trigger OnAction()
                    var
                        BankAcc: Record "Bank Account";
                    begin
                        BankAcc.SetRange("No.", "Our Bank");
                        REPORT.Run(REPORT::"Payment History Overview", true, true, BankAcc);
                    end;
                }
            }
        }
    }

    trigger OnInit()
    begin
        "Our BankVisible" := true;
    end;

    trigger OnOpenPage()
    begin
        "Our BankVisible" := GetFilter("Our Bank") = '';
    end;

    var
        SentProtocol: Record "Export Protocol";
        [InDataSet]
        "Our BankVisible": Boolean;

    [Scope('OnPrem')]
    procedure OpenPaymentCard()
    var
        PaymentCard: Page "Payment History Card";
    begin
        PaymentCard.SetTableView(Rec);
        PaymentCard.SetRecord(Rec);
        PaymentCard.Run;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPrintDocketOnAfterPaymHistSetFilters(Rec: Record "Payment History"; var SentProtocol: Record "Export Protocol"; var PaymHist: Record "Payment History")
    begin
    end;
}

