program LoadDataFromCSV;

uses
  Vcl.Forms,
  uMain in 'units\uMain.pas' {Form1},
  uWriteToLogFile in 'units\uWriteToLogFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
