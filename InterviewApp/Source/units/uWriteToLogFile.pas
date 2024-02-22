unit uWriteToLogFile;

interface
uses Classes, SysUtils;

Type TMPMessageType = (mpmtInformation, mpmtWarning, mpmtError);
function  DateStampStr(pSeparator: String; pWithTime: Boolean = True): String;
procedure WriteMessage(pMsgStr: String; pMsgType: TMPMessageType); overload;
procedure WriteMessage(pFilePrefix, pMsgStr: String; pMsgType: TMPMessageType); overload;
function  HandleSpecialChars(pStr: String): String;

implementation

function HandleSpecialChars(pStr: String): String;
var
  lStr1 : String;
  lStr2 : String;
  lSplChars : Array of char;
  lLenOfSplChar : Integer;
  lPosOfSplChar : Integer;
  lCtr : Integer;

begin
  lStr1 := '';
  lStr2 := pStr;
//  lSplChars := [',','.','/','!','@','#','$','%','^','&','*','''','"',';','_','(',')',':','|','[',']'];
  lSplChars := [''''];
  lLenOfSplChar := Length(lSplChars);
  for lCtr := 0 to lLenOfSplChar - 1 do
  begin
    lPosOfSplChar := pos(lSplChars[lCtr], lStr2);
    if lPosOfSplChar > 0 then
    begin
      while lPosOfSplChar > 0 do
      begin
        lStr1 := lStr1 + copy(lStr2, 1, pos(lSplChars[lCtr], lStr2) - 1) + '''' + lSplChars[lCtr];
        lStr2 := copy(pStr, pos(lSplChars[lCtr], lStr2) + 1, length(lStr2));
        lPosOfSplChar := pos(lSplChars[lCtr], lStr2);
      end;
    end
    else
    begin
    end;
    result := lStr1 + lStr2;


  end;
end;


function  DateStampStr(pSeparator: String; pWithTime: Boolean = True): String;
begin
  if pWithTime then
    Result := FormatDateTime('yyyy' + pSeparator + 'MM' + pSeparator + 'dd hh:mm:ss', Now)
  else
    Result := FormatDateTime('yyyy' + pSeparator + 'MM' + pSeparator + 'dd', Now)
end;

procedure WriteMessage(pFilePrefix, pMsgStr: String; pMsgType: TMPMessageType); overload;
var
  PrefixStr: String;
  MsgTypeStr: String;
  FileName: String;
  LogFile : TextFile;
  FilePath: String;
begin
//  if not (Wrapper.Staff.Config['WRITE_TO_LOGFILE'] = 'TRUE') then
//    exit;

//  FilePath := ExtractFilePath(Application.ExeName);
//  FilePath := FilePath + 'Log\';
  FilePath := 'Log\';
  if ForceDirectories(FilePath) then
  begin
    FileName := FilePath + pFilePrefix + '_' + DateStampStr('', False) + '.log';
  end
  else
   Exit;
  AssignFile(LogFile, FileName);
  if FileExists(FileName) then
  begin
    Append(LogFile);
  end
  else
  begin
    ReWrite(LogFile);
  end;

  case pMsgType of
    mpmtInformation: MsgTypeStr := 'Information';
    mpmtWarning: MsgTypeStr := 'Warning';
    mpmtError: MsgTypeStr := 'Error';
  end;
  PrefixStr :=DateStampStr('/') + ' ' + MsgTypeStr;
  WriteLn(LogFile, PrefixStr + ' ' + pMsgStr);
  CloseFile(LogFile);

end;

procedure WriteMessage(pMsgStr: String; pMsgType: TMPMessageType);
var
  PrefixStr: String;
  MsgTypeStr: String;
  FileName: String;
  LogFile : TextFile;
  FilePath: String;
begin
//  if not (Wrapper.Staff.Config['WRITE_TO_LOGFILE'] = 'TRUE') then
//    exit;

//  FilePath := ExtractFilePath(Application.ExeName);
//  FilePath := FilePath + 'Log\';
  FilePath := 'Log\';
  if ForceDirectories(FilePath) then
  begin
    FileName := FilePath + DateStampStr('', False) + '.log';
  end
  else
   Exit;
  AssignFile(LogFile, FileName);
  if FileExists(FileName) then
  begin
    Append(LogFile);
  end
  else
  begin
    ReWrite(LogFile);
  end;

  case pMsgType of
    mpmtInformation: MsgTypeStr := 'Information';
    mpmtWarning: MsgTypeStr := 'Warning';
    mpmtError: MsgTypeStr := 'Error';
  end;
  PrefixStr :=DateStampStr('/') + ' ' + MsgTypeStr;
  WriteLn(LogFile, PrefixStr + ' ' + pMsgStr);
  CloseFile(LogFile);

end;

end.



