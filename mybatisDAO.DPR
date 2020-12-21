program mybatisDAO;

uses
  Forms,
  Windows,
  WinSvc,
  SvcMgr,
  SysUtils,
  uFrmMain in 'src\frm\uFrmMain.PAS' {frmMain},
  uCharSplit in 'src\utils\uCharSplit.pas',
  uCharUtils in 'src\utils\uCharUtils.pas',
  uDateUtils in 'src\utils\uDateUtils.pas',
  uFileUtils in 'src\utils\uFileUtils.pas',
  uFormIniFiles in 'src\utils\uFormIniFiles.pas',
  uWriteFile in 'src\utils\uWriteFile.pas',
  uAppConst in 'src\utils\uAppConst.pas',
  uLog4me in 'src\utils\log\uLog4me.pas',
  uLogFile in 'src\utils\log\uLogFile.pas',
  uInstanceService in 'src\utils\uInstanceService.pas',
  uFrmAboutBox in 'src\frm\uFrmAboutBox.pas' {FrmAboutBox},
  uVerInfo in 'src\utils\uVerInfo.pas',
  uFrmSetting in 'src\frm\uFrmSetting.pas' {frmSetting};

{$R *.RES}

function Installing: Boolean;
begin
  Result := FindCmdLineSwitch('INSTALL',['-','\','/'], True) or
            FindCmdLineSwitch('UNINSTALL',['-','\','/'], True);
end;

function StartService: Boolean;
var
  Mgr, Svc: Integer;
  UserName, ServiceStartName: string;
  Config: Pointer;
  Size: DWord;
begin
  Result := False;
  Mgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if Mgr <> 0 then begin
    Svc := OpenService(Mgr, PChar(SServiceName), SERVICE_ALL_ACCESS);
    Result := Svc <> 0;
    if Result then begin
      QueryServiceConfig(Svc, nil, 0, Size);
      Config := AllocMem(Size);
      try
        QueryServiceConfig(Svc, Config, Size, Size);
        ServiceStartName := PQueryServiceConfig(Config)^.lpServiceStartName;
        if CompareText(ServiceStartName, 'LocalSystem') = 0 then
          ServiceStartName := 'SYSTEM';
      finally
        Dispose(Config);
      end;
      CloseServiceHandle(Svc);
    end;
    CloseServiceHandle(Mgr);
  end;
  if Result then begin
    Size := 256;
    SetLength(UserName, Size);
    GetUserName(PChar(UserName), Size);
    SetLength(UserName, StrLen(PChar(UserName)));
    Result := CompareText(UserName, ServiceStartName) = 0;
  end;
end;

begin
  if not Installing then begin
    CreateMutex(nil, True, 'mybatis_dao_0.1');
    if GetLastError = ERROR_ALREADY_EXISTS then begin
      MessageBox(0, PChar(SAlreadyRunning), SApplicationName, MB_ICONERROR);
      Halt;
    end;
  end;
  if Installing or StartService then begin
    SvcMgr.Application.Initialize;
    g_InstanceService := TInstanceService.CreateNew(SvcMgr.Application, 0);
    SvcMgr.Application.CreateForm(TFrmMain, FrmMain);
  SvcMgr.Application.Run;
  end else begin
    //Forms.Application.MainFormOnTaskbar := false;
    //Forms.Application.ShowMainForm := False;
    Forms.Application.Initialize;
    //Forms.Application.CreateForm(TFrmMain, FrmMain);
    //Application.CreateForm(TdmHttpUtils, dmHttpUtils);
    Application.CreateForm(TfrmMain, frmMain);
   //Application.CreateForm(TAboutBox, AboutBox);
    frmMain.Initialize(False);
    Forms.Application.Run;
  end;
end.
 
