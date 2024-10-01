table 1007 "Job WIP Warning"
{
    Caption = 'Job WIP Warning';
    DrillDownPageID = "Job WIP Warnings";
    LookupPageID = "Job WIP Warnings";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
        }
        field(2; "Job No."; Code[20])
        {
            Caption = 'Job No.';
            TableRelation = Job;
        }
        field(3; "Job Task No."; Code[20])
        {
            Caption = 'Job Task No.';
            TableRelation = "Job Task"."Job Task No.";
        }
        field(4; "Job WIP Total Entry No."; Integer)
        {
            Caption = 'Job WIP Total Entry No.';
            Editable = false;
            TableRelation = "Job WIP Total";
        }
        field(5; "Warning Message"; Text[250])
        {
            Caption = 'Warning Message';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Job No.", "Job Task No.")
        {
        }
        key(Key3; "Job WIP Total Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label '%1 is 0.';
        Text002: Label 'Cost completion is greater than 100%.';
        Text003: Label '%1 is negative.';

    procedure CreateEntries(JobWIPTotal: Record "Job WIP Total")
    var
        Job: Record Job;
    begin
        Job.Get(JobWIPTotal."Job No.");
        if not Job.Complete then begin
            if JobWIPTotal."Contract (Total Price)" = 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text001, JobWIPTotal.FieldCaption("Contract (Total Price)")));

            if JobWIPTotal."Schedule (Total Cost)" = 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text001, JobWIPTotal.FieldCaption("Schedule (Total Cost)")));

            if JobWIPTotal."Schedule (Total Price)" = 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text001, JobWIPTotal.FieldCaption("Schedule (Total Price)")));

            if JobWIPTotal."Usage (Total Cost)" > JobWIPTotal."Schedule (Total Cost)" then
                InsertWarning(JobWIPTotal, Text002);

            if JobWIPTotal."Calc. Recog. Sales Amount" < 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text003, JobWIPTotal.FieldCaption("Calc. Recog. Sales Amount")));

            if JobWIPTotal."Calc. Recog. Costs Amount" < 0 then
                InsertWarning(JobWIPTotal, StrSubstNo(Text003, JobWIPTotal.FieldCaption("Calc. Recog. Costs Amount")));
        end;
    end;

    procedure DeleteEntries(JobWIPTotal: Record "Job WIP Total")
    begin
        SetRange("Job WIP Total Entry No.", JobWIPTotal."Entry No.");
        if not IsEmpty() then
            DeleteAll(true);
    end;

    local procedure InsertWarning(JobWIPTotal: Record "Job WIP Total"; Message: Text[250])
    begin
        Reset;
        if FindLast then
            "Entry No." += 1
        else
            "Entry No." := 1;
        "Job WIP Total Entry No." := JobWIPTotal."Entry No.";
        "Job No." := JobWIPTotal."Job No.";
        "Job Task No." := JobWIPTotal."Job Task No.";
        "Warning Message" := Message;
        Insert;
    end;
}

