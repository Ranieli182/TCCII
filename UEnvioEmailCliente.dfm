object frmEnvioEmailCliente: TfrmEnvioEmailCliente
  Left = 0
  Top = 0
  Caption = 'Envio E-mail Clientes'
  ClientHeight = 381
  ClientWidth = 834
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 834
    Height = 41
    Align = alTop
    Caption = 'Envio E-mail Clientes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Comic Sans MS'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object pnlPesquisa: TPanel
    Left = 0
    Top = 82
    Width = 834
    Height = 64
    Align = alTop
    TabOrder = 1
    object lblPesquisa: TLabel
      Left = 232
      Top = 2
      Width = 80
      Height = 13
      Caption = 'Tipo de Pesquisa'
    end
    object edtPesquisar: TEdit
      Left = 24
      Top = 16
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = edtPesquisarChange
    end
    object btnPesquisar: TButton
      Left = 167
      Top = 14
      Width = 36
      Height = 25
      ImageIndex = 33
      Images = dtmImagens.iml24x24
      TabOrder = 1
      OnClick = btnPesquisarClick
    end
    object cbnTipoDePesquisa: TComboBox
      Left = 232
      Top = 21
      Width = 145
      Height = 21
      ItemIndex = 1
      TabOrder = 2
      Text = 'Descri'#231#227'o'
      Items.Strings = (
        'C'#243'digo'
        'Descri'#231#227'o')
    end
    object chkSelecionarTodos: TCheckBox
      Left = 416
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Selecionar Todos'
      TabOrder = 3
      OnClick = chkSelecionarTodosClick
    end
  end
  object dbgSistemas: TDBGrid
    Left = 0
    Top = 146
    Width = 834
    Height = 235
    Align = alClient
    DataSource = dtsClientes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'MC01CODIGO'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'MC01NOME'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'MC01FANTASIA'
        Width = 64
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'MC01EMAIL'
        Width = 64
        Visible = True
      end>
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 41
    Width = 834
    Height = 41
    Align = alTop
    TabOrder = 3
    object btnCancelar: TButton
      AlignWithMargins = True
      Left = 119
      Top = 4
      Width = 109
      Height = 33
      Align = alLeft
      Caption = '&Cancelar'
      ImageIndex = 2
      Images = dtmImagens.iml24x24
      TabOrder = 0
      OnClick = btnCancelarClick
    end
    object btnEnviar: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 109
      Height = 33
      Align = alLeft
      Caption = '&Enviar'
      ImageIndex = 9
      Images = dtmImagens.iml24x24
      TabOrder = 1
      OnClick = btnEnviarClick
    end
  end
  object dtsClientes: TDataSource
    DataSet = dtmConexao.qryClientes
    Left = 560
    Top = 91
  end
  object frxRelatorio: TfrxReport
    Version = '5.6.8'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Padr'#227'o'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 43049.728265752320000000
    ReportOptions.LastChange = 43049.728265752320000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 640
    Top = 224
    Datasets = <>
    Variables = <>
    Style = <>
    object Data: TfrxDataPage
      Height = 1000.000000000000000000
      Width = 1000.000000000000000000
    end
    object Page1: TfrxReportPage
      PaperWidth = 210.000000000000000000
      PaperHeight = 297.000000000000000000
      PaperSize = 9
      LeftMargin = 10.000000000000000000
      RightMargin = 10.000000000000000000
      TopMargin = 10.000000000000000000
      BottomMargin = 10.000000000000000000
    end
  end
  object email: TMAPIMail
    EditDialog = True
    ResolveNames = False
    RequestReceipt = False
    Left = 336
    Top = 232
  end
end
