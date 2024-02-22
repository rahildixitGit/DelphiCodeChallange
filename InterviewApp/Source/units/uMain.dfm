object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Load from CSV files'
  ClientHeight = 262
  ClientWidth = 491
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl_connState: TLabel
    Left = 127
    Top = 10
    Width = 65
    Height = 13
    Caption = 'lbl_connState'
  end
  object mem_csvFile: TMemo
    Left = 16
    Top = 56
    Width = 457
    Height = 183
    TabOrder = 0
    WordWrap = False
  end
  object btn_connectDb: TButton
    Left = 16
    Top = 8
    Width = 105
    Height = 21
    Caption = 'Connect DB'
    TabOrder = 1
    OnClick = btn_connectDbClick
  end
  object btn_loadCsvFile: TButton
    Left = 16
    Top = 29
    Width = 169
    Height = 25
    Caption = 'Load CSV file'
    TabOrder = 2
    OnClick = btn_loadCsvFileClick
  end
  object Button1: TButton
    Left = 304
    Top = 25
    Width = 169
    Height = 25
    Caption = 'Start'
    TabOrder = 3
    OnClick = Button1Click
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 245
    Width = 491
    Height = 17
    Align = alBottom
    TabOrder = 4
  end
  object Monitor: TFDMoniCustomClientLink
    Tracing = True
    Left = 215
  end
  object FDConnSourceDb: TFDConnection
    Params.Strings = (
      'Database=C:\ManagementPlus\Backup\Indiana\DATABASE\DATABASE.GDB'
      'User_Name=SYSDBA'
      'Password=thg'
      'MonitorBy=Custom'
      'Protocol=TCPIP'
      'Server=localhost'
      'SQLDialect=1'
      'DriverID=IB')
    Left = 239
  end
  object FDQry_Common: TFDQuery
    Connection = FDConnSourceDb
    Left = 268
  end
  object od_CSV: TOpenDialog
    Left = 424
  end
  object FDTbl_common: TFDTable
    Connection = FDConnSourceDb
    Left = 296
  end
  object od_Db: TOpenDialog
    Left = 352
  end
end
