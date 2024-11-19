program UnitConv;
uses
  Interfaces,
  Forms,
  ucMain, ucFormat;

{$R *.res}

begin
 {$if declared(UseHeapTrace)}
  GlobalSkipIfNoLeaks := True;  // supported as of debugger version 3.2.0
 {$endIf}
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
