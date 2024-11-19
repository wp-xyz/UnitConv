program UnitConv;
uses
  Interfaces, SysUtils, Forms,
  ucMain, ucFormat;

{$R *.res}

{$if declared(UseHeapTrace)}
const
  HeapTrcFile = 'heaptrace.trc';
{$endif}

begin
 {$if declared(UseHeapTrace)}
  GlobalSkipIfNoLeaks := True;      // supported as of debugger version 3.2.0
  if FileExists(HeapTrcFile) then
    DeleteFile(HeapTrcFile);
  SetHeapTraceOutput(HeapTrcFile);  // supported as of debugger version 3.1.1
  {$endif}

  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
