unit uIdUtils;

interface

uses
  Classes;

type
  TIdUtils = class
  private
    { Private declarations }
    class var it: byte;
    //class var dt1970: TDateTime;
  protected
    class function getNewId(): Int64;
  public
    { Public declarations }
    class function getNewIdS(): String; //获得毫秒
    class constructor create();
    class destructor Destroy();
  end;

implementation

uses StrUtils, Sysutils, DateUtils, Windows;

class constructor TIdUtils.create;
begin
  it := 0;
  //java里的时间是从1970年1月1日0点到当前的间隔
  //dt1970 := EncodeDateTime( 1970, 1, 1, 0, 0, 0, 0 );
end;

class destructor TIdUtils.Destroy;
begin
end;

class function TIdUtils.getNewId(): Int64; //获得毫秒
begin
  Result := StrToInt(getNewIdS());
end;

{function getNewId(): int64;
var
  SysTime: TsystemTime;
  timen,time2: TDateTime;
  ss2,ss3: int64;
begin

  GetLocalTime(SysTime);
  timen:= SystemTimeToDateTime(SysTime);
  time2 := EncodeDateTime( 1960, 1, 1, 0, 0, 0, 0 );

  ss2 := 28800000;
  ss3 := MilliSecondsBetween( timen, time2 );
  Result := ss3- ss2;
end;}

{function getNewId(): int64;
var
  SysTime: TsystemTime;
  timen,time2: TDateTime;
  ss2,ss3: int64;
begin

  GetLocalTime(SysTime);
  timen := SystemTimeToDateTime(SysTime);
  ss3 := MilliSecondsBetween( timen, time2 );
  Result := ss3- ss2;
end;}

{class function TIdUtils.getNewId: Int64;
begin
  Result := StrToInt(getNewIdS);
end;}

class function TIdUtils.getNewIdS: String;

  {function getBetweenId(): Int64; //获得毫秒
  begin
    Result := MilliSecondsBetween(now, dt1970);
  end;}

  function getNewIdR(): Int64; //获得毫秒
    function getN(const A: TDateTime): Int64;
    var
      LTimeStamp: TTimeStamp;
    begin
      LTimeStamp := DateTimeToTimeStamp(A);
      Result := LTimeStamp.Date;
      Result := (Result * MSecsPerDay) + LTimeStamp.Time;
    end;
  begin
    Result := getN(now());
  end;

begin
  //timen := SystemTimeToDateTime(SysTime);
  //Result := UnixToDateTime(SysTime);
  //Result := IntToStr(DateTimeToUnix(now));
  //Format('DR%.8d', [100]);// 一共8位数字不够的补零
  Result := Format('%d%.2d', [ getNewIdR(), it]);
  Inc(it);
  if (it > 98) then begin
    it := 0;
  end;
end;

end.
