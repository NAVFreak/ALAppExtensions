pageextension 18900 "Bank Payment Voucher" extends "Bank Payment Voucher"
{
    layout
    {
        addbefore(Amount)
        {
            field("TCS Nature of Collection"; Rec."TCS Nature Of Collection")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the TCS Nature of collection on which the TCS will be calculated for the journal line.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    Rec.AllowedNOCLookup(Rec, Rec."Account No.");
                    UpdateTaxAmount();
                end;

                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
            field("T.C.A.N. No."; Rec."T.C.A.N. No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the T.C.A.N. number of the person who is responsible for collecting tax.';
                trigger OnValidate()
                begin
                    UpdateTaxAmount();
                end;
            }
        }
        modify(Amount)
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Credit Amount")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Debit Amount")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Amount (LCY)")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
        modify("Document Type")
        {
            trigger OnAfterValidate()
            begin
                UpdateTaxAmount();
            end;
        }
    }
    actions
    {
        addfirst(navigation)
        {
            group("Tax payments")
            {
                action(TCS)
                {
                    Caption = 'TCS';
                    ApplicationArea = Basic, Suite;
                    Image = CollectedTax;
                    ToolTip = 'Select TCS to open Pay TCS page that will show all TCS entries.';
                    trigger OnAction()
                    var
                        PayTCS: Codeunit "Pay-TCS";
                    begin
                        PayTCS.PayTCS(Rec);
                    end;
                }
            }
        }
    }
    procedure UpdateTaxAmount()
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CurrPage.SaveRecord();
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;
}