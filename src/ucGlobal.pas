unit ucGlobal;

interface

Const
  { Natural constants in SI units, 1986 recommended values in  "Physics Today" }
  _h             = 6.6260755E-34;    { Planck's constant }
  _c             = 2.99792458E8;     { speed of light }
  _e             = 1.60217733E-19;   { elementary chart }
  _k             = 1.380658E-23;     { Boltzmann constant }
  _u             = 1.6605402E-27;    { atomic mass unit }
  _gn            = 9.80665;          { standard acceleration of gravity }

  diLength       = 0;
  diArea         = 1;
  diVolume       = 2;
  diMass         = 3;
  diTime         = 4;
  diSpeed        = 5;
  diAccel        = 6;
  diForce        = 7;
  diFlowRate     = 8;
  diPressure     = 9;
  diTemperature  = 10;
  diEnergy       = 11;
  diPower        = 12;
  diMagField     = 13;
  diOzoneConc    = 14;
  diAngle        = 15;
  diMemory       = 16;
  diLast  = diMemory;
  diCount = diLast + 1;

type
  { Converstion from the source basis units [s] to destination units [d]:
       <d> = (A*<s> + B)/(C*<s> + D)
    Usually A depends on the unit, and B=0, C=0, D=1. }
  TUnitItem = record
    Name    : string;
    A,B,C,D : double;
  end;

  TDataItem = record
    Name  : string;
    Value : double;
    Units : array of TUnitItem;
    Source: integer;
    Dest  : integer;
    ImageIndex : integer;
  End;

Var
  DataItems: Array Of TDataItem;

Procedure CreateItems;
Procedure DestroyItems;
Function  ConvertUnitFrom(x,A,B,C,D: Double) : Double;
Function  ConvertUnitTo(y,A,B,C,D: Double) : Double;

type
  TFloatFormat = (fmtStandard, fmtExp, fmtFixed);
  TDecimalSep = (dsDot, dsComma);
  TThousandSep = (tsComma, tsDot, tsSpace);

var
  fmtFloat: TFloatFormat = fmtStandard;
  fmtDecimals: Integer = 3;
  decimalSep: TDecimalSep = dsDot;
  thousandSep: TThousandSep = tsComma;

function BuildFormatStr(AFloatFormat: TFloatFormat; ADecimals: Integer): String;
function GetDecimalSep: TDecimalSep;
function GetThousandSep: TThousandSep;
procedure UpdateFormatSettings(ADecimalSep: TDecimalSep; AThousandSep: TThousandSep);

implementation

uses
  SysUtils, Math;

Procedure CreateUnitItem(dataID, unitID: Integer; Name:String;
  A,B,C,D:Double);
Begin
  DataItems[dataID].Units[unitID].Name := Name;
  DataItems[dataID].Units[unitID].A := A;
  DataItems[dataID].Units[unitID].B := B;
  DataItems[dataID].Units[unitID].C := C;
  DataItems[dataID].Units[unitID].D := D;
End;


Procedure CreateLengthItems;
Begin
  With DataItems[diLength] Do Begin
    Name := 'Length';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diLength);
    SetLength(Units, 15);
    CreateUnitItem(diLength, 0, 'kilometers (km)',  1E3,  0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 1, 'meters (m)',       1.0,  0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 2, 'centimeters (cm)', 1E-2, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 3, 'millimeters (mm)', 1E-3, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 4, 'microns (�m)', 1E-6, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 5, 'nanometers (nm)',  1E-9, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 6, 'Angstr�m (A�)',  1E-10, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 7, 'Inches',          0.0254, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 8, 'milli-inches (mils)', 0.0254E-3, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 9, 'feet (ft)', 0.3048, 0.0, 0.0, 1.0);
    CreateunitItem(diLength, 10,'yard (yd)', 0.9144,  0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 11,'Sea miles (sm)', 1852.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diLength, 12, 'light years (ly)',
      _c*60*60*24*365, 0, 0, 1);               { c from Physics Today}
    CreateUnitItem(diLength, 13, 'astronomic units (ua)',
      1.49597870691E11, 0, 0, 1);                               {Physics Today}
    CreateUnitItem(diLength, 14, 'Parsec (pc)',
      3.0857E16, 0, 0, 1);
  End;
End;

Procedure CreateAreaItems;
Begin
  With DataItems[diArea] Do Begin
    Name := 'Area';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diArea);
    SetLength(Units, 11);
    CreateUnitItem(diArea, 0, 'km²', 1E6, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 1, 'square meters (m²)', 1.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 2, 'cm²', 1E-4, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 3, 'mm²', 1E-6, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 4, 'µm²', 1E-12, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 5, 'Ar (a)', 100.0, 0.0, 0.0, 1.0);
    CreateunitItem(diArea, 6, 'Hektar (ha)', 1E4, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 7, 'Morgen (mor)', 2.5E3, 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 8, 'square inches', Sqr(0.0254), 0.0, 0.0, 1.0);
    CreateUnitItem(diArea, 9, 'square feet (ft²)', Sqr(0.3048), 0.0, 0.0, 1.0);
    CreateUnitItem(diArea,10, 'acres (ac)', 4077.0, 0.0, 0.0, 1.0);
  End;
End;

Procedure CreateVolumeItems;
Begin
  With DataItems[diVolume] Do Begin
    Name := 'Volume';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diVolume);
    SetLength(Units, 11);
    CreateUnitItem(diVolume, 0, 'cubic meters (m³)', 1E6, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 1, 'cubic centimeters (cm³)', 1.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 2, 'liters (l)', 1E3, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 3, 'Maß (German)', 1E3, 0, 0, 1);
    CreateUnitItem(diVolume, 4, 'Halbe (German)', 500.0, 0, 0, 1);
    CreateUnitItem(diVolume, 5, 'milliliters (ml)', 1.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 6, 'gallons (USA)', 3785.4117, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 7, 'gallons (GB)', 4546.1, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 8, 'cubic feet (cf)', 28316.846, 0.0, 0.0, 1.0);
    CreateUnitItem(diVolume, 9, 'fluid ounces (fl.oz) (USA)', 29.5735, 0, 0, 1);
    CreateUnitItem(diVolume, 10,'fluid ounces (fl.oz) (GB)',  28.4131, 0, 0, 1);
  End;
End;


Procedure CreateTimeItems;
Begin
  With DataItems[diTime] do begin
    Name := 'Time';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diTime);
    SetLength(Units, 6);
    CreateUnitItem(diTime, 0, 'seconds (s)', 1, 0, 0, 1);
    CreateUnitItem(ditime, 1, 'minutes (min)', 60, 0, 0, 1);
    CreateUnitItem(diTime, 2, 'hours (h)', 60.0*60, 0, 0, 1);
    CreateUnitItem(diTime, 3, 'days (d)', 24.0*60*60, 0, 0, 1);
    CreateunitItem(diTime, 4, 'weeks (w)', 7.0*24*60*60, 0, 0, 1);
    CreateunitItem(diTime, 5, 'years (y)', 365.0*24*60*60, 0, 0, 1);
  End;
End;


Procedure CreateSpeedItems;
Begin
  With DataItems[diSpeed] Do begin
    Name := 'Speed';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diSpeed);
    SetLength(Units, 4);
    CreateUnitItem(diSpeed, 0, 'meters per second (m/s)',
      1, 0, 0, 1);
    CreateUnitItem(diSpeed, 1, 'kilometers per hour (km/h)',
      1E3/3600, 0, 0, 1);
    CreateunitItem(diSpeed, 2, 'knots (Kn)',
      0.514444, 0, 0, 1);
    CreateUnitItem(diSpeed, 3, 'Mach',
      310.0, 0, 0, 1);
  End;
End;


Procedure CreateAccelItems;
Begin
  With DataItems[diAccel] do begin
    Name := 'Acceleration';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diAccel);
    SetLength(Units, 3);
    CreateUnitItem(diAccel, 0, 'm/s²', 1, 0, 0, 1);
    CreateUnitItem(diAccel, 1, 'acceleration of gravity (g)', _gn, 0, 0, 1);
    CreateUnitItem(diAccel, 2, 'seconds from 0 to 100 km/h', 0, 100/3.6, 1, 0);
  End;
End;


Procedure CreateMassItems;
Begin
  With DataItems[diMass] do begin
    Name := 'Mass';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diMass);
    SetLength(Units, 5);
    CreateUnitItem(diMass, 0, 'grams (g)', 1E-3, 0, 0, 1);
    CreateUnitItem(diMass, 1, 'kilograms (kg)', 1, 0, 0, 1);
    CreateUnitItem(diMass, 2, 'pounds (German)', 500.0, 0, 0, 1);
    CreateUnitItem(diMass, 2, 'tons (t)', 1E3, 0, 0, 1);
    CreateUnitItem(diMass, 3, 'atomic mass units (u)', _u, 0, 0, 1);
  End;
End;


Procedure CreateFlowRateItems;
Begin
  With DataItems[diFlowRate] Do Begin
    Name := 'Flow rate';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diFlowRate);
    SetLength(Units, 8);
    CreateUnitItem(diFlowRate, 0, 'standard cubic centimeters per minute (sccm)',
      1.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diFlowRate, 1, 'standard liters per minute (slm)',
      1E3, 0.0, 0.0, 1.0);
    CreateunitItem(diFlowRate, 2, 'Standardliter pro Stunde (slh)',
      1E3/60.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diFlowRate, 3, 'cubic meters per hour (m³/h)',
      1E6/60, 0.0, 0.0, 1.0);
    CreateUnitItem(diFlowrate, 4, 'gallons per minute (gpm)',
      3785.4117, 0.0, 0.0, 1.0);
    CreateUnitItem(diFlowRate, 5, 'gallons per hour (gph)',
      3785.4117/60.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diFlowRate, 6, 'cubic feet per minute (cfm)',
      28316.846, 0.0, 0.0, 1.0);
    CreateUnitItem(diFlowRate, 7, 'cubic feet per hour (cfh)',
      28316.846/60.0, 0.0, 0.0, 1.0);
  End;
End;


Procedure CreateForceItems;
Begin
  With DataItems[diForce] do begin
    Name := 'Force';
    value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diForce);
    SetLength(Units, 4);
    CreateUnitItem(diForce, 0, 'Newton (N)', 1, 0, 0, 1);
    CreateunitItem(diForce, 1, 'kilo pond (kp)',
      _gn, 0, 0, 1);
    CreateUnitItem(diForce, 2, 'pond (p)',
      _gn*1E-3, 0, 0, 1);
    CreateUnitItem(diForce, 3, 'dyne', 1E-5, 0, 0, 1);
  End;
End;


Procedure CreatePressureItems;
Begin
  With DataItems[diPressure] Do Begin
    Name := 'Pressure';
    Value := 1.0;
    Source := 2;
    Dest := 3;
    ImageIndex := ord(diPressure);
    SetLength(Units, 9);
    CreateUnitItem(diPressure, 0, 'atmosphere (at)', 1.01325, 0, 0, 1);
    CreateUnitItem(diPressure, 1, 'bar', 1.0, 0, 0, 1);
    CreateUnitItem(diPressure, 2, 'millibar (mbar)', 1E-3, 0, 0, 1);
    CreateUnitItem(diPressure, 3, 'torr', 1.333E-3, 0, 0, 1);
    CreateUnitItem(diPressure, 4, 'millitorr (mTorr)', 1.333E-6, 0, 0, 1);
    CreateUnitItem(diPressure, 5, 'Newton pro m² (N/m²)', 1E-5, 0, 0, 1);
    CreateUnitItem(diPressure, 6, 'Pascal (Pa)', 1E-5, 0, 0, 1);
    CreateUnitItem(diPressure, 7, 'Hecto pascal (hPa)',  1E-3, 0, 0, 1);
    CreateUnitItem(diPressure, 8, 'Pounds per Square Inch (psi)', 0.0689, 0,0,1);
  End;
End;


Procedure CreateTemperatureItems;
Begin
  With DataItems[diTemperature] Do Begin
    Name := 'Temperature';
    Value := 0.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diTemperature);
    SetLength(Units, 3);
    CreateUnitItem(diTemperature, 0, 'Celsius (°C)', 1.0, 0.0, 0.0, 1.0);
    CreateUnitItem(diTemperature, 1, 'Fahrenheit (°F)', 5/9, -32*5/9, 0.0, 1.0);
    CreateUnitItem(diTemperature, 2, 'Kelvin (K)', 1.0, -273.15, 0.0, 1.0);
  End;
End;


Procedure CreateEnergyItems;
Begin
  With DataItems[diEnergy] do begin
    Name := 'Energy';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diEnergy);
    SetLength(Units, 15);
    CreateUnitItem(diEnergy, 0, 'Joule (J)', 1, 0, 0, 1);
    CreateUnitItem(diEnergy, 1, 'erg', 1E-7, 0, 0, 1);
    CreateUnitItem(diEnergy, 2, 'calories (cal)', 4.18683, 0, 0, 1);
    CreateUnitItem(diEnergy, 3, 'kilocalories (kcal)', 4.18683E3, 0, 0, 1);
    CreateUnitItem(diEnergy, 4, 'Watt seconds (Ws)', 1, 0, 0, 1);
    CreateUnitItem(diEnergy, 5, 'Kilowatt hours (kWh)', 3.6E6, 0, 0, 1);
    CreateUnitItem(diEnergy, 6, 'Elektronenvolt (eV)', _e, 0, 0, 1);
    CreateUnitItem(diEnergy, 7, 'Megaelektronenvolt (MeV)', _e*1E6, 0, 0, 1);
    CreateUnitItem(diEnergy, 8, 'Kelvin (K)', _k, 0, 0, 1);
    CreateUnitItem(diEnergy, 9, 'Kilojoule/mol (kJ/mol)', 0.0104*1.602E-19,0,0,1);
    CreateUnitItem(diEnergy,10, 'kcal/mol', 6.95198E-21, 0, 0, 1);
    CreateUnitItem(diEnergy,11, 'Hertz (Hz)', _h, 0, 0, 1);
    CreateUnitItem(diEnergy,12, 'nm (wavelength)', 0, 1, 1E-9/(_h*_c), 0);
    CreateUnitItem(diEnergy,13, 'wave numbers (1/cm)', _h*_c*1E2, 0, 0, 1);
    CreateUnitItem(diEnergy,14, 'Rydberg (ryd)', 13.605698*_e, 0, 0, 1);           { Ryd from Physics Today }
  End;
End;


Procedure CreatePowerItems;
Begin
  With DataItems[diPower] do begin
    Name := 'Power';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diPower);
    SetLength(Units, 6);
    CreateUnitItem(diPower, 0, 'Watt (W)', 1, 0, 0, 1);
    CreateUnitItem(diPower, 1, 'Kilowatt (kW)', 1E3, 0, 0, 1);
    CreateUnitItem(diPower, 2, 'Joules per second (J/s)', 1, 0, 0, 1);
    CreateUnitItem(diPower, 3, 'Horse powers (PS)', 736, 0, 0, 1);
    CreateUnitItem(diPower, 4, 'Kilopond-meters per second (kp m/s)', _gn, 0, 0, 1);
    CreateUnitItem(diPower, 5, 'Kilocalories per second (kcal/s)', 4.19E3, 0, 0, 1);
  End;
End;


Procedure CreateOzoneConcItems;
Begin
  With DataItems[diOzoneConc] Do Begin
    Name := 'Ozone concentration';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diOzoneConc);
    SetLength(Units, 4);
    CreateUnitItem(diOzoneConc, 0, 'gramms per normal cubic meter (g/Nm³)',
      1, 0, 0, 1);
    CreateUnitItem(diOzoneConc, 1, 'micro grams per normal cubic meter (µg/m³)',
      1E-6, 0.0, 0.0, 1.0);
    CreateUnitItem(diOzoneConc, 2, 'Weight percent (Wt%)',
      32.0*44.606507, 0, -1/3, 100);
    CreateUnitItem(diOzoneConc, 3, 'Volume percent (Vol%)',
      0.48*44.606507, 0, 0, 1);
  End;
End;


Procedure CreateMagFieldItems;
Begin
  With DataItems[diMagField] do begin
    Name := 'Magnetic field';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diMagField);
    SetLength(Units, 4);
    CreateUnitItem(diMagField, 0, 'Tesla (T)', 1, 0, 0, 1);
    CreateUnitItem(diMagField, 1, 'Gauss (G)', 1E-4, 0, 0, 1);
    CreateUnitItem(diMagField, 2, 'Oersted (Oe)', 1E-4, 0, 0, 1);
    CreateUnitItem(diMagField, 3, 'Amperes per meter (A/m)', 4E-7*pi, 0, 0, 1);
  End;
End;


Procedure CreateAngleItems;
begin
  with DataItems[diAngle] do begin
    Name := 'Angle';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diAngle);
    SetLength(Units, 4);
    CreateUnitItem(diAngle, 0, 'degrees', 1, 0, 0, 1);
    CreateUnitItem(diAngle, 1, 'minutes ('')', double(1.0)/60, 0, 0, 1);
    CreateUnitItem(diAngle, 2, 'seconds (")', double(1.0)/3600, 0, 0, 1);
    CreateUnitItem(diAngle, 3, 'radians (rad)', double(180.0)/pi, 0, 0, 1);
  end;
end;

procedure CreateMemoryItems;
begin
  with DataItems[diMemory] do begin
    Name := 'Data volume';
    Value := 1.0;
    Source := 0;
    Dest := 1;
    ImageIndex := ord(diMemory);
    SetLength(Units, 4);
    CreateUnitItem(diMemory, 0, 'bytes', 1, 0, 0, 1);
    CreateUnitItem(diMemory, 1, 'kilo bytes (KB)', 1024, 0, 0, 1);
    CreateUnitItem(diMemory, 2, 'mega bytes (MB)', 1024*1024, 0, 0, 1);
    CreateUnitItem(diMemory, 3, 'giga bytes (GB)', 1024*1024*1024, 0, 0, 1);
  end;
end;

Procedure CreateItems;
Begin
  SetLength(DataItems, diCount);
  CreateLengthItems;
  CreateAreaItems;
  CreateVolumeItems;
  CreateMassItems;
  CreateForceItems;
  CreateTimeItems;
  CreateSpeedItems;
  CreateAccelItems;
  CreateFlowRateItems;
  CreatePressureItems;
  CreateTemperatureItems;
  CreateEnergyItems;
  CreatePowerItems;
  CreateMagFieldItems;
  CreateOzoneConcItems;
  CreateAngleItems;
  CreateMemoryItems;
End;


Procedure DestroyItems;
Var
  i : Integer;
Begin
  for i:=0 To diCount-1 do
    Finalize(DataItems[i].Units);
  Finalize(DataItems);
End;


{ Converts x from the basis units to the new units.
  Uses the equation:
    y = (Ax + B)/(Cx + D)
  A, B, C and D are defined by the CreateXXXXItems procedure.
  An EZeroDivide exception is raised if the denominator is zero. }
function ConvertUnitFrom(x, A, B, C, D: Double) : Double;
begin
  if C*x + D <> 0.0 then
    Result := (A*x + B) / (C*x + D)
  else 
    Result := NaN;
end;


{ Convert y from the new units back to the base units (x).
  The conversion is determined by the constants A, B, C, D defined by the
  CreateXXXXItems procedure.
  It follows from y = (Ax + B)/(Cx + D) that x = (B - Dy)/(Cy - A).
  An EZeroDivide exception is raised if the denominator is zero. }
function ConvertUnitTo(y, A, B, C, D: Double) : Double;
begin
  if y*C - A <> 0.0 then
    Result := (B - y*D) / (y*C - A)
  else
    Result := NaN;
end;


function BuildFormatStr(AFloatFormat: TFloatFormat; ADecimals: Integer): String;
const
  FMT: Array[TFloatFormat] of string = ('g', 'e', 'f');
begin
  if AFloatFormat = fmtStandard then
    Result := ''
  else
    Result := '%.' + IntToStr(ADecimals) + FMT[AFloatFormat];
end;

function GetDecimalSep: TDecimalSep;
begin
  case FormatSettings.DecimalSeparator of
    ',': Result := dsComma;
    '.': Result := dsDot;
    else raise Exception.Create('Decimal separator not supported.');
  end;
end;

function GetThousandSep: TThousandSep;
begin
  case FormatSettings.ThousandSeparator of
    ',': Result := tsComma;
    '.': Result := tsDot;
    ' ': Result := tsSpace;
    else raise Exception.Create('Thousand separator not supported.');
  end;
end;

procedure UpdateFormatSettings(ADecimalSep: TDecimalSep; AThousandSep: TThousandSep);
begin
  case ADecimalSep of
    dsDot: FormatSettings.DecimalSeparator := '.';
    dsComma: FormatSettings.DecimalSeparator := ',';
  end;
  case AThousandSep of
    tsComma: Formatsettings.ThousandSeparator := ',';
    tsDot: FormatSettings.ThousandSeparator := '.';
    tsSpace: FormatSettings.ThousandSeparator := ' ';
  end;
end;

end.


