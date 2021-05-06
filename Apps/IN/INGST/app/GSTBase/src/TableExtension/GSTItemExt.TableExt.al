tableextension 18008 "GST Item Ext." extends Item
{
    fields
    {
        field(18000; "GST Group Code"; code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
        field(18001; "HSN/SAC Code"; code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(18002; "GST Credit"; enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(18003; Exempted; boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18004; "Price Exclusive of Tax"; boolean)
        {
            Caption = 'Price Exclusive of Tax';
            DataClassification = CustomerContent;
        }
        field(18005; Subcontracting; Boolean)
        {
            Caption = 'Subcontracting';
            DataClassification = CustomerContent;
        }
        field(18006; "Sub. Comp. Location"; Code[10])
        {
            Caption = 'Sub. Comp. Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Subcontracting Location" = const(false));
        }
    }
}