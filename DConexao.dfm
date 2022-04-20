object dtmConexao: TdtmConexao
  OldCreateOrder = False
  Height = 328
  Width = 438
  object cnnConexao: TFDConnection
    Params.Strings = (
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Port=3050'
      'Database=D:\Projetos\TCCII - Ranieli\BancoDados\BANCO'
      'Server=127.0.0.1'
      'Protocol=TCPIP'
      'DriverID=FB')
    LoginPrompt = False
    Transaction = trsTransacao
    Left = 24
    Top = 16
  end
  object trsTransacao: TFDTransaction
    Connection = cnnConexao
    Left = 24
    Top = 80
  end
  object qryConsulta: TFDQuery
    Connection = cnnConexao
    Left = 24
    Top = 152
  end
  object qryUsuarios: TFDQuery
    Connection = cnnConexao
    SQL.Strings = (
      'select * from usuarios')
    Left = 96
    Top = 152
    object qryUsuariosIDCODIGOUSUARIO: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'IDCODIGOUSUARIO'
      Origin = 'IDCODIGOUSUARIO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qryUsuariosDESCRICAOUSUARIO: TStringField
      DisplayLabel = 'Descri'#231#227'o '
      FieldName = 'DESCRICAOUSUARIO'
      Origin = 'DESCRICAOUSUARIO'
    end
    object qryUsuariosSENHAUSUARIO: TStringField
      DisplayLabel = 'Senha'
      FieldName = 'SENHAUSUARIO'
      Origin = 'SENHAUSUARIO'
      Size = 10
    end
    object qryUsuariosTIPOUSUARIO: TStringField
      DisplayLabel = 'Tipo'
      FieldName = 'TIPOUSUARIO'
      Origin = 'TIPOUSUARIO'
      FixedChar = True
      Size = 1
    end
    object qryUsuariosDATAUSUARIO: TDateField
      DisplayLabel = 'Data'
      FieldName = 'DATAUSUARIO'
      Origin = 'DATAUSUARIO'
    end
  end
  object qrySistema: TFDQuery
    Connection = cnnConexao
    SQL.Strings = (
      'select * from sistemas')
    Left = 96
    Top = 16
    object qrySistemaIDCODIGOSISTEMA: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'IDCODIGOSISTEMA'
      Origin = 'IDCODIGOSISTEMA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qrySistemaDESCRICAOSISTEMA: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'DESCRICAOSISTEMA'
      Origin = 'DESCRICAOSISTEMA'
    end
    object qrySistemaDATASISTEMA: TDateField
      DisplayLabel = 'Data do Sistema'
      FieldName = 'DATASISTEMA'
      Origin = 'DATASISTEMA'
    end
  end
  object qryVersoes: TFDQuery
    Connection = cnnConexao
    SQL.Strings = (
      'Select * from versoes')
    Left = 96
    Top = 88
    object qryVersoesIDCODIGOVERSAO: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'IDCODIGOVERSAO'
      Origin = 'IDCODIGOVERSAO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qryVersoesDESCRICAOVERSAO: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'DESCRICAOVERSAO'
      Origin = 'DESCRICAOVERSAO'
      Size = 10
    end
    object qryVersoesDATAVERSAO: TDateField
      DisplayLabel = 'Data da Vers'#227'o'
      FieldName = 'DATAVERSAO'
      Origin = 'DATAVERSAO'
    end
  end
  object qrySubversoes: TFDQuery
    Connection = cnnConexao
    SQL.Strings = (
      'SELECT'
      '    SV.IDCODIGOSUBVERSAO   ,'
      '    SV.DESCRICAOSUBVERSAO  ,'
      '    SV.DATASUBVERSAO       ,'
      '    SV.IDCODIGOVERSAO       ,'
      '    V.DESCRICAOVERSAO       '
      ''
      'FROM     SUBVERSOES SV'
      'INNER JOIN VERSOES     V'
      'ON ( SV.IDCODIGOVERSAO = V.IDCODIGOVERSAO)')
    Left = 168
    Top = 16
    object qrySubversoesIDCODIGOSUBVERSAO: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'IDCODIGOSUBVERSAO'
      Origin = 'IDCODIGOSUBVERSAO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qrySubversoesDESCRICAOSUBVERSAO: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'DESCRICAOSUBVERSAO'
      Origin = 'DESCRICAOSUBVERSAO'
      Size = 10
    end
    object qrySubversoesDATASUBVERSAO: TDateField
      DisplayLabel = 'Data'
      FieldName = 'DATASUBVERSAO'
      Origin = 'DATASUBVERSAO'
    end
    object qrySubversoesIDCODIGOVERSAO: TIntegerField
      DisplayLabel = 'C'#243'digo Vers'#227'o'
      FieldName = 'IDCODIGOVERSAO'
      Origin = 'IDCODIGOVERSAO'
    end
    object qrySubversoesDESCRICAOVERSAO: TStringField
      AutoGenerateValue = arDefault
      DisplayLabel = 'Vers'#227'o'
      FieldName = 'DESCRICAOVERSAO'
      Origin = 'DESCRICAOVERSAO'
      ProviderFlags = []
      ReadOnly = True
      Size = 10
    end
  end
  object qryModificacoes: TFDQuery
    Connection = cnnConexao
    SQL.Strings = (
      'SELECT'
      '    M.IDCODIGOMODIFICACAO   ,'
      '    M.DESCRICAOMODIFICACAO  ,'
      '    M.DATAMODIFICACAO       ,'
      '    M.TIPOMODIFICACAO       ,'
      '    M.IDCODIGOVERSAO        ,'
      '    M.IDCODIGOSUBVERSAO     ,'
      '    M.IDCODIGOSISTEMA       ,'
      '   -- V.IDCODIGOVERSAO        ,'
      '    V.DESCRICAOVERSAO       ,'
      '   -- SV.IDCODIGOSUBVERSAO    ,'
      '    SV.DESCRICAOSUBVERSAO   ,'
      '    --S.IDCODIGOSISTEMA       ,'
      '    S.DESCRICAOSISTEMA      '
      ''
      ''
      'FROM     MODIFICACOES M'
      'INNER JOIN VERSOES     V'
      'ON ( M.IDCODIGOVERSAO = V.IDCODIGOVERSAO)'
      'INNER JOIN SUBVERSOES     SV'
      'ON ( M.IDCODIGOSUBVERSAO  = SV.IDCODIGOSUBVERSAO)'
      'INNER JOIN SISTEMAS     S'
      'ON ( M.IDCODIGOSISTEMA = S.IDCODIGOSISTEMA)')
    Left = 168
    Top = 88
    object qryModificacoesIDCODIGOMODIFICACAO: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'IDCODIGOMODIFICACAO'
      Origin = 'IDCODIGOMODIFICACAO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qryModificacoesDESCRICAOMODIFICACAO: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'DESCRICAOMODIFICACAO'
      Origin = 'DESCRICAOMODIFICACAO'
      Size = 400
    end
    object qryModificacoesDATAMODIFICACAO: TDateField
      DisplayLabel = 'Data'
      FieldName = 'DATAMODIFICACAO'
      Origin = 'DATAMODIFICACAO'
    end
    object qryModificacoesTIPOMODIFICACAO: TStringField
      DisplayLabel = 'Tipo'
      FieldName = 'TIPOMODIFICACAO'
      Origin = 'TIPOMODIFICACAO'
      FixedChar = True
      Size = 1
    end
    object qryModificacoesIDCODIGOVERSAO: TIntegerField
      DisplayLabel = 'Vers'#227'o'
      FieldName = 'IDCODIGOVERSAO'
      Origin = 'IDCODIGOVERSAO'
    end
    object qryModificacoesIDCODIGOSUBVERSAO: TIntegerField
      DisplayLabel = 'Subvers'#227'o'
      FieldName = 'IDCODIGOSUBVERSAO'
      Origin = 'IDCODIGOSUBVERSAO'
    end
    object qryModificacoesIDCODIGOSISTEMA: TIntegerField
      DisplayLabel = 'Sistema'
      FieldName = 'IDCODIGOSISTEMA'
      Origin = 'IDCODIGOSISTEMA'
    end
    object qryModificacoesDESCRICAOVERSAO: TStringField
      AutoGenerateValue = arDefault
      DisplayLabel = 'Vers'#227'o'
      FieldName = 'DESCRICAOVERSAO'
      Origin = 'DESCRICAOVERSAO'
      ProviderFlags = []
      ReadOnly = True
      Size = 10
    end
    object qryModificacoesDESCRICAOSUBVERSAO: TStringField
      AutoGenerateValue = arDefault
      DisplayLabel = 'Subvers'#227'o'
      FieldName = 'DESCRICAOSUBVERSAO'
      Origin = 'DESCRICAOSUBVERSAO'
      ProviderFlags = []
      ReadOnly = True
      Size = 10
    end
    object qryModificacoesDESCRICAOSISTEMA: TStringField
      AutoGenerateValue = arDefault
      DisplayLabel = 'Sistema '
      FieldName = 'DESCRICAOSISTEMA'
      Origin = 'DESCRICAOSISTEMA'
      ProviderFlags = []
      ReadOnly = True
    end
  end
  object qryClientes: TFDQuery
    Connection = cnnConexao
    SQL.Strings = (
      'select * from mc01cliente')
    Left = 168
    Top = 152
    object qryClientesMC01CODIGO: TIntegerField
      DisplayLabel = 'C'#243'digo'
      FieldName = 'MC01CODIGO'
      Origin = 'MC01CODIGO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object qryClientesMC01NOME: TStringField
      DisplayLabel = 'Raz'#227'o Social'
      FieldName = 'MC01NOME'
      Origin = 'MC01NOME'
      Size = 35
    end
    object qryClientesMC01FANTASIA: TStringField
      DisplayLabel = 'Nome Fantasia'
      FieldName = 'MC01FANTASIA'
      Origin = 'MC01FANTASIA'
      Size = 35
    end
    object qryClientesMC01EMAIL: TStringField
      DisplayLabel = 'E-mail'
      FieldName = 'MC01EMAIL'
      Origin = 'MC01EMAIL'
      Size = 50
    end
  end
end
