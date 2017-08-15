program mybatisDAO;

uses
  Vcl.Forms,
  uFrmMain in 'src\uFrmMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
