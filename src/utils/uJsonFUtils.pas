unit uJsonFUtils;

interface

uses
  Classes, uJsonSUtils, System.JSON.Types;

type

  TJsonFUtils = class(TJsonSUtils)
  private
  public
    { Public declarations }
    class function DeserializeNF<T>(const fName: string): T; static;
    class function DeserializeF<T>(const fName: string): T; static;
    class function SerializeF<T>(const u: T; const fName: string;
      const fm: TJsonFormatting=TJsonFormatting.None): boolean; static;
    //
    class function loadFromFile(const fName: string): string; static;
    class function saveToFile(const S, fName: string): boolean; static;
 end;

implementation

uses SysUtils;//, uLog4me;

{ TJsonSUtils }

class function TJsonFUtils.loadFromFile(const fName: string): string;
var strs: TStrings;
begin
  Result := '';
  strs := TStringList.Create();
  try
    try
      strs.LoadFromFile(fName, TEncoding.UTF8);
      Result := strs.Text;
    except
      on e: exception do begin
        //log4error('loadFromFile: ' + fName + ', ' + e.Message);
      end;
    end;
  finally
    strs.Free;
  end;
end;

class function TJsonFUtils.DeserializeF<T>(const fName: string): T;
var S: string;
begin
  Result := T(nil);
  S := loadFromFile(fName);
  Result := Deserialize<T>(S);
end;

class function TJsonFUtils.DeserializeNF<T>(const fName: string): T;
var S: string;
begin
  Result := T(nil);
  if FileExists(fName) then begin
    S := loadFromFile(fName);
    Result := Deserialize<T>(S);
  end;
end;

class function TJsonFUtils.saveToFile(const S: string; const fName: string): boolean;
var strs: TStrings;
begin
  Result := false;
  strs := TStringList.Create();
  try
    strs.Text := S;
    try
      strs.SaveToFile(fName, TEncoding.UTF8);
      Result := true;
    except
      on e: exception do begin
        //log4error('saveToFile: ' + fName + ', ' + S + ', ' + e.Message);
      end;
    end;
  finally
    strs.Free;
  end;
end;

class function TJsonFUtils.SerializeF<T>(const u: T; const fName: string;
  const fm: TJsonFormatting): boolean;
var S: string;
begin
  S := TJsonSUtils.Serialize<T>(u, fm);
  Result := saveToFile(S, fName);
end;

end.

