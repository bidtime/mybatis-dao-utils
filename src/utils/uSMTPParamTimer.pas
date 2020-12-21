unit uSMTPParamTimer;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls;

type
  TSMTPParamRec = record
    FTimerEnabled: boolean;
    FTimerIterv: integer;
    FTimerIterv_try: integer;
    FNeedConnect: boolean;
    FTimeTryNums: integer;
    //
    SMTP_Username: string; //设置登陆帐号
    SMTP_Password: string; //设置登录password
    SMTP_Host: string; //设置SMTP地址
    SMTP_Port: integer; //设置port   必须转化为整型
    SMTP_UseSSL: boolean;
    SMTP_SSL_Port: integer;
    SMTP_AuthCode: string;
    SMTP_ToUser: string;
    SMTP_AuthLogin: boolean;   // 需要登陆验证
    SMTP_UseAuthCode: boolean;
    SMTP_ConnectTimeout: integer;
    procedure init();
  end;
  TSMTPParamTimer = class
  private
    FStatusEv: TGetStrProc;
    FPopError: TGetStrProc;
    FPopInfo: TGetStrProc;
    FLogsEv: TGetStrProc;
    FErrorEv: TGetStrProc;
    FMsgSubject: string;
    FMsgBody: string;
    FIniChanged: boolean;
    FErrors: boolean;
    FTrySendNums: integer;
    function readWriteIni(const bWrite: boolean): boolean;
    procedure showStatus(const S: string);
    procedure showLogs(const S: string);
    procedure setParJson(const S: string);
    procedure Timer1OnTimer(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    FSmtpPar: TSMTPParamRec;
    FTimer1: TTimer;
    constructor Create();
    destructor Destroy(); override;
    procedure initial();
    function getParJson(): string;
    procedure startMessage(const subject, bodyText: string);
    procedure stopMessage(const subject, bodyText: string);
    procedure setParJsonStart(const S: string);
    function send(const subject, msgBody: string): boolean;

    property StatusEv: TGetStrProc read FStatusEv write FStatusEv;
    property LogsEv: TGetStrProc read FLogsEv write FLogsEv;
    property ErrorEv: TGetStrProc read FErrorEv write FErrorEv;
    property PopError: TGetStrProc read FPopError write FPopError;
    property PopInfo: TGetStrProc read FPopInfo write FPopInfo;
  end;

implementation

uses DateUtils, uFileUtils, uJsonFUtils, uJsonSUtils, System.JSON.Types,
  uDESCrypt, uSMTPUtils;

procedure TSMTPParamTimer.showLogs(const S: string);
begin
  if Assigned(self.FLogsEv) then begin
    FLogsEv(S);
  end;
end;

procedure TSMTPParamTimer.showStatus(const S: string);
begin
  if Assigned(self.FStatusEv) then begin
    FStatusEv(S);
  end;
end;

constructor TSMTPParamTimer.create();
begin
  inherited create();
  FIniChanged := false;
  FErrors := false;
  FTrySendNums := 0;
  FTimer1 := TTimer.Create(nil);
  FTimer1.OnTimer := Timer1OnTimer;
  readWriteIni(false);
end;

destructor TSMTPParamTimer.Destroy;
begin
  if (FIniChanged) then begin
    readWriteIni(true);
  end;
  FTimer1.Free;
  inherited Destroy;
end;

procedure TSMTPParamTimer.initial;
var
  S: string;
begin
  ShowLogs('smtpParamTimer: initial begin...');
  S := TJsonSUtils.Serialize<TSMTPParamRec>(FSmtpPar, TJsonFormatting.Indented);
  ShowLogs('smtpParam: ' + S);
  //
  self.FTimer1.Interval := FSmtpPar.FTimerIterv;
  self.FTimer1.Enabled := FSmtpPar.FTimerEnabled;
  //
  ShowLogs('smtpParamTimer: initial end.');
end;

function TSMTPParamTimer.readWriteIni(const bWrite: boolean): boolean;
var fileName: string;
  S: string;
begin
  fileName := TFileUtils.appFile('smtpParamTimer.json');
  if not bWrite then begin
    FSmtpPar.init();
    FSmtpPar := TJsonFUtils.DeserializeNF<TSMTPParamRec>(fileName);
    S := DeCryptStr(FSmtpPar.SMTP_Password);
    FSmtpPar.SMTP_Password := S;
    S := DeCrypTStr(FSmtpPar.SMTP_AuthCode);
    FSmtpPar.SMTP_AuthCode := S;
    Result := true;
  end else begin
    S := EnCryptStr(FSmtpPar.SMTP_Password);
    FSmtpPar.SMTP_Password := S;
    S := EnCryptStr(FSmtpPar.SMTP_AuthCode);
    FSmtpPar.SMTP_AuthCode := S;
    TJsonFUtils.SerializeF<TSMTPParamRec>(FSmtpPar, fileName, TJsonFormatting.Indented);
    Result := true;
  end;
end;

procedure TSMTPParamTimer.Timer1OnTimer(Sender: TObject);
var b: boolean;
begin
  self.FTimer1.Enabled := false;
  try
    b := send(FMsgSubject, FMsgBody);
    if (FTrySendNums = -1) then begin
      if (b) then begin
        FMsgBody := '';
      end;
    end else begin
      if (b) or (FTrySendNums >= FSmtpPar.FTimeTryNums) then begin
        FMsgBody := '';
        FTrySendNums := 0;
      end else begin
        Inc(FTrySendNums);
      end;
    end;
  finally
    self.FTimer1.Enabled := true;
  end;
end;

function TSMTPParamTimer.send(const subject, msgBody: string): boolean;

  function getNeed(const subT, bodyT: string): boolean;
  var b: boolean;
    p: TSMTPParms;
  begin
    Result := false;
    try
      p.Username := FSmtpPar.SMTP_Username;
      p.Password := FSmtpPar.SMTP_Password;
      p.Host := FSmtpPar.SMTP_Host;
      p.Port := FSmtpPar.SMTP_Port;
      p.UseSSL := FSmtpPar.SMTP_UseSSL;
      p.SSL_Port := FSmtpPar.SMTP_SSL_Port;
      p.AuthCode := FSmtpPar.SMTP_AuthCode;
      p.AuthLogin := FSmtpPar.SMTP_AuthLogin;
      p.UseAuthCode := FSmtpPar.SMTP_UseAuthCode;
      p.ConnectTimeout := FSmtpPar.SMTP_ConnectTimeout;
      b := TSMTPUtils.SendMail(p, FSmtpPar.SMTP_ToUser, subT, bodyT);
      //self.showLogs(format('send: %d [%s]-%s, %s', [FTrySendNums, subT, bodyT, boolToStr(b, true)]));
      Result := b;
    except
      on E: Exception do begin
        self.showStatus(format('send: %d [%s], error, %s', [FTrySendNums, subT, E.Message]));
        self.FErrorEv(format('send: %d [%s]-%s, error, %s', [FTrySendNums, subT, bodyT, E.Message]));
      end;
    end;
  end;

  function donotNeed(const subT, bodyT: string): boolean;
  begin
    self.showLogs(format('send: %d [%s]-%s, true, do not need send', [FTrySendNums, subT, bodyT]));
    Result := true;
  end;
begin
  Result := false;
  if msgBody.IsEmpty then begin
    exit;
  end;
  if FSmtpPar.FNeedConnect then begin
    Result := getNeed(subject, msgBody);
  end else begin
    Result := donotNeed(subject, msgBody);
  end;
end;

function TSMTPParamTimer.getParJson: string;
begin
  Result := TJsonSUtils.Serialize<TSMTPParamRec>(FSmtpPar, TJsonFormatting.Indented);
end;

procedure TSMTPParamTimer.startMessage(const subject, bodyText: string);
begin
  if not FErrors then begin
    FErrors := true;
    self.FMsgSubject := subject;
    self.FMsgBody := bodyText;
  end;
end;

procedure TSMTPParamTimer.stopMessage(const subject, bodyText: string);
begin
  if FErrors then begin
    FErrors := false;
    self.FMsgSubject := subject;
    self.FMsgBody := bodyText;
  end;
end;

procedure TSMTPParamTimer.setParJson(const S: string);
begin
  FSmtpPar := TJsonSUtils.Deserialize<TSMTPParamRec>(S);
end;

procedure TSMTPParamTimer.setParJsonStart(const S: string);
begin
  self.setParJson(S);
  FIniChanged := true;
  self.initial;
end;

{ TSMTPParamRec }

procedure TSMTPParamRec.init;
begin
  FTimerIterv := 2 * 1000;
  FTimerIterv_try := 10 * 1000;
  FTimerEnabled := false;
  FNeedConnect := false;
  FTimeTryNums := 5;
  //
  SMTP_AuthLogin := true;
  SMTP_ConnectTimeout := 30000;
  //SMTP_Username:='ecarpo_bms@tom.com'; //设置登陆帐号
  //SMTP_Password:='1qaz@WSX'; //设置登录password
  //SMTP_Host:='smtp.tom.com'; //设置SMTP地址
  SMTP_Port:=25; //设置port   必须转化为整型
end;

{initialization
finalization}

end.
