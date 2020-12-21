unit uSMTPUtils2;

interface

uses classes;

type
  TSMTPParms = record
    Username: string; //设置登陆帐号
    Password: string; //设置登录password
    Host: string; //设置SMTP地址
    Port: integer; //设置port   必须转化为整型
    UseSSL: boolean;
    SSL_Port: integer;
    AuthCode: string;
    AuthLogin: boolean;   // 需要登陆验证
    UseAuthCode: boolean;
  end;
  TSMTPUtils2 = class
  private
    class var FLogsEv: TGetStrProc;
    class var FErrorEv: TGetStrProc;
    class procedure showLogs(const S: string);
    class procedure showError(const S: string);
  protected
  public
    class function SendMail(const p: TSMTPParms; const toUser, subject, bodyText: string): boolean; overload;
    class function SendMail(const p: TSMTPParms; const toUser: string;
      const subject: string; const bodyText: TStrings): boolean; overload;
    class property LogsEv: TGetStrProc read FLogsEv write FLogsEv;
    class property ErrorEv: TGetStrProc read FErrorEv write FErrorEv;
  end;

implementation

uses SysUtils, IdBaseComponent, IdMessage, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient,
  IdSMTPBase, IdSMTP, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  uSSLEmail;

class function TSMTPUtils2.SendMail(const p: TSMTPParms; const toUser: string;
  const subject: string; const bodyText: string): boolean;
var strs: TStrings;
begin
  strs := TStringList.Create;
  try
    strs.Add(bodyText);
    Result := SendMail(p, toUser, subject, strs);
  finally
    strs.Free;
  end;
end;

class function TSMTPUtils2.SendMail(const p: TSMTPParms; const toUser: string;
  const subject: string; const bodyText: TStrings): boolean;

var sslEMail: TSSLEmail;
begin
  sslEMail := TSSLEmail.Create;
  try
    sslEMail.edSMTPServer := p.Host;
    if p.UseSSL then begin
      sslEMail.edSMTPPort := p.SSL_Port;
      if p.UseAuthCode then begin
        sslEmail.edPassword := p.AuthCode;
      end else begin
        sslEmail.edPassword := p.Password;
      end;
    end else begin
      sslEMail.edSMTPPort := p.Port;
      sslEmail.edPassword := p.Password;
    end;
    sslEmail.edSSLConnection := p.UseSSL;
    sslEmail.edSenderEmail := p.Username;
    sslEmail.edSenderName := p.Username;
    sslEmail.edToEmail := toUser;
    sslEmail.edSubject := subject;
    sslEmail.edBody := bodyText;
    Result := sslEmail.SendEmail;
  finally
    sslEMail.Free;
  end;
end;

{
http://mail.tom.com/webmail/main/index.action
ecarpo_bms@tom.com
1qaz@WSX
//

  "SMTP_ToUser": "875560580@qq.com;373226941@qq.com;35672187@qq.com",

sina:
serial:d4cdf8230f0a0c53

}

class procedure TSMTPUtils2.showError(const S: string);
begin
  if Assigned(self.FErrorEv) then begin
    FErrorEv(S);
  end;
end;

class procedure TSMTPUtils2.showLogs(const S: string);
begin
  if Assigned(self.FLogsEv) then begin
    FLogsEv(S);
  end;
end;

end.
