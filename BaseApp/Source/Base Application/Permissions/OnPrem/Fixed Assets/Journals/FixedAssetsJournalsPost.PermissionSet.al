permissionset 2018 "Fixed Assets Journals - Post"
{
    Access = Public;
    Assignable = false;
    Caption = 'Post FA journals';

    Permissions = tabledata "Accounting Period" = r,
                  tabledata "Analysis View" = rimd,
                  tabledata "Analysis View Entry" = rim,
                  tabledata "Analysis View Filter" = r,
                  tabledata "Bank Account" = m,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "Batch Processing Parameter" = Rimd,
                  tabledata "Batch Processing Session Map" = Rimd,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata Currency = r,
                  tabledata "Currency Exchange Rate" = r,
                  tabledata Customer = r,
                  tabledata "Date Compr. Register" = r,
                  tabledata "Dimension Combination" = R,
                  tabledata "Dimension Value Combination" = R,
                  tabledata "FA Allocation" = R,
                  tabledata "FA Depreciation Book" = Rm,
                  tabledata "FA Journal Batch" = RID,
                  tabledata "FA Journal Line" = RIMD,
                  tabledata "FA Journal Setup" = R,
                  tabledata "FA Journal Template" = RI,
                  tabledata "FA Ledger Entry" = rim,
                  tabledata "FA Posting Group" = R,
                  tabledata "FA Posting Type Setup" = R,
                  tabledata "FA Reclass. Journal Batch" = RID,
                  tabledata "FA Reclass. Journal Line" = RIMD,
                  tabledata "FA Reclass. Journal Template" = RI,
                  tabledata "FA Register" = Rim,
                  tabledata "Fixed Asset" = R,
                  tabledata "G/L Account" = r,
                  tabledata "G/L Entry - VAT Entry Link" = Ri,
                  tabledata "G/L Entry" = Ri,
                  tabledata "G/L Register" = Rim,
                  tabledata "Gen. Business Posting Group" = R,
                  tabledata "Gen. Jnl. Allocation" = RIMD,
                  tabledata "Gen. Journal Batch" = RID,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RI,
                  tabledata "Gen. Product Posting Group" = R,
                  tabledata "General Ledger Setup" = r,
                  tabledata "General Posting Setup" = r,
                  tabledata "Ins. Coverage Ledger Entry" = rm,
                  tabledata Maintenance = R,
                  tabledata "Maintenance Ledger Entry" = rim,
#if not CLEAN20
                  tabledata "Native - Payment" = RIMD,
#endif
                  tabledata "Reversal Entry" = RIMD,
                  tabledata "Tax Area" = R,
                  tabledata "Tax Area Line" = R,
                  tabledata "Tax Detail" = R,
                  tabledata "Tax Group" = R,
                  tabledata "Tax Jurisdiction" = R,
                  tabledata "User Setup" = r,
                  tabledata "VAT Assisted Setup Bus. Grp." = r,
                  tabledata "VAT Assisted Setup Templates" = r,
                  tabledata "VAT Business Posting Group" = R,
                  tabledata "VAT Entry" = Ri,
                  tabledata "VAT Posting Setup" = r,
                  tabledata "VAT Product Posting Group" = R,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = r,
                  tabledata "VAT Reporting Code" = R,
                  tabledata "VAT Setup Posting Groups" = r,
                  tabledata Vendor = r;
}
