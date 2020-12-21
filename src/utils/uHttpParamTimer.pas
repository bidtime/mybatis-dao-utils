unit uHttpParamTimer;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls;

type
  THttpParamRec = record
    FTimerEnabled: boolean;
    FTimerIterv: integer;
    FTimerIterv_try: integer;
    FNeedConnect: boolean;
    FServerUrl: string;
    FShowRespText: boolean;

    procedure init();
  end;
  THttpParamTimer = class
  private
    FStatusEv: TGetStrProc;
    FPopError: TGetStrProc;
    FPopInfo: TGetStrProc;
    FLogsEv: TGetStrProc;
    FErrorEv: TGetStrProc;
    FSendMailEv: TGetStrProc;
    FSuccessEv: TGetStrProc;
    function readWriteIni(const bWrite: boolean): boolean;
    procedure showStatus(const S: string);
    procedure showLogs(const S: string);
    function mergQuery(const url: string): string;
    procedure setParJson(const S: string);
    procedure Timer1OnTimer(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    HttpPar: THttpParamRec;
    FTimer1: TTimer;
    constructor Create();
    destructor Destroy(); override;
    procedure initial();
    procedure get(const u: string); overload;
    procedure get(); overload;

    function getParJson(): string;
    procedure setParJsonStart(const S: string);

    property StatusEv: TGetStrProc read FStatusEv write FStatusEv;
    property LogsEv: TGetStrProc read FLogsEv write FLogsEv;
    property ErrorEv: TGetStrProc read FErrorEv write FErrorEv;
    property PopError: TGetStrProc read FPopError write FPopError;
    property PopInfo: TGetStrProc read FPopInfo write FPopInfo;
    property SendMailEv: TGetStrProc read FSendMailEv write FSendMailEv;
    property SuccessEv: TGetStrProc read FSuccessEv write FSuccessEv;
  end;

implementation

uses uFileUtils, uJsonFUtils, uIdUtils, uHttpUtils, uHttpException, uJsonSUtils, System.JSON.Types;

procedure THttpParamTimer.showLogs(const S: string);
begin
  if Assigned(self.FLogsEv) then begin
    FLogsEv(S);
  end;
end;

procedure THttpParamTimer.showStatus(const S: string);
begin
  if Assigned(self.FStatusEv) then begin
    FStatusEv(S);
  end;
  //Inc(FDivTimer);
end;

constructor THttpParamTimer.create();
begin
  inherited create();
  FTimer1 := TTimer.Create(nil);
  FTimer1.OnTimer := Timer1OnTimer;
  readWriteIni(false);
end;

destructor THttpParamTimer.Destroy;
begin
  //readWriteIni(true);
  FTimer1.Free;
  inherited Destroy;
end;

procedure THttpParamTimer.initial;
var
  S: string;
begin
  ShowLogs('httpParamTimer: initial begin...');
  S := TJsonSUtils.Serialize<THttpParamRec>(HttpPar, TJsonFormatting.Indented);
  ShowLogs('HttpParam: ' + S);
  //
  self.FTimer1.Interval := HttpPar.FTimerIterv;
  self.FTimer1.Enabled := HttpPar.FTimerEnabled;
  //
  ShowLogs('httpParamTimer: initial end.');
end;

procedure THttpParamTimer.get;
begin
  self.get(HttpPar.FServerUrl);
end;

function THttpParamTimer.readWriteIni(const bWrite: boolean): boolean;
var fileName: string;
begin
  fileName := TFileUtils.appFile('httpParamTimer.json');
  if not bWrite then begin
    HttpPar.init();
    HttpPar := TJsonFUtils.DeserializeNF<THttpParamRec>(fileName);
    Result := true;
  end else begin
    TJsonFUtils.SerializeF<THttpParamRec>(HttpPar, fileName, TJsonFormatting.Indented);
    Result := true;
  end;
end;

procedure THttpParamTimer.Timer1OnTimer(Sender: TObject);

  procedure getNeed(const u: string);
  var S, url: string;
  begin
    try
      url := mergQuery(u);
      S := THttpUtils.get(url, 5000, 8000, TEncoding.UTF8);
      //
      FSuccessEv(format('get: %s, ok', [url]));
      self.showStatus(format('get: %s, ok', [url]));
      if HttpPar.FShowRespText then begin
        self.showLogs(format('get: %s, ok, %s', [url, S]));
      end else begin
        self.showLogs(format('get: %s, ok', [url]));
      end;
      //
      if self.FTimer1.Interval<>HttpPar.FTimerIterv then begin
        self.FTimer1.Interval := HttpPar.FTimerIterv;
      end;
    except
      on E: THttpBreakException do begin
        self.showStatus(format('get: %s, error, %d', [url, THttpBreakException(E).statusCode]));
        self.FErrorEv(format('get: %s, error, %s', [url, E.Message]));
        if self.FTimer1.Interval<>HttpPar.FTimerIterv_try then begin
          self.FTimer1.Interval := HttpPar.FTimerIterv_try;
        end;
        //
        if Assigned(FSendMailEv) then begin
          FSendMailEv(format('get: %s, error, %s', [url, E.Message]));
        end;
      end;
      on E: Exception do begin
        self.showStatus(format('get: %s, error, %s', [url, E.Message]));
        self.FErrorEv(format('get: %s, error, %s', [url, E.Message]));
        //
        if Assigned(FSendMailEv) then begin
          FSendMailEv(format('get: %s, error, %s', [url, E.Message]));
        end;
      end;
    end;
  end;

  procedure donotNeed(const url: string);
  begin
    self.showStatus(format('get: %s, do not need get', [url]));
    self.showLogs(format('get: %s, do not need get', [url]));
  end;

begin
  if HttpPar.FNeedConnect then begin
    getNeed(HttpPar.FServerUrl);
  end else begin
    donotNeed(HttpPar.FServerUrl);
  end;
end;

procedure THttpParamTimer.get(const u: string);
var S, url: string;
begin
  try
    url := mergQuery(u);
    S := THttpUtils.get(url, 10000, 10000, TEncoding.UTF8);
    self.showStatus(format('get: %s, ok', [url]));
    if HttpPar.FShowRespText then begin
      self.showLogs(format('get: %s, ok, %s', [url, S]));
    end else begin
      self.showLogs(format('get: %s, ok', [url]));
    end;
  except
    on E: THttpBreakException do begin
      self.showStatus(format('get: %s, error, %d', [url, THttpBreakException(E).statusCode]));
      self.FErrorEv(format('get: %s, error, %s', [url, E.Message]));
      FPopError(format('get: %s, error, %s', [url, E.Message]));
    end;
    on E: Exception do begin
      self.showStatus(format('get: %s, error, %s', [url, E.Message]));
      self.FErrorEv(format('get: %s, error, %s', [url, E.Message]));
      FPopError(format('get: %s, error, %s', [url, E.Message]));
      if Assigned(FSendMailEv) then begin
        FSendMailEv(format('get: %s, error, %s', [url, E.Message]));
      end;
    end;
  end;
end;

function THttpParamTimer.mergQuery(const url: string): string;
begin
  Result := url + '?' + 't=' + TIdUtils.getNewIdS;
end;

function THttpParamTimer.getParJson: string;
begin
  Result := TJsonSUtils.Serialize<THttpParamRec>(HttpPar, TJsonFormatting.Indented);
end;

procedure THttpParamTimer.setParJson(const S: string);
begin
  HttpPar := TJsonSUtils.Deserialize<THttpParamRec>(S);
end;

procedure THttpParamTimer.setParJsonStart(const S: string);
begin
  self.setParJson(S);
  self.initial;
  self.readWriteIni(true);
end;

{ THttpParamRec }

procedure THttpParamRec.init;
begin
  FTimerIterv := 4 * 60 * 1000;
  FTimerIterv_try := 10 * 1000;
  FTimerEnabled := false;
  FShowRespText := false;
  FServerUrl := 'http://47.92.90.248:6788/ormrpc/services';
  FNeedConnect := false;
end;

{initialization
finalization}

end.
