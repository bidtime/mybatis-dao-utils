object frmSetting: TfrmSetting
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #35774#32622
  ClientHeight = 431
  ClientWidth = 574
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 368
    Top = 399
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 470
    Top = 399
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = Button2Click
  end
  object PageControl1: TPageControl
    Left = 5
    Top = 8
    Width = 561
    Height = 385
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'SQL Mapper'
      object memoSqlMap: TMemo
        Left = 0
        Top = 0
        Width = 553
        Height = 357
        Align = alClient
        Lines.Strings = (
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<!DOCTYPE generatorConfiguration'
          
            '  PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.' +
            '0//EN"'
          '  "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">'
          ''
          '<generatorConfiguration>'
          '  <context id="test1" targetRuntime="MyBatis3">'
          ''
          '    <property name="javaFileEncoding" value="UTF-8" />'
          '    <property name="autoDelimitKeywords" value="false" />'
          ''
          
            '    <plugin type="com.ecarpo.framework.mybatis.generator.FormatM' +
            'apperPlugin"></plugin>'
          '    <!--'
          
            '    <plugin type="com.ecarpo.framework.mybatis.generator.Mybatis' +
            'SerializablePlugin"></plugin>'
          '    -->'
          ''
          
            '    <plugin type="com.ecarpo.framework.mybatis.generator.FormatM' +
            'apperPlugin"/>'
          ''
          
            '    <commentGenerator type="com.ecarpo.framework.mybatis.generat' +
            'or.MybatisCommentGenerator">'
          '      <property name="addRemarkComments" value="true" />'
          '      <property name="dateFormat" value="yyyy-MM-dd HH:mm:ss" />'
          '    </commentGenerator>'
          ''
          '    <!-- dbms -->'
          
            '    <jdbcConnection driverClass="%s" connectionURL="%s" userId="' +
            '%s" password="%s">'
          '      <property name="nullCatalogMeansCurrent" value="true" />'
          '    </jdbcConnection>'
          ''
          
            '    <javaTypeResolver type="com.ecarpo.framework.mybatis.generat' +
            'or.MybatisJavaTypeResolver">'
          '      <property name="forceBigDecimals" value="false" />'
          '    </javaTypeResolver>'
          ''
          '    <!-- dao -->'
          '    <!-- %s dao begin -->'
          '    <javaModelGenerator targetPackage="%s" targetProject="%s">'
          '      <property name="enableSubPackages" value="true" />'
          '      <property name="trimStrings" value="true" />'
          '      <property name="immutable" value="false"/>'
          '    </javaModelGenerator>'
          ''
          '    <sqlMapGenerator targetPackage="%s" targetProject="%s">'
          '      <property name="enableSubPackages" value="true" />'
          '    </sqlMapGenerator>'
          ''
          
            '    <javaClientGenerator type="XMLMAPPER" targetPackage="%s" tar' +
            'getProject="%s">'
          '      <property name="enableSubPackages" value="true" />'
          '    </javaClientGenerator>'
          ''
          '    <table tableName="%s" domainObjectName="%s" mapperName="%s"'
          
            '      enableCountByExample="false" enableDeleteByExample="false"' +
            ' enableSelectByExample="false"'
          
            '      selectByExampleQueryId="false" enableUpdateByExample="fals' +
            'e">'
          '      <property name="useActualColumnNames" value="false" />'
          '    </table>'
          ''
          '    <!-- %s dao end -->'
          ''
          '  </context>'
          '</generatorConfiguration>;')
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Update Mapper'
      ImageIndex = 2
      object GroupBox2: TGroupBox
        Left = 0
        Top = 0
        Width = 553
        Height = 357
        Align = alClient
        TabOrder = 0
        object rbUpdateMap: TRadioButton
          Left = 26
          Top = 21
          Width = 101
          Height = 21
          Caption = 'updateMap'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbUpdateForVer: TRadioButton
          Left = 26
          Top = 64
          Width = 96
          Height = 21
          Caption = 'updateForVer'
          TabOrder = 1
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'SQL format'
      ImageIndex = 3
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 553
        Height = 357
        Align = alClient
        TabOrder = 0
        object Label2: TLabel
          Left = 26
          Top = 118
          Width = 83
          Height = 13
          Caption = 'Identation size'#65306
        end
        object RadioButton1: TRadioButton
          Left = 26
          Top = 53
          Width = 113
          Height = 17
          Caption = 'Ident using Tabs'
          TabOrder = 0
        end
        object RadioButton2: TRadioButton
          Left = 26
          Top = 86
          Width = 113
          Height = 17
          Caption = 'Ident using Spaces'
          TabOrder = 1
        end
        object Edit1: TEdit
          Left = 109
          Top = 115
          Width = 65
          Height = 21
          TabOrder = 2
          Text = '4'
        end
        object Button3: TButton
          Left = 180
          Top = 113
          Width = 26
          Height = 25
          Caption = #65293
          TabOrder = 3
          OnClick = Button3Click
        end
        object Button4: TButton
          Left = 210
          Top = 113
          Width = 26
          Height = 25
          Caption = #65291
          TabOrder = 4
          OnClick = Button4Click
        end
        object CheckBox1: TCheckBox
          Left = 26
          Top = 21
          Width = 137
          Height = 17
          Caption = 'Clear all blank lines'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
      end
    end
  end
end
