permissionset 8992 "D365 WHSE, EDIT"
{
    Assignable = true;

    Caption = 'Dynamics 365 Create warehouse';
    Permissions = tabledata "Bin Content" = RIMD,
                  tabledata "Bin Content Buffer" = RIMD,
                  tabledata "Bin Creation Wksh. Name" = RIMD,
                  tabledata "Bin Creation Wksh. Template" = RIMD,
                  tabledata "Bin Creation Worksheet Line" = RIMD,
                  tabledata "Bin Template" = RIMD,
                  tabledata "Bin Type" = RIMD,
                  tabledata "Posted Invt. Pick Header" = RIMD,
                  tabledata "Posted Invt. Pick Line" = RIMD,
                  tabledata "Posted Invt. Put-away Header" = RIMD,
                  tabledata "Posted Invt. Put-away Line" = RIMD,
                  tabledata "Posted Whse. Receipt Header" = RIMD,
                  tabledata "Posted Whse. Receipt Line" = RIMD,
                  tabledata "Posted Whse. Shipment Header" = RIMD,
                  tabledata "Posted Whse. Shipment Line" = RIMD,
                  tabledata "Put-away Template Header" = RIMD,
                  tabledata "Put-away Template Line" = RIMD,
                  tabledata "Registered Whse. Activity Hdr." = Rimd,
                  tabledata "Registered Whse. Activity Line" = Rimd,
                  tabledata "Special Equipment" = RIMD,
                  tabledata "Warehouse Activity Header" = RIMD,
                  tabledata "Warehouse Activity Line" = RIMD,
                  tabledata "Warehouse Class" = RIMD,
                  tabledata "Warehouse Employee" = RIMD,
                  tabledata "Warehouse Entry" = Rimd,
                  tabledata "Warehouse Journal Batch" = RIMD,
                  tabledata "Warehouse Journal Line" = RIMD,
                  tabledata "Warehouse Journal Template" = RIMD,
                  tabledata "Warehouse Receipt Header" = RIMD,
                  tabledata "Warehouse Receipt Line" = RIMD,
                  tabledata "Warehouse Register" = RIMD,
                  tabledata "Warehouse Request" = RIMD,
                  tabledata "Warehouse Setup" = RIMD,
                  tabledata "Warehouse Shipment Header" = RIMD,
                  tabledata "Warehouse Shipment Line" = RIMD,
                  tabledata "Warehouse Source Filter" = RIMD,
                  tabledata "Whse. Cross-Dock Opportunity" = RIMD,
                  tabledata "Whse. Internal Pick Header" = RIMD,
                  tabledata "Whse. Internal Pick Line" = RIMD,
                  tabledata "Whse. Internal Put-away Header" = RIMD,
                  tabledata "Whse. Internal Put-away Line" = RIMD,
                  tabledata "Whse. Item Entry Relation" = RIMD,
                  tabledata "Whse. Pick Request" = RIMD,
                  tabledata "Whse. Put-away Request" = RIMD,
                  tabledata "Whse. Worksheet Line" = RIMD,
                  tabledata "Whse. Worksheet Name" = RIMD,
                  tabledata "Whse. Worksheet Template" = RIMD,
                  tabledata Zone = RIMD;
}
