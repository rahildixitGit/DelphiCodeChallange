unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, Db, uWriteToLogFile,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.IB,
  FireDAC.Phys.IBDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Moni.Base, FireDAC.Moni.Custom;

type
  TForm1 = class(TForm)
    mem_csvFile: TMemo;
    btn_connectDb: TButton;
    btn_loadCsvFile: TButton;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    Monitor: TFDMoniCustomClientLink;
    FDConnSourceDb: TFDConnection;
    FDQry_Common: TFDQuery;
    lbl_connState: TLabel;
    od_CSV: TOpenDialog;
    FDTbl_common: TFDTable;
    od_Db: TOpenDialog;
    procedure btn_connectDbClick(Sender: TObject);
    procedure btn_loadCsvFileClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    EMP_CODE   : string;
    EMP_FNAME  : string;
    EMP_LNAME  : string;
    EMP_DOB    : TDateTime;
    EMP_DOJ    : TDateTime;
    EMP_PHONE  : string;
    EMP_MOBILE : string;
    EMP_EMAIL  : string;
    EMP_SALARY : string;

    procedure insertInToDbTable;
    procedure readCSVFile;
    procedure parseCSVRow(pRow, pSaperator : String);
    procedure Initialize;
    procedure LoadCFVFile;
    function StrToDate(pStrDate: String; pSaperator: Char): TDateTime;
  public
    { Public declarations }
{DB_TARGET}
    DATABASE_PATH   : String;
    DB_SERVER       : String;
    PORT            : String;
    USER_NAME       : String;
    PASSWORD        : String;
    TABLE_NAME      : String;

    dsCommQuery   : TDataSource;

  end;
  TWriteLog = function(pMsgStr: String):integer; stdcall;

var
  Form1: TForm1;

implementation
uses IniFiles;

{$R *.dfm}
//function Write2Log(pMsgStr: String): integer;  stdcall; external 'writeLog.dll';

{ TForm1 }

procedure TForm1.btn_connectDbClick(Sender: TObject);
begin
  Initialize;
end;

procedure TForm1.btn_loadCsvFileClick(Sender: TObject);
begin
  LoadCFVFile;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  readCSVFile;
end;

procedure TForm1.Initialize;
var
  lIniFile      : TIniFile;
  lIniFilePath  : String;

  valProvider    : String;
  valInitCatalog : String;
  valDataSource  : String;
  valUserId      : String;
  valUserPwd     : String;
  connString     : String;
begin
  lIniFilePath := ExtractFilePath(Application.ExeName);
  lIniFilePath := lIniFilePath + Copy(ExtractFileName(Application.ExeName), 1, Pos('.', ExtractFileName(Application.ExeName))) + 'ini';
  lIniFile := TIniFile.Create(lIniFilePath);
  try
  {Connection DB_CONFIG}
    DB_SERVER          := lIniFile.ReadString('DATABASE', 'DB_SERVER', '');
    DATABASE_PATH      := lIniFile.ReadString('DATABASE', 'DATABASE_PATH', '');
    PORT               := lIniFile.ReadString('DATABASE', 'PORT', '');
    USER_NAME          := lIniFile.ReadString('DATABASE', 'USER_NAME', '');
    PASSWORD           := lIniFile.ReadString('DATABASE', 'PASSWORD', '');
    TABLE_NAME         := lIniFile.ReadString('DATABASE', 'TABLE_NAME', '');
  finally
    FreeAndNil(lIniFile);
  end;

  FDQry_Common.Connection := FDConnSourceDb;
  FDTbl_common.Connection := FDConnSourceDb;
  dsCommQuery    := TDataSource.Create(Self);
  valProvider    := 'SQLOLEDB.1';
  dsCommQuery.DataSet := FDQry_Common;
  valUserId      := USER_NAME;
  valUserPwd     := PASSWORD;
  FDConnSourceDb.Params.Values['Server']   := DB_SERVER;
  FDConnSourceDb.Params.Values['Database'] := DATABASE_PATH;
  FDConnSourceDb.Params.Values['UserName'] := USER_NAME;
  FDConnSourceDb.Params.Values['Password'] := PASSWORD;
  FDConnSourceDb.LoginPrompt := False;
  try
    FDConnSourceDb.Connected := True;
    lbl_connState.Caption := 'Connected to ' + DATABASE_PATH;
  except
    on e: exception do
    begin
      lbl_connState.Caption := 'Connection failed!' + e.Message;
    end;
  end;
end;

procedure TForm1.insertInToDbTable;
begin
  try
    FDTbl_common.Insert;

    FDTbl_common.FieldByName('emp_code').AsString   := EMP_CODE;
    FDTbl_common.FieldByName('emp_fname').AsString  := EMP_FNAME;
    FDTbl_common.FieldByName('emp_lname').AsString  := EMP_LNAME;
    FDTbl_common.FieldByName('emp_dob').AsDateTime  := EMP_DOB;
    FDTbl_common.FieldByName('emp_doj').AsDateTime  := EMP_DOJ;
    FDTbl_common.FieldByName('emp_phone').AsString  := EMP_PHONE;
    FDTbl_common.FieldByName('emp_mobile').AsString := EMP_MOBILE;
    FDTbl_common.FieldByName('emp_email').AsString  := EMP_EMAIL;
    FDTbl_common.FieldByName('emp_salary').AsString := EMP_SALARY;
    FDTbl_common.Post;
  except
    on e: exception do
    begin
      WriteMessage('EMP_CODE: ' + EMP_CODE + ' - ' + e.Message, mpmtWarning);
    end;
  end;
end;

procedure TForm1.LoadCFVFile;
begin
  if od_CSV.Execute then
  begin
    mem_csvFile.Lines.LoadFromFile(od_CSV.FileName);
  end;
end;

procedure TForm1.parseCSVRow(pRow, pSaperator: String);
var
  lStr1     : String;
  lStr2     : String;
  lPos1     : Integer;
  lPos2     : Integer;
  lDate     : String;
  lStatus   : Integer;
  lHandle   : THandle;
  lWriteLog : TWriteLog;
begin
  lStr1 := pRow;

  lPos1 := pos(pSaperator, lStr1);
  EMP_CODE := copy(lStr1, 1, lPos1 -1);
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  EMP_FNAME := copy(lStr1, 1, lPos1 - 1);
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  EMP_LNAME := copy(lStr1, 1, lPos1 - 1);
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  lDate := copy(lStr1, 1, lPos1 -1);
  EMP_DOB := StrToDate(lDate, '/');
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  lDate := copy(lStr1, 1, lPos1 -1);
  EMP_DOJ := StrToDate(lDate, '/');
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  EMP_PHONE := copy(lStr1, 1, lPos1 -1);
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  EMP_MOBILE := copy(lStr1, 1, lPos1 -1);
  Delete(lStr1, 1, lPos1);

  lPos1 := pos(pSaperator, lStr1);
  EMP_EMAIL := copy(lStr1, 1, lPos1 -1);
  Delete(lStr1, 1, lPos1);

//  lPos1 := pos(pSaperator, lStr1);
//  EMP_SALARY := copy(lStr1, 1, lPos1 -1);
//  Delete(lStr1, 1, lPos1);
  EMP_SALARY := lStr1;

  lHandle := LoadLibrary('writeLog.dll');
  @lWriteLog := GetProcAddress(lHandle, 'Write2Log');
  if (@lWriteLog <> nil) then
  begin
    lStatus := lWriteLog('Details inserted for employee ' + ' ' + EMP_FNAME);
  end;
  FreeLibrary(lHandle);
end;

function TForm1.StrToDate(pStrDate:String; pSaperator: Char): TDateTime;
var
  fs: TFormatSettings;
  s: string;
begin
  fs := TFormatSettings.Create;
  fs.DateSeparator   := '/';
  fs.ShortDateFormat := 'yyyy/MM/dd';
  fs.TimeSeparator   := ':';
  fs.ShortTimeFormat := 'hh:mm';
  fs.LongTimeFormat  := 'hh:mm:ss';

  Result := StrToDateTime(pStrDate, fs);
end;

procedure TForm1.readCSVFile;
var
  lCtr : Integer;
  lRow : String;
begin
  FDTbl_common.TableName := TABLE_NAME;
  FDTbl_common.Active    := True;
  for lCtr := 1 to mem_csvFile.Lines.Count - 1 do
  begin
    lRow := mem_csvFile.Lines[lCtr];
    parseCSVRow(lRow, ',');
    insertInToDbTable;
  end;
end;

end.
