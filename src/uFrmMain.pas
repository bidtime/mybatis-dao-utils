unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ToolWin, Vcl.ComCtrls,
  Vcl.ExtCtrls;

type
  TfrmMain = class(TForm)
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    btnDo: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    targetPackage: TEdit;
    edt_target_project: TEdit;
    Label5: TLabel;
    edt_tableName: TEdit;
    edt_className: TEdit;
    Label6: TLabel;
    Memo1: TMemo;
    Label7: TLabel;
    subPackage: TEdit;
    Label2: TLabel;
    edtDriverClass: TEdit;
    edtConnectionURL: TEdit;
    Label1: TLabel;
    Splitter1: TSplitter;
    Label8: TLabel;
    edtUserId: TEdit;
    edtPassword: TEdit;
    Label9: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure btnDoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FBName: string;
    { Private declarations }
    function getAppPath(): string;
    procedure ctrl_file(const bWrite: boolean=false);
    procedure setFPath(const S: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses IniFiles;

{$R *.dfm}

const XML_CONTENT = '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
'<!DOCTYPE generatorConfiguration' + #13#10 +
'  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"' + #13#10 +
'  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">' + #13#10 +
'' + #13#10 +

'<generatorConfiguration>' + #13#10 +
'  <context id="test1" targetRuntime="MyBatis3">' + #13#10 +

'' + #13#10 +

'    <property name="javaFileEncoding" value="UTF-8" />' + #13#10 +
'    <property name="autoDelimitKeywords" value="false" />' + #13#10 +

'' + #13#10 +

'    <!--' + #13#10 +
'    <plugin type="com.ecarpo.framework.mybatis.generator.MybatisSerializablePlugin"></plugin>' + #13#10 +
'    -->' + #13#10 +

'' + #13#10 +

'    <commentGenerator type="com.ecarpo.framework.mybatis.generator.MybatisCommentGenerator">' + #13#10 +
'      <property name="addRemarkComments" value="true" />' + #13#10 +
'      <property name="dateFormat" value="yyyy-MM-dd HH:mm:ss" />' + #13#10 +
'    </commentGenerator>' + #13#10 +

'' + #13#10 +
'    <!-- dbms -->' + #13#10 +
'    %s' + #13#10 +

'' + #13#10 +
'    <javaTypeResolver type="com.ecarpo.framework.mybatis.generator.MybatisJavaTypeResolver">' + #13#10 +
'      <property name="forceBigDecimals" value="false" />' + #13#10 +
'    </javaTypeResolver>' + #13#10 +
'' + #13#10 +

'    <!-- dao -->' + #13#10 +
'    %s' + #13#10 +

'' + #13#10 +

'  </context>' + #13#10 +
'</generatorConfiguration>';

const DB_PROP = '<jdbcConnection driverClass="%s" connectionURL="%s"' + #13#10 +
'      userId="%s" password="%s">' + #13#10 +
'    </jdbcConnection>' + #13#10;

const DAO_SETTING = '<!-- %s dao begin -->' + #13#10 +
''+ #13#10 +
'    <javaModelGenerator targetPackage="%s" targetProject="%s">' + #13#10 +
'      <property name="enableSubPackages" value="true" />' + #13#10 +
'      <property name="trimStrings" value="true" />' + #13#10 +
'      <property name="immutable" value="false"/>' + #13#10 +
'    </javaModelGenerator>' + #13#10 +
'' + #13#10 +
'    <sqlMapGenerator targetPackage="%s" targetProject="%s">' + #13#10 +
'      <property name="enableSubPackages" value="true" />' + #13#10 +
'    </sqlMapGenerator>' + #13#10 +
'' + #13#10 +
'    <javaClientGenerator type="XMLMAPPER" targetPackage="%s" targetProject="%s">' + #13#10 +
'      <property name="enableSubPackages" value="true" />' + #13#10 +
'    </javaClientGenerator>' + #13#10 +
'' + #13#10 +
'    <table tableName="%s" domainObjectName="%s" mapperName="%s"' + #13#10 +
'      enableCountByExample="false" enableDeleteByExample="false" enableSelectByExample="false"' + #13#10 +
'      selectByExampleQueryId="false" enableUpdateByExample="false">' + #13#10 +
'      <property name="useActualColumnNames" value="false" />' + #13#10 +
'    </table>' + #13#10 +
'' + #13#10 +
'    <!-- %s dao begin -->';

function getDAOXML(const targetProject, entitySubPackage, daoSubPackage: string;
  const tableName: string; const clzNameDO, clzNameDAO: string): string;
begin
  Result := format(DAO_SETTING, [tableName,
    entitySubPackage, targetProject,
    daoSubPackage, targetProject,
    daoSubPackage, targetProject,
    tableName, clzNameDO, clzNameDAO,

    tableName]);
end;

function getDBXML(const driverClass, connectionURL: string;
  const userId: string; const password: string): string;
begin
  Result := format(DB_PROP, [driverClass, connectionURL, userId, password]);
end;

function getXMLContent(const dbProp, daoXML: string): string;
begin
  Result := format(XML_CONTENT, [dbProp, daoXML]);
end;

function readFromFile(const fname: string): string;
var strs: TStrings;
begin
  strs := TStringList.Create;
  try
    strs.LoadFromFile(fname);
    Result := strs.Text;
  finally
    strs.Free;
  end;
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

{
const SS = '    <!-- user dao begin --> ' +
''+
'    <javaModelGenerator targetPackage="com.ecarpo.bms.ap.server.auth.user.entity" targetProject="./src/main/java">' +
'      <property name="enableSubPackages" value="true" />' +
'      <property name="trimStrings" value="true" />' +
'      <property name="immutable" value="false"/>' +
'    </javaModelGenerator>' +
'' +
'    <sqlMapGenerator targetPackage="com.ecarpo.bms.ap.server.auth.user.dao" targetProject="./src/main/java">' +
'      <property name="enableSubPackages" value="true" />' +
'    </sqlMapGenerator>' +
'' +
'    <javaClientGenerator type="XMLMAPPER" targetPackage="com.ecarpo.bms.ap.server.auth.user.dao"' +
'      targetProject="./src/main/java">' +
'      <property name="enableSubPackages" value="true" />' +
'    </javaClientGenerator>' +
'' +
'    <table tableName="ap_user" domainObjectName="ApUserDO" mapperName="ApUserDao"' +
'      enableCountByExample="false" enableDeleteByExample="false" enableSelectByExample="false"' +
'      selectByExampleQueryId="false" enableUpdateByExample="false">' +
'      <property name="useActualColumnNames" value="false" />' +
'    </table>' +
'' +
'    <!-- user dao begin -->'
;
}

procedure TfrmMain.btnDoClick(Sender: TObject);

    function getFirstUpper(const S: string): string;
    var str: string;
    begin
      str := s.Substring(0,1);
      result := String.UpperCase(str) + s.Substring(1);
    end;

    function getClassName(const S: string): string;
    var
      strs: TStrings;
      i: integer;
    begin
      Result := '';
      strs := TStringList.Create();
      try
        strs.Delimiter := '_';
        strs.DelimitedText := S;
        strs.StrictDelimiter := true;
        for I := 0 to strs.Count - 1 do begin
          Result := Result + getFirstUpper(strs[i]);
        end;
      finally
        strs.Free;
      end;
    end;

    function getSubPackage(const S: string): string;
    var
      strs: TStrings;
      i: integer;
    begin
      Result := '';
      strs := TStringList.Create();
      try
        strs.Delimiter := '_';
        strs.DelimitedText := S;
        strs.StrictDelimiter := true;
        for I := 1 to strs.Count - 1 do begin
          Result := Result + String.LowerCase(strs[i]);
        end;
      finally
        strs.Free;
      end;
    end;

  function getDAOSection(): string;
  var cur_subpackage, entitySubPackage, daoSubPackage: string;
    className, classNameDO, classNameDAO: string;
  begin
    className := getClassName(edt_tableName.Text);
    edt_className.Text := className;

    classNameDO := className + 'DO';
    classNameDAO := className + 'DAO';

    subPackage.text := getSubPackage(edt_tableName.Text);
    cur_subpackage := targetPackage.Text + '.' + subPackage.text;
    entitySubPackage := cur_subpackage + '.' + 'entity';
    daoSubPackage := cur_subpackage + '.' + 'dao';
    {
    const targetProject, entitySubPackage, daoSubPackage, tableAlias: string;
    const tableName: string; const clzName: string
    }
    Result := getDAOXML(edt_target_project.Text, entitySubPackage,
      daoSubPackage,
      edt_tableName.text, classNameDO, classNameDAO);
  end;

  function getDBSection(): string;
  begin
    Result := getDBXML(self.edtDriverClass.Text, self.edtConnectionURL.Text,
      self.edtUserId.Text, self.edtPassword.text);
  end;

var dbSection, daoSection: string;

begin
  dbSection := getDBSection();
  daoSection := getDAOSection();
  //
  self.Memo1.Text := getXMLContent(dbSection, daoSection);
end;

procedure TfrmMain.ctrl_file(const bWrite: boolean);
var myIniFile: TIniFile;
  i: integer;
  ctrl: TControl;
begin
 myIniFile := Tinifile.create(self.FBName);
 try
   for I := 0 to self.GroupBox1.ControlCount - 1 do begin
     ctrl := GroupBox1.Controls[I];
     if (ctrl is TEdit) then begin
       if bWrite then begin
         myIniFile.WriteString('combox', TComboBox(ctrl).Name, TComboBox(ctrl).Text);
       end else begin
         TComboBox(ctrl).Text := myIniFile.ReadString('combox', TComboBox(ctrl).Name, TComboBox(ctrl).Text);
       end;
     end;
   end;
 finally
   myIniFile.Free;
 end;
end;

function TfrmMain.getAppPath: string;
begin
  Result := ExtractFilePath(Application.ExeName);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  setFPath(self.getAppPath());
  self.WindowState := wsMaximized;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  ctrl_file(true);
end;

procedure TfrmMain.setFPath(const S: string);
begin
  FBName := S + '\' + 'setting.ini';
  ctrl_file();
end;

end.
