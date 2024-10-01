﻿page 5903 "Service Item Lines"
{
    Caption = 'Service Item Lines';
    DataCaptionFields = "Document Type", "Document No.", "Fault Reason Code";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Service Item Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies whether the service document is a service order or service quote.';
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the service order linked to this service item line.';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the line.';
                }
                field("Service Item Group Code"; "Service Item Group Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the code of the service item group for this item.';
                }
                field("Service Item No."; "Service Item No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the service item number registered in the Service Item table.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies a description of this service item.';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the item number linked to this service item.';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the serial number of this item.';
                }
                field(Warranty; Warranty)
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies that warranty on either parts or labor exists for this item.';
                }
                field("Contract No."; "Contract No.")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the number of the service contract associated with the item or service on the line.';
                }
                field("Fault Reason Code"; "Fault Reason Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the fault reason code for the item.';
                }
                field("Fault Area Code"; "Fault Area Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the fault area code for this item.';
                }
                field("Symptom Code"; "Symptom Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the symptom code for this item.';
                }
                field("Resolution Code"; "Resolution Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the resolution code for this item.';
                }
                field("Fault Code"; "Fault Code")
                {
                    ApplicationArea = Service;
                    ToolTip = 'Specifies the fault code for this item.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Worksheet")
            {
                Caption = '&Worksheet';
                Image = Worksheet;
                group("Com&ments")
                {
                    Caption = 'Com&ments';
                    Image = ViewComments;
                    action(Faults)
                    {
                        ApplicationArea = Service;
                        Caption = 'Faults';
                        Image = Error;
                        RunObject = Page "Service Comment Sheet";
                        RunPageLink = "Table Name" = CONST("Service Header"),
                                      "Table Subtype" = FIELD("Document Type"),
                                      "No." = FIELD("Document No."),
                                      "Table Line No." = FIELD("Line No."),
                                      Type = CONST(Fault);
                        ToolTip = 'View or edit the different fault codes that you can assign to service items. You can use fault codes to identify the different service item faults or the actions taken on service items for each combination of fault area and symptom codes.';
                    }
                    action(Resolutions)
                    {
                        ApplicationArea = Service;
                        Caption = 'Resolutions';
                        Image = Completed;
                        RunObject = Page "Service Comment Sheet";
                        RunPageLink = "Table Name" = CONST("Service Header"),
                                      "Table Subtype" = FIELD("Document Type"),
                                      "No." = FIELD("Document No."),
                                      "Table Line No." = FIELD("Line No."),
                                      Type = CONST(Resolution);
                        ToolTip = 'View or edit the different resolution codes that you can assign to service items. You can use resolution codes to identify methods used to solve typical service problems.';
                    }
                    action(Internal)
                    {
                        ApplicationArea = Service;
                        Caption = 'Internal';
                        Image = Comment;
                        RunObject = Page "Service Comment Sheet";
                        RunPageLink = "Table Name" = CONST("Service Header"),
                                      "Table Subtype" = FIELD("Document Type"),
                                      "No." = FIELD("Document No."),
                                      "Table Line No." = FIELD("Line No."),
                                      Type = CONST(Internal);
                        ToolTip = 'View or reregister internal comments for the service item. Internal comments are for internal use only and are not printed on reports.';
                    }
                    action(Accessories)
                    {
                        ApplicationArea = Service;
                        Caption = 'Accessories';
                        Image = ServiceAccessories;
                        RunObject = Page "Service Comment Sheet";
                        RunPageLink = "Table Name" = CONST("Service Header"),
                                      "Table Subtype" = FIELD("Document Type"),
                                      "No." = FIELD("Document No."),
                                      "Table Line No." = FIELD("Line No."),
                                      Type = CONST(Accessory);
                        ToolTip = 'View or register comments for the accessories to the service item.';
                    }
                    action(Loaners)
                    {
                        ApplicationArea = Service;
                        Caption = 'Loaners';
                        Image = Loaners;
                        RunObject = Page "Service Comment Sheet";
                        RunPageLink = "Table Name" = CONST("Service Header"),
                                      "Table Subtype" = FIELD("Document Type"),
                                      "No." = FIELD("Document No."),
                                      "Table Line No." = FIELD("Line No."),
                                      Type = CONST("Service Item Loaner");
                        ToolTip = 'View or select from items that you lend out temporarily to customers to replace items that they have in service.';
                    }
                }
                group("Service &Item")
                {
                    Caption = 'Service &Item';
                    Image = ServiceItem;
                    action(Card)
                    {
                        ApplicationArea = Service;
                        Caption = 'Card';
                        Image = EditLines;
                        RunObject = Page "Service Item Card";
                        RunPageLink = "No." = FIELD("Service Item No.");
                        ToolTip = 'View or change detailed information about the record on the document or journal line.';
                    }
                    action("&Log")
                    {
                        ApplicationArea = Service;
                        Caption = '&Log';
                        Image = Approve;
                        RunObject = Page "Service Item Log";
                        RunPageLink = "Service Item No." = FIELD("Service Item No.");
                        ToolTip = 'View a list of the service item changes that have been logged, for example, when the warranty has changed or a component has been added. This window displays the field that was changed, the old value and the new value, and the date and time that the field was changed.';
                    }
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Service Item Worksheet")
                {
                    ApplicationArea = Service;
                    Caption = 'Service Item Worksheet';
                    Image = ServiceItemWorksheet;
                    RunObject = Page "Service Item Worksheet";
                    RunPageLink = "Document Type" = FIELD("Document Type"),
                                  "Document No." = FIELD("Document No."),
                                  "Line No." = FIELD("Line No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or edit a worksheet where you record information about service items, such as repair status, fault comments and codes, and cost. In this window, you can update information on the items such as repair status and fault and resolution codes. You can also enter new service lines for resource hours, for the use of spare parts and for specific service costs.';
                }
            }
        }
    }
}

