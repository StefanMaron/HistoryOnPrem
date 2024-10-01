permissionset 8620 "CashFlow - Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'Cash Flow Total';

    Permissions = tabledata "Azure AI Usage" = Rimd,
                  tabledata "Cash Flow Account" = RIMD,
                  tabledata "Cash Flow Account Comment" = RIMD,
                  tabledata "Cash Flow Azure AI Buffer" = Rimd,
                  tabledata "Cash Flow Chart Setup" = RIMD,
                  tabledata "Cash Flow Forecast" = RIMD,
                  tabledata "Cash Flow Forecast Entry" = RIMD,
                  tabledata "Cash Flow Manual Expense" = RIMD,
                  tabledata "Cash Flow Manual Revenue" = RIMD,
                  tabledata "Cash Flow Report Selection" = RIMD,
                  tabledata "Cash Flow Setup" = RIMD,
                  tabledata "Cash Flow Worksheet Line" = RIMD,
                  tabledata Customer = RM,
                  tabledata "G/L Account" = RM,
                  tabledata "Source Code Setup" = RM,
                  tabledata Vendor = RM;
}
