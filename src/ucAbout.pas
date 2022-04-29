unit ucAbout;

interface

uses
  LCLIntf, LCLType, Types, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  
  { TAboutBox }

  TAboutBox = class(TForm)
    Image1: TImage;
    Label2: TLabel;
    lblIcons8: TLabel;
    lblProgName: TLabel;
    lblAuthor: TLabel;
    btnOK: TButton;
    Bevel1: TBevel;
    lblVersion: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblIcons8Click(Sender: TObject);
    procedure lblIcons8MouseEnter(Sender: TObject);
    procedure lblIcons8MouseLeave(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  AboutBox: TAboutBox;

  
implementation

{$R *.lfm}

uses
  fileinfo;

function GetCompilationTime: TDateTime;
var
  fs: TFormatSettings;
begin
  fs := DefaultFormatSettings;
  fs.TimeSeparator := ':';
  fs.DecimalSeparator := '.';
  fs.ShortDateFormat := 'yyyy"/"mm"/"dd';
  fs.LongTimeFormat := 'hh":"nn":"ss';
  fs.DateSeparator := '/';
  Result := StrToDateTime({$I %DATE%} + ' ' + {$I %TIME%}, fs)
end; 


function GetProgramVersion: String;
var
  info: TFileVersionInfo;
begin
  info := TFileVersionInfo.Create(nil);
  try
    info.ReadFileInfo;    
    Result := Format('%s [built %s]', [
      info.VersionStrings.Values['ProductVersion'],
      FormatDateTime('yyyy-mm-dd', GetCompilationTime)
    ]);
  finally
    info.Free;
  end;
end;


procedure TAboutBox.btnOKClick(Sender: TObject);
begin
  Close;
end;


procedure TAboutBox.FormCreate(Sender: TObject);
var
  sz: TSize;
begin
  sz := Size(Image1.Width, Image1.Height);
  Image1.Picture.Assign(Application.Icon);
  Image1.Picture.Icon.Current := Image1.Picture.Icon.GetBestIndexForSize(sz);
  lblVersion.Caption := 'Version ' + GetProgramVersion;
end;


procedure TAboutBox.lblIcons8Click(Sender: TObject);
begin
  OpenURL(lblIcons8.Hint);
end;


procedure TAboutBox.lblIcons8MouseEnter(Sender: TObject);
begin
  lblIcons8.Font.Style := lblIcons8.Font.Style + [fsUnderline];
end;


procedure TAboutBox.lblIcons8MouseLeave(Sender: TObject);
begin
  lblIcons8.Font.Style := lblIcons8.Font.Style - [fsUnderline];
end;


end.
