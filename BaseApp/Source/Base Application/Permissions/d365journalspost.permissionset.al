permissionset 681 "D365 JOURNALS, POST"
{
    Assignable = true;

    Caption = 'Dynamics 365 Post journals';
    Permissions = tabledata "Avg. Cost Adjmt. Entry Point" = RIM,
                  tabledata "Bank Account" = R,
                  tabledata "Bank Account Ledger Entry" = Rim,
                  tabledata "Bank Account Posting Group" = R,
                  tabledata "Batch Processing Parameter" = Rimd,
                  tabledata "Batch Processing Session Map" = Rimd,
                  tabledata Bin = R,
                  tabledata "Check Ledger Entry" = Rimd,
                  tabledata "Cust. Invoice Disc." = R,
                  tabledata "Cust. Ledger Entry" = Rimd,
                  tabledata "Detailed Cust. Ledg. Entry" = Rimd,
                  tabledata "Detailed Employee Ledger Entry" = Rimd,
                  tabledata "Detailed Vendor Ledg. Entry" = Rimd,
                  tabledata "Employee Ledger Entry" = Rimd,
                  tabledata "G/L - Item Ledger Relation" = RIMD,
                  tabledata "G/L Entry - VAT Entry Link" = Ri,
                  tabledata "G/L Entry" = Rimd,
                  tabledata "G/L Register" = Rimd,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Intrastat Jnl. Line" = RIMD,
                  tabledata "Item Entry Relation" = R,
                  tabledata "Item Journal Line" = RIMD,
                  tabledata "Item Register" = Rimd,
                  tabledata "Item Tracing Buffer" = Rimd,
                  tabledata "Item Tracing History Buffer" = Rimd,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Job Ledger Entry" = Rimd,
                  tabledata "Lot No. Information" = RIMD,
                  tabledata "Package No. Information" = RIMD,
                  tabledata "Phys. Invt. Counting Period" = RIMD,
                  tabledata "Phys. Invt. Item Selection" = RIMD,
                  tabledata "Planning Component" = Rm,
                  tabledata "Post Value Entry to G/L" = i,
                  tabledata "Record Buffer" = Rimd,
                  tabledata "Serial No. Information" = RIMD,
                  tabledata "Standard General Journal Line" = RIMD,
                  tabledata "Standard Item Journal" = RIMD,
                  tabledata "Standard Item Journal Line" = RIMD,
                  tabledata "Stockkeeping Unit" = R,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Transaction Type" = R,
                  tabledata "Transport Method" = R,
                  tabledata "Value Entry Relation" = R,
                  tabledata "VAT Entry" = Rimd,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Registration No. Format" = R,
                  tabledata "Vendor Invoice Disc." = R,
                  tabledata "Vendor Ledger Entry" = Rimd,
                  tabledata "Warehouse Register" = r,
                  tabledata "Whse. Item Entry Relation" = R;
}
