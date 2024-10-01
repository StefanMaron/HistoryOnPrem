page 1606 "Office Doc Selection Dlg"
{
    Caption = 'No document found';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            label(Control4)
            {
                ShowCaption = false;
                Caption = '';
            }
            label(DocumentCouldNotBeFound)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'This document could not be found. You may use the links below to browse document lists or search for a specific document.';
                Editable = false;
                HideValue = true;
                ToolTip = 'Specifies whether the document was found.';
            }
            group("Search Sales Documents")
            {
                Caption = 'Search Sales Documents';
                Editable = false;
                field(SalesQuotes; SalesQuotesLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered sales quotes.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Sales, "Document Type"::Quote);
                    end;
                }
                field(SalesOrders; SalesOrdersLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered sales orders.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Sales, "Document Type"::Order);
                    end;
                }
                field(SalesInvoices; SalesInvoicesLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered sales invoices.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Sales, "Document Type"::Invoice);
                    end;
                }
                field(SalesCrMemos; SalesCredMemosLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered sales credit memos.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Sales, "Document Type"::"Credit Memo");
                    end;
                }
            }
            group("Search Purchasing Documents")
            {
                Caption = 'Search Purchasing Documents';
                field(PurchaseOrders; PurchOrdersLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered purchase orders.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Purchase, "Document Type"::Order);
                    end;
                }
                field(PurchaseInvoices; PurchInvoicesLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered purchase invoices.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Purchase, "Document Type"::Invoice);
                    end;
                }
                field(PurchaseCrMemos; PurchCredMemosLbl)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Specifies entered purchase credit memos.';

                    trigger OnDrillDown()
                    begin
                        with DummyOfficeDocumentSelection do
                            OfficeDocumentHandler.ShowDocumentSelection(Series::Purchase, "Document Type"::"Credit Memo");
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        DummyOfficeDocumentSelection: Record "Office Document Selection";
        SalesOrdersLbl: Label 'Sales Orders';
        SalesQuotesLbl: Label 'Sales Quotes';
        SalesInvoicesLbl: Label 'Sales Invoices';
        SalesCredMemosLbl: Label 'Sales Credit Memos';
        PurchInvoicesLbl: Label 'Purchase Invoices';
        PurchCredMemosLbl: Label 'Purchase Credit Memos';
        OfficeDocumentHandler: Codeunit "Office Document Handler";
        PurchOrdersLbl: Label 'Purchase Orders';
}

