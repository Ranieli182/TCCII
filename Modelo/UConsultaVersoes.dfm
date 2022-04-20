object frmEnvioEmailCliente: TfrmEnvioEmailCliente
  Left = 0
  Top = 0
  Caption = 'Envio E-mail Clientes'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 635
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
    Width = 635
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
      Top = 16
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
    object rbtnSelecionarTodos: TRadioButton
      Left = 408
      Top = 16
      Width = 113
      Height = 17
      Caption = 'Selecionar Todos'
      TabOrder = 3
    end
  end
  object dbgSistemas: TDBGrid
    Left = 0
    Top = 146
    Width = 635
    Height = 153
    Align = alClient
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'IDCODIGOSUBVERSAO'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DESCRICAOSUBVERSAO'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DATASUBVERSAO'
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'IDCODIGOVERSAO'
        Visible = True
      end>
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 41
    Width = 635
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
      ExplicitLeft = 349
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
    DataSet = dtmConexao.qryclientes
    Left = 560
    Top = 91
  end
end
