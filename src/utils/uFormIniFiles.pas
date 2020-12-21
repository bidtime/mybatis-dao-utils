unit uFormIniFiles;

interface

uses
  Forms;

type
  TFormIniFiles = class
  private
  protected
  public
    { Public declarations }
    class function rwIni(frm: TCustomForm; const bWrite: boolean; const needFrm: boolean=true): boolean;
    class function rwIniCtrls(frm: TCustomForm; const bWrite: boolean): boolean;
  end;

implementation

uses IniFiles, SysUtils, StrUtils, Controls, StdCtrls, ComCtrls, Classes;

{ TdmTableTypeInf }

function getAppPath: string;
begin
  //Result := ExtractFilePath(Application.ExeName);
  Result := ExtractFilePath(ParamStr(0));
end;

function readFromFile(const fname: string): string;
var strs: TStrings;
begin
  strs := TStringList.Create;
  try
    if FileExists(fname) then begin
      strs.LoadFromFile(fname);
    end;
    Result := strs.Text;
  finally
    strs.Free;
  end;
end;

procedure strsFromFile(strs: TStrings; const fname: string);
begin
  if FileExists(fname) then begin
    strs.LoadFromFile(fname);
  end;
end;

procedure strsToFile(strs: TStrings; const fname: string);
begin
  strs.SaveToFile(fname, TEncoding.UTF8);
end;

procedure saveToFile(const fname, ctx: string);
var strs: TStrings;
begin
  strs := TStringList.Create;
  try
    strs.Text := ctx;
    strs.SaveToFile(fname, TEncoding.UTF8);
  finally
    strs.Free;
  end;
end;

procedure doCtrlFile(frm: TComponent; iniFile: TIniFile; const bWrite: boolean);
var i: integer;
  ctrl: TComponent;
begin
  for I := 0 to frm.ComponentCount - 1 do begin
    ctrl := frm.Components[I];
    doCtrlFile(ctrl, iniFile, bWrite);
    if (ctrl is TComboBox) then begin
      if bWrite then begin
        iniFile.WriteInteger(frm.Name, TComboBox(ctrl).Name+'_idx', TComboBox(ctrl).ItemIndex);
        iniFile.WriteString(frm.Name, TComboBox(ctrl).Name, TComboBox(ctrl).Text);
      end else begin
        TComboBox(ctrl).Text := iniFile.ReadString(frm.Name, TComboBox(ctrl).Name, TComboBox(ctrl).Text);
        TComboBox(ctrl).ItemIndex := iniFile.ReadInteger(frm.Name, TComboBox(ctrl).Name+'_idx', TComboBox(ctrl).ItemIndex);
      end;
    end else if (ctrl is TEdit) then begin
      if bWrite then begin
        iniFile.WriteString(frm.Name, TEdit(ctrl).Name, TEdit(ctrl).Text);
      end else begin
        TEdit(ctrl).Text := iniFile.ReadString(frm.Name, TEdit(ctrl).Name, TEdit(ctrl).Text);
      end;
    end else if (ctrl is TRadioButton) then begin
      if bWrite then begin
        iniFile.WriteBool(frm.Name, TRadioButton(ctrl).Name, TRadioButton(ctrl).checked);
      end else begin
        TRadioButton(ctrl).checked := iniFile.ReadBool(frm.Name, TRadioButton(ctrl).Name, TRadioButton(ctrl).checked);
      end;
    end else if (ctrl is TCheckBox) then begin
      if bWrite then begin
        iniFile.WriteBool(frm.Name, TCheckBox(ctrl).Name, TCheckBox(ctrl).checked);
      end else begin
        TCheckBox(ctrl).checked := iniFile.ReadBool(frm.Name, TCheckBox(ctrl).Name, TCheckBox(ctrl).checked);
      end;
    end else if (ctrl is TMemo) and (TMemo(ctrl).tag=0) then begin
      if bWrite then begin
        strsToFile(TMemo(ctrl).Lines, getAppPath+frm.Name+'_'+TMemo(ctrl).name+'.txt');
      end else begin
        strsFromFile(TMemo(ctrl).Lines, getAppPath+frm.Name+'_'+TMemo(ctrl).name+'.txt');
      end;
    end else if (ctrl is TPageControl) then begin
      if bWrite then begin
        iniFile.WriteInteger(frm.Name, TPageControl(ctrl).Name, TPageControl(ctrl).ActivePageIndex);
      end else begin
        TPageControl(ctrl).ActivePageIndex := iniFile.ReadInteger(frm.Name, TPageControl(ctrl).Name, 0);
      end;
    end;
  end;
end;

class function TFormIniFiles.rwIni(frm: TCustomForm; const bWrite: boolean; const needFrm: boolean): boolean;
var fileName: string;
  iniFile: TIniFile;
  S: string;
begin
  fileName := getAppPath + frm.Name + '.ini';
  iniFile := Tinifile.Create(fileName);
  try
    if needFrm then begin
      if not bWrite then begin
        frm.top := iniFile.ReadInteger('mainform', 'top', frm.top);
        frm.left := iniFile.ReadInteger('mainform', 'left', frm.left);
        frm.height := iniFile.ReadInteger('mainform', 'height', frm.height);
        frm.width := iniFile.ReadInteger('mainform', 'width', frm.width);
        // (wsNormal, wsMinimized, wsMaximized);
        S := iniFile.ReadString('mainform', 'windowState', '0');
        if S.Equals('1') then begin
          frm.WindowState := wsMaximized;
        end else begin
          frm.WindowState := wsNormal;
        end;
      end else begin
        iniFile.WriteInteger('mainform', 'top', frm.top);
        iniFile.WriteInteger('mainform', 'left', frm.left);
        iniFile.WriteInteger('mainform', 'height', frm.height);
        iniFile.WriteInteger('mainform', 'width', frm.width);
        // (wsNormal, wsMinimized, wsMaximized);
        iniFile.WriteString('mainform', 'windowState',
          IfThen(frm.WindowState=wsMaximized, '1', '0'));
      end;
    end;
    doCtrlFile(frm, iniFile, bWrite);
    Result := true;
  finally
    iniFile.Free;
  end;
end;

class function TFormIniFiles.rwIniCtrls(frm: TCustomForm;
  const bWrite: boolean): boolean;
begin
  Result := rwIni(frm, bWrite, false);
end;

end.
