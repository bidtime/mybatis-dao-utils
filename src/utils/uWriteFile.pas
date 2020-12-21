unit uWriteFile;

interface

uses classes, sysutils, windows, IniFiles;

type
  TWriteFile = class
  private
    fWriteFile: String; //日志文件全名
    ffileflag: string;
    FOnGetStr: TGetStrProc;
    log_ThreadLock: TRTLCriticalSection; // 临界区
    log_fileStream: TFileStream;
    //log_initime: TDateTime;
    log_doerror, log_dowarn, log_dodebug, log_doinfo: Boolean;
    //
    log_fullpath: AnsiString;                 //日志文件全路径
    log_arcpath: AnsiString;                 //日志archive目录
    log_path: AnsiString;                     //日志目录
    log_level: AnsiString;                    //日志级别
    function getWriteFileExt: string;
    function getWriteFileByDay(const dt: TDateTime): string;
    function getWriteFileByDd: string;
  protected
    procedure setLogPath(const path: AnsiString);
    function getLogPath(): AnsiString;
    //procedure createLogDays(const today: TDateTime; const nDiff: integer);
    procedure log_init(const flag: string);
    procedure log4me_addLog(fName: AnsiString; p: PAnsiChar);
    procedure log4write(msg: AnsiString);
//    procedure makeFileList(Path: string; const FileExt: string; strs: TStrings;
//      const maxRows: integer);
    procedure read_write_ini(const bWrite: boolean);
    procedure setLog4Level(const level: AnsiString);
    procedure setWriteFilePath(const path: AnsiString);
    procedure zipArchFile(const fName: string);
    //procedure zipBeforeDay(const today: TDateTime);
    function zipFile2(const fName, zipName: string): boolean;               //初始化时，zip before days
  public
    constructor Create(const flag: string);
    destructor Destroy; override;
    //
    procedure  error(msg: AnsiString);                      //写ERROR级别的日志
    procedure  warn(msg: AnsiString);                       //写WARN级别的日志
    procedure  info(msg: AnsiString);                       //写INFO级别的日志
    procedure  debug(msg: AnsiString);                      //写DEBUG级别的日志
    procedure setLogLevel(const level: AnsiString);
    function getLogLevel(): String;
    function  getLog4FileName(): AnsiString; //得到当前日志文件全名
    property OnGetStr: TGetStrProc read FOnGetStr write FOnGetStr;
  end;

implementation

uses DateUtils, zip;

function getRootDir: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

procedure TWriteFile.setWriteFilePath(const path: AnsiString);
begin
  log_path := path;
  log_fullpath := getRootDir() + log_path + '\';
  log_arcpath := log_fullpath + 'archive' + '\';
  ForceDirectories(log_fullpath);
  ForceDirectories(log_arcpath);
end;

procedure TWriteFile.setLog4Level(const level: AnsiString);
begin
  log_doerror :=  (level = 'debug') or (level = 'info') or (level = 'warn') or (level = 'error');
  log_dowarn :=  (level = 'debug') or (level = 'info') or (level = 'warn');
  log_doinfo  :=  (level = 'debug') or (level = 'info');
  log_dodebug :=  (level = 'debug');
  if (not log_doerror) and (not log_dowarn) and (not log_doinfo)
    and (not log_dodebug) then begin
    raise Exception.Create('日志级别必需是：debug、info、warn、error');
  end;
  log_level := level;
end;

function TWriteFile.getWriteFileByDay(const dt: TDateTime): string;
begin
  //Result := log_fullpath + FormatDateTime('yyyy-mm-dd hh:nn:ss', dt) + getWriteFileExt;
  Result := log_fullpath + FormatDateTime('yyyy-mm-dd', dt) + getWriteFileExt;
end;

function TWriteFile.getWriteFileByDd(): string;
begin
  Result := log_fullpath + getWriteFileExt;
end;

function TWriteFile.getWriteFileExt(): string;
begin
  if ffileflag.IsEmpty then begin
    Result := '.log';
  end else begin
    Result := '_' + ffileflag + '.log';
  end;
end;

procedure TWriteFile.read_write_ini(const bWrite: boolean);

  procedure readIni(iniFile: TIniFile);
  var path, level: string;
  begin
    path := iniFile.ReadString('log4me', 'path', 'log');
    level := LowerCase(iniFile.ReadString('log4me', 'level', 'info'));
    //
    setWriteFilePath(path);
    setLog4Level(level);
  end;

  procedure writeIni(iniFile: TIniFile);
  begin
    iniFile.WriteString('log4me', 'path', log_path);
    iniFile.WriteString('log4me', 'level', log_level);
  end;

var fileName: string;
  iniFile: TIniFile;
begin
  fileName := getRootDir() + '\' + 'log4me.ini';
  iniFile := Tinifile.Create(filename);
  try
    if not bWrite then begin
      readIni(iniFile);
    end else begin
      writeIni(iniFile);
    end;
  finally
    iniFile.Free;
  end;
end;

function TWriteFile.zipFile2(const fName: string; const zipName: string): boolean;
var
  zf:TZipFile;
begin
  Result := false;
  zf := TZipFile.Create;
  try
    try
      //创建ZIP压缩文件
      zf.Open(zipName, zmWrite);
      zf.Add(fName);
      zf.Close;
      Result := true;
    except
      on E: Exception do begin
        error('zipfile2: ' + e.Message);
      end;
    end;
  finally
    zf.Free;
  end;
end;

procedure TWriteFile.zipArchFile(const fName: string);
var zipName: string;
  i: integer;
begin
  if FileExists(fName) then begin
    i := 0;
    repeat
      zipName := log_arcpath + ExtractFileName(
        ChangeFileExt(fName, inttostr(i) + '.zip'));
      Inc(i);
    until not FileExists(zipName);
    if (zipFile2(fName, zipName)) then begin
      DeleteFile(PChar(fName));
    end;
  end;
end;

procedure TWriteFile.log_init(const flag: string);
begin
  ffileflag := flag;
  fWriteFile := '';
  log_doerror := False;

  log_dowarn := False;
  log_dodebug := False;
  log_doinfo := False;
  //
  read_write_ini(false);
end;

procedure TWriteFile.setLogLevel(const level: AnsiString);
begin
  setLog4Level(level);
  read_write_ini(true);
end;

function TWriteFile.getLogLevel(): String;
begin
  Result := log_level;
end;

procedure TWriteFile.setLogPath(const path: AnsiString);
begin
  setWriteFilePath(path);
  read_write_ini(true);
end;

function TWriteFile.getLogPath(): AnsiString;
begin
  Result := log_path;
end;

procedure TWriteFile.log4me_addLog(fName: AnsiString; p: PAnsiChar);

  procedure writeFileLog();
  var
    fmode :Word;
    tmp: AnsiString;
  begin
    try
      //如果要写的日志文件和打开的不同（在程序第一次运行和跨天的时候出现）
      //则关闭打开的日志文件。
      if not SameText(fName, fWriteFile) then begin
        if Assigned(log_fileStream) then begin
          log_fileStream.Free;
          log_fileStream := nil;
        end;
        //
        fWriteFile := fName;
      end;

      //如果要写的日志文件没有打开（在程序第一次运行和跨天的时候出现）
      //则打开日志文件。
      if not Assigned(log_fileStream) then begin
         if FileExists(fWriteFile) then begin
           fmode := fmOpenWrite or fmShareDenyNone
         end else begin
           fmode := fmCreate or fmShareDenyNone ;
         end;
        log_fileStream := TFileStream.Create(fWriteFile, fmode);
        log_fileStream.Position := log_fileStream.Size;
      end;
      //在日志文件中写入日志
      log_fileStream.Write(p^, strlen(p));
    except
      on E:Exception do begin
        try
          tmp := getRootDir() + '\' + 'log4me_err.log';
          if FileExists(tmp) then begin
             fmode := fmOpenWrite or fmShareDenyNone;
          end else begin
             fmode := fmCreate or fmShareDenyNone ;
          end;
          with TFileStream.Create(tmp, fmode) do begin
            Position := Size;
            tmp := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' ' +  E.Message + #13#10;
            Write(tmp[1], Length(tmp));
            Free;
          end;
        except
        end;
      end;
    end;
  end;
begin
  EnterCriticalSection(log_ThreadLock);    //进入临界区，多线程时可以保护资源
  try
    writeFileLog();
  finally
    LeaveCriticalSection(log_ThreadLock);  //无论如何，离开临界区
  end;
end;

procedure TWriteFile.log4write(msg: AnsiString);
begin
  if Assigned(self.FOnGetStr) then begin
    FOnGetStr(msg);
  end;
  //写到当天的日志文件中
  log4me_addLog(getWriteFileByDd(), PAnsiChar(msg + #13#10));
end;

//-----下面4个是对外方法-------------------------

function TWriteFile.getLog4FileName(): AnsiString;
begin
  Result := fWriteFile;
end;

procedure TWriteFile.error(msg: AnsiString);
begin
  if log_doerror then begin
    log4write(msg);
  end;
end;

procedure TWriteFile.warn(msg: AnsiString);
begin
  if log_dowarn then begin
    log4write(msg);
  end;
end;

procedure TWriteFile.info(msg: AnsiString);
begin
  if log_doinfo then begin
    log4write(msg);
  end;
end;

procedure TWriteFile.debug(msg: AnsiString);
begin
  if log_dodebug then begin
    log4write(msg);
  end;
end;

constructor TWriteFile.Create(const flag: string);
begin
  inherited create;
  log_fileStream := nil;
  InitializeCriticalSection(log_ThreadLock);
  zipArchFile(self.getWriteFileByDay(now));
  log_init(flag);
  debug('-- ' + FormatDateTime('hh:nn:ss.zzz', now) + ' ' + ' start ');
end;

destructor TWriteFile.Destroy;
begin
  DeleteCriticalSection(log_ThreadLock);
  if Assigned(log_fileStream) then begin
    log_fileStream.Free;
  end;
  zipArchFile(self.getWriteFileByDay(now));
  inherited;
end;

end.
