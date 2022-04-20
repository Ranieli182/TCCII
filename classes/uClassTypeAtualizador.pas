unit uClassTypeAtualizador;

interface

type
  TTipoRotina = (trConfiguracaoBackup, trConfiguracaoGeral);

  TServicoWebService = (swNone, swConsultaAtualizacoes, swConsultaEmpresas, swCadastraLogs, swCadastraLogErros, swUltimaAtualizacao, swCadastraLogAtualizacao,
    swCadastraLogLogin, swCadastraAtualizacao);

  TConsultaEmpresa = (ceCodigoEmpresa, ceChaveRegistro, ceCnpj);

  TFuncaoAplicativo = (faAtualizador,faHistoricoLogin);

implementation

end.
