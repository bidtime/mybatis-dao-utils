unit uSSLEmail;

interface

uses IdMessage, Classes, IdSMTP, IdMessageBuilder;

//const SMTP_PORT_EXPLICIT_TLS = 587;

type
    TSSLEmail = class(TObject)
    private
        IdMessage: TIdMessage;
        SMTP: TIdSMTP;
        FedBody: TStrings;
        FedSMTPPort: Integer;
        FedToEmail: string;
        FedSubject: string;
        FedSMTPServer: string;
        FedCCEmail: string;
        FedPassword: string;
        //FedBCCEmail: string;
        FedSenderName: string;
        FedUserName: string;
        FedPriority: TIdMessagePriority;
        FedSenderEmail: string;
        FedSSLConnection: Boolean;
        FedAttachmentList: TStrings;
        FedFormatHTML: Boolean;
        // Getter / Setter
        procedure SetBody(const Value: TStrings);
        procedure Init;
        procedure InitMailMessage;
        procedure InitSASL;
        procedure AddSSLHandler;
        procedure SetedAttachmentList(const Value: TStrings);
        procedure SetedFormatHTML(const Value: Boolean);
    public
        constructor Create; overload;
        constructor Create(const ASMTPServer: string; const ASMTPPort: Integer; const AUserName, APassword: string); overload;
        destructor Destroy; override;
        function SendEmail: boolean;
 // Properties property edBCCEmail: string read FedBCCEmail write FedBCCEmail;
        property edBody: TStrings read FedBody write SetBody;
        //property edBodyText: TStrings read FedBody write FedBodyText;
        property edCCEmail: string read FedCCEmail write FedCCEmail;
        property edPassword: string read FedPassword write FedPassword;
        property edPriority: TIdMessagePriority read FedPriority write FedPriority;
        property edSenderEmail: string read FedSenderEmail write FedSenderEmail;
        property edSenderName: string read FedSenderName write FedSenderName;
        property edSMTPServer: string read FedSMTPServer write FedSMTPServer;
        property edSMTPPort: Integer read FedSMTPPort write FedSMTPPort;
        property edSSLConnection: Boolean read FedSSLConnection write FedSSLConnection;
        property edToEmail: string read FedToEmail write FedToEmail;
        property edUserName: string read FedUserName write FedUserName;
        property edSubject: string read FedSubject write FedSubject;
        property edFormatHTML: Boolean read FedFormatHTML write SetedFormatHTML;
        property edAttachmentList: TStrings read FedAttachmentList write SetedAttachmentList;
    end;


implementation

uses
    IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
    IdMessageClient, IdSMTPBase, IdBaseComponent, IdIOHandler, IdIOHandlerSocket,
    IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdSASLLogin, IdSASL_CRAM_SHA1, IdSASL,
    IdSASLUserPass, IdSASL_CRAMBase, IdSASL_CRAM_MD5, IdSASLSKey, IdSASLPlain,
    IdSASLOTP, IdSASLExternal, IdSASLDigest, IdSASLAnonymous, IdUserPassProvider,
    SysUtils;

constructor TSSLEmail.Create;
begin
    inherited;
    Init;
    FedBody := TStringList.Create;
    edAttachmentList := TStringList.Create;
end;


procedure TSSLEmail.Init;
begin
    edSSLConnection := True;
    edPriority := TIdMessagePriority.mpNormal;
end;


constructor TSSLEmail.Create(const ASMTPServer: string; const ASMTPPort: Integer; const AUserName, APassword: string);
begin
    Create;
    edSMTPServer := ASMTPServer;
    edSMTPPort := ASMTPPort;
    edUserName := AUserName;
    edPassword := APassword;
end;


destructor TSSLEmail.Destroy;
begin
    //edBody.Free;
    edAttachmentList.Free;
    inherited;
end;
 // Setter / Getter -----------------------------------------------------------


procedure TSSLEmail.SetBody(const Value: TStrings);
begin
    FedBody.Assign(Value);
end;


procedure TSSLEmail.SetedAttachmentList(const Value: TStrings);
begin
    FedAttachmentList := Value;
end;


procedure TSSLEmail.SetedFormatHTML(const Value: Boolean);
begin
    FedFormatHTML := Value;
end;
 // Send the mail -------------------------------------------------------------


function TSSLEmail.SendEmail: boolean;
begin
    IdMessage := TIdMessage.Create;
    try
        InitMailMessage;
        SMTP := TIdSMTP.Create;
        try
            if edSSLConnection then begin
              AddSSLHandler;
              //if edSMTPPort = SMTP_PORT_EXPLICIT_TLS then
              //    SMTP.UseTLS := utUseExplicitTLS
              //else
                SMTP.UseTLS := utUseImplicitTLS;
            end;
            if (edUserName <> '') or (edPassword <> '') then begin
              SMTP.AuthType := satSASL;
              InitSASL;
            end else begin
              SMTP.AuthType := satNone;
            end;
            SMTP.Host := edSMTPServer;
            SMTP.Port := edSMTPPort;
            SMTP.ConnectTimeout := 30000;
            SMTP.UseEHLO := True;
            try
              SMTP.Connect;
              try
                try
                  SMTP.Send(IdMessage);
                  Result := true;
                except
                  on E: Exception do begin
                    raise Exception.Create(e.Message);
                  end;
                end;
              finally
                SMTP.Disconnect;
              end;
            except
              on E: Exception do begin
                raise Exception.Create(e.Message);
              end;
            end;
          finally
            SMTP.Free;
          end;
    finally
        IdMessage.Free;
    end;
end;
 // Prepare the mail ----------------------------------------------------------


procedure TSSLEmail.InitMailMessage;
var
    Index: Integer;
begin
    with TIdMessageBuilderHtml.Create do
    try
        HtmlCharSet := 'UTF-8';
        if edFormatHTML then
            Html.Text := FedBody.Text
        else
            PlainText.Text := FedBody.Text;
        for Index := 0 to FedAttachmentList.Count - 1 do
            Attachments.Add(edAttachmentList[Index]);
        FillMessage(IdMessage);
    finally
        Free;
    end;
    IdMessage.Charset := 'UTF-8';
    IdMessage.Body := edBody;
    IdMessage.Sender.Text := edSenderEmail;
    IdMessage.From.Name := edSenderName;
    IdMessage.From.Address := edSenderEmail;
    IdMessage.ReplyTo.EMailAddresses := edSenderEmail;
    IdMessage.Recipients.EMailAddresses := edToEmail;
    IdMessage.Subject := edSubject;
    IdMessage.Priority := edPriority;
    IdMessage.CCList.EMailAddresses := edCCEmail;
    IdMessage.ReceiptRecipient.Text := '';
    //IdMessage.BccList.EMailAddresses := edBCCEmail;
end;


procedure TSSLEmail.AddSSLHandler;
var
    SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
    SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(SMTP);
 // SSL/TLS handshake determines the highest available SSL/TLS version dynamically SSLHandler.SSLOptions.Method := sslvSSLv23;
    SSLHandler.SSLOptions.Mode := sslmClient;
    SSLHandler.SSLOptions.VerifyMode := [];
    SSLHandler.SSLOptions.VerifyDepth := 0;
    SMTP.IOHandler := SSLHandler;
end;


procedure TSSLEmail.InitSASL;
var
    IdUserPassProvider: TIdUserPassProvider;
    IdSASLCRAMMD5: TIdSASLCRAMMD5;
    IdSASLCRAMSHA1: TIdSASLCRAMSHA1;
    IdSASLPlain: TIdSASLPlain;
    IdSASLLogin: TIdSASLLogin;
    IdSASLSKey: TIdSASLSKey;
    IdSASLOTP: TIdSASLOTP;
    IdSASLAnonymous: TIdSASLAnonymous;
    IdSASLExternal: TIdSASLExternal;
begin
    IdUserPassProvider := TIdUserPassProvider.Create(SMTP);
    IdUserPassProvider.Username := edUserName;
    IdUserPassProvider.Password := edPassword;
    IdSASLCRAMSHA1 := TIdSASLCRAMSHA1.Create(SMTP);
    IdSASLCRAMSHA1.UserPassProvider := IdUserPassProvider;
    IdSASLCRAMMD5 := TIdSASLCRAMMD5.Create(SMTP);
    IdSASLCRAMMD5.UserPassProvider := IdUserPassProvider;
    IdSASLSKey := TIdSASLSKey.Create(SMTP);
    IdSASLSKey.UserPassProvider := IdUserPassProvider;
    IdSASLOTP := TIdSASLOTP.Create(SMTP);
    IdSASLOTP.UserPassProvider := IdUserPassProvider;
    IdSASLAnonymous := TIdSASLAnonymous.Create(SMTP);
    IdSASLExternal := TIdSASLExternal.Create(SMTP);
    IdSASLLogin := TIdSASLLogin.Create(SMTP);
    IdSASLLogin.UserPassProvider := IdUserPassProvider;
    IdSASLPlain := TIdSASLPlain.Create(SMTP);
    IdSASLPlain.UserPassProvider := IdUserPassProvider;
    SMTP.SASLMechanisms.Add.SASL := IdSASLCRAMSHA1;
    SMTP.SASLMechanisms.Add.SASL := IdSASLCRAMMD5;
    SMTP.SASLMechanisms.Add.SASL := IdSASLSKey;
    SMTP.SASLMechanisms.Add.SASL := IdSASLOTP;
    SMTP.SASLMechanisms.Add.SASL := IdSASLAnonymous;
    SMTP.SASLMechanisms.Add.SASL := IdSASLExternal;
    SMTP.SASLMechanisms.Add.SASL := IdSASLLogin;
    SMTP.SASLMechanisms.Add.SASL := IdSASLPlain;
end;

end.
