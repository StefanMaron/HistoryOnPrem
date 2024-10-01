permissionset 191 "D365 SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'Dyn. 365 Company data setup';

    IncludedPermissionSets = "BaseApp Objects - Exec",
                             "System App - Basic",
                             "Company - Edit";

    Permissions = tabledata "Data Sensitivity" = RIMD,
                  tabledata "NAV App Installed App" = Rimd,
                  tabledata "Object Options" = IMD,
                  tabledata "Acc. Sched. Cell Value" = D,
                  tabledata "Acc. Sched. KPI Web Srv. Line" = RIMD,
                  tabledata "Acc. Sched. KPI Web Srv. Setup" = RIMD,
                  tabledata "Acc. Schedule Line" = RIMD,
                  tabledata "Acc. Schedule Line Entity" = RIMD,
                  tabledata "Acc. Schedule Name" = RIMD,
                  tabledata "Accounting Period" = RIMD,
                  tabledata "Action Message Entry" = D,
                  tabledata Activity = D,
                  tabledata "Analysis Column" = D,
                  tabledata "Analysis Column Template" = D,
                  tabledata "Analysis Field Value" = D,
                  tabledata "Analysis Line" = D,
                  tabledata "Analysis Line Template" = D,
                  tabledata "Analysis Report Name" = D,
                  tabledata "Analysis Type" = D,
                  tabledata "Analysis View" = RIMD,
                  tabledata "Analysis View Budget Entry" = RD,
                  tabledata "Analysis View Entry" = RimD,
                  tabledata "Analysis View Filter" = RIMD,
                  tabledata "Applied Payment Entry" = D,
                  tabledata "Approval Workflow Wizard" = RIMD,
                  tabledata Area = RIMD,
                  tabledata "Assembly Setup" = Rimd,
                  tabledata "Assisted Company Setup Status" = RIMD,
                  tabledata Attachment = D,
                  tabledata "Availability at Date" = D,
                  tabledata "Availability Calc. Overview" = D,
                  tabledata "Average Cost Calc. Overview" = D,
                  tabledata "Avg. Cost Adjmt. Entry Point" = rimD,
                  tabledata "Azure AD App Setup" = RIMD,
                  tabledata "Azure AD Mgt. Setup" = RIMD,
                  tabledata "Bank Acc. Reconciliation" = D,
                  tabledata "Bank Acc. Reconciliation Line" = D,
                  tabledata "Bank Account" = RIMD,
                  tabledata "Bank Account Ledger Entry" = rmd,
                  tabledata "Bank Account Posting Group" = RIMD,
                  tabledata "Bank Account Statement" = D,
                  tabledata "Bank Account Statement Line" = d,
                  tabledata "Bank Clearing Standard" = ID,
                  tabledata "Bank Export/Import Setup" = RIMD,
                  tabledata "Bank Pmt. Appl. Rule" = RIMD,
                  tabledata "Bank Pmt. Appl. Settings" = RIMD,
                  tabledata "Bank Stmt Multiple Match Line" = D,
                  tabledata "Base Calendar" = RIMD,
                  tabledata "Base Calendar Change" = RIMD,
                  tabledata Bin = RIMD,
                  tabledata "Bin Content" = RIMD,
                  tabledata "BOM Component" = RIMD,
                  tabledata "Business Relation" = D,
                  tabledata "Business Unit" = D,
                  tabledata "Business Unit Information" = D,
                  tabledata "Business Unit Setup" = D,
                  tabledata Campaign = D,
                  tabledata "Campaign Entry" = D,
                  tabledata "Campaign Status" = D,
                  tabledata "Cancelled Document" = Rimd,
                  tabledata "Cash Flow Setup" = Rid,
                  tabledata "Change Log Entry" = Rimd,
                  tabledata "Change Log Setup (Field)" = RIMD,
                  tabledata "Change Log Setup (Table)" = RIMD,
                  tabledata "Change Log Setup" = RIMD,
                  tabledata "Check Ledger Entry" = rd,
                  tabledata "Close Opportunity Code" = D,
                  tabledata "Communication Method" = RIMD,
                  tabledata "Company Information" = RIMD,
                  tabledata "Config. Field Mapping" = RIMD,
                  tabledata "Config. Line" = RIMD,
                  tabledata "Config. Package" = RIMD,
                  tabledata "Config. Package Data" = RIMD,
                  tabledata "Config. Package Error" = RIMD,
                  tabledata "Config. Package Field" = RIMD,
                  tabledata "Config. Package Filter" = RIMD,
                  tabledata "Config. Package Record" = RIMD,
                  tabledata "Config. Package Table" = RIMD,
                  tabledata "Config. Question" = RIMD,
                  tabledata "Config. Question Area" = RIMD,
                  tabledata "Config. Questionnaire" = RIMD,
                  tabledata "Config. Record For Processing" = RIMD,
                  tabledata "Config. Related Field" = RIMD,
                  tabledata "Config. Related Table" = RIMD,
                  tabledata "Config. Selection" = RIMD,
                  tabledata "Config. Setup" = RIMD,
                  tabledata "Config. Table Processing Rule" = RIMD,
                  tabledata "Config. Template Header" = RIMD,
                  tabledata "Config. Template Line" = RIMD,
                  tabledata "Config. Tmpl. Selection Rules" = RIMD,
                  tabledata "Consolidation Account" = D,
                  tabledata "Cont. Duplicate Search String" = RIMD,
                  tabledata Contact = RIMD,
                  tabledata "Contact Business Relation" = RImD,
                  tabledata "Contact Duplicate" = RD,
                  tabledata "Contact Industry Group" = RD,
                  tabledata "Contact Job Responsibility" = RD,
                  tabledata "Contact Mailing Group" = RD,
                  tabledata "Contact Profile Answer" = RD,
                  tabledata "Contact Value" = D,
                  tabledata "Contact Web Source" = RD,
                  tabledata "Contract Gain/Loss Entry" = rmD,
                  tabledata "Coupling Field Buffer" = RIMD,
                  tabledata "Coupling Record Buffer" = RIMD,
                  tabledata "Credit Trans Re-export History" = D,
                  tabledata "Credit Transfer Entry" = D,
                  tabledata "Credit Transfer Register" = D,
                  tabledata "CRM Connection Setup" = RIMD,
                  tabledata "CRM Full Synch. Review Line" = RIMD,
                  tabledata "CRM Integration Record" = RIMD,
                  tabledata "CRM Option Mapping" = RIMD,
                  tabledata "CRM Redirect" = R,
                  tabledata "CRM Synch Status" = RIMD,
                  tabledata "CRM Synch. Conflict Buffer" = RIMD,
                  tabledata "CRM Synch. Job Status Cue" = RIMD,
                  tabledata "Curr. Exch. Rate Update Setup" = RIMD,
                  tabledata Currency = RIMD,
                  tabledata "Currency Exchange Rate" = RIMD,
                  tabledata "Currency for Fin. Charge Terms" = RIMD,
                  tabledata "Currency for Reminder Level" = RIMD,
                  tabledata "Cust. Invoice Disc." = RIMD,
                  tabledata "Cust. Ledger Entry" = RMd,
                  tabledata Customer = RIMD,
                  tabledata "Customer Bank Account" = RIMD,
                  tabledata "Customer Discount Group" = RIMD,
                  tabledata "Customer Posting Group" = RIMD,
                  tabledata "Customer Price Group" = RIMD,
                  tabledata "Customer Template" = RIMD,
                  tabledata "Customized Calendar Change" = RIMD,
                  tabledata "Customized Calendar Entry" = RIMD,
                  tabledata "Data Exch." = RIMD,
                  tabledata "Data Exchange Type" = RimD,
                  tabledata "Data Migration Entity" = RIMD,
                  tabledata "Data Migration Error" = RIMD,
                  tabledata "Data Migration Parameters" = RIMD,
                  tabledata "Data Migration Setup" = RIMD,
                  tabledata "Data Migration Status" = RIMD,
                  tabledata "Data Migrator Registration" = RIMD,
                  tabledata "Data Privacy Records" = RIMD,
                  tabledata "Date Compr. Register" = Rd,
                  tabledata "Deferral Header Archive" = D,
                  tabledata "Deferral Line Archive" = D,
                  tabledata "Delivery Sorter" = D,
                  tabledata "Detailed Cust. Ledg. Entry" = Rimd,
                  tabledata "Detailed Vendor Ledg. Entry" = Rimd,
                  tabledata Dimension = RIMD,
                  tabledata "Dimension Value" = RIMD,
                  tabledata "Direct Debit Collection" = D,
                  tabledata "Direct Debit Collection Entry" = D,
                  tabledata "Doc. Exch. Service Setup" = RIMD,
                  tabledata "Dtld. Price Calculation Setup" = RIMD,
                  tabledata "Duplicate Price Line" = RIMD,
                  tabledata "Duplicate Search String Setup" = RD,
                  tabledata "Dynamic Request Page Entity" = RIMD,
                  tabledata "Dynamic Request Page Field" = RIMD,
                  tabledata "Employee Ledger Entry" = Rmd,
                  tabledata "Employee Posting Group" = RIMD,
                  tabledata "Exch. Rate Adjmt. Reg." = d,
                  tabledata "Exchange Folder" = D,
                  tabledata "Exchange Service Setup" = RIMD,
                  tabledata "Exp. Phys. Invt. Tracking" = RIMD,
                  tabledata "FA Setup" = Rimd,
                  tabledata "Filed Contract Line" = RmD,
                  tabledata "Fin. Charge Comment Line" = D,
                  tabledata "Finance Charge Interest Rate" = RIMD,
                  tabledata "Finance Charge Memo Header" = D,
                  tabledata "Finance Charge Memo Line" = D,
                  tabledata "Finance Charge Terms" = RIMD,
                  tabledata "Finance Charge Text" = RIMD,
                  tabledata "G/L - Item Ledger Relation" = D,
                  tabledata "G/L Account (Analysis View)" = D,
                  tabledata "G/L Account" = RIMD,
                  tabledata "G/L Account Category" = RIMD,
                  tabledata "G/L Budget Entry" = RIMD,
                  tabledata "G/L Budget Name" = RIMD,
                  tabledata "G/L Entry - VAT Entry Link" = rmd,
                  tabledata "G/L Entry" = Rmd,
                  tabledata "G/L Register" = d,
                  tabledata "Gen. Journal Line" = RIMD,
                  tabledata "Gen. Journal Template" = RIMD,
                  tabledata "General Ledger Setup" = RIMD,
                  tabledata "General Posting Setup" = RIMD,
                  tabledata "Human Resources Setup" = Rimd,
                  tabledata "Inc. Doc. Attachment Overview" = RIMD,
                  tabledata "Incoming Document" = RIMD,
                  tabledata "Incoming Document Approver" = RIMD,
                  tabledata "Incoming Documents Setup" = RIMD,
                  tabledata "Integration Field Mapping" = RIMD,
                  tabledata "Integration Synch. Job" = RIMD,
                  tabledata "Integration Synch. Job Errors" = RIMD,
                  tabledata "Integration Table Mapping" = RIMD,
                  tabledata "Inter. Log Entry Comment Line" = D,
                  tabledata "Interaction Log Entry" = RmD,
                  tabledata "Intermediate Data Import" = RimD,
                  tabledata "Intrastat Setup" = RIMD,
                  tabledata "Inventory Adjmt. Entry (Order)" = d,
                  tabledata "Inventory Comment Line" = D,
                  tabledata "Inventory Page Data" = D,
                  tabledata "Inventory Period" = RIMD,
                  tabledata "Inventory Period Entry" = D,
                  tabledata "Inventory Posting Group" = RIMD,
                  tabledata "Inventory Posting Setup" = RIMD,
                  tabledata "Inventory Profile Track Buffer" = D,
                  tabledata "Inventory Report Entry" = D,
                  tabledata "Inventory Report Header" = D,
                  tabledata "Inventory Setup" = RIMD,
                  tabledata "Issued Fin. Charge Memo Header" = RmD,
                  tabledata "Issued Fin. Charge Memo Line" = d,
                  tabledata "Issued Reminder Header" = RmD,
                  tabledata "Issued Reminder Line" = d,
                  tabledata Item = RIMD,
                  tabledata "Item Analysis View" = RIMD,
                  tabledata "Item Analysis View Budg. Entry" = RIMD,
                  tabledata "Item Analysis View Entry" = RIMD,
                  tabledata "Item Analysis View Filter" = RIMD,
                  tabledata "Item Application Entry History" = D,
                  tabledata "Item Availability by Date" = D,
                  tabledata "Item Availability Line" = D,
                  tabledata "Item Budget Entry" = RIMD,
                  tabledata "Item Budget Name" = RIMD,
                  tabledata "Item Category" = RIMD,
                  tabledata "Item Charge" = RIMD,
                  tabledata "Item Charge Assignment (Purch)" = rD,
                  tabledata "Item Charge Assignment (Sales)" = rD,
                  tabledata "Item Cross Reference" = RIMD,
                  tabledata "Item Discount Group" = RIMD,
                  tabledata "Item Entry Relation" = RIMD,
                  tabledata "Item Journal Line" = RIMD,
                  tabledata "Item Ledger Entry" = Rmd,
                  tabledata "Item Reference" = RIMD,
                  tabledata "Item Register" = d,
                  tabledata "Item Tracing Buffer" = Rimd,
                  tabledata "Item Tracing History Buffer" = Rimd,
                  tabledata "Item Tracking Code" = RIMD,
                  tabledata "Item Tracking Setup" = RIMD,
                  tabledata "Item Translation" = RIMD,
                  tabledata "Item Vendor" = RIMD,
                  tabledata "Job Queue Category" = RIMD,
                  tabledata "Job Queue Log Entry" = RIMD,
                  tabledata "Job WIP Method" = Rimd,
                  tabledata "Jobs Setup" = Rimd,
                  tabledata "License Agreement" = RIMD,
                  tabledata "Line Fee Note on Report Hist." = Rimd,
                  tabledata Location = RIMD,
                  tabledata "Logged Segment" = d,
                  tabledata "Lot No. Information" = RIMD,
                  tabledata Manufacturer = RIMD,
                  tabledata "Marketing Setup" = RImD,
                  tabledata "Memoized Result" = D,
                  tabledata "No. Series" = RIMD,
                  tabledata "No. Series Line" = RIMD,
                  tabledata "No. Series Relationship" = RIMD,
                  tabledata "Nonstock Item" = RIMD,
                  tabledata "Nonstock Item Setup" = RIMD,
                  tabledata "Notification Entry" = RimD,
                  tabledata "O365 Document Sent History" = RmD,
                  tabledata "OCR Service Setup" = RIMD,
                  tabledata "Office Add-in Setup" = RIMD,
                  tabledata "Online Map Parameter Setup" = RIMD,
                  tabledata "Online Map Setup" = RIMD,
                  tabledata Opportunity = RmD,
                  tabledata "Opportunity Entry" = RmD,
                  tabledata "Order Address" = RIMD,
                  tabledata "Order Promising Line" = D,
                  tabledata "Order Promising Setup" = RIMD,
                  tabledata "Order Tracking Entry" = d,
                  tabledata "Package No. Information" = RIMD,
                  tabledata "Payable Employee Ledger Entry" = D,
                  tabledata "Payable Vendor Ledger Entry" = D,
                  tabledata "Payment Application Proposal" = D,
                  tabledata "Payment Matching Details" = D,
                  tabledata "Payment Method" = RIMD,
                  tabledata "Payment Service Setup" = RIMD,
                  tabledata "Payment Terms" = RIMD,
                  tabledata "Phys. Inventory Ledger Entry" = Rmd,
                  tabledata "Phys. Invt. Comment Line" = RIMD,
                  tabledata "Phys. Invt. Count Buffer" = RIMD,
                  tabledata "Phys. Invt. Counting Period" = D,
                  tabledata "Phys. Invt. Item Selection" = D,
                  tabledata "Phys. Invt. Order Header" = RIMD,
                  tabledata "Phys. Invt. Order Line" = RIMD,
                  tabledata "Phys. Invt. Record Header" = RIMD,
                  tabledata "Phys. Invt. Record Line" = RIMD,
                  tabledata "Phys. Invt. Tracking" = RIMD,
                  tabledata "Plan Permission Set" = d,
                  tabledata "Planning Assignment" = D,
                  tabledata "Planning Component" = D,
                  tabledata "Positive Pay Entry" = D,
                  tabledata "Positive Pay Entry Detail" = D,
                  tabledata "Post Code" = RIMD,
                  tabledata "Post Value Entry to G/L" = d,
                  tabledata "Postcode Service Config" = RIMD,
                  tabledata "Posted Payment Recon. Hdr" = D,
                  tabledata "Posted Payment Recon. Line" = D,
                  tabledata "Posted Whse. Receipt Header" = D,
                  tabledata "Posted Whse. Receipt Line" = D,
                  tabledata "Posted Whse. Shipment Header" = D,
                  tabledata "Posted Whse. Shipment Line" = D,
                  tabledata "Price Asset" = RIMD,
                  tabledata "Price Calculation Buffer" = RIMD,
                  tabledata "Price Calculation Setup" = RIMD,
                  tabledata "Price Line Filters" = RIMD,
                  tabledata "Price List Header" = RIMD,
                  tabledata "Price List Line" = RIMD,
                  tabledata "Price Source" = RIMD,
                  tabledata "Price Worksheet Line" = RIMD,
                  tabledata "Profile Questionnaire Line" = RD,
                  tabledata "Pstd. Exp. Phys. Invt. Track" = RIMD,
                  tabledata "Pstd. Phys. Invt. Order Hdr" = RIMD,
                  tabledata "Pstd. Phys. Invt. Order Line" = RIMD,
                  tabledata "Pstd. Phys. Invt. Record Hdr" = RIMD,
                  tabledata "Pstd. Phys. Invt. Record Line" = RIMD,
                  tabledata "Pstd. Phys. Invt. Tracking" = RIMD,
                  tabledata "Purch. Cr. Memo Hdr." = RmD,
                  tabledata "Purch. Cr. Memo Line" = Rmd,
                  tabledata "Purch. Inv. Header" = RmD,
                  tabledata "Purch. Inv. Line" = Rmd,
                  tabledata "Purch. Rcpt. Header" = RmD,
                  tabledata "Purch. Rcpt. Line" = Rmd,
                  tabledata "Purchase Discount Access" = RIMD,
                  tabledata "Purchase Header" = RmD,
                  tabledata "Purchase Header Archive" = RmD,
                  tabledata "Purchase Line" = RmD,
                  tabledata "Purchase Line Archive" = RmD,
                  tabledata "Purchase Line Discount" = RIMD,
                  tabledata "Purchase Prepayment %" = RIMD,
                  tabledata "Purchase Price" = RIMD,
                  tabledata "Purchase Price Access" = RIMD,
                  tabledata "Purchases & Payables Setup" = RIMD,
                  tabledata Purchasing = RIMD,
                  tabledata Rating = D,
                  tabledata "Record Buffer" = Rimd,
                  tabledata "Registered Whse. Activity Hdr." = d,
                  tabledata "Registered Whse. Activity Line" = rmd,
                  tabledata "Reminder Comment Line" = D,
                  tabledata "Reminder Header" = D,
                  tabledata "Reminder Level" = RIMD,
                  tabledata "Reminder Line" = D,
                  tabledata "Reminder Terms" = RIMD,
                  tabledata "Reminder Text" = RIMD,
                  tabledata "Reminder/Fin. Charge Entry" = Rd,
                  tabledata "Req. Wksh. Template" = RIMD,
                  tabledata "Requisition Line" = RmD,
                  tabledata "Requisition Wksh. Name" = RIMD,
                  tabledata "Res. Capacity Entry" = RIMD,
                  tabledata "Res. Journal Line" = rD,
                  tabledata "Reservation Entry" = RimD,
                  tabledata "Resource Cost" = D,
                  tabledata "Resource Price" = D,
                  tabledata "Resource Unit of Measure" = D,
                  tabledata "Resources Setup" = RimD,
                  tabledata "Responsibility Center" = RIMD,
                  tabledata "Restricted Record" = D,
                  tabledata "Return Reason" = RIMD,
                  tabledata "Return Receipt Header" = RmD,
                  tabledata "Return Receipt Line" = Rm,
                  tabledata "Return Shipment Header" = Rmd,
                  tabledata "Return Shipment Line" = Rm,
                  tabledata "Rlshp. Mgt. Comment Line" = rD,
                  tabledata "Rounding Method" = RIMD,
                  tabledata "Sales & Receivables Setup" = RIMD,
                  tabledata "Sales Cr.Memo Header" = RmD,
                  tabledata "Sales Cr.Memo Line" = Rmd,
                  tabledata "Sales Discount Access" = RIMD,
                  tabledata "Sales Header" = RmD,
                  tabledata "Sales Header Archive" = RmD,
                  tabledata "Sales Invoice Header" = RmD,
                  tabledata "Sales Invoice Line" = Rmd,
                  tabledata "Sales Line" = RmD,
                  tabledata "Sales Line Archive" = RmD,
                  tabledata "Sales Line Discount" = RIMD,
                  tabledata "Sales Planning Line" = d,
                  tabledata "Sales Prepayment %" = RIMD,
                  tabledata "Sales Price" = RIMD,
                  tabledata "Sales Price Access" = RIMD,
                  tabledata "Sales Price Worksheet" = RIMD,
                  tabledata "Sales Shipment Header" = RmD,
                  tabledata "Sales Shipment Line" = Rmd,
                  tabledata "Salesperson/Purchaser" = RIMD,
                  tabledata Salutation = D,
                  tabledata "Saved Segment Criteria" = D,
                  tabledata "Saved Segment Criteria Line" = D,
                  tabledata "Segment Criteria Line" = D,
                  tabledata "Segment Header" = D,
                  tabledata "Segment History" = D,
                  tabledata "Segment Interaction Language" = D,
                  tabledata "Segment Line" = D,
                  tabledata "Segment Wizard Filter" = D,
                  tabledata "Sent Notification Entry" = RimD,
                  tabledata "Serial No. Information" = RIMD,
                  tabledata "Service Contract Header" = Rm,
                  tabledata "Service Contract Line" = Rm,
                  tabledata "Service Header" = Rm,
                  tabledata "Service Invoice Line" = Rm,
                  tabledata "Service Item" = Rm,
                  tabledata "Service Item Component" = rm,
                  tabledata "Service Item Line" = Rm,
                  tabledata "Service Ledger Entry" = rm,
                  tabledata "Service Line" = Rm,
                  tabledata "Service Zone" = R,
                  tabledata "Ship-to Address" = RIMD,
                  tabledata "Shipment Method" = RIMD,
                  tabledata "Shipping Agent" = RIMD,
                  tabledata "Shipping Agent Services" = RIMD,
                  tabledata "Social Listening Search Topic" = RIMD,
                  tabledata "Social Listening Setup" = Rimd,
                  tabledata "Source Code" = RIMD,
                  tabledata "Source Code Setup" = RIMD,
                  tabledata "Special Equipment" = RIMD,
                  tabledata "Standard Customer Sales Code" = RIMD,
                  tabledata "Standard General Journal Line" = RIMD,
                  tabledata "Standard Item Journal" = RIMD,
                  tabledata "Standard Item Journal Line" = RIMD,
                  tabledata "Standard Purchase Code" = RIMD,
                  tabledata "Standard Purchase Line" = RIMD,
                  tabledata "Standard Sales Code" = RIMD,
                  tabledata "Standard Sales Line" = RIMD,
                  tabledata "Standard Vendor Purchase Code" = RIMD,
                  tabledata "Stockkeeping Unit" = RIMD,
                  tabledata "Stockkeeping Unit Comment Line" = RIMD,
                  tabledata "Substitution Condition" = RIMD,
                  tabledata "Tariff Number" = RIMD,
                  tabledata "Tax Area" = RIMD,
                  tabledata "Tax Area Line" = RIMD,
                  tabledata "Tax Area Translation" = RIMD,
                  tabledata "Tax Detail" = RIMD,
                  tabledata "Tax Group" = RIMD,
                  tabledata "Tax Jurisdiction" = RIMD,
                  tabledata "Tax Jurisdiction Translation" = RIMD,
                  tabledata Team = D,
                  tabledata "Team Salesperson" = D,
                  tabledata "Temp Integration Field Mapping" = RIMD,
                  tabledata "Tenant Config. Package File" = RIMD,
                  tabledata Territory = RIMD,
                  tabledata "Timeline Event" = D,
                  tabledata "Timeline Event Change" = D,
                  tabledata "To-do" = RmD,
                  tabledata "To-do Interaction Language" = D,
                  tabledata "Tracking Specification" = RimD,
                  tabledata "Transaction Specification" = RIMD,
                  tabledata "Transaction Type" = RIMD,
                  tabledata "Transfer Line" = D,
                  tabledata "Transfer Route" = RIMD,
                  tabledata "Transport Method" = RIMD,
                  tabledata "Untracked Planning Element" = D,
                  tabledata "User Group Member" = RIMD,
                  tabledata "User Group Plan" = d,
                  tabledata "User Security Status" = D,
                  tabledata "User Setup" = RIMD,
                  tabledata "User Task Group" = RIMD,
                  tabledata "User Task Group Member" = RIMD,
                  tabledata "User Time Register" = RIMD,
                  tabledata "Value Entry" = Rmd,
                  tabledata "Value Entry Relation" = RIMD,
                  tabledata "VAT Amount Line" = RIMD,
                  tabledata "VAT Assisted Setup Bus. Grp." = RIMD,
                  tabledata "VAT Assisted Setup Templates" = RIMD,
                  tabledata "VAT Business Posting Group" = RIMD,
                  tabledata "VAT Clause" = RIMD,
                  tabledata "VAT Clause by Doc. Type" = RIMD,
                  tabledata "VAT Clause by Doc. Type Trans." = RIMD,
                  tabledata "VAT Clause Translation" = RIMD,
                  tabledata "VAT Entry" = Rmd,
                  tabledata "VAT Posting Setup" = RIMD,
                  tabledata "VAT Product Posting Group" = RIMD,
                  tabledata "VAT Rate Change Conversion" = RIMD,
                  tabledata "VAT Rate Change Log Entry" = Rid,
                  tabledata "VAT Rate Change Setup" = RIMD,
                  tabledata "VAT Reg. No. Srv Config" = RIMD,
                  tabledata "VAT Reg. No. Srv. Template" = RIMD,
                  tabledata "VAT Registration Log Details" = RIMD,
                  tabledata "VAT Registration No. Format" = RIMD,
                  tabledata "VAT Report Error Log" = RIMD,
                  tabledata "VAT Report Header" = RIMD,
                  tabledata "VAT Report Line" = RIMD,
                  tabledata "VAT Report Line Relation" = RIMD,
                  tabledata "VAT Report Setup" = RIMD,
                  tabledata "VAT Return Period" = RIMD,
                  tabledata "VAT Setup Posting Groups" = RIMD,
                  tabledata "VAT Statement Line" = RIMD,
                  tabledata "VAT Statement Name" = RIMD,
                  tabledata "VAT Statement Template" = RIMD,
                  tabledata Vendor = RIMD,
                  tabledata "Vendor Bank Account" = RIMD,
                  tabledata "Vendor Invoice Disc." = RIMD,
                  tabledata "Vendor Ledger Entry" = RMd,
                  tabledata "Vendor Posting Group" = RIMD,
                  tabledata "Warehouse Activity Header" = rmD,
                  tabledata "Warehouse Activity Line" = rmD,
                  tabledata "Warehouse Comment Line" = D,
                  tabledata "Warehouse Register" = D,
                  tabledata "Warehouse Request" = rmD,
                  tabledata "Warehouse Setup" = RID,
                  tabledata "Warehouse Shipment Line" = rmD,
                  tabledata "Warehouse Source Filter" = D,
                  tabledata "Warranty Ledger Entry" = Rmd,
                  tabledata "Web Source" = D,
                  tabledata "Whse. Item Entry Relation" = RIMD,
                  tabledata "Whse. Pick Request" = D,
                  tabledata "Whse. Put-away Request" = D,
                  tabledata "Whse. Worksheet Line" = rD,
                  tabledata "Work Center" = rD,
                  tabledata "Work Type" = D,
                  tabledata "Workflow - Table Relation" = RIMD,
                  tabledata Workflow = RIMD,
                  tabledata "Workflow Event" = RIMD,
                  tabledata "Workflow Event Queue" = RIMD,
                  tabledata "Workflow Response" = RIMD,
                  tabledata "Workflow Rule" = RIMD,
                  tabledata "Workflow Step" = RIMD,
                  tabledata "Workflow Step Argument" = RIMD,
                  tabledata "Workflow Step Instance" = RimD,
                  tabledata "Workflow Table Relation Value" = RimD,
                  tabledata "Workflow User Group" = RIMD,
                  tabledata "Workflow User Group Member" = RIMD,
                  tabledata "Report Settings Override" = Rimd;
}
