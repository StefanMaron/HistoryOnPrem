permissionset 5807 "D365 PURCH DOC, EDIT"
{
    Assignable = true;

    Caption = 'Dyn. 365 Create purch. doc.';
    Permissions = tabledata "Approval Workflow Wizard" = RIMD,
                  tabledata "Bank Account" = R,
                  tabledata "Cancelled Document" = Rimd,
                  tabledata "Contact Business Relation" = R,
                  tabledata Currency = RM,
                  tabledata "Customer Bank Account" = R,
                  tabledata "Detailed Employee Ledger Entry" = Rm,
                  tabledata "Detailed Vendor Ledg. Entry" = Rm,
                  tabledata "Employee Ledger Entry" = Rm,
                  tabledata "General Ledger Setup" = rm,
                  tabledata "Item Charge" = R,
                  tabledata "Item Cross Reference" = R,
                  tabledata "Item Entry Relation" = R,
                  tabledata "Item Reference" = R,
                  tabledata "Item Tracing Buffer" = Rimd,
                  tabledata "Item Tracing History Buffer" = Rimd,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Job Queue Category" = RIMD,
                  tabledata "Notification Entry" = RIMD,
                  tabledata "Order Address" = RIMD,
                  tabledata "Payment Terms" = RMD,
                  tabledata "Planning Component" = RIm,
                  tabledata "Purch. Cr. Memo Hdr." = R,
                  tabledata "Purch. Cr. Memo Line" = R,
                  tabledata "Purch. Inv. Header" = R,
                  tabledata "Purch. Inv. Line" = R,
                  tabledata "Purch. Rcpt. Header" = R,
                  tabledata "Purch. Rcpt. Line" = R,
                  tabledata "Purchase Header" = RIMD,
                  tabledata "Purchase Header Archive" = RIMD,
                  tabledata "Purchase Line" = RIMD,
                  tabledata "Purchase Line Archive" = RIMD,
                  tabledata "Record Buffer" = Rimd,
                  tabledata "Requisition Line" = RIMD,
                  tabledata "Restricted Record" = RIMD,
                  tabledata "Return Reason" = R,
                  tabledata "Return Shipment Header" = R,
                  tabledata "Return Shipment Line" = R,
                  tabledata "Ship-to Address" = RIMD,
                  tabledata "Standard General Journal Line" = RIMD,
                  tabledata "Standard Purchase Code" = RIMD,
                  tabledata "Standard Purchase Line" = RIMD,
                  tabledata "Standard Vendor Purchase Code" = RIMD,
                  tabledata "Stockkeeping Unit" = R,
                  tabledata "Time Sheet Chart Setup" = RIMD,
                  tabledata "Time Sheet Comment Line" = RIMD,
                  tabledata "Time Sheet Detail" = RIMD,
                  tabledata "Time Sheet Header" = RIMD,
                  tabledata "Time Sheet Line" = RIMD,
                  tabledata "Time Sheet Posting Entry" = RIMD,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Transaction Type" = R,
                  tabledata "Transport Method" = R,
                  tabledata "Unplanned Demand" = RIMD,
                  tabledata "User Task Group" = RIMD,
                  tabledata "User Task Group Member" = RIMD,
                  tabledata "Value Entry Relation" = R,
                  tabledata "VAT Amount Line" = RIMD,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata Vendor = RM,
                  tabledata "Vendor Bank Account" = R,
                  tabledata "Vendor Invoice Disc." = R,
                  tabledata "Vendor Ledger Entry" = Rm,
                  tabledata "Whse. Item Entry Relation" = R,
                  tabledata "Workflow - Table Relation" = RIMD,
                  tabledata Workflow = RIMD,
                  tabledata "Workflow Event" = RIMD,
                  tabledata "Workflow Event Queue" = RIMD,
                  tabledata "Workflow Response" = RIMD,
                  tabledata "Workflow Rule" = RIMD,
                  tabledata "Workflow Step" = RIMD,
                  tabledata "Workflow Step Argument" = RIMD,
                  tabledata "Workflow Step Instance" = RIMD,
                  tabledata "Workflow Table Relation Value" = RIMD,
                  tabledata "Workflow User Group" = RIMD,
                  tabledata "Workflow User Group Member" = RIMD;
}
