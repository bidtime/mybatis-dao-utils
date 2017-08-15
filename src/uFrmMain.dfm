object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'mybatis DAO version 1.0 build by riverbo 2017.06.16 '
  ClientHeight = 537
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 198
    Width = 900
    Height = 4
    Cursor = crVSplit
    Align = alTop
    ExplicitTop = 171
    ExplicitWidth = 955
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 518
    Width = 900
    Height = 19
    Panels = <>
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 900
    Height = 29
    Caption = 'ToolBar1'
    TabOrder = 1
    object btnDo: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 22
      Caption = #29983#25104
      TabOrder = 0
      OnClick = btnDoClick
    end
    object Button2: TButton
      Left = 75
      Top = 0
      Width = 75
      Height = 22
      Caption = #36864#20986
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 29
    Width = 900
    Height = 169
    Align = alTop
    Caption = 'Public'
    TabOrder = 2
    object Label3: TLabel
      Left = 24
      Top = 35
      Width = 70
      Height = 13
      Caption = 'targetPackage'
    end
    object Label4: TLabel
      Left = 24
      Top = 89
      Width = 68
      Height = 13
      Caption = 'targetProject:'
    end
    object Label5: TLabel
      Left = 24
      Top = 63
      Width = 51
      Height = 13
      Caption = 'tableName'
    end
    object Label6: TLabel
      Left = 25
      Top = 142
      Width = 50
      Height = 13
      Caption = 'className'
    end
    object Label7: TLabel
      Left = 24
      Top = 116
      Width = 57
      Height = 13
      Caption = 'subPackage'
    end
    object Label2: TLabel
      Left = 463
      Top = 35
      Width = 53
      Height = 13
      Caption = 'driverClass'
    end
    object Label1: TLabel
      Left = 463
      Top = 62
      Width = 71
      Height = 13
      Caption = 'connectionURL'
    end
    object Label8: TLabel
      Left = 463
      Top = 89
      Width = 31
      Height = 13
      Caption = 'userId'
    end
    object Label9: TLabel
      Left = 463
      Top = 116
      Width = 46
      Height = 13
      Caption = 'password'
    end
    object targetPackage: TEdit
      Left = 102
      Top = 32
      Width = 333
      Height = 21
      TabOrder = 0
      Text = 'com.ecarpo.bms.ap.server.auth'
    end
    object edt_target_project: TEdit
      Left = 102
      Top = 86
      Width = 333
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
      Text = './src/main/java'
    end
    object edt_tableName: TEdit
      Left = 102
      Top = 59
      Width = 333
      Height = 21
      TabOrder = 2
      Text = 'ap_user'
    end
    object edt_className: TEdit
      Left = 102
      Top = 140
      Width = 333
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 3
    end
    object subPackage: TEdit
      Left = 102
      Top = 113
      Width = 333
      Height = 21
      TabOrder = 4
      Text = 'user'
    end
    object edtDriverClass: TEdit
      Left = 552
      Top = 32
      Width = 330
      Height = 21
      ReadOnly = True
      TabOrder = 5
      Text = 'com.mysql.jdbc.Driver'
    end
    object edtConnectionURL: TEdit
      Left = 552
      Top = 59
      Width = 330
      Height = 21
      ReadOnly = True
      TabOrder = 6
      Text = 'jdbc:mysql://127.0.0.1:3306/ecarpo_bms'
    end
    object edtUserId: TEdit
      Left = 552
      Top = 86
      Width = 330
      Height = 21
      ReadOnly = True
      TabOrder = 7
      Text = 'root'
    end
    object edtPassword: TEdit
      Left = 552
      Top = 113
      Width = 330
      Height = 21
      ReadOnly = True
      TabOrder = 8
      Text = '123456'
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 202
    Width = 900
    Height = 316
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 3
  end
end
