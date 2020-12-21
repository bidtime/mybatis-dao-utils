unit uLog4me;

interface

uses classes, uLogFile;

type
  TLog4me = class
  private
    { Private declarations }
    class var FLogFile: TLogFile;
  public
    { Public declarations }
    class procedure error(msg: AnsiString); //写ERROR级别的日志
    class procedure warn(msg: AnsiString);  //写ERROR级别的日志
    class procedure info(msg: AnsiString);  //写INFO级别的日志
    class procedure debug(msg: AnsiString); //写DEBUG级别的日志
    class constructor create();
    class destructor Destroy();
  end;

implementation

{TLog4me}

class constructor TLog4me.create();
begin
  FLogFile := TLogFile.create('');
end;

class destructor TLog4me.Destroy;
begin
  if Assigned(FLogFile) then begin
    FLogFile.Free;
  end;
end;

//-----下面4个是对外方法-------------------------

class procedure TLog4me.error(msg: AnsiString); //写ERROR级别的日志
begin
  FLogFile.error(msg);
end;

class procedure TLog4me.warn(msg: AnsiString); //写ERROR级别的日志
begin
  FLogFile.warn(msg);
end;

class procedure TLog4me.info(msg: AnsiString); //写INFO级别的日志
begin
  FLogFile.info(msg);
end;

class procedure TLog4me.debug(msg: AnsiString); //写DEBUG级别的日志
begin
  FLogFile.debug(msg);
end;

end.
