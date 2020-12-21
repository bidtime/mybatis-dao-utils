unit uFrmMain;

interface

uses Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.Menus, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdActns, Vcl.ActnList, Vcl.ToolWin, System.ImageList,
  System.Actions, Messages, uAppConst, ufrmSetting, FireDAC.VCLUI.Memo;

type
  TfrmMain = class(TForm)
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ToolBar1: TToolBar;
    ToolButton9: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ActionList1: TActionList;
    FileNew1: TAction;
    FileOpen1: TAction;
    FileSave1: TAction;
    FileSaveAs1: TAction;
    FileExit1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    HelpAbout1: TAction;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    Help1: TMenuItem;
    HelpAboutItem: TMenuItem;
    memoLogs: TMemo;
    ToolButton7: TToolButton;
    Button1: TButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    actnFileProps: TAction;
    TrayIcon1: TTrayIcon;
    PopupMenu: TPopupMenu;
    miProperties: TMenuItem;
    MenuItem1: TMenuItem;
    miClose: TMenuItem;
    Button2: TButton;
    ToolButton11: TToolButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    targetPackage: TEdit;
    edt_target_project: TEdit;
    edt_tableName: TEdit;
    edt_className: TEdit;
    subPackage: TEdit;
    edtDriverClass: TEdit;
    edtConnectionURL: TEdit;
    edtUserId: TEdit;
    edtPassword: TEdit;
    TabSheet2: TTabSheet;
    memoUpdateMapper: TFDGUIxFormsMemo;
    TabSheet3: TTabSheet;
    memoSqlFormat: TFDGUIxFormsMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    memoResult: TMemo;
    ToolButton12: TToolButton;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actnFilePropsExecute(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miPropertiesClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FClosing: Boolean;
    //FProgmanOpen: Boolean;
    FFromService: Boolean;
    NT351: Boolean;
    FFrmSetting: TfrmSetting;
    procedure addLog(const S: string; const clear: boolean); overload;
    procedure addLog(const S: string); overload;
    procedure setMsg(const S: string);
    function readWriteIni(const bWrite: boolean): boolean;
    procedure ShowStatus(const S: string);
    //
    procedure UIInitialize(var Message: TMessage); message UI_INITIALIZE;
    //定义系统消息
    procedure SysCommand(var SysMsg: TMessage); message WM_SYSCOMMAND;
    procedure errorHintS(const S: string; const sec: integer); overload;
    procedure infoHintS(const S: string; const sec: integer); overload;
    procedure errorHintS(const S: string); overload;
    procedure infoHintS(const S: string); overload;
    procedure addError(const S: string);
    { Private declarations }
    procedure doMybatisMapper;
    procedure doSqlFormat;
    procedure doUpdateMap;
  public
    { Public declarations }
    procedure Initialize(const FromService: Boolean);
    procedure popHint(const S: string; const bf: TBalloonFlags;
      const tmSecs: integer);  //系统消息
  end;

var
  frmMain: TfrmMain;

implementation

uses uFrmAboutbox, uFormIniFiles, SysUtils, uFileUtils, uLog4me;

{$R *.dfm}

procedure TfrmMain.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;

procedure TfrmMain.FileOpen1Execute(Sender: TObject);
begin
  OpenDialog.Execute;
end;

procedure TfrmMain.FileSave1Execute(Sender: TObject);
begin
  SaveDialog.Execute;
end;

procedure TfrmMain.addLog(const S: string; const clear: boolean);
begin
  if clear then begin
    memoLogs.clear;
  end;
  if memoLogs.Lines.Count>5000 then begin
    memoLogs.Lines.Delete(memoLogs.Lines.Count-1);
  end;
  memoLogs.Lines.Insert(0, FormatDateTime('yyyy-mm-dd hh:nn:ss ', now())  + S );
end;

procedure TfrmMain.actnFilePropsExecute(Sender: TObject);
//var sHttpParam, sSMTPParam: string;
begin
  {sHttpParam := FHttpParamTimer.getParJson();
  sSMTPParam := FSMTPParamTimer.getParJson();
  if TFrmHttpParam.showNewModel(sHttpParam, sSMTPParam) then begin
    FHttpParamTimer.setParJsonStart(sHttpParam);
    FSMTPParamTimer.setParJsonStart(sSMTPParam);
  end;}
  FFrmSetting.showModal;
end;

procedure TfrmMain.addLog(const S: string);
begin
  TLog4me.debug(S);
  addLog(S, false);
end;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  if self.PageControl1.ActivePageIndex=0 then begin
    self.memoResult.Clear;
  end else if self.PageControl1.ActivePageIndex=1 then begin
    self.memoResult.Clear;
  end else if self.PageControl1.ActivePageIndex=2 then begin
    self.memoResult.Clear;
  end else begin
    ShowMessage('请选中标签页，再操作！');
  end;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  if self.PageControl1.ActivePageIndex=0 then begin
    doMybatisMapper();
  end else if self.PageControl1.ActivePageIndex=1 then begin
    doUpdateMap;
  end else if self.PageControl1.ActivePageIndex=2 then begin
    doSqlFormat();
  end else begin
    ShowMessage('请选中标签页，再操作！');
  end;
end;

procedure TfrmMain.addError(const S: string);
begin
  TLog4me.error(S);
  addLog(S, false);
end;

procedure TfrmMain.ShowStatus(const S: string);
var str: string;
begin
  str := FormatDateTime('yyyy-mm-dd hh:nn:ss ', now()) + S ;
  //ShowPanel(str, 1);
  self.StatusBar.SimpleText := str;
  //addLog(S);
end;

procedure TfrmMain.SysCommand(var SysMsg: TMessage);
begin
  case SysMsg.WParam of
   SC_MINIMIZE: begin  //如果单击最小化的时候
     //self.TrayIcon1.Visible := true;
     self.Visible := not self.Visible;//互斥，就是你有我没有你没有我就有
     end;
//   SC_CLOSE: begin
     //self.TrayIcon1.Visible := true;
   //  self.Visible := not self.Visible;//互斥，就是你有我没有你没有我就有
   else begin
     inherited;
   end;
  end;
end;

procedure TfrmMain.TrayIcon1DblClick(Sender: TObject);
begin
  miPropertiesClick(miProperties);
end;

procedure TfrmMain.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var pt: TPoint;
begin
  if Button = mbRight then begin
    //if not Visible then begin
      //SetForegroundWindow(Handle);
      GetCursorPos(pt);
      PopupMenu.Popup(pt.x, pt.y);
    //end else begin
    //  SetForegroundWindow(Handle);
    //end;
  end;
end;

procedure TfrmMain.UIInitialize(var Message: TMessage);
var b: boolean;
begin
  b := (Message.WParam <> 0);
  //TLog4Me.info('p:' + IntToStr(Message.WParam));
  //TLog4Me.info('b:' + BoolToStr(b, true));
  Initialize(b);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  TFormIniFiles.rwIni(self, false);
  FClosing := False;
  addLog('', true);
  FFrmSetting := TfrmSetting.Create(self);
  //
  readWriteIni(false);
  //self.TrayIcon1.Hint := self.Caption;
  //self.TrayIcon1.Icon.Handle := Forms.Application.Icon.Handle;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  TFormIniFiles.rwIni(self, true);
  readWriteIni(true);
  FFrmSetting.free;
end;

procedure TfrmMain.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.HelpAbout1Execute(Sender: TObject);
begin
  TFrmAboutBox.showNewForm;
end;

procedure TfrmMain.Initialize(const FromService: Boolean);
begin
  FFromService := FromService;
  NT351 := (Win32MajorVersion <= 3) and (Win32Platform = VER_PLATFORM_WIN32_NT);
  if NT351 then begin
    if not FromService then begin
      raise Exception.CreateRes(@SServiceOnly);
    end;
    BorderIcons := BorderIcons + [biMinimize];
    BorderStyle := bsSingle;
  end;
  //ReadSettings;
  if FromService then begin
    miClose.Visible := False;
    N1.Visible := False;
  end;
end;

procedure TfrmMain.miCloseClick(Sender: TObject);
begin
  FClosing := True;
  Close;
end;

procedure TfrmMain.miPropertiesClick(Sender: TObject);
begin
  //Show;
  self.Visible := not self.Visible;
  if Visible then begin
    SetForegroundWindow(Handle);
  end;
end;

function TfrmMain.readWriteIni(const bWrite: boolean): boolean;
begin
end;

procedure TfrmMain.setMsg(const S: string);
begin
  addLog(S);
end;

procedure TfrmMain.popHint(const S: string; const bf: TBalloonFlags; const tmSecs: integer);
begin
  TrayIcon1.Animate:=true;
  TrayIcon1.BalloonFlags := bf;
  //TrayIcon1.Hint := self.Caption;
  //bfNone = NIIF_NONE, bfInfo = NIIF_INFO, bfWarning = NIIF_WARNING, bfError = NIIF_ERROR
  if bf = bfError then begin
    TrayIcon1.BalloonTitle := '错误';
  end else if bf = bfWarning then begin
    TrayIcon1.BalloonTitle := '警告';
  end else begin
    TrayIcon1.BalloonTitle := '提示';
  end;
  TrayIcon1.BalloonHint := S;
  TrayIcon1.BalloonTimeout := tmSecs;
  TrayIcon1.ShowBalloonHint;
end;

procedure TfrmMain.infoHintS(const S: string; const sec: integer);
begin
  popHint(S, bfInfo, sec * 1000);
end;

procedure TfrmMain.errorHintS(const S: string; const sec: integer);
begin
  popHint(S, bfError, sec * 1000);
end;

procedure TfrmMain.errorHintS(const S: string);
begin
  errorHintS(S, 30);
end;

procedure TfrmMain.infoHintS(const S: string);
begin
  infoHintS(S, 30);
end;

procedure TfrmMain.doMybatisMapper();

  function getDAOXML(const driverClass, connectionURL, userId, password: string;
    const targetProject, entitySubPackage, daoSubPackage: string;
    const tableName: string; const clzNameDO, clzNameDAO: string): string;
  begin
    Result := format(self.FFrmSetting.memoSqlMap.text, [
      // connection
      driverClass, connectionURL, userId, password,

      // DAO
      tableName,
      entitySubPackage, targetProject,
      daoSubPackage, targetProject,
      daoSubPackage, targetProject,
      tableName, clzNameDO, clzNameDAO,

      tableName]);
  end;

    function getFirstUpper(const S: string): string;
    var str: string;
    begin
      str := s.Substring(0,1);
      result := String.UpperCase(str) + s.Substring(1);
    end;

    function getClassName(const S: string): string;
    var
      strs: TStrings;
      i: integer;
    begin
      Result := '';
      strs := TStringList.Create();
      try
        strs.Delimiter := '_';
        strs.DelimitedText := S;
        strs.StrictDelimiter := true;
        for I := 0 to strs.Count - 1 do begin
          Result := Result + getFirstUpper(strs[i]);
        end;
      finally
        strs.Free;
      end;
    end;

    function getSubPackage(const S: string): string;
    var
      strs: TStrings;
      i: integer;
    begin
      Result := '';
      strs := TStringList.Create();
      try
        strs.Delimiter := '_';
        strs.DelimitedText := S;
        strs.StrictDelimiter := true;
        for I := 1 to strs.Count - 1 do begin
          Result := Result + String.LowerCase(strs[i]);
        end;
      finally
        strs.Free;
      end;
    end;

  function getDAOSection(): string;
  var cur_subpackage, entitySubPackage, daoSubPackage: string;
    className, classNameDO, classNameDAO: string;
  begin
    className := getClassName(edt_tableName.Text);
    edt_className.Text := className;

    classNameDO := className + 'DO';
    classNameDAO := className + 'Mapper';

    subPackage.text := getSubPackage(edt_tableName.Text);
    cur_subpackage := targetPackage.Text + '.' + subPackage.text;
    entitySubPackage := cur_subpackage + '.' + 'entity';
    daoSubPackage := cur_subpackage + '.' + 'dao';
    {
    const targetProject, entitySubPackage, daoSubPackage, tableAlias: string;
    const tableName: string; const clzName: string
    }
    Result := getDAOXML(self.edtDriverClass.Text,
      self.edtConnectionURL.Text,
      self.edtUserId.Text,
      self.edtPassword.text,
      self.edt_target_project.Text,
      entitySubPackage, daoSubPackage,
      edt_tableName.text, classNameDO, classNameDAO);
  end;

begin
  self.memoResult.Text := getDAOSection();
end;

procedure TfrmMain.doSqlFormat();

  procedure doIt(str1, str2: TStrings);
  var i: integer;
    S, ident: string;
  begin
    ident := self.FFrmSetting.getIdent;
    for I := 0 to str1.Count - 1 do begin
      S := str1[I];
      if ffrmSetting.clearBlank then begin
        if (String.IsNullOrWhiteSpace(S)) then begin
          Continue;
        end else begin
          str2.Add(ident + S);
        end;
      end else begin
        str2.Add(ident + S);
      end;
    end;
  end;

//var pkMap: TDictionary<string, string>;
begin
  memoResult.Clear;
  setMsg('prepare do it...');
  //pkMap := TDictionary<string, string>.Create;
  try
    setMsg('get table pro...');
    doIt(self.memoSqlFormat.Lines, self.memoResult.Lines);
    //prepareIt(MemoRaw.Lines, pkMap, MemoSql.Lines);
    setMsg('doing it...');
    //doneProLines(MemoSql.Lines, pkMap);
  finally
    //pkMap.free;
  end;
  setMsg('done.');
end;
procedure TfrmMain.doUpdateMap();

  function getLeftStr(const S: string; const c: string): string;
  var pos1: integer;
  begin
    pos1 := s.IndexOf(c);
    Result := s.Substring(0, pos1);
  end;

  function geMiddleStrReplace(const S: string; const c: string): string;
    function getPropKey(const S: string): string;
    var key: string;
    begin
      key := getLeftStr(S, ' ');
      //Result := 'keys.containsKey(%s)';
      Result := String.Format('keys.containsKey(%s)', [QuotedStr(key)]);
    end;
  var pos1, pos2: integer;
    middl, prop: string;
  begin
    pos1 := s.IndexOf(c);
    pos2 := s.LastIndexOf(c);
    middl := s.Substring(pos1+1, pos2-pos1-1);
    prop := getPropKey(middl);
    Result := s.Substring(0, pos1) + '"' + prop + '"' + s.Substring(pos2+1);
  end;

  //#{departId,jdbcType=BIGINT}
  function getParam(const S: string): string;
    function getPropKey(const S: string): string;
    begin
      Result := String.Format('keys.%s', [S]);
    end;
  var pos1, pos2: integer;
    middl, prop: string;
  begin
    pos1 := s.IndexOf('{');
    pos2 := s.IndexOf(',');
    middl := s.Substring(pos1+1, pos2-pos1-1);
    prop := getPropKey(middl);
    Result := s.Substring(0, pos1+1) + prop + s.Substring(pos2);
  end;

  function doOne(const S: string): string;
  begin
    Result := geMiddleStrReplace(S, '"');
  end;

  function getSpace(const S: string): string;
  begin
    Result := getLeftStr(S, '<update');
  end;

  function getUpdateId(): string;
  begin
    if self.FFrmSetting.rbUpdateMap.Checked then begin
      Result := 'updateMap';
    end else if self.FFrmSetting.rbUpdateForVer.Checked then begin
      Result := 'updateForVer';
    end else begin
      raise Exception.Create('请选择选项');
    end;
  end;

  procedure doIt(str1, str2: TStrings);
  var i: integer;
    S1, str, rst: string;
  begin
    //ident := self.FFrmSetting.getIdent;
    for I := 0 to str1.Count - 1 do begin
      str := str1[I];
      S1 := str.Trim;
      //str := s
      if S1.StartsWith('<!-- @mbg.generated') then begin
        continue;
      end;
      if S1.StartsWith('<update id=') then begin
        rst := '<update id="%s" parameterType="java.util.Map">';
        rst := format(rst, [getUpdateId()]);
        str2.Add(getSpace(str) + rst);
      end else if S1.StartsWith('<if test') then begin
        rst := doOne(str);
        str2.Add(rst);
      //end else if (hit) then begin
      //  rst := S.replace(key, 'keys.'+key);
      //  str2.Add(rst);
      end else if S1.StartsWith('</if>') then begin
        str2.Add(str);
      end else if S1.Contains('#{') then begin
        rst := getParam(Str);
        str2.Add(rst);
      end else begin
        str2.Add(str);
      end;
    end;
  end;

//var pkMap: TDictionary<string, string>;
begin
  memoResult.Clear;
  setMsg('prepare do it...');
  //pkMap := TDictionary<string, string>.Create;
  try
    setMsg('get table pro...');
    doIt(self.memoUpdateMapper.Lines, self.memoResult.Lines);
    //prepareIt(MemoRaw.Lines, pkMap, MemoSql.Lines);
    setMsg('doing it...');
    //doneProLines(MemoSql.Lines, pkMap);
  finally
    //pkMap.free;
  end;
  setMsg('done.');
end;

end.
