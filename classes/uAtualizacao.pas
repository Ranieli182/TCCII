unit uAtualizacao;

interface

type TAtualizacao=class
  private
    FVersao: string;
    FSistema: integer;
    FDescricao: string;
    FCodigoEmpresa: integer;

  public
   property Versao: string read FVersao write FVersao;
   property Sistema: integer read FSistema write FSistema;
   property Descricao: string read FDescricao write FDescricao;
   property CodigoEmpresa: integer read FCodigoEmpresa write FCodigoEmpresa;

  // {"atualizacao":[{"VER":"blablabla","SIS":"1","DESC":"blabalbalbablablabal","COD_EMP":0}]}
end;

implementation

end.
