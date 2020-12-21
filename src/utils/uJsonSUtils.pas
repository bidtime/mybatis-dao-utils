unit uJsonSUtils;

interface

uses System.JSON.Types;

type

  TJsonSUtils = class
  private
  public
    { Public declarations }
    class function Serialize<T>(const u: T; const fm: TJsonFormatting=TJsonFormatting.None): string; static;
    class function Deserialize<T>(const S: string): T; static;
 end;

implementation

uses System.JSON.Serializers, SysUtils;

{ TJsonSUtils }

class function TJsonSUtils.Serialize<T>(const u: T; const fm: TJsonFormatting=TJsonFormatting.None): string;
var Serializer: TJsonSerializer;
begin
  Result := '';
  Serializer := TJsonSerializer.Create;
  try
    Serializer.Formatting := fm;
    try
      Result := Serializer.Serialize<T>(u);
    except
      on e: exception do begin
      end;
    end;
  finally
    Serializer.Free;
  end;
end;

class function TJsonSUtils.Deserialize<T>(const S: string): T;
var Serializer: TJsonSerializer;
begin
  Result := T(nil);
  if S.IsEmpty then begin
    exit;
  end;
  Serializer := TJsonSerializer.Create;
  try
    try
      Result := Serializer.DeSerialize<T>(S);
    except
      on e: exception do begin
      end;
    end;
  finally
    Serializer.Free;
  end;
end;

end.

