unit uEmpresa;

interface

uses uClassTypeAtualizador;

type
  TEmpresa = class
    private
      FCodigoEmpresa: Integer;
      FNome: string;
      FCpf_Cnpj: string;
      FFantasia: string;
      FAtivo: Boolean;
      FBackupOnline: Boolean;
      FChaveRegistro: string;
      FAtualizacaoAutomatica: Boolean;
      FTipoConsulta: TConsultaEmpresa;
      //

    public
      property CodigoEmpresa: Integer read FCodigoEmpresa write FCodigoEmpresa;
      property Nome: string read FNome write FNome;
      property Cpf_Cnpj: string read FCpf_Cnpj write FCpf_Cnpj;
      property Fantasia: string read FFantasia write FFantasia;
      property Ativo: Boolean read FAtivo write FAtivo;
      property BackupOnline: Boolean read FBackupOnline write FBackupOnline;
      property ChaveRegistro: string read FChaveRegistro write FChaveRegistro;
      property AtualizacaoAutomatica: Boolean read FAtualizacaoAutomatica write FAtualizacaoAutomatica;
      property TipoConsulta: TConsultaEmpresa read FTipoConsulta write FTipoConsulta;
  end;

implementation

end.
