unit uLogs;

interface

uses
  FireDAC.Comp.Client, System.SysUtils, uFuncoes;

type
  TLogLocal = class
  private
    FId: Integer;
    FCodigoEmpresa: Integer;
    FDescricao: string;
    FNomeEmpresa: string;
    FDataHora: TDateTime;
    FDiaSemana: string;
    FQry: TFDQuery;
    FEnderecosIp: string;
    FNomeComputador: string;
    FTamanhoArquivoCompactado: Double;
    FNomeArquivo: string;
    FDataHoraFim: TDateTime;
    FTamanhoArquivo: Double;
    FTipo: string;
    FCaminhoArquivoFTP: string;
    FEnviadoParaServidor: string;

    FDataSet: TFDQuery;
    FDataSetConsulta: TFDQuery;
    FListaDeLogsNaoEnviadosParaServidor: TFDQuery;

    procedure SetNomeComputador(const Value: string); // bitrix #824
    function GetNomeComputador: string;               // bitrix #824

  public
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property CodigoEmpresa: Integer read FCodigoEmpresa write FCodigoEmpresa;
    property DataHora: TDateTime read FDataHora write FDataHora;
    property Descricao: string read FDescricao write FDescricao;
    property NomeEmpresa: string read FNomeEmpresa write FNomeEmpresa;
    property NomeComputador: string read GetNomeComputador write SetNomeComputador;
    property EnderecosIp: string read FEnderecosIp write FEnderecosIp;
    property DiaSemana: string read FDiaSemana write FDiaSemana;
    property Qry: TFDQuery read FQry write FQry;
    property DataHoraFim: TDateTime read FDataHoraFim write FDataHoraFim;
    property NomeArquivo: string read FNomeArquivo write FNomeArquivo;
    property TamanhoArquivo: Double read FTamanhoArquivo write FTamanhoArquivo;
    property TamanhoArquivoCompactado: Double read FTamanhoArquivoCompactado write FTamanhoArquivoCompactado;
    property CaminhoArquivoFTP: string read FCaminhoArquivoFTP write FCaminhoArquivoFTP;
    property Tipo: string read FTipo write FTipo;

    property ListaDeLogsNaoEnviadosParaServidor: TFDQuery read FListaDeLogsNaoEnviadosParaServidor
      write FListaDeLogsNaoEnviadosParaServidor;

    property EnviadoParaServidor: string read FEnviadoParaServidor write FEnviadoParaServidor;

    procedure Gravar(pLogLocal: TLogLocal);
    constructor Create(pConexao: TFDConnection);
    procedure CarregaListaDeLogNaoEnviadosParaServidor;
    procedure CarregaLogNaoEnviadosParaServidorPeloId(pId: Integer);
    procedure TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;
    procedure TrocaSituacaoDoLogParaEnviadoParaServidor(pIdLog: Integer);
    procedure Limpar;
  end;

implementation

{ TLogLocal }

procedure TLogLocal.CarregaListaDeLogNaoEnviadosParaServidor;
begin
  FListaDeLogsNaoEnviadosParaServidor.Close;
  FListaDeLogsNaoEnviadosParaServidor.SQL.Clear;
  FListaDeLogsNaoEnviadosParaServidor.SQL.Add('SELECT * FROM MC_LOG_LOCAL           ');
  FListaDeLogsNaoEnviadosParaServidor.SQL.Add('WHERE ENVIADO_PARA_SERVIDOR <> ''S'' ');
  FListaDeLogsNaoEnviadosParaServidor.Open;
  FListaDeLogsNaoEnviadosParaServidor.FetchAll;
end;

procedure TLogLocal.CarregaLogNaoEnviadosParaServidorPeloId(pId: Integer);
begin
  FListaDeLogsNaoEnviadosParaServidor.Close;
  FListaDeLogsNaoEnviadosParaServidor.SQL.Clear;
  FListaDeLogsNaoEnviadosParaServidor.SQL.Add('SELECT * FROM MC_LOG_LOCAL            ');
  FListaDeLogsNaoEnviadosParaServidor.SQL.Add('WHERE ID = :ID  ;                     ');
  FListaDeLogsNaoEnviadosParaServidor.ParamByName('ID').AsInteger := pId;
  FListaDeLogsNaoEnviadosParaServidor.Open;
end;

constructor TLogLocal.Create(pConexao: TFDConnection);
begin
  FDataSet := TFDQuery.Create(nil);
  FDataSetConsulta := TFDQuery.Create(nil);
  FListaDeLogsNaoEnviadosParaServidor := TFDQuery.Create(nil);
  FDataSet.Connection := pConexao;
  FDataSetConsulta.Connection := pConexao;
  FListaDeLogsNaoEnviadosParaServidor.Connection := pConexao;

  FNomeComputador := TFuncoes.NomeComputador;
  FEnderecosIp := TFuncoes.EnderecosIpComputador;
end;

destructor TLogLocal.Destroy;
begin
  FDataSet.Free;
  FDataSetConsulta.Free;
  FListaDeLogsNaoEnviadosParaServidor.Free;
  inherited;
end;

function TLogLocal.GetNomeComputador: string;
begin
Result:= FNomeComputador;
end;

procedure TLogLocal.Gravar(pLogLocal: TLogLocal);
begin
  try
    pLogLocal.FQry.Close;
    pLogLocal.FQry.SQL.Clear;
    pLogLocal.FQry.SQL.Add('INSERT INTO MC_LOG_LOCAL (         ');
    pLogLocal.FQry.SQL.Add('     ID,                           ');
    pLogLocal.FQry.SQL.Add('     CODIGO_EMPRESA,               ');
    pLogLocal.FQry.SQL.Add('     NOME_EMPRESA,                 ');
    pLogLocal.FQry.SQL.Add('     DATA_HORA,                    ');
    pLogLocal.FQry.SQL.Add('     NOME_COMPUTADOR,              ');
    pLogLocal.FQry.SQL.Add('     ENDERECOS_IP,                 ');
    pLogLocal.FQry.SQL.Add('     DESCRICAO,                    ');
    pLogLocal.FQry.SQL.Add('     DATA_HORA_FIM,                ');
    pLogLocal.FQry.SQL.Add('     NOME_ARQUIVO,                 ');
    pLogLocal.FQry.SQL.Add('     TAMANHO_ARQUIVO,              ');
    pLogLocal.FQry.SQL.Add('     TAMANHO_ARQUIVO_COMPACTADO,   ');
    pLogLocal.FQry.SQL.Add('     CAMINHO_ARQUIVO_FTP,          ');
    pLogLocal.FQry.SQL.Add('     TIPO                          ');
    pLogLocal.FQry.SQL.Add('  )                                ');
    pLogLocal.FQry.SQL.Add(' VALUES(                           ');
    pLogLocal.FQry.SQL.Add('     :ID,                          ');
    pLogLocal.FQry.SQL.Add('     :CODIGO_EMPRESA,              ');
    pLogLocal.FQry.SQL.Add('     :NOME_EMPRESA,                ');
    pLogLocal.FQry.SQL.Add('     :DATA_HORA,                   ');
    pLogLocal.FQry.SQL.Add('     :NOME_COMPUTADOR,             ');
    pLogLocal.FQry.SQL.Add('     :ENDERECOS_IP,                ');
    pLogLocal.FQry.SQL.Add('     :DESCRICAO,                   ');
    pLogLocal.FQry.SQL.Add('     :DATA_HORA_FIM,               ');
    pLogLocal.FQry.SQL.Add('     :NOME_ARQUIVO,                ');
    pLogLocal.FQry.SQL.Add('     :TAMANHO_ARQUIVO,             ');
    pLogLocal.FQry.SQL.Add('     :TAMANHO_ARQUIVO_COMPACTADO,  ');
    pLogLocal.FQry.SQL.Add('     :CAMINHO_ARQUIVO_FTP,         ');
    pLogLocal.FQry.SQL.Add('     :TIPO                         ');
    pLogLocal.FQry.SQL.Add('  )                                ');
    pLogLocal.FQry.ParamByName('ID').AsInteger := pLogLocal.Id;
    pLogLocal.FQry.ParamByName('CODIGO_EMPRESA').AsInteger := pLogLocal.CodigoEmpresa;
    pLogLocal.FQry.ParamByName('NOME_EMPRESA').AsString := pLogLocal.NomeEmpresa;
    pLogLocal.FQry.ParamByName('DATA_HORA').AsDateTime := pLogLocal.DataHora;
    pLogLocal.FQry.ParamByName('NOME_COMPUTADOR').AsString := pLogLocal.NomeComputador;
    pLogLocal.FQry.ParamByName('ENDERECOS_IP').AsString := pLogLocal.EnderecosIp;
    pLogLocal.FQry.ParamByName('DESCRICAO').AsString := pLogLocal.Descricao;
    pLogLocal.FQry.ParamByName('DATA_HORA_FIM').AsDateTime := pLogLocal.DataHoraFim;
    pLogLocal.FQry.ParamByName('NOME_ARQUIVO').AsString := pLogLocal.NomeArquivo;
    pLogLocal.FQry.ParamByName('TAMANHO_ARQUIVO').AsFloat := pLogLocal.TamanhoArquivo;
    pLogLocal.FQry.ParamByName('TAMANHO_ARQUIVO_COMPACTADO').AsFloat := pLogLocal.TamanhoArquivoCompactado;
    pLogLocal.FQry.ParamByName('CAMINHO_ARQUIVO_FTP').AsString := pLogLocal.CaminhoArquivoFTP;
    pLogLocal.FQry.ParamByName('TIPO').AsString := pLogLocal.Tipo;
    pLogLocal.FQry.execSql;
    pLogLocal.FQry.Connection.Commit;
  except
    on E: Exception do
    begin
      pLogLocal.FQry.Connection.Rollback;
    end;
  end;

end;

procedure TLogLocal.Limpar;
begin
  FCodigoEmpresa := 0;
  FDescricao := '';
  FNomeEmpresa := '';
  FDataHora := 0;
  FDiaSemana := '';
  FNomeComputador := TFuncoes.NomeComputador;
  FEnderecosIp := TFuncoes.EnderecosIpComputador;
  FTamanhoArquivoCompactado := 0;
  FNomeArquivo := '';
  FDataHoraFim := 0;
  FTamanhoArquivo := 0;
  FTipo := '';
  FCaminhoArquivoFTP := '';
end;

procedure TLogLocal.SetNomeComputador(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FNomeComputador := lTextoTratado;
end;

procedure TLogLocal.TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;
begin
  try
    FDataSet.Close;
    FDataSet.SQL.Clear;
    FDataSet.SQL.Add('UPDATE MC_LOG_LOCAL SET                ');
    FDataSet.SQL.Add('      ENVIADO_PARA_SERVIDOR = ''S''    ');
    FDataSet.SQL.Add('WHERE ENVIADO_PARA_SERVIDOR <> ''S'' ; ');
    FDataSet.execSql;
  except
    // não faço nada aqui para não travar o fluxo da aplicação
  end;
end;

procedure TLogLocal.TrocaSituacaoDoLogParaEnviadoParaServidor(pIdLog: Integer);
begin
  try
    FDataSet.Close;
    FDataSet.SQL.Clear;
    FDataSet.SQL.Add('UPDATE MC_LOG_LOCAL SET                ');
    FDataSet.SQL.Add('      ENVIADO_PARA_SERVIDOR = ''S''    ');
    FDataSet.SQL.Add('WHERE ID = :ID ;                       ');
    FDataSet.ParamByName('ID').AsInteger := pIdLog;
    FDataSet.execSql;
  except
    // não faço nada aqui para não travar o fluxo da aplicação
  end;
end;

end.
