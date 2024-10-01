permissionset 7946 "Payables Documents - Edit"
{
    Access = Public;
    Assignable = false;
    Caption = 'Create purchase orders, etc.';

    IncludedPermissionSets = "Language - Read";

    Permissions = tabledata "Bank Account" = R,
                  tabledata Bin = R,
                  tabledata "BOM Component" = R,
                  tabledata "Comment Line" = R,
                  tabledata "Company Information" = R,
                  tabledata "Country/Region" = R,
                  tabledata Currency = R,
                  tabledata "Currency Exchange Rate" = R,
                  tabledata Customer = R,
                  tabledata "Customer Bank Account" = R,
                  tabledata "Default Dimension" = R,
                  tabledata "Default Dimension Priority" = R,
                  tabledata "Detailed Vendor Ledg. Entry" = R,
                  tabledata "Dtld. Price Calculation Setup" = R,
                  tabledata "Duplicate Price Line" = R,
                  tabledata "Employee Ledger Entry" = R,
                  tabledata "Employee Posting Group" = R,
                  tabledata "Entry Summary" = RIMD,
                  tabledata "Extended Text Header" = R,
                  tabledata "Extended Text Line" = R,
                  tabledata "G/L Account" = R,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Ledger Setup" = rm,
                  tabledata "General Posting Setup" = R,
                  tabledata "Inventory Posting Group" = R,
                  tabledata "Inventory Posting Setup" = R,
                  tabledata Item = R,
                  tabledata "Item Charge" = R,
                  tabledata "Item Charge Assignment (Purch)" = RIMD,
                  tabledata "Item Charge Assignment (Sales)" = Rm,
                  tabledata "Item Cross Reference" = R,
                  tabledata "Item Journal Line" = Rm,
                  tabledata "Item Ledger Entry" = Rm,
                  tabledata "Item Reference" = R,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Item Tracking Comment" = RIMD,
                  tabledata "Item Translation" = R,
                  tabledata "Item Unit of Measure" = R,
                  tabledata "Item Variant" = R,
                  tabledata "Item Vendor" = R,
                  tabledata Job = R,
                  tabledata "Job Planning Line - Calendar" = R,
                  tabledata "Job Planning Line" = R,
                  tabledata "Job Task" = R,
                  tabledata Location = R,
                  tabledata "Lot No. Information" = RIMD,
                  tabledata "My Vendor" = Rimd,
                  tabledata "Order Address" = R,
                  tabledata "Package No. Information" = RIMD,
                  tabledata "Payment Method" = R,
                  tabledata "Payment Terms" = R,
                  tabledata "Planning Component" = Rm,
                  tabledata "Price Asset" = R,
                  tabledata "Price Calculation Buffer" = R,
                  tabledata "Price Calculation Setup" = R,
                  tabledata "Price Line Filters" = R,
                  tabledata "Price List Header" = R,
                  tabledata "Price List Line" = R,
                  tabledata "Price Source" = R,
                  tabledata "Price Worksheet Line" = R,
                  tabledata "Prod. Order Component" = Rm,
                  tabledata "Prod. Order Line" = Rm,
                  tabledata "Purch. Comment Line" = RIMD,
                  tabledata "Purch. Inv. Header" = R,
                  tabledata "Purch. Inv. Line" = R,
                  tabledata "Purch. Rcpt. Header" = R,
                  tabledata "Purch. Rcpt. Line" = R,
                  tabledata "Purchase Discount Access" = R,
                  tabledata "Purchase Header" = RIMD,
                  tabledata "Purchase Header Archive" = RIMD,
                  tabledata "Purchase Line" = RIMD,
                  tabledata "Purchase Line Archive" = RIMD,
                  tabledata "Purchase Line Discount" = R,
                  tabledata "Purchase Price" = R,
                  tabledata "Purchase Price Access" = R,
                  tabledata "Reason Code" = R,
                  tabledata "Report Selections" = R,
                  tabledata "Requisition Line" = Rim,
                  tabledata "Reservation Entry" = Rimd,
                  tabledata "Responsibility Center" = R,
                  tabledata "Return Reason" = R,
                  tabledata "Return Shipment Header" = R,
                  tabledata "Return Shipment Line" = R,
                  tabledata "Sales Header" = Rm,
                  tabledata "Sales Line" = Rm,
                  tabledata "Salesperson/Purchaser" = R,
                  tabledata "Serial No. Information" = RIMD,
                  tabledata "Ship-to Address" = R,
                  tabledata "Shipment Method" = R,
                  tabledata "Standard Purchase Code" = R,
                  tabledata "Standard Purchase Line" = R,
                  tabledata "Standard Vendor Purchase Code" = R,
                  tabledata "Tax Area" = R,
                  tabledata "Tax Area Line" = R,
                  tabledata "Tax Detail" = R,
                  tabledata "Tax Group" = R,
                  tabledata "Tax Jurisdiction" = R,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Transaction Type" = R,
                  tabledata "Transport Method" = R,
                  tabledata "Unit of Measure" = R,
                  tabledata "Unit of Measure Translation" = R,
                  tabledata "User Setup" = r,
                  tabledata "Value Entry" = Rm,
                  tabledata "VAT Amount Line" = RIMD,
                  tabledata "VAT Assisted Setup Bus. Grp." = R,
                  tabledata "VAT Assisted Setup Templates" = R,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Posting Setup" = R,
                  tabledata "VAT Product Posting Group" = R,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Setup Posting Groups" = R,
                  tabledata Vendor = R,
                  tabledata "Vendor Bank Account" = R,
                  tabledata "Vendor Invoice Disc." = R,
                  tabledata "Vendor Ledger Entry" = R,
                  tabledata "Vendor Posting Group" = R;
}
