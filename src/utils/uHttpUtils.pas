unit uHttpUtils;

interface

uses
  Classes, System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.mime, SysUtils;

type
  TMyHttpClient = class(TNetHTTPClient)
  private
    FOK: boolean;
    function postGet(const url, method: string; const ob: TObject;
      const tmConn, tmRes: integer; const encode: TEncoding): string;
    procedure DoOnRequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure DoOnRequestError(const Sender: TObject; const AError: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    class constructor create;
  end;

  THttpUtils = class
  private
    { Private declarations }
    class var fCookie: string;
  public
    { Public declarations }
    class function get(const url: string; const ob: TObject; const tmConn,
      tmRes: integer; const encode: TEncoding): string; overload; static;
    class function get(const url: string; const tmConn,
      tmRes: integer; const encode: TEncoding): string; overload; static;
    class function postGet(const url, method: string; const ob: TObject;
      const tmConn, tmRes: integer; const encode: TEncoding): string; static;
    class constructor create;
    class destructor destroy;
    class function postJson(const url, S: string; const tmConn,
      tmRes: integer): string; static;
    class function post(const url: string;
      const ob: TObject; const tmConn, tmRes: integer): string; overload;
    class function post(const url: string; const ob: TObject;
      const tmConn, tmRes: integer; const encode: TEncoding): string; overload;
    class function upload(const url, fileName: String; const tmConn: integer;
      const tmRes: integer): string;
    class function post(const url, S: string; const tmConn, tmRes: integer):
      string; overload; static;
    class function get(const url: string; const S: string; const tmConn, tmRes:
      integer): string; overload;
    class procedure addCookie(const cookie: string);
  end;

var
  g_closed: boolean = false;
  p_closed: ^boolean = @g_closed;

implementation

uses System.NetConsts, System.Net.URLClient, Forms, uHttpException;//, uLog4me;

class procedure THttpUtils.addCookie(const cookie: string);
begin
  THttpUtils.fCookie := cookie;
end;

class constructor THttpUtils.create;
begin
  inherited;
end;

class destructor THttpUtils.destroy;
begin
  inherited;
end;

class function THttpUtils.upload(Const url, fileName: String;
  const tmConn: integer; const tmRes: integer): string;
var
  multFormData: TMultipartFormData;
begin
  multFormData := TMultipartFormData.Create;
  try
    multFormData.AddFile('file', FileName);
    Result := post(url, multFormData, tmConn, tmRes);
  finally
    multFormData.Free;
  end;
end;

class function THttpUtils.post(const url: string;
  const ob: TObject; const tmConn, tmRes: integer): string;
begin
  Result := post(url, ob, tmConn, tmRes, TEncoding.UTF8);
end;

class function THttpUtils.post(const url: string; const S: string;
  const tmConn, tmRes: integer): string;
var strs: TStrings;
begin
  strs := TStringList.Create;
  try
    strs.Text := S;
    Result := THttpUtils.post(url, strs, tmConn, tmRes);
  finally
    strs.Free;
  end;
end;

class function THttpUtils.get(const url: string; const S: string;
  const tmConn, tmRes: integer): string;
var strs: TStrings;
begin
  strs := TStringList.Create;
  try
    strs.Text := S;
    Result := THttpUtils.get(url, strs, tmConn, tmRes, TEncoding.UTF8);
  finally
    strs.Free;
  end;
end;

class function THttpUtils.postJson(const url: string; const S: string;
  const tmConn, tmRes: integer): string;
var ss: TStringStream;
begin
  ss := TStringStream.Create(S, TEncoding.UTF8);
  try
    //ss.WriteString(S);
    Result := THttpUtils.post(url, ss, tmConn, tmRes);
  finally
    ss.Free;
  end;
end;

class function THttpUtils.post(const url: string;
  const ob: TObject; const tmConn, tmRes: integer; const encode: TEncoding): string;
begin
  Result := THttpUtils.postGet(url, sHTTPMethodPost, ob, tmConn, tmRes, encode);
end;

class function THttpUtils.get(const url: string;
  const ob: TObject; const tmConn, tmRes: integer; const encode: TEncoding): string;
begin
  Result := THttpUtils.postGet(url, sHTTPMethodGet, ob, tmConn, tmRes, encode);
end;

class function THttpUtils.get(const url: string;
  const tmConn, tmRes: integer; const encode: TEncoding): string;
begin
  Result := THttpUtils.postGet(url, sHTTPMethodGet, nil, tmConn, tmRes, encode);
end;

class function THttpUtils.postGet(const url: string; const method: string;
  const ob: TObject; const tmConn, tmRes: integer; const encode: TEncoding): string;
var
  lHttp: TMyHttpClient;
begin
  Result := '';
  lHttp := TMyHttpClient.create(nil);
  try
    lHttp.ConnectionTimeout := tmConn; // 10Ãë
    lHttp.ResponseTimeout := tmRes;
    Result := lHttp.postGet(url, method, ob, tmConn, tmRes, encode);
  finally
    lHttp.Free;
  end;
end;

{ TMyHttpClient }

constructor TMyHttpClient.create(AOwner: TComponent);
begin
  inherited create(AOwner);
  FOK := false;
  self.AllowCookies := true;
  self.Asynchronous := true;
  //
  //self.ConnectionTimeout := tmConn; // 10Ãë
  //self.ResponseTimeout := tmRes;
  self.AcceptCharSet := 'utf-8';
  self.AcceptEncoding := 'utf-8';
  self.AcceptLanguage := 'zh-CN';
  self.Accept := 'application/json';
  //self.ContentType := 'application/json';
  //self.ContentType := 'multipart/form-data';
  self.UserAgent := DefaultUserAgent;//'Embarcadero URI Client/1.0';
  //
  self.OnRequestCompleted := self.DoOnRequestCompleted;
  self.OnRequestError := self.DoOnRequestError;
end;

procedure TMyHttpClient.DoOnRequestCompleted(const Sender: TObject; const AResponse: IHTTPResponse);
begin
  FOK := true;
end;

procedure TMyHttpClient.DoOnRequestError(const Sender: TObject;
  const AError: string);
begin
  FOK := true;
end;

class constructor TMyHttpClient.Create;
begin
end;

destructor TMyHttpClient.Destroy;
begin
  inherited Destroy;
end;

function TMyHttpClient.postGet(const url, method: string; const ob: TObject;
  const tmConn, tmRes: integer; const encode: TEncoding): string;

  function getType(): string;
  begin
    if ob=nil then begin
      Result := 'none';
    end else begin
      Result := ob.ClassName + '->' + ob.ToString;
    end;
  end;

const FMT_BEGIN = '%s, %s, %s';
const FMT_END = '%s, %s, %s, result(%s)';
const FMT_END_ = '%s, %s, %s, state(%d), result(%s)';

  function doResponse(ssRst: TStringStream): integer;
  var
    lResponse: IHTTPResponse;
  begin
    Result := 0;
    lResponse := nil;
    try
      try
        if SameText(method, sHTTPMethodPost) then begin
          if ob is TMultipartFormData then begin
            //lHttp.ContentType := 'multipart/form-data';
            //ShowSysLog('postGet: data TMultipartFormData, size ' + IntToStr((TMultipartFormData(ob)).Stream.Size));
            lResponse := self.Post(Url, TMultipartFormData(ob), ssRst);
          end else if ob is TStringStream then begin
            TStringStream(ob).Position := 0;
            //ShowSysLog('postGet: data TStringStream, ' + (TStringStream(ob)).DataString);
            self.ContentType := 'application/json';
            lResponse := self.Post(Url, TStringStream(ob), ssRst);
            if p_Closed^ then begin
              //self.
            end;
          end else if ob is TStream then begin
            //ShowSysLog('postGet: data TStream, size ' + IntToStr((TStream(ob)).Size));
            lResponse := self.Post(Url, TStream(ob), ssRst);
          end else if ob is TStrings then begin
            //ShowSysLog('postGet: data TStrings, ' + (TStrings(ob)).Text);
            lResponse := self.Post(Url, TStrings(ob), ssRst);
          end else begin
            raise Exception.Create('Error: ' + ob.ClassName + ' not support.');
          end;
        end else if SameText(method, sHTTPMethodGet) then begin
          if not Assigned(ob) then begin
            lResponse := self.get(Url, ssRst);
          end else begin
            if ob is TStream then begin
              lResponse := self.get(Url, ssRst);
            end else begin
              raise Exception.Create('Error: ' + ob.ClassName + ' not support.');
            end;
          end;
        end;
        while not FOK do begin
          Sleep(0);
          if p_Closed^ then begin
            break;
          end;
          Application.ProcessMessages;
        end;
      except
        on E: Exception do begin
          //log4error(method + ': ' + format(FMT_END, [url, method, getType(), Result]));
          raise Exception.create(e.message);
        end;
      end;
    finally
      if Assigned(lResponse) then begin
        Result := lResponse.statusCode;
      end;
    end;
  end;

var
  ssRst: TStringStream;
  statusCode: integer;
begin
  Result := '';
  //ShowSysLog(method + ': begin, ' + format(FMT_BEGIN, [url, method, getType()]));
  //log4info(method + ': begin, ' + format(FMT_BEGIN, [url, method, getType()]));
  ssRst := TStringStream.Create('', encode);
  try
    // add cookie
    //self.CookieManager.AddServerCookie(
    //  //'ACCESS_TICKET="TGT-171-O42vP4LGehJ3z3VGOXPteuccJWdxBvSDTa1bUlSX1VT2miqnKM-cas.ecarpo.com"',
    //  THttpUtils.fCookie,
    //  url);
    statusCode := doResponse(ssRst);
    if ( statusCode = 200 ) then begin
      Result := ssRst.DataString;
      //cookieS := lHttp.CookieManager.CookieHeaders(TURI.Create(url));
      //log4info(method + ': end, ' + format(FMT_END_, [url, method, getType(), statusCode, Result]));
    end else begin
      //log4error(method + ': end, ' + format(FMT_END_, [url, method, getType(), statusCode, Result]));
      raise THttpBreakException.create(statusCode, format('httpCode(%d)', [statusCode]));
//      if (statusCode <> 500) then begin
//        if ( (statusCode>=400) and (statusCode<500) ) or
//            ( (statusCode>500) and (statusCode<600) ) then begin
//          raise THttpBreakException.create(format('httpCode(%d)', [statusCode]));
//        end;
//      end;
      //ShowSysLog(method + ': end, ' + format(FMT_END, [url, method, getType(), Result]));
    end;
  finally
    ssRst.Free;
  end;
end;

end.


