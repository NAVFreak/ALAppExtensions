namespace Microsoft.DataMigration;

table 4005 "Hybrid Company"
{
    DataPerCompany = false;
    ReplicateData = false;

    // We must prohibit extending this table since it is not populated by the application.
    Extensible = false;

    fields
    {
        field(1; "Name"; Text[50])
        {
            Description = 'The SQL-friendly name of a company';
            DataClassification = SystemMetadata;
        }
        field(2; "Display Name"; Text[250])
        {
            Description = 'The display name for the company';
            DataClassification = SystemMetadata;
        }
        field(3; "Replicate"; Boolean)
        {
            Description = 'Indicates whether to replicate the company data';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if not Rec.IsTemporary() then
                    ShowWarningForTooManyCompanies();
            end;
        }
        field(4; "Estimated Size"; Decimal)
        {
            Description = 'The size in GB of the company data to be migrated';
            DataClassification = SystemMetadata;
        }

        field(20; "Company Initialization Status"; Option)
        {
            Description = 'Shows if the Company was initialized';
            OptionMembers = Unknown,"Not Initialized","Initialization Failed",Initialized;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if ("Company Initialization Status" = "Company Initialization Status"::"Initialization Failed") then
                    exit;

                Clear("Company Initialization Failure");
                Clear("Company Initialization Task");
            end;
        }

        field(21; "Company Initialization Failure"; Blob)
        {
            Description = 'Shows the error message from the latest failure.';
            DataClassification = SystemMetadata;
        }

        field(22; "Company Initialization Task"; Guid)
        {
            Description = 'ID of the task used to initialize the company.';
            DataClassification = SystemMetadata;
        }

        field(30; Replicated; Boolean)
        {
            Description = 'Indicates if the company was replicated';
            FieldClass = FlowField;
            CalcFormula = exist("Hybrid Replication Detail" where("Company Name" = field(Name), Status = Const(2)));
        }
    }

    keys
    {
        key(PK; "Name")
        {
            Clustered = true;
        }
    }

    procedure SetSelected(SelectAll: Boolean)
    begin
        ModifyAll(Replicate, SelectAll);
    end;

    procedure GetTotalMigrationSize(): Decimal
    var
        DataToMigrate: Decimal;
    begin
        Reset();
        SetRange(Replicate, true);

        if FindSet() then
            repeat
                DataToMigrate += Rec."Estimated Size";
            until Rec.Next() = 0;

        exit(DataToMigrate);
    end;

    procedure GetTotalOnPremSize(): Decimal
    var
        DataToMigrate: Decimal;
    begin
        Reset();

        if FindSet() then
            repeat
                DataToMigrate += Rec."Estimated Size";
            until Rec.Next() = 0;

        exit(DataToMigrate);
    end;

    procedure GetCompanyInitFailureMessage(): Text;
    var
        MessageInStream: InStream;
        CompanyInitFailureMessage: Text;
    begin
        CompanyInitFailureMessage := '';
        CalcFields("Company Initialization Failure");
        if "Company Initialization Failure".HasValue() then begin
            "Company Initialization Failure".CREATEINSTREAM(MessageInStream);
            MessageInStream.Read(CompanyInitFailureMessage);
        end;

        exit(CompanyInitFailureMessage);
    end;

    procedure SetCompanyInitFailureMessage(CompanyInitFailureMessage: Text);
    var
        FailureMessageOutStream: OutStream;
    begin
        "Company Initialization Failure".CreateOutStream(FailureMessageOutStream);
        FailureMessageOutStream.Write(CompanyInitFailureMessage);
        Modify();
    end;

    procedure GetRecommendedNumberOfCompaniesToReplicateInBatch(): Integer
    begin
        exit(300);
    end;

    local procedure ShowWarningForTooManyCompanies()
    var
        SelectedForMigrationHybridCompany: Record "Hybrid Company";
    begin
        if WarningShown then
            exit;

        if not Replicate then
            exit;

        if not GuiAllowed() then
            exit;

        SelectedForMigrationHybridCompany.SetRange(Replicate, true);
        if SelectedForMigrationHybridCompany.Count() < GetRecommendedNumberOfCompaniesToReplicateInBatch() then
            exit;

        WarningShown := true;
        if not Confirm(MovingTooManyCompaniesQst) then
            Replicate := false;
    end;

    var
        WarningShown: Boolean;
        MovingTooManyCompaniesQst: Label 'You''ve selected many companies to move in the batch. This may lead to an error because of the large amount of metadata when you attempt to replicate the data. If this occurs, we recommend you return to this page and select fewer companies to move in a batch.\\Do you want to continue?';
}