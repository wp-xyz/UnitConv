program UnitConv;
uses
  Interfaces,
  Forms,
  ucMain, ucFormat;

{$R *.RES}

begin
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
