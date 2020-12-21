unit uFrmSetting;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmSetting = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Edit1: TEdit;
    Button3: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    memoSqlMap: TMemo;
    TabSheet2: TTabSheet;
    GroupBox2: TGroupBox;
    rbUpdateMap: TRadioButton;
    rbUpdateForVer: TRadioButton;
    TabSheet3: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure ctrl_file(const bWrite: boolean=false);
    procedure operEdit(Sender: TObject; const plus: boolean);
  public
    { Public declarations }
    //
    function getIdent(): string;
    function clearBlank(): boolean;
  end;

implementation

uses uFormIniFiles;

{$R *.dfm}

{ TfrmSetting }

procedure TfrmSetting.Button1Click(Sender: TObject);
begin
  ctrl_file(true);
  ModalResult := mrOK;
end;

procedure TfrmSetting.Button2Click(Sender: TObject);
begin
  ctrl_file(false);
  ModalResult := mrCancel;
end;

procedure TfrmSetting.Button3Click(Sender: TObject);
begin
  operEdit(Sender, false);
end;

procedure TfrmSetting.Button4Click(Sender: TObject);
begin
  operEdit(Sender, true);
end;

procedure TfrmSetting.operEdit(Sender: TObject; const plus: boolean);
var S: string;
  n: Integer;
begin
  if Sender is TEdit then begin
    S := TEdit(Sender).text;
    try
      n := StrToInt(S);
      if (plus) then begin
        Inc(n);
      end else begin
        Dec(n);
      end;
      TEdit(Sender).text := IntToStr(n);
    except

    end;
  end;
end;

function TfrmSetting.clearBlank: boolean;
begin
  Result := self.CheckBox1.Checked;
end;

procedure TfrmSetting.ctrl_file(const bWrite: boolean);
begin
  TFormIniFiles.rwIniCtrls(self, bWrite);
end;

procedure TfrmSetting.FormCreate(Sender: TObject);
begin
  ctrl_file(false);
end;

function TfrmSetting.getIdent: string;

  function getChar(): char;
  begin
    if self.RadioButton1.Checked then begin
      Result := #9;
    end else begin
      Result := #32;
    end;
  end;

var i, len: Integer;
begin
  Result := '';
  len := StrToIntDef(self.Edit1.Text, 0);
  for I := 0 to len-1 do begin
    Result := Result + getChar();
  end;
end;

end.
