// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.TimeSheet;

pageextension 6486 "Serv. Timesheet Lines" extends "Time Sheet Lines"
{
    layout
    {
        addafter("Work Type Code")
        {
            field("Service Order No."; Rec."Service Order No.")
            {
                ApplicationArea = Jobs;
                ToolTip = 'Specifies the service order number that is associated with the time sheet line.';
                Visible = ServiceOrderNoVisible;
            }
        }
    }
}