unit uLogErros;

interface

uses
  FireDAC.Comp.Client, System.SysUtils, uFuncoes;

type
  TLogErros = class
  private

    FId: Integer;
    FDataHora: TDateTime;
    FCodigoEmpresa: Integer;
    FNomeEmpresa: string;
    FClasseErro: string;
    FMensagemErro: string;
    FVersaoApp: string;
    FMetodo: string;
    FClasse: string;
    FEnviadoParaServidor: string;
    FDataSet: TFDQuery;
    FDataSetConsulta: TFDQuery;
    FListaDeLogsDeErroNaoEnviadosParaServidor: TFDQuery;

    procedure SetMensagemErro(const Value: string);
    function GetMensagemErro: string;

    procedure SetVersaoApp(const Value: string);
    function GetVersaoApp: string;

    procedure SetClasseErro(const Value: string);
    function GetClasseErro: string;

    function GeraProximoId: Integer;
  public
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property DataHora: TDateTime read FDataHora write FDataHora;
    property CodigoEmpresa: Integer read FCodigoEmpresa write FCodigoEmpresa;
    property NomeEmpresa: string read FNomeEmpresa write FNomeEmpresa;
    property ClasseErro: string read GetClasseErro write SetClasseErro;
    property MensagemErro: string read GetMensagemErro write SetMensagemErro;
    property VersaoApp: string read GetVersaoApp write SetVersaoApp;
    property Metodo: string read FMetodo write FMetodo;
    property Classe: string read FClasse write FClasse;

    property EnviadoParaServidor: string read FEnviadoParaServidor write FEnviadoParaServidor;
    property ListaDeLogsDeErroNaoEnviadosParaServidor: TFDQuery read FListaDeLogsDeErroNaoEnviadosParaServidor
      write FListaDeLogsDeErroNaoEnviadosParaServidor;

    constructor Create(pConexao: TFDConnection);
    procedure CarregaListaDeLogDeErrosNaoEnviadosParaServidor;
    procedure CarregaLogDeErrosNaoEnviadosParaServidorPeloId(pId: Integer);
    procedure TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;
    procedure TrocaSituacaoDoLogParaEnviadoParaServidor(pIdLog: Integer);
    procedure GravaLog;
    procedure Limpar;
  end;

implementation

{ TLogErros }

constructor TLogErros.Create(pConexao: TFDConnection);
begin
  FDataSet := TFDQuery.Create(nil);
  FDataSetConsulta := TFDQuery.Create(nil);
  FListaDeLogsDeErroNaoEnviadosParaServidor := TFDQuery.Create(nil);
  FDataSet.Connection := pConexao;
  FDataSetConsulta.Connection := pConexao;
  FListaDeLogsDeErroNaoEnviadosParaServidor.Connection := pConexao;
end;

destructor TLogErros.Destroy;
begin
  FDataSet.Free;
  FDataSetConsulta.Free;
  FListaDeLogsDeErroNaoEnviadosParaServidor.Free;
  inherited;
end;

function TLogErros.GeraProximoId: Integer;
begin
  Result := 0;

  FDataSetConsulta.Close;
  FDataSetConsulta.SQL.Clear;
  FDataSetConsulta.SQL.Add('SELECT MAX(ID_LOG_ERROS) ID FROM MC_LOG_ERROS ');
  FDataSetConsulta.Open;

  if not(FDataSetConsulta.IsEmpty) then
  begin
    if FDataSetConsulta.FieldByName('id').IsNull then
    begin
      Result := 1;
    end
    else
    begin
      Result := FDataSetConsulta.FieldByName('id').AsInteger + 1;
    end;
  end;
end;

function TLogErros.GetClasseErro: string;
begin
  Result := FClasseErro;
end;

function TLogErros.GetMensagemErro: string;
begin
  Result := FMensagemErro;
end;

function TLogErros.GetVersaoApp: string;
begin
  Result := FVersaoApp;
end;

procedure TLogErros.GravaLog;
begin
  try
    FId := GeraProximoId;
    FDataHora := Now;

    FDataSet.Close;
    FDataSet.SQL.Clear;
    FDataSet.SQL.Add('INSERT INTO  MC_LOG_ERROS (   ');
    FDataSet.SQL.Add('    ID_LOG_ERROS,             ');
    FDataSet.SQL.Add('    DATA_HORA,                ');
    FDataSet.SQL.Add('    CODIGO_EMPRESA,           ');
    FDataSet.SQL.Add('    NOME_EMPRESA,             ');
    FDataSet.SQL.Add('    CLASSE_ERRO,              ');
    FDataSet.SQL.Add('    MENSAGEM_ERRO,            ');
    FDataSet.SQL.Add('    VERSAO_APP,               ');
    FDataSet.SQL.Add('    METODO,                   ');
    FDataSet.SQL.Add('    CLASSE                    ');
    FDataSet.SQL.Add('   )                          ');
    FDataSet.SQL.Add('VALUES                        ');
    FDataSet.SQL.Add('(                             ');
    FDataSet.SQL.Add('    :ID_LOG_ERROS,            ');
    FDataSet.SQL.Add('    :DATA_HORA,               ');
    FDataSet.SQL.Add('    :CODIGO_EMPRESA,          ');
    FDataSet.SQL.Add('    :NOME_EMPRESA,            ');
    FDataSet.SQL.Add('    :CLASSE_ERRO,             ');
    FDataSet.SQL.Add('    :MENSAGEM_ERRO,           ');
    FDataSet.SQL.Add('    :VERSAO_APP,              ');
    FDataSet.SQL.Add('    :METODO,                  ');
    FDataSet.SQL.Add('    :CLASSE                   ');
    FDataSet.SQL.Add(')  ;                          ');
    FDataSet.ParamByName('ID_LOG_ERROS').AsInteger := FId;
    FDataSet.ParamByName('DATA_HORA').AsDateTime := FDataHora;
    FDataSet.ParamByName('CODIGO_EMPRESA').AsInteger := FCodigoEmpresa;
    FDataSet.ParamByName('NOME_EMPRESA').AsString := FNomeEmpresa;
    FDataSet.ParamByName('CLASSE_ERRO').AsString := FClasseErro;
    FDataSet.ParamByName('MENSAGEM_ERRO').AsString := FMensagemErro;
    FDataSet.ParamByName('VERSAO_APP').AsString := FVersaoApp;
    FDataSet.ParamByName('METODO').AsString := FMetodo;
    FDataSet.ParamByName('CLASSE').AsString := FClasse;
    FDataSet.ExecSQL;
  except
    // não faço nada aqui para não travar o fluxo da aplicação
  end;
end;

procedure TLogErros.Limpar;
begin
  FCodigoEmpresa := 0;
  FNomeEmpresa := '';
  FClasseErro := '';
  FMensagemErro := '';
  FVersaoApp := '';
  FMetodo := '';
  FClasse := '';
  FEnviadoParaServidor := '';
end;

procedure TLogErros.SetClasseErro(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FClasseErro := lTextoTratado;
end;

procedure TLogErros.SetMensagemErro(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FMensagemErro := lTextoTratado;
end;

procedure TLogErros.SetVersaoApp(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FVersaoApp := lTextoTratado;

end;

procedure TLogErros.TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;
begin
  try
    FDataSet.Close;
    FDataSet.SQL.Clear;
    FDataSet.SQL.Add('UPDATE MC_LOG_ERROS SET                ');
    FDataSet.SQL.Add('      ENVIADO_PARA_SERVIDOR = ''S''    ');
    FDataSet.SQL.Add('WHERE ENVIADO_PARA_SERVIDOR <> ''S'' ; ');
    FDataSet.ExecSQL;
  except
    // não faço nada aqui para não travar o fluxo da aplicação
  end;
end;

procedure TLogErros.TrocaSituacaoDoLogParaEnviadoParaServidor(pIdLog: Integer);
begin
  try
    FDataSet.Close;
    FDataSet.SQL.Clear;
    FDataSet.SQL.Add('UPDATE MC_LOG_ERROS SET                ');
    FDataSet.SQL.Add('      ENVIADO_PARA_SERVIDOR = ''S''    ');
    FDataSet.SQL.Add('WHERE ID_LOG_ERROS = :ID_LOG_ERROS ;   ');
    FDataSet.ParamByName('ID_LOG_ERROS').AsInteger := pIdLog;
    FDataSet.ExecSQL;
  except
    // não faço nada aqui para não travar o fluxo da aplicação
  end;
end;

procedure TLogErros.CarregaListaDeLogDeErrosNaoEnviadosParaServidor;
begin
  FListaDeLogsDeErroNaoEnviadosParaServidor.Close;
  FListaDeLogsDeErroNaoEnviadosParaServidor.SQL.Clear;
  FListaDeLogsDeErroNaoEnviadosParaServidor.SQL.Add('SELECT * FROM MC_LOG_ERROS           ');
  FListaDeLogsDeErroNaoEnviadosParaServidor.SQL.Add('WHERE ENVIADO_PARA_SERVIDOR <> ''S'' ');
  FListaDeLogsDeErroNaoEnviadosParaServidor.Open;
  FListaDeLogsDeErroNaoEnviadosParaServidor.FetchAll;
end;

procedure TLogErros.CarregaLogDeErrosNaoEnviadosParaServidorPeloId(pId: Integer);
begin
  FListaDeLogsDeErroNaoEnviadosParaServidor.Close;
  FListaDeLogsDeErroNaoEnviadosParaServidor.SQL.Clear;
  FListaDeLogsDeErroNaoEnviadosParaServidor.SQL.Add('SELECT * FROM MC_LOG_ERROS            ');
  FListaDeLogsDeErroNaoEnviadosParaServidor.SQL.Add('WHERE ID_LOG_ERROS = :ID_LOG_ERROS  ; ');
  FListaDeLogsDeErroNaoEnviadosParaServidor.ParamByName('ID_LOG_ERROS').AsInteger := pId;
  FListaDeLogsDeErroNaoEnviadosParaServidor.Open;
end;

end.
