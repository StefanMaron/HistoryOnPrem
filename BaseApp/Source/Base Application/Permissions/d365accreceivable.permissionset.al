permissionset 7862 "D365 ACC. RECEIVABLE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Dyn. 365 Accounts receivable';

    IncludedPermissionSets = "D365 JOURNALS, POST",
                             "D365 SALES DOC, POST";

    Permissions = tabledata "Applied Payment Entry" = RIMD,
                  tabledata "Bank Acc. Reconciliation" = RIMD,
                  tabledata "Bank Acc. Reconciliation Line" = RIMD,
                  tabledata "Bank Acc. Rec. Match Buffer" = RIMD,
                  tabledata "Bank Account Statement" = RimD,
                  tabledata "Bank Account Statement Line" = Rimd,
                  tabledata "Bank Pmt. Appl. Rule" = RIMD,
                  tabledata "Bank Pmt. Appl. Settings" = RIMD,
                  tabledata "Credit Transfer Entry" = Rimd,
                  tabledata "Currency Exchange Rate" = D,
                  tabledata "Currency for Fin. Charge Terms" = R,
                  tabledata "Currency for Reminder Level" = R,
                  tabledata Customer = D,
                  tabledata "Date Compr. Register" = Rimd,
                  tabledata "Exch. Rate Adjmt. Reg." = Rimd,
                  tabledata "Fin. Charge Comment Line" = RIMD,
                  tabledata "Finance Charge Interest Rate" = RIMD,
                  tabledata "Finance Charge Memo Header" = RIMD,
                  tabledata "Finance Charge Memo Line" = RIMD,
                  tabledata "Finance Charge Text" = RIMD,
                  tabledata "Incoming Document" = Rimd,
                  tabledata "Issued Fin. Charge Memo Header" = Rimd,
                  tabledata "Issued Fin. Charge Memo Line" = Rimd,
                  tabledata "Issued Reminder Header" = Rimd,
                  tabledata "Issued Reminder Line" = Rimd,
                  tabledata "Item Charge" = R,
                  tabledata "Item Charge Assignment (Purch)" = RIMD,
                  tabledata "Item Charge Assignment (Sales)" = RIMD,
#if not CLEAN19
                  tabledata "Item Cross Reference" = RIMD,
#endif
                  tabledata "Item Entry Relation" = R,
                  tabledata "Item Journal Line" = RIMD,
                  tabledata "Item Ledger Entry" = Rimd,
                  tabledata "Item Reference" = RIMD,
                  tabledata "Item Register" = Rimd,
                  tabledata "Item Tracing Buffer" = Rimd,
                  tabledata "Item Tracing History Buffer" = Rimd,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Job Ledger Entry" = Rimd,
                  tabledata "Job Queue Category" = RIMD,
                  tabledata "Line Fee Note on Report Hist." = Rim,
                  tabledata "Lot No. Information" = RIMD,
                  tabledata "Notification Entry" = RIMD,
                  tabledata "O365 Document Sent History" = RimD,
                  tabledata Opportunity = R,
                  tabledata "Opportunity Entry" = RIM,
                  tabledata "Order Address" = RIMD,
                  tabledata "Order Promising Line" = RiMD,
                  tabledata "Package No. Information" = RIMD,
                  tabledata "Payment Matching Details" = RIMD,
                  tabledata "Payment Method" = RIMD,
                  tabledata "Posted Payment Recon. Hdr" = RIMD,
                  tabledata "Posted Payment Recon. Line" = RIMD,
                  tabledata "Posted Whse. Shipment Header" = R,
                  tabledata "Posted Whse. Shipment Line" = R,
                  tabledata "Price Asset" = RIMD,
                  tabledata "Price Calculation Buffer" = RIMD,
                  tabledata "Price Calculation Setup" = RIMD,
                  tabledata "Price Line Filters" = RIMD,
                  tabledata "Price List Header" = RIMD,
                  tabledata "Price List Line" = RIMD,
                  tabledata "Price Source" = RIMD,
                  tabledata "Price Worksheet Line" = RIMD,
                  tabledata "Purch. Rcpt. Header" = i,
                  tabledata "Purch. Rcpt. Line" = Ri,
                  tabledata "Purchase Header" = Rimd,
                  tabledata "Purchase Line" = RIMD,
                  tabledata "Reminder Comment Line" = RIMD,
                  tabledata "Reminder Header" = RIMD,
                  tabledata "Reminder Level" = R,
                  tabledata "Reminder Line" = RIMD,
                  tabledata "Reminder Text" = R,
                  tabledata "Reminder/Fin. Charge Entry" = Rimd,
                  tabledata "VAT Registration No. Format" = IMD;
}
