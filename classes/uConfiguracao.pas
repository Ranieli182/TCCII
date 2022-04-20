unit uConfiguracao;

interface

uses
  uEmpresa;

type
  TConfiguracao = class
    private
      FDiretorioFTP: string;
      FAplicativo: string;
      FUsuarioWebService: string;
      FSenhaWebService: string;
      FHostWebService: string;
      FSistema: Integer;
      FCodigoEmpresaLoginWebService:Integer;
      FEmpresa: TEmpresa;
    public
      destructor Destroy; override;
      property DiretorioFTP: string read FDiretorioFTP write FDiretorioFTP;
      property Aplicativo: string read FAplicativo write FAplicativo;
      property UsuarioWebService: string read FUsuarioWebService write FUsuarioWebService;
      property SenhaWebService: string read FSenhaWebService write FSenhaWebService;
      property HostWebService: string read FHostWebService write FHostWebService;
      property Sistema: Integer read FSistema write FSistema;
      property CodigoEmpresaLoginWebService:Integer read FCodigoEmpresaLoginWebService
      write FCodigoEmpresaLoginWebService;
      property Empresa: TEmpresa read FEmpresa write FEmpresa;

      constructor Create(pDiretorioFTP, pAplicativo: string);

  end;

implementation

{ TConfiguracao }

constructor TConfiguracao.Create(pDiretorioFTP, pAplicativo: string);
begin
  FDiretorioFTP := pDiretorioFTP;
  FAplicativo := pAplicativo;

  FEmpresa := TEmpresa.Create;
end;

destructor TConfiguracao.Destroy;
begin
  FEmpresa.Free;
  inherited;
end;

end.
