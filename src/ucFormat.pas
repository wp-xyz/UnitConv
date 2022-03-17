unit ucFormat;

interface

uses
  SysUtils,Classes, Graphics, Controls, Dialogs,
  StdCtrls, ExtCtrls, Forms, Buttons, Spin;

type
  
  { TFormatDlg }

  TFormatDlg = class(TForm)
    lblDecimalSeparator: TLabel;
    lblTousandsSeparator: TLabel;
    edDecimals: TSpinEdit;
    lblDecimals: TLabel;
    cbDecimalSeparator: TComboBox;
    cbThousandSeparator: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    rbFormatAuto: TRadioButton;
    rbFormatExp: TRadioButton;
    rbFormatFixed: TRadioButton;
    rgFormats: TGroupBox;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbFormatAutoClick(Sender: TObject);
    procedure rbFormatExpClick(Sender: TObject);
    procedure rbFormatFixedClick(Sender: TObject);
  private
    function Validate(out AErrMsg: String; out AControl: TWinControl): Boolean;
  end;

var
  FormatDlg: TFormatDlg;

implementation

uses
  ucGlobal;

{$R *.lfm}

procedure TFormatDlg.btnOKClick(Sender: TObject);
var
  msg: String;
  C: TWinControl;
begin
  if not Validate(msg, C) then
  begin
    C.SetFocus;
    MessageDlg(msg, mtError, [mbOK], 0);
    ModalResult := mrNone;
    exit;
  end;

  if rbFormatAuto.Checked then
    fmtFloat := fmtStandard
  else if rbFormatExp.Checked then
    fmtFloat := fmtExp
  else if rbFormatFixed.Checked then
    fmtFloat := fmtFixed;

  fmtDecimals := edDecimals.Value;

  UpdateFormatSettings(
    TDecimalSep(cbDecimalSeparator.ItemIndex),
    TThousandSep(cbThousandSeparator.ItemIndex)
  );
end;

procedure TFormatDlg.FormShow(Sender: TObject);
begin
  Case fmtFloat of
    fmtStandard : rbFormatAuto.Checked := true;
    fmtExp      : rbFormatExp.Checked := true;
    fmtFixed    : rbFormatFixed.Checked := true;
  end;
  edDecimals.Value := fmtDecimals;
  cbDecimalSeparator.ItemIndex := ord(GetDecimalSep);
  cbThousandSeparator.ItemIndex := ord(GetThousandSep);
end;

procedure TFormatDlg.rbFormatAutoClick(Sender: TObject);
begin
  If rbFormatAuto.Checked Then begin
    edDecimals.Enabled := False;
    lblDecimals.Enabled := False;
    edDecimals.Color := clBtnFace;
  End;
end;

procedure TFormatDlg.rbFormatExpClick(Sender: TObject);
begin
  If rbFormatExp.Checked Then begin
    edDecimals.Enabled := True;
    lblDecimals.Enabled := True;
    edDecimals.Color := clWindow;
  End;
end;

procedure TFormatDlg.rbFormatFixedClick(Sender: TObject);
begin
  If rbFormatFixed.Checked Then begin
    edDecimals.Enabled := True;
    lblDecimals.Enabled := True;
    edDecimals.Color := clWindow;
  End;
end;

function TFormatDlg.Validate(out AErrMsg: String; out AControl: TWinControl): Boolean;
begin
  Result := false;
  if cbThousandSeparator.Text = cbDecimalSeparator.Text then
  begin
    AErrMsg := 'Decimal separator and thousand separator must be different.';
    AControl := cbDecimalSeparator;
    exit;
  end;
  Result := true;
end;

end.
