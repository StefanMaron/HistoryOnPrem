page 11000000 "Telebank - Bank Overview"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Telebank - Bank Overview';
    Editable = false;
    PageType = List;
    SourceTable = "Bank Account";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the bank account.';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the bank account.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code for the amounts.';
                }
                field(IBAN; IBAN)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bank account''s international bank account number.';
                    Visible = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field(Control6; Balance)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    BlankZero = true;
                    ToolTip = 'Specifies the bank account''s current balance denominated in the applicable foreign currency.';
                }
                field("Min. Balance"; "Min. Balance")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    ToolTip = 'Specifies a minimum balance for the bank account.';
                    Visible = false;
                }
                field(Proposal; Proposal)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount of proposed and to be processed payments/collections for this bank account.';

                    trigger OnDrillDown()
                    begin
                        OpenProposal;
                    end;
                }
                field("Payment History"; "Payment History")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    BlankZero = true;
                    ToolTip = 'Specifies the total amount of payment history entries for this bank account that have not been posted yet.';

                    trigger OnDrillDown()
                    begin
                        OpenPayment;
                    end;
                }
                field("Credit limit"; "Credit limit")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = "Currency Code";
                    AutoFormatType = 1;
                    Caption = 'Credit Limit';
                    ToolTip = 'Specifies the remaining amount available to use for payments.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Bank Acc.")
            {
                Caption = '&Bank Acc.';
                Image = Bank;
                action(Card)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Bank Account Card";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about the Telebank proposal.';
                }
                action(Statistics)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Bank Account Statistics";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View the current balance on the bank account and a summary of the net changes for the current month, current year and last year.';
                }
                action("Co&mments")
                {
                    ApplicationArea = Advanced;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Bank Account"),
                                  "No." = FIELD("No.");
                    ToolTip = 'View or edit comments for the selected record.';
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(270),
                                      "No." = FIELD("No.");
                        ShortCutKey = 'Shift+Ctrl+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up. You can assign dimension codes to transactions to distribute costs and analyze historical information.';
                    }
                    action(DimensionsMultiple)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            BankAcc: Record "Bank Account";
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(BankAcc);
                            DefaultDimMultiple.SetMultiRecord(BankAcc, FieldNo("No."));
                            DefaultDimMultiple.RunModal;
                        end;
                    }
                }
                action(Balance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance';
                    Image = Balance;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Bank Account Balance";
                    RunPageLink = "No." = FIELD("No."),
                                  "Date Filter" = FIELD("Date Filter"),
                                  "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                                  "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter");
                    ToolTip = 'View a summary of the bank account balance in different periods.';
                }
                action("St&atements")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'St&atements';
                    Image = BankAccountStatement;
                    RunObject = Page "Bank Account Statement List";
                    RunPageLink = "Bank Account No." = FIELD("No.");
                    ToolTip = 'View all posted bank statements for the selected bank.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Ledger E&ntries';
                    Image = LedgerEntries;
                    RunObject = Page "Bank Account Ledger Entries";
                    RunPageLink = "Bank Account No." = FIELD("No.");
                    RunPageView = SORTING("Bank Account No.");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the bank ledger entries.';
                }
                action("Chec&k Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chec&k Ledger Entries';
                    Image = CheckLedger;
                    RunObject = Page "Check Ledger Entries";
                    RunPageLink = "Bank Account No." = FIELD("No.");
                    RunPageView = SORTING("Bank Account No.");
                    ToolTip = 'View the entries for the selected bank account that result from posting transactions that are paid with checks.';
                }
                action(Contact)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'C&ontact';
                    Image = ContactPerson;
                    ToolTip = 'View detailed information for the contact at the selected bank.';

                    trigger OnAction()
                    begin
                        ShowContact;
                    end;
                }
            }
            group("&Telebank")
            {
                Caption = '&Telebank';
                Image = ElectronicBanking;
                action(Proposal_Navigate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proposal';
                    Image = SuggestElectronicDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'Create a new payment or collection proposal for the selected bank.';

                    trigger OnAction()
                    begin
                        OpenProposal;
                    end;
                }
                action(GetProposalEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Get Proposal &Entries';
                    Ellipsis = true;
                    Image = SuggestVendorPayments;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Generate proposal lines for payments or collections based on vendor or customer ledger entries.';

                    trigger OnAction()
                    begin
                        REPORT.RunModal(REPORT::"Get Proposal Entries");
                        CurrPage.Update();
                    end;
                }
                separator(Action14)
                {
                }
                action(PaymentHistory)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment History';
                    Image = PaymentHistory;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Ctrl+F11';
                    ToolTip = 'View or manage payment information for a each payment or collection that has been generated from a payment or collection proposal. View who and when the payment history was created and exported. Export a payment history, change the status, and view or resolve any payment file errors.';

                    trigger OnAction()
                    begin
                        OpenPayment;
                    end;
                }
            }
        }
        area(processing)
        {
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action(ProposalOverview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Proposal Overview';
                    Ellipsis = true;
                    Image = SuggestElectronicDocument;
                    ToolTip = 'View all proposal lines for the bank account.';

                    trigger OnAction()
                    begin
                        BankAcct := Rec;
                        BankAcct.SetRecFilter;

                        REPORT.Run(REPORT::"Proposal Overview", true, true, BankAcct);
                    end;
                }
                action(PaymentHistoryOverview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pa&yment History Overview';
                    Ellipsis = true;
                    Image = Payment;
                    ToolTip = 'View all payment history entries for the bank accounts.';

                    trigger OnAction()
                    begin
                        BankAcct := Rec;
                        BankAcct.SetRecFilter;

                        REPORT.RunModal(REPORT::"Payment History Overview", true, false, BankAcct);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Detail Trial Balance")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Detail Trial Balance';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Bank Acc. - Detail Trial Bal.";
                ToolTip = 'View, print, or send a report that shows a detailed trial balance for selected bank accounts. You can use the report at the close of an accounting period or fiscal year.';
            }
            action("Check Details")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Check Details';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Bank Account - Check Details";
                ToolTip = 'View a detailed trial balance for selected checks. For each entry, the report shows a description, an amount, a printed amount, the entry status, the original entry status, and so on.';
            }
            action("Trial Balance by Period")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance by Period';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Trial Balance by Period";
                ToolTip = 'View the opening balance of the bank account, the movements in the selected period of month, quarter, or year, and the resulting closing balance.';
            }
            action("Trial Balance")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance';
                Image = "Report";
                Promoted = false;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Trial Balance";
                ToolTip = 'View the opening balance of the bank account, the movements in the selected period of month, quarter, or year, and the resulting closing balance.';
            }
        }
    }

    var
        BankAcct: Record "Bank Account";

    [Scope('OnPrem')]
    procedure OpenPayment()
    var
        PaymentHistory: Page "Payment History List";
        PaymHist: Record "Payment History";
    begin
        PaymHist.FilterGroup(10);
        PaymHist.SetRange("Our Bank", "No.");
        PaymHist.FilterGroup(0);
        PaymentHistory.SetTableView(PaymHist);
        PaymentHistory.Run;
    end;

    [Scope('OnPrem')]
    procedure OpenProposal()
    var
        ProposalWindow: Page "Telebank Proposal";
        Prop: Record "Proposal Line";
    begin
        Prop.SetRange("Our Bank No.", "No.");
        ProposalWindow.SetTableView(Prop);
        ProposalWindow.SetRecord(Prop);
        ProposalWindow.Run;
    end;
}

