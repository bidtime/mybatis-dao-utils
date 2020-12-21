unit uFrmAboutBox;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, Buttons,
  ExtCtrls, jpeg;

type
  TFrmAboutBox = class(TForm)
    labProgramName: TLabel;
    labCompany: TLabel;
    Image1: TImage;
    Label4: TLabel;
    labTel1: TLabel;
    labTel2: TLabel;
    labVersionBuild: TLabel;
    labWeb: TLabel;
    labVersinNo: TLabel;
    Label3: TLabel;
    btnOk: TButton;
    gbTitle: TGroupBox;
    btnUpgrade: TButton;
    procedure FormCreate(Sender: TObject);
    procedure labWebClick(Sender: TObject);
    procedure btnUpgradeClick(Sender: TObject);
    public
      class procedure showNewForm(Owner: TComponent=nil);
      class function getAppInfo(): string;
  end;

implementation

uses ShellApi, uVerInfo;

{$R *.DFM}

class function TFrmAboutBox.getAppInfo: string;
begin
  Result := AppName + ' ' +
    //Application.title + ' ' +
    AppExt + ' ' +
    '版本：' + FloatToStr(Version) + ' ' +
    'build ' + Build + ''
    ;
end;

procedure TFrmAboutBox.btnUpgradeClick(Sender: TObject);
begin
  //autoDl();
end;

procedure TFrmAboutBox.FormCreate(Sender: TObject);
begin
  labProgramName.Caption := AppName;
  labCompany.caption := CompanyName;
  labTel1.caption := TelInfo1;
  labTel2.caption := TelInfo2;
  labWeb.caption := WebAddress;
  //labProgramName.Caption := AppName + ' ' + Application.title + ' ' + AppExt;
  labProgramName.Caption := AppName + ' ' + AppExt;

  labVersinNo.Caption := FloatToStr(Version);

  Caption := '关于 ' + labProgramName.Caption;

  labVersionBuild.Caption := Build;
  //{$IFDEF Debug}
//  if RELEASE_VERSION=0 then
//    labVersionBuild.Caption := labVersionBuild.Caption + ' ²âÊÔ°æ'
//  else
//    //{$ELSE}
//    labVersionBuild.Caption := labVersionBuild.Caption + ' ·¢ÐÐ°æ';
  //{$ENDIF}
end;

procedure TFrmAboutBox.labWebClick(Sender: TObject);
begin
  ShellExecute(0, Nil,PChar(labWeb.caption), Nil, Nil, SW_NORMAL);
end;

class procedure TFrmAboutBox.showNewForm(Owner: TComponent);
var frm: TFrmAboutBox;
begin
  frm := TFrmAboutBox.create(Owner);
  try
    frm.ShowModal();
  finally
    if Assigned(frm) then begin
      frm.Hide;
      frm.Free;
    end;
  end;
end;

end.
