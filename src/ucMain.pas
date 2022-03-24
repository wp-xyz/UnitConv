unit ucMain;

{$mode Delphi}

interface

uses
  LCLIntf, LCLType,
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ImgList, ExtCtrls,
  ucGlobal, ucFormat;

type
  
  { TMainForm }

  TMainForm = class(TForm)
    btnCopy: TSpeedButton;
    btnPaste: TSpeedButton;
    edSource: TEdit;
    edResult: TEdit;
    cbSourceUnits: TComboBox;
    cbResultUnits: TComboBox;
    Images: TImageList;
    HeaderLabel: TLabel;
    lblCorresponds: TLabel;
    btnExit: TBitBtn;
    btnAbout: TBitBtn;
    btnFormat: TBitBtn;
    lvDatatypes: TListView;
    HeaderPanel: TPanel;
    HeaderImage: TImage;
    PanelControls: TPanel;
    PanelLeft: TPanel;
    PanelRight: TPanel;
    Splitter1: TSplitter;
    btnFlip: TBitBtn;
    PanelBottom: TPanel;
    btnLargeIcons: TSpeedButton;
    btnSmallIcons: TSpeedButton;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure cbSourceUnitsChange(Sender: TObject);
    procedure cbResultUnitsChange(Sender: TObject);
    procedure edSourceChange(Sender: TObject);
//    procedure lbDataTypesClick(Sender: TObject);
    procedure btnFlipClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure btnFormatClick(Sender: TObject);
    procedure lvDatatypesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure PanelControlsResize(Sender: TObject);
    procedure btnIconStyleClicked(Sender: TObject);
  private
    { Private-Deklarationen }
    OldFlipWidth : integer;
    Procedure Calculate;
    Procedure FillCombo(ACombo:TCustomCombobox);
    Procedure PickItem(item:TListItem);
    Function  FormatFloatToWidth(x: Double; AWidth: Integer) : String;
    Function  FormatFloat(x:Double) : String;
    function  CalcIniName: String;
    Procedure ReadIni;
    Procedure WriteIni;
  protected
    procedure Loaded; override;
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  Clipbrd, IniFiles, TypInfo, Math,
  ucAbout;

const
  SMALL_LARGE: array[boolean] of string = ('small', 'large');
  
procedure TMainForm.btnAboutClick(Sender: TObject);
var
  F: TAboutBox;
begin
  F := TAboutBox.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

procedure TMainForm.btnCopyClick(Sender: TObject);
var
  s : string;
  i : integer;
begin
  s := '';
  for i:=1 to Length(EdResult.Text) do
    if EdResult.Text[i] <> FormatSettings.ThousandSeparator then
      s := s + EdResult.Text[i];
  Clipboard.AsText := s;
end;


procedure TMainForm.btnExitClick(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.btnIconStyleClicked(Sender: TObject);
begin
  if Sender = BtnLargeIcons then
    LvDataTypes.ViewStyle := vsIcon
  else
  if Sender = BtnSmallIcons then
  begin
    LvDataTypes.ViewStyle := vsReport;
    LvDataTypes.Columns[0].AutoSize := true;
  end;
end;


procedure TMainForm.btnFlipClick(Sender: TObject);
var
  tmp : Integer;
begin
  tmp := cbSourceUnits.ItemIndex;
  cbSourceUnits.ItemIndex := cbResultUnits.ItemIndex;
  cbResultUnits.ItemIndex := tmp;
  Calculate;
end;


procedure TMainForm.btnFormatClick(Sender: TObject);
var
  F: TFormatDlg;
begin
  F := TFormatDlg.Create(nil);
  try
    if F.ShowModal = mrOK then
      Calculate;
  finally
    F.Free;
  end;
end;

procedure TMainForm.btnPasteClick(Sender: TObject);
var
  s: string;
  x: Double;
begin
  s := Clipboard.AsText;
  if TryStrToFloat(s, x) then
    edSource.Text := s
  else
    MessageDlg('The clipboard does not contain a valid number..', mtError,
      [mbOK], 0);
end;


function TMainForm.CalcIniName : String;
begin
  Result := ChangeFileExt(Application.ExeName, '.ini');
end;


procedure TMainForm.Calculate;
var
  dt  : integer;
  src : integer;
  dst : integer;
  x, y: double;
  res : double;
begin
  if edSource.Text = '' then exit;

  dt := LvDataTypes.Selected.Index;
  src := cbSourceUnits.ItemIndex;
  dst := cbResultUnits.ItemIndex;

  if TryStrToFloat(EdSource.Text, y) then
  begin
    DataItems[dt].Value := y;
    DataItems[dt].Source := src;
    DataItems[dt].Dest := dst;
    with DataItems[dt].Units[src] do
      x := ConvertUnitFrom(y, A,B,C,D);
    if IsNaN(x) then
    begin
      edResult.Text := '(division by zero)';
      exit;
    end;
    with DataItems[dt].Units[dst] do
      res := ConvertUnitTo(x, A,B,C,D);
    if IsNaN(res) then
    begin
      edResult.Text := '(division by zero)';
      exit;
    end;
    edResult.Text := FormatFloat(res);
  end else
    MessageDlg('Invalid number entered.', mtError, [mbOK], 0);
end;


procedure TMainForm.cbResultUnitsChange(Sender: TObject);
begin
  cbSourceUnitsChange(Sender);
end;


procedure TMainForm.cbSourceUnitsChange(Sender: TObject);
begin
  btnFlip.Enabled := cbSourceUnits.ItemIndex <> cbResultUnits.ItemIndex;
  Calculate;
end;


procedure TMainForm.edSourceChange(Sender: TObject);
var
  x: Double;
begin
  if TryStrToFloat(edSource.Text, x) then
  begin
    if (Abs(x)=1) or (x=0) then
      lblCorresponds.Caption := 'corresponds to'
    else
      lblCorresponds.Caption := 'correspond to ';

    Calculate;
  end;
end;


procedure TMainForm.FillCombo(ACombo:TCustomComboBox);
var
  dt  : Integer;
  i   : Integer;
begin
  dt := LvDataTypes.ItemIndex;

  ACombo.Items.BeginUpdate;
  try
    ACombo.Items.Clear;
    for i:= Low(DataItems[dt].Units) To High(DataItems[dt].Units) Do begin
      ACombo.Items.Add(DataItems[dt].Units[i].Name);
    end;

    if ACombo = cbResultUnits then
      ACombo.ItemIndex := DataItems[dt].Dest
    else
      ACombo.ItemIndex := DataItems[dt].Source;
  finally
    ACombo.Items.EndUpdate;
  end;
end;


function TMainForm.FormatFloat(x:Double): String;
var
  fmt: String;
begin
  fmt := BuildFormatStr(fmtFloat, fmtDecimals);
  if fmt = '' then
    Result := FormatFloatToWidth(x, edResult.Width)
  else
    Result := SysUtils.Format(fmt, [x]);
end;


function TMainForm.FormatFloatToWidth(x: Double; AWidth: Integer): string;
var
  s: String;
  p: Integer;
  d: Integer;
  ws: Integer;
begin
  AWidth := AWidth - Canvas.TextWidth('M');
  p := 18;
  d := 10;
  repeat
    s := FloatToStrF(x, ffNumber, p, d);
    if d > 0 then begin
      while s[Length(s)]='0' do
        Delete(s, Length(s), 1);
      if s[Length(s)] = FormatSettings.DecimalSeparator then
        Delete(s, Length(s), 1);
    end;
    ws := Canvas.TextWidth(s);
    Dec(d);
  until (ws <= AWidth) or (d = 0);
  if (d = 0) or
    ((x <> 0.0) and (StrToFloat(FloatToStrF(x, ffFixed, p, d)) = 0.0))
  then begin
    p := 18;
    repeat
      s := FloatToStrF(x, ffExponent, p, 2);
      ws := Canvas.TextWidth(s);
      Dec(p);
    until (ws <= AWidth) or (p=0);
    p := Length(s);
    while (s[p]<>'E') do Dec(p);
    Dec(p);
    while (s[p] <> FormatSettings.DecimalSeparator) and (s[p] = '0') do begin
      Delete(s, p, 1);
      Dec(p);
    end;
    if s[p] = FormatSettings.DecimalSeparator then
      Insert('0', s, p+1);
  end;
  Result := s;
end;


procedure TMainForm.FormActivate(Sender: TObject);
begin
  Constraints.MinHeight := PanelRight.Top + PanelControls.Top + PanelControls.Height + PanelBottom.Height; //BtnExit.Height + BtnExit.BorderSpacing.Bottom*2;
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteIni;
end;


procedure TMainForm.FormCreate(Sender: TObject);
Var
  i : Integer;
begin
  lvDataTypes.LargeImages := Images;
  lvDataTypes.SmallImages := Images;
  lvDataTypes.LargeImagesWidth := 32;
  lvDataTypes.SmallImagesWidth := 16;
  
  // Avoid flicker of some controls
  //lvDataTypes.ControlStyle := lvDataTypes.ControlStyle + [csParentBackground];  // no transparent icon background
  btnLargeIcons.ControlStyle := btnLargeIcons.ControlStyle + [csParentBackground];
  btnSmallIcons.ControlStyle := btnSmallIcons.ControlStyle + [csParentBackground];

  CreateItems;
  for i:=Low(DataItems) to High(DataItems) do
    with LvDatatypes.Items.Add do begin
      Caption := DataItems[i].Name;
      ImageIndex := DataItems[i].ImageIndex;
    end;
  LvDataTypes.Selected := LvDataTypes.Items[0];

  ReadIni;

  lvDataTypes.Columns[0].Width := lvDataTypes.ClientWidth - GetSystemMetrics(SM_CXVSCROLL); 

  PickItem(lvDataTypes.Items[0]);

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DestroyItems;
end;


procedure TMainForm.Loaded;
begin
  inherited;
  OldFlipWidth := BtnFlip.Width;
end;


procedure TMainForm.lvDatatypesSelectItem(Sender: TObject; Item:TListItem;
  Selected: Boolean);
begin
  if Selected then PickItem(Item);
end;


procedure TMainForm.PanelControlsResize(Sender: TObject);
begin
  with PanelControls do begin
    EdSource.Width := (ClientWidth - EdSource.Left - cbSourceUnits.BorderSpacing.Right * 2) div 2;
    CbSourceUnits.Width := EdSource.Width;
  end;

  Calculate;
end;


procedure TMainForm.PickItem(item:TListItem);
var
  bmp : TBitmap;
  dataItem: TDataItem;
begin
  dataItem := DataItems[item.Index];

  if item <> LvDataTypes.Selected then
    LvDataTypes.Selected := item;

  FillCombo(cbSourceUnits);
  cbSourceUnits.ItemIndex := dataItem.Source;

  FillCombo(cbResultUnits);
  cbResultUnits.ItemIndex := dataitem.Dest;

  EdSource.Text := FormatFloat(dataItem.Value);

  HeaderLabel.Caption := dataItem.Name;

  bmp := TBitmap.Create;
  try
    Images.Resolution[HeaderImage.Width].GetBitmap(dataItem.ImageIndex, bmp);
    HeaderImage.Picture.Assign(bmp);
  finally
    bmp.Free;
  end;

  Calculate;
end;


procedure TMainForm.ReadIni;
var
  f: String;
  s: string;
  inifile: TCustomIniFile;
  b: Integer;
begin
  f := CalcIniName;
  if not FileExists(f) then 
    exit;
  
  iniFile := TIniFile.Create(f);
  try
    with inifile do begin
      Left := ReadInteger('Form', 'Left', Left);
      Top := ReadInteger('Form', 'Top',  Top);
      Width := ReadInteger('Form', 'Width', Width);
      Height := ReadInteger('Form', 'Height', Height);
      PanelLeft.Width := ReadInteger('Form', 'ListWidth', PanelLeft.Width);
      s := ReadString('Form', 'Icons', SMALL_LARGE[btnLargeIcons.Down]);
      if s = 'large' then
      begin
        BtnLargeIcons.Down := true;
        LvDataTypes.ViewStyle := vsIcon;
      end else
      begin
        BtnSmallIcons.Down := true;
        LvDataTypes.ViewStyle := vsReport;
      end;

      s := ReadString('FloatFormat', 'Type', '');
      if s = '' then
        fmtFloat := fmtStandard
      else
        fmtFloat := TFloatFormat(GetEnumValue(TypeInfo(TFloatFormat), s));
      fmtDecimals := ReadInteger('FloatFormat', 'Decimals', fmtDecimals);
      s := ReadString('FloatFormat', 'DecimalSeparator', '');
      if s <> '' then
        case TDecimalSep(GetEnumValue(TypeInfo(TDecimalSep), s)) of
          dsDot: FormatSettings.DecimalSeparator := '.';
          dsComma: FormatSettings.DecimalSeparator := ',';
        end;
      s := ReadString('FloatFormat', 'ThousandSeparator', '');
      if s <> '' then
        case TThousandSep(GetEnumValue(TypeInfo(TThousandSep), s)) of
          tsComma: FormatSettings.ThousandSeparator := ',';
          tsDot: FormatSettings.ThousandSeparator := '.';
          tsSpace: Formatsettings.ThousandSeparator := ' ';
        end;
    end;
  finally
    inifile.Free;
  end;
end;


procedure TMainForm.WriteIni;
var
  iniFile : TIniFile;
begin
  inifile := TIniFile.Create(CalcIniName);
  with iniFile do begin
    WriteInteger('Form', 'Left', Left);
    WriteInteger('Form', 'Top', top);
    WriteInteger('Form', 'Width', Width);
    WriteInteger('Form', 'Height', Height);
    WriteInteger('Form', 'ListWidth', PanelLeft.Width);
    WriteString('Form', 'Icons', SMALL_LARGE[btnLargeIcons.Down]);

    WriteString('FloatFormat', 'Type', GetEnumName(TypeInfo(TFloatFormat), integer(fmtFloat)));
    WriteInteger('FloatFormat', 'Decimals', fmtDecimals);
    WriteString('FloatFormat', 'DecimalSeparator', GetEnumName(TypeInfo(TDecimalSep), integer(GetDecimalSep)));
    WriteString('FloatFormat', 'ThousandSeparator', GetEnumName(TypeInfo(TThousandSep), integer(GetThousandSep)));
  end;
  inifile.Free;
end;


end.
