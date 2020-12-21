
{*******************************************************}
{                                                       }
{                yuntong lib                             }
{       Instahce Server source code                     }
{                                                       }
{       Copyright (c) 1997,99 btr Corporation           }
{                                                       }
{*******************************************************}

unit uInstanceService;

interface

uses
  SvcMgr, Windows, Messages, Classes;

type
  TInstanceService = class(TService)
  protected
    procedure Start(Sender: TService; var Started: Boolean);
    procedure Stop(Sender: TService; var Stopped: Boolean);
  public
    function GetServiceController: TServiceController; override;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
  end;

var g_InstanceService: TInstanceService;

implementation

uses uAppConst, uFrmMain;

{ TSocketService }

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  g_InstanceService.Controller(CtrlCode);
end;

function TInstanceService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

constructor TInstanceService.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited CreateNew(AOwner, Dummy);
  AllowPause := False;
  Interactive := True;
  DisplayName := SApplicationName;
  Name := SServiceName;
  OnStart := Start;
  OnStop := Stop;
end;

procedure TInstanceService.Start(Sender: TService; var Started: Boolean);
begin
  PostMessage(FrmMain.Handle, UI_INITIALIZE, 1, 0);
  Started := True;
end;

procedure TInstanceService.Stop(Sender: TService; var Stopped: Boolean);
begin
  PostMessage(FrmMain.Handle, WM_QUIT, 0, 0);
  Stopped := True;
end;

end.
