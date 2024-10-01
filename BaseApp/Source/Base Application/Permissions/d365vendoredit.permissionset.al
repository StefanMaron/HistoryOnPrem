permissionset 9921 "D365 VENDOR, EDIT"
{
    Assignable = true;
    Caption = 'Dynamics 365 Create vendors';

    IncludedPermissionSets = "D365 VENDOR, VIEW";

    Permissions = tabledata "Bank Account Ledger Entry" = rm,
                  tabledata "Check Ledger Entry" = r,
                  tabledata "Cont. Duplicate Search String" = RIMD,
                  tabledata Contact = RIM,
                  tabledata "Contact Business Relation" = RImD,
                  tabledata "Contact Duplicate" = R,
                  tabledata "Contract Gain/Loss Entry" = rm,
                  tabledata Currency = RM,
                  tabledata "Cust. Ledger Entry" = r,
                  tabledata "Detailed Vendor Ledg. Entry" = Rimd,
                  tabledata "Dtld. Price Calculation Setup" = RIMD,
                  tabledata "Duplicate Price Line" = RIMD,
                  tabledata "Duplicate Search String Setup" = R,
                  tabledata "Filed Contract Line" = rm,
                  tabledata "G/L Entry - VAT Entry Link" = rm,
                  tabledata "G/L Entry" = rm,
                  tabledata "Interaction Log Entry" = R,
                  tabledata "Item Analysis View Budg. Entry" = r,
                  tabledata "Item Analysis View Entry" = rid,
                  tabledata "Item Budget Entry" = r,
#if not CLEAN19
                  tabledata "Item Cross Reference" = IMD,
#endif
                  tabledata "Item Reference" = IMD,
                  tabledata "Item Vendor" = Rid,
                  tabledata "Nonstock Item" = rm,
                  tabledata Opportunity = R,
                  tabledata "Order Address" = RIMD,
                  tabledata "Payment Method" = R,
                  tabledata "Price Asset" = RIMD,
                  tabledata "Price Calculation Buffer" = RIMD,
                  tabledata "Price Calculation Setup" = RIMD,
                  tabledata "Price Line Filters" = RIMD,
                  tabledata "Price List Header" = RIMD,
                  tabledata "Price List Line" = RIMD,
                  tabledata "Price Source" = RIMD,
                  tabledata "Price Worksheet Line" = RIMD,
                  tabledata "Purch. Cr. Memo Hdr." = rm,
                  tabledata "Purch. Cr. Memo Line" = rm,
                  tabledata "Purch. Inv. Header" = rm,
                  tabledata "Purch. Inv. Line" = rm,
                  tabledata "Purch. Rcpt. Header" = rm,
                  tabledata "Purch. Rcpt. Line" = rm,
                  tabledata "Purchase Discount Access" = RIMD,
                  tabledata "Purchase Header Archive" = r,
#if not CLEAN19
                  tabledata "Purchase Line Discount" = RIMD,
                  tabledata "Purchase Price" = RIMD,
#endif
                  tabledata "Purchase Price Access" = RIMD,
                  tabledata "Purchases & Payables Setup" = M,
                  tabledata "Registered Whse. Activity Line" = rm,
                  tabledata "Res. Capacity Entry" = RIMD,
                  tabledata "Return Receipt Header" = rm,
                  tabledata "Return Receipt Line" = rm,
                  tabledata "Return Shipment Header" = Rm,
                  tabledata "Return Shipment Line" = rm,
                  tabledata "Service Item" = r,
                  tabledata "Ship-to Address" = RIMD,
                  tabledata "Social Listening Search Topic" = RIMD,
                  tabledata "Standard Purchase Code" = RIMD,
                  tabledata "Standard Purchase Line" = RIMD,
                  tabledata "Standard Vendor Purchase Code" = RIMD,
                  tabledata "To-do" = R,
                  tabledata "VAT Entry" = Rm,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Reg. No. Srv Config" = RIMD,
                  tabledata "VAT Reg. No. Srv. Template" = RIMD,
                  tabledata "VAT Registration Log Details" = RIMD,
                  tabledata "VAT Registration No. Format" = RIMD,
                  tabledata Vendor = RIMD,
                  tabledata "Vendor Bank Account" = IMD,
                  tabledata "Vendor Invoice Disc." = IMD,
                  tabledata "Vendor Ledger Entry" = M,
                  tabledata "Warehouse Activity Header" = r,
                  tabledata "Warehouse Activity Line" = r,
                  tabledata "Warehouse Request" = rm,
                  tabledata "Warehouse Shipment Line" = rm,
                  tabledata "Warranty Ledger Entry" = rm,
                  tabledata "Whse. Worksheet Line" = r,
                  tabledata "Work Center" = r;
}
