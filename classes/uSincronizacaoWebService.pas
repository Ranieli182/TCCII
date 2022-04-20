unit uSincronizacaoWebService;

interface

uses
  uClassTypeAtualizador,
  uFuncoes,
  REST.Client,
  IPPeerClient,
  Data.Bind.Components,
  Data.Bind.ObjectScope,
  REST.Response.Adapter,
  REST.Types,
  FireDAC.Comp.Client,
  System.JSON,
  System.Classes,
  uLogErros,
  System.SysUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  uLogs,
  uConfiguracao,
  uLogAtualizacao,
  uLogLoginNuvem, uAtualizacao;

type
  TSincronizacaoWebService = class
  private
    FMemTable: TFDMemTable;

{$REGION 'Componentes para conex�o com Web Service'}
    FRestClient: TRESTClient;
    FRestRequest: TRESTRequest;
    FRestResponse: TRESTResponse;
    FRestResponseDataSetAdapter: TRESTResponseDataSetAdapter;
{$ENDREGION}
{$REGION 'M�todos para configura�ao e conex�o com Web Service'}
    procedure ConfiguraRestClient(pConfiguracao: TConfiguracao);
    procedure ConfiguraRestRequest(pConfiguracao: TConfiguracao;
      pTipoServicoWS: TServicoWebService);
    procedure ConfiguraRestResponse(pConfiguracao: TConfiguracao;
      pTipoServicoWS: TServicoWebService);
    procedure InicializaRestResponseDataSetAdapter;
    procedure ExecutarRequisicao;
    procedure ConsultaNoWebService(pConfiguracao: TConfiguracao;
      pTipoServicoWS: TServicoWebService);
{$ENDREGION}
    function CadastraLogDeErroNoWebService(pConfiguracao: TConfiguracao;
      pId: Integer; pConexao: TFDConnection): string;
    function CadastraLogNoWebService(pConfiguracao: TConfiguracao;
      pConexao: TFDConnection): string;
    function CadastraListaDeLogDeErroNoWebService(pConfiguracao: TConfiguracao;
      pConexao: TFDConnection): string;

    function ConsultaEmpresasNoWebService(pConfiguracao: TConfiguracao)
      : boolean;
    function UltimaVersaoDoSistemaNoWebService(pConfiguracao
      : TConfiguracao): Integer;
    function CadastraLogAtualizacaoNoWebService(pLogAtualizacao
      : TLogAtualizacao; pConfiguracao: TConfiguracao): boolean;
    function CadastraLogLoginNoWebService(pLogLoginNuvem: TLogLoginNuvem;
      pConfiguracao: TConfiguracao): boolean;
    function CadastraAtualizacaoNoWebService(pAtualizacao: TAtualizacao;
      pConfiguracao: TConfiguracao): boolean;

  public
    destructor Destroy; override;

    class procedure ExecutaCadastraLogErroNoWebService(pConfiguracao
      : TConfiguracao; pId: Integer; pConexao: TFDConnection);
    class procedure ExecutaCadastraLogNoWebService(pConfiguracao: TConfiguracao;
      pConexao: TFDConnection);

    class function ExecutaConsultaEmpresasNoWebService(pConfiguracao
      : TConfiguracao): boolean;
    class function ExecutaUltimaVersaoDoSistemaNoWebService
      (pConfiguracao: TConfiguracao): Integer;
    class function ExecutaCadastraLogAtualizacaoNoWebService(pLogAtualizacao
      : TLogAtualizacao; pConfiguracao: TConfiguracao): boolean;
    class function ExecutaCadastraLogLoginNoWebService(pLogLoginNuvem
      : TLogLoginNuvem; pConfiguracao: TConfiguracao): boolean;
    class function ExecutaCadastraAtualizacaoNoWebService
      (pAtualizacao: TAtualizacao; pConfiguracao: TConfiguracao): boolean;

    class function ExecutaCadastraListaDeLogErrosNoWebService
      (pConfiguracao: TConfiguracao; pConexao: TFDConnection): string;

    constructor Create;

    procedure ExecutaConsultaNoWebService(pConfiguracao: TConfiguracao;
      pTipoConsulta: TServicoWebService);

    property MemTable: TFDMemTable read FMemTable write FMemTable;
  end;

implementation

{ TSincronizacaoWebService }

function TSincronizacaoWebService.CadastraLogNoWebService
  (pConfiguracao: TConfiguracao; pConexao: TFDConnection): string;
var
  lHoraInicial: TDateTime;
  lObjetoJson, lObjetoRaiz: TJSONObject;
  lJsonArray: TJSONArray;
  lContaRegistros: Integer;
  lRetornoDaRequisicaoAposCadastrar, lDiretorioPublicoApp, lNomeArquivoTxt,
    lCaminhoCompletoArquivo: string;
  FBackupTxt: TStringList;
  lLogs, lLogTransporte: TLogLocal; // 4.1 // #774
  lLogErros: TLogErros;
  lTamanhoArquivoString, lTamanhoArquivoCompactadoString: string;
begin
  Result := '';
  lTamanhoArquivoString := '';
  lTamanhoArquivoCompactadoString := '';

  lLogTransporte := TLogLocal.Create(pConexao);
  // lLogTransporte.CarregaLogNaoEnviadosParaServidorPeloId(pId);

  if not(lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.RecordCount > 0) then
  begin
    Result := 'N�o existem logs para serem enviados...';
  end
  else
  begin
    try
      lDiretorioPublicoApp := '';
      lCaminhoCompletoArquivo := '';

      lHoraInicial := Now;
      lContaRegistros := 0;

      lNomeArquivoTxt := 'bkp_log_' + tfuncoes.DecodificarDataHora(Now)
        + '.txt';
      lLogErros := TLogErros.Create(pConexao);
      try
        // FDataModule.AbreQueryConfiguracao;
        // Configuracao.Carregar;
        try
          FBackupTxt := TStringList.Create;
          try
            // cria objetos json dos pedidos
            lJsonArray := TJSONArray.Create;
            lObjetoRaiz := TJSONObject.Create;

            while not lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.Eof do
            begin
              lObjetoJson := TJSONObject.Create;

              if lLogTransporte.EnviadoParaServidor <> 'S' then
              begin
                try
                  // lLogTransporte.Id:=pId; // bitrix #824
                  lLogTransporte.NomeEmpresa :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('NOME_EMPRESA').AsString;
                  lLogTransporte.NomeComputador :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('NOME_COMPUTADOR').AsString;
                  lLogTransporte.DataHora :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('DATA_HORA').AsDateTime;
                  lLogTransporte.EnderecosIp :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('ENDERECOS_IP').AsString;

                  lLogTransporte.Descricao :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('DESCRICAO').AsString;
                  lLogTransporte.NomeArquivo :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('NOME_ARQUIVO').AsString;

                  lLogTransporte.CaminhoArquivoFTP :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('CAMINHO_ARQUIVO_FTP').AsString;

                  // lTamanhoArquivoString := FormatFloat('#,####0.0000',
                  // lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.FieldByName('TAMANHO_ARQUIVO').AsFloat);

                  lTamanhoArquivoString :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('TAMANHO_ARQUIVO').AsString;
                  lLogTransporte.TamanhoArquivo :=
                    StrToFloat(StringReplace(lTamanhoArquivoString, '.', '',
                    [rfReplaceAll]));

                  // lTamanhoArquivoCompactadoString :=
                  // FormatFloat('#,####0.0000', lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.FieldByName
                  // ('TAMANHO_ARQUIVO_COMPACTADO').AsFloat);

                  lTamanhoArquivoCompactadoString :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('TAMANHO_ARQUIVO_COMPACTADO').AsString;
                  lLogTransporte.TamanhoArquivoCompactado :=
                    StrToFloat(StringReplace(lTamanhoArquivoCompactadoString,
                    '.', '', [rfReplaceAll]));

                  lLogTransporte.DataHora :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('DATA_HORA').AsDateTime;
                  lLogTransporte.DataHoraFim :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('DATA_HORA_FIM').AsDateTime;

                  lLogTransporte.Tipo :=
                    lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.
                    FieldByName('TIPO').AsString;

                  lObjetoJson.AddPair(TJSONPair.Create('NOME_EMP',
                    lLogTransporte.NomeEmpresa));
                  lObjetoJson.AddPair(TJSONPair.Create('NOME_PC',
                    lLogTransporte.NomeComputador));
                  lObjetoJson.AddPair(TJSONPair.Create('DATA',
                    FormatDateTime('Y-m-d h:n:s', Now)));
                  lObjetoJson.AddPair(TJSONPair.Create('END_IP',
                    lLogTransporte.EnderecosIp));
                  lObjetoJson.AddPair(TJSONPair.Create('DESCRICAO',
                    lLogTransporte.Descricao));
                  lObjetoJson.AddPair(TJSONPair.Create('NOME_ARQ',
                    lLogTransporte.NomeArquivo));
                  lObjetoJson.AddPair(TJSONPair.Create('CAMINHO',
                    lLogTransporte.CaminhoArquivoFTP));
                  lObjetoJson.AddPair(TJSONPair.Create('TAM_ARQ',
                    TJSONNumber.Create(lLogTransporte.TamanhoArquivo)));
                  lObjetoJson.AddPair(TJSONPair.Create('TAM_ARQ_COMP',
                    TJSONNumber.Create
                    (lLogTransporte.TamanhoArquivoCompactado)));

                  if (lLogTransporte.Tipo = 'L') then
                  begin
                    lObjetoJson.AddPair(TJSONPair.Create('LOCAL_INI',
                      FormatDateTime('Y-m-d h:n:s', lLogTransporte.DataHora)));
                    lObjetoJson.AddPair(TJSONPair.Create('LOCAL_FIM',
                      FormatDateTime('Y-m-d h:n:s',
                      lLogTransporte.DataHoraFim)));
                    lObjetoJson.AddPair(TJSONPair.Create('FTP_INI',
                      FormatDateTime('Y-m-d h:n:s', 0)));
                    lObjetoJson.AddPair(TJSONPair.Create('FTP_FIM',
                      FormatDateTime('Y-m-d h:n:s', 0)));
                  end
                  else
                  begin
                    lObjetoJson.AddPair(TJSONPair.Create('FTP_INI',
                      FormatDateTime('Y-m-d h:n:s', lLogTransporte.DataHora)));
                    lObjetoJson.AddPair(TJSONPair.Create('FTP_FIM',
                      FormatDateTime('Y-m-d h:n:s',
                      lLogTransporte.DataHoraFim)));
                    lObjetoJson.AddPair(TJSONPair.Create('LOCAL_INI',
                      FormatDateTime('Y-m-d h:n:s', 0)));
                    lObjetoJson.AddPair(TJSONPair.Create('LOCAL_FIM',
                      FormatDateTime('Y-m-d h:n:s', 0)));

                  end;

                  lObjetoJson.AddPair(TJSONPair.Create('TIPO',
                    lLogTransporte.Tipo));

                  // {"historico":[{"NOME_EMP":"teste","NOME_PC":"PCNOME","DATA":"2017-06-26 10:00:00" ,"END_IP":"192.168.1.1.",
                  // "DESCRICAO":"teste","NOME_ARQ":"Arquivo teste","CAMINHO":"patas","TAM_ARQ":123,"TAM_ARQ_COMP":125,
                  // "LOCAL_INI":"2017-06-26 10:00:00","LOCAL_FIM":"2017-06-26 10:10:00","FTP_INI":"2017-06-26 10:15:00",
                  // "FTP_FIM":"2017-06-26 10:18:00","TIPO":"F"}]}

                  lJsonArray.AddElement(lObjetoJson);
                except
                  raise;
                end;

              end;

              Inc(lContaRegistros);
              lLogTransporte.ListaDeLogsNaoEnviadosParaServidor.Next;
            end;
            // envia json pedidos

            lObjetoRaiz.AddPair('historico', lJsonArray);
            // ShowMessage(lObjetoRaiz.ToString); // para teste apenas

            FBackupTxt.Text := lObjetoRaiz.ToString;
            lDiretorioPublicoApp := ExtractFilePath(application.exeName)
              + 'Logs\';
            lCaminhoCompletoArquivo := lDiretorioPublicoApp + lNomeArquivoTxt;
            // ShowMessage(lCaminhoDocumentos);

            try
              if not DirectoryExists(lDiretorioPublicoApp) then
              begin
                ForceDirectories(lDiretorioPublicoApp);
              end;

              if DirectoryExists(lDiretorioPublicoApp) then
              begin
                FBackupTxt.SaveToFile(lCaminhoCompletoArquivo);
              end;
            except
              // n�o faz nada em caso de exce��o pois isso � apenas um log para maior seguran�a
            end;

            try
              ConfiguraRestClient(pConfiguracao);
              ConfiguraRestRequest(pConfiguracao, swCadastraLogs);
              ConfiguraRestResponse(pConfiguracao, swCadastraLogs);
              InicializaRestResponseDataSetAdapter;
              FRestRequest.Params.ParameterByName('json').Value :=
                lObjetoRaiz.ToString;
              // FRestRequest.Params.ParameterByName('cod_empresa').Value := pconfiguracao.codigoempresa.ToString;

              ExecutarRequisicao;

              lRetornoDaRequisicaoAposCadastrar :=
                UpperCase(FRestResponse.Content);
            except
              on E: Exception do
              begin
                lRetornoDaRequisicaoAposCadastrar := UpperCase(E.Message);
              end;
            end;
            // ShowMessage(lRetornoDaRequisicaoAposCadastrar);

            if (lRetornoDaRequisicaoAposCadastrar = 'OK') then
            begin
              lLogTransporte.TrocaSituacaoDoLogParaEnviadoParaServidor
                (lLogTransporte.Id);

              Result := 'Foram enviados ' + lContaRegistros.ToString +
                ' logs para a nuvem.' + sLineBreak + 'Hora Inicial: ' +
                DateTimeToStr(lHoraInicial) + sLineBreak + 'Hora Final: ' +
                DateTimeToStr(Now);
            end
            else
            begin
              Result := 'Problemas ao tentar enviar logs para o servidor, por gentileza tente novamente!'
                + sLineBreak + DateTimeToStr(lHoraInicial) + sLineBreak +
                'Hora Final: ' + DateTimeToStr(Now);
            end;

          except
            raise;
          end;

        finally
          FBackupTxt.Free;
        end;
      except
        on E: Exception do
        begin
          lLogErros.ClasseErro := E.ClassName;
          lLogErros.MensagemErro := E.Message;
          // lLogErros.VersaoApp := lLogTransporte.VersaoApp;
          lLogErros.Metodo := 'CadastraLogNoWebService';
          lLogErros.Classe := Self.ClassName;
          lLogErros.GravaLog;
        end;
      end;
    finally
      lLogErros.Free;
      lLogTransporte.Free;
    end;
  end;

end;

procedure TSincronizacaoWebService.ConfiguraRestClient(pConfiguracao
  : TConfiguracao);
begin
  FRestClient.Disconnect; // 4.0
  FRestClient.ResetToDefaults;

  // 4.0
  // FDataModulo.AbreQueryConfiguracao;
  // Configuracao.Carregar;

  FRestClient.Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRestClient.AcceptCharset := 'UTF-8, *;q=0.8';
  FRestClient.AllowCookies := True;
  FRestClient.AutoCreateParams := True;

  FRestClient.BaseURL := pConfiguracao.HostWebService;
  // 'http://webmc.com.br/ws/mcbkp'; // buscar da configura��o

  FRestClient.ContentType := 'application/x-www-form-urlencoded';
  FRestClient.FallbackCharsetEncoding := 'UTF-8';
  FRestClient.HandleRedirects := True;
  FRestClient.RaiseExceptionOn500 := True;
  FRestClient.SynchronizedEvents := True;
  FRestClient.Tag := 0;
  FRestClient.UserAgent := 'Embarcadero RESTClient/1.0';
end;

procedure TSincronizacaoWebService.ConfiguraRestRequest(pConfiguracao
  : TConfiguracao; pTipoServicoWS: TServicoWebService);
var
  lSenhaCriptografada: string;
begin
  FRestRequest.ResetToDefaults;
  FRestRequest.Client := FRestClient;
  FRestRequest.Response := FRestResponse;

  // FDataModulo.AbreQueryConfiguracao;
  // Configuracao.Carregar;

  {
    Enviar dados via post usando as seguintes Keys:
    -usu�rio
    -senha
    -cod_empresa
    -fun��o
    -sistema
    -Cod_emp_cons
    -Ch_registro
    -Cnpj
    -Json

  }

  lSenhaCriptografada := pConfiguracao.SenhaWebService;
  // tfuncoes.CriptografarDados('123456');

  FRestRequest.AddParameter('usuario', pConfiguracao.UsuarioWebService);
  // mcdev
  FRestRequest.AddParameter('senha', lSenhaCriptografada);
  FRestRequest.AddParameter('cod_empresa',
    pConfiguracao.CodigoEmpresaLoginWebService.ToString);

  case pTipoServicoWS of
    swConsultaAtualizacoes:
      begin
        FRestRequest.AddParameter('funcao', 'consulta_atualizacao');
        FRestRequest.AddParameter('sistema', pConfiguracao.Sistema.ToString);
        FRestRequest.AddParameter('ultima', 'S');
      end;
    swConsultaEmpresas:
      begin
        FRestRequest.AddParameter('funcao', 'consulta_empresas');
      end;
    swUltimaAtualizacao:
      begin
        FRestRequest.AddParameter('funcao', 'consulta_ultima_atualizacao');
        FRestRequest.AddParameter('sistema', pConfiguracao.Sistema.ToString);
      end;
    swCadastraLogAtualizacao:
      begin
        FRestRequest.AddParameter('funcao', 'cadastra_log_atualizacao');
        // FRestRequest.AddParameter('sistema', pConfiguracao.Sistema.ToString);
      end;
    swCadastraLogLogin:
      begin
        FRestRequest.AddParameter('funcao', 'cadastra_log_login');
        // FRestRequest.AddParameter('sistema', pConfiguracao.Sistema.ToString);
      end;
    swCadastraAtualizacao:
      begin
        FRestRequest.AddParameter('funcao', 'cadastra_atualizacao');
        // FRestRequest.AddParameter('sistema', pConfiguracao.Sistema.ToString);
      end;

  end;

  FRestRequest.AddParameter('cod_emp_cons', '');
  FRestRequest.AddParameter('ch_registro', '');
  FRestRequest.AddParameter('cnpj', '');
  FRestRequest.AddParameter('json', '');

  FRestRequest.Method := rmPOST;
end;

procedure TSincronizacaoWebService.ConfiguraRestResponse(pConfiguracao
  : TConfiguracao; pTipoServicoWS: TServicoWebService);
begin
  FRestResponse.ResetToDefaults;
  FRestResponse.ContentType := 'text/html';
  FRestResponse.RootElement := '';
end;

function TSincronizacaoWebService.CadastraLogAtualizacaoNoWebService
  (pLogAtualizacao: TLogAtualizacao; pConfiguracao: TConfiguracao): boolean;
var
  lHoraInicial: TDateTime;
  lObjetoJson, lObjetoRaiz: TJSONObject;
  lJsonArray: TJSONArray;
  lContaRegistros: Integer;
  lRetornoDaRequisicaoAposCadastrar, lDiretorioPublicoApp, lNomeArquivoTxt,
    lCaminhoCompletoArquivo: string;
  FBackupTxt: TStringList;

begin
  // -cadastra_atualizacao:Fun��o para cadastrar atualiza��es, usando as seguintes keys : fun��o:cadastra_atualizacao, Json: (ENVIAR DADOS)

  // Exemplo de Json:

  Result := False;

  try
    lDiretorioPublicoApp := '';
    lCaminhoCompletoArquivo := '';

    lHoraInicial := Now;
    lContaRegistros := 0;

    lNomeArquivoTxt := 'bkp_log_erros_' + tfuncoes.DecodificarDataHora
      (Now) + '.txt';

    FBackupTxt := TStringList.Create;
    try
      // cria objetos json dos pedidos
      lJsonArray := TJSONArray.Create;
      lObjetoRaiz := TJSONObject.Create;
      lObjetoJson := TJSONObject.Create;
      try
        {
          $cod_empresa= $e->COD_EMPRESA;
          $data_hora= $e->DATA_HORA;
          $versao= $e->NUMERO_VERSAO;
          $versao= $e->VERSAO;
          $nome_computador= $e->NOME_COMPUTADOR;
          $enderecos_ip= $e->ENDERECOS_IP;
          $processador_computador= $e->PROCESSADOR_COMPUTADOR;
          $sistema_operacional= $e->SISTEMA_OPERACIONAL;
          $codigo_app= $e->CODIGO_APP;
        }

        // lObjetoJson.AddPair(TJSONPair.Create('COD_EMPRESA', TJSONNumber.Create(pLogAtualizacao.CodigoEmpresa)));
        lObjetoJson.AddPair(TJSONPair.Create('CH_REG',
          pLogAtualizacao.ChaveRegistro));
        lObjetoJson.AddPair(TJSONPair.Create('DATA_HORA',
          FormatDateTime('Y-m-d h:n:s', pLogAtualizacao.DataHora)));
        lObjetoJson.AddPair(TJSONPair.Create('VERSAO',
          TJSONNumber.Create(pLogAtualizacao.NumeroVersao)));
        lObjetoJson.AddPair(TJSONPair.Create('NOME_COMPUTADOR',
          pLogAtualizacao.NomeComputador));
        lObjetoJson.AddPair(TJSONPair.Create('ENDERECOS_IP',
          pLogAtualizacao.EnderecosIpComputador));
        lObjetoJson.AddPair(TJSONPair.Create('PROCESSADOR_COMPUTADOR',
          pLogAtualizacao.ProcessadorComputador));
        lObjetoJson.AddPair(TJSONPair.Create('SISTEMA_OPERACIONAL',
          pLogAtualizacao.InformacoesWindows));
        lObjetoJson.AddPair(TJSONPair.Create('CODIGO_APP',
          TJSONNumber.Create(pLogAtualizacao.CodigoSistema)));

        lJsonArray.AddElement(lObjetoJson);
      except
        raise;
      end;

      Inc(lContaRegistros);
      lObjetoRaiz.AddPair('log_atualizacao', lJsonArray);
      // ShowMessage(lObjetoRaiz.ToString); // para teste apenas

      // FBackupTxt.Text := lObjetoRaiz.ToString;
      // lDiretorioPublicoApp := ExtractFilePath(application.exeName) + 'Log_Erros\';
      // lCaminhoCompletoArquivo := lDiretorioPublicoApp + lNomeArquivoTxt;
      // ShowMessage(lCaminhoDocumentos);

      // try
      // if not DirectoryExists(lDiretorioPublicoApp) then
      // begin
      // ForceDirectories(lDiretorioPublicoApp);
      // end;
      //
      // if DirectoryExists(lDiretorioPublicoApp) then
      // begin
      // FBackupTxt.SaveToFile(lCaminhoCompletoArquivo);
      // end;
      // except
      // // n�o faz nada em caso de exce��o pois isso � apenas um log para maior seguran�a
      // end;

      try
        ConfiguraRestClient(pConfiguracao);
        ConfiguraRestRequest(pConfiguracao, swCadastraLogAtualizacao);
        ConfiguraRestResponse(pConfiguracao, swCadastraLogAtualizacao);
        InicializaRestResponseDataSetAdapter;

        // FRestRequest.Params.ParameterByName('cod_emp_cons').Value := pConfiguracao.CodigoEmpresaLoginWebService.ToString;
        FRestRequest.Params.ParameterByName('json').Value :=
          lObjetoRaiz.ToString;

        FRestRequest.Execute;

        lRetornoDaRequisicaoAposCadastrar := UpperCase(FRestResponse.Content);
      except
        on E: Exception do
        begin
          lRetornoDaRequisicaoAposCadastrar := UpperCase(E.Message);
        end;
      end;
      // ShowMessage(lRetornoDaRequisicaoAposCadastrar);

      // if (lRetornoDaRequisicaoAposCadastrar = 'OK') then
      // begin
      // lLogErrosTransporte.TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;
      //
      // Result := 'Foram enviados ' + lContaRegistros.ToString + ' logs de erros para a nuvem.' + sLineBreak + 'Hora Inicial: ' +
      // DateTimeToStr(lHoraInicial) + sLineBreak + 'Hora Final: ' + DateTimeToStr(Now);
      // end
      // else
      // begin
      // Result := 'Problemas ao tentar enviar logs de erros para o servidor, por gentileza tente novamente!' + sLineBreak + DateTimeToStr(lHoraInicial) +
      // sLineBreak + 'Hora Final: ' + DateTimeToStr(Now);
      // end;

    except
      raise;
    end;

  finally
    FBackupTxt.Free;
  end;

end;

function TSincronizacaoWebService.ConsultaEmpresasNoWebService
  (pConfiguracao: TConfiguracao): boolean;
begin
  // exemplo json retorno
  // {"empresa":[{"nom":"MC SISTEMAS","cnpj":"","fan":"MC SISTEMAS","ati":"S","bkon":"S","chreg":"024721052001171516","plano":"1"}]}]}

  Result := False;

  ConfiguraRestClient(pConfiguracao);
  ConfiguraRestRequest(pConfiguracao, swConsultaEmpresas);
  ConfiguraRestResponse(pConfiguracao, swConsultaEmpresas);
  InicializaRestResponseDataSetAdapter;

  case pConfiguracao.Empresa.TipoConsulta of
    ceCodigoEmpresa:
      begin
        FRestRequest.Params.ParameterByName('cod_emp_cons').Value :=
          pConfiguracao.Empresa.CodigoEmpresa.ToString;
      end;
    ceChaveRegistro:
      begin
        FRestRequest.Params.ParameterByName('ch_registro').Value :=
          pConfiguracao.Empresa.ChaveRegistro;
      end;
    ceCnpj:
      begin
        FRestRequest.Params.ParameterByName('cnpj').Value :=
          pConfiguracao.Empresa.Cpf_Cnpj;
      end;
  end;

  ExecutaConsultaNoWebService(pConfiguracao, swConsultaEmpresas);

  FMemTable.Open;

  if FMemTable.RecordCount > 0 then
  begin
    Result := True;

    // pConfiguracao.Empresa.CodigoEmpresa:=  FMemTable.FieldByName('').AsInteger;
    pConfiguracao.Empresa.Nome := FMemTable.FieldByName('nom').AsString;
    pConfiguracao.Empresa.Cpf_Cnpj := FMemTable.FieldByName('cnpj').AsString;
    pConfiguracao.Empresa.Fantasia := FMemTable.FieldByName('fan').AsString;
    pConfiguracao.Empresa.Ativo := FMemTable.FieldByName('ati').AsString = 'S';
    pConfiguracao.Empresa.BackupOnline := FMemTable.FieldByName('bkon')
      .AsString = 'S';
    pConfiguracao.Empresa.AtualizacaoAutomatica :=
      FMemTable.FieldByName('atu_aut').AsString = 'S';
    pConfiguracao.Empresa.ChaveRegistro :=
      FMemTable.FieldByName('chreg').AsString;
  end;
end;

procedure TSincronizacaoWebService.ConsultaNoWebService(pConfiguracao
  : TConfiguracao; pTipoServicoWS: TServicoWebService);
var
  lRootElement: string;
begin
  ConfiguraRestResponse(pConfiguracao, pTipoServicoWS);
  ExecutarRequisicao;
  case pTipoServicoWS of
    swConsultaAtualizacoes:
      begin
        lRootElement := 'atualizacao';
      end;
    swConsultaEmpresas:
      begin
        lRootElement := 'empresa';
      end;
    swUltimaAtualizacao:
      begin
        lRootElement := 'atualizacao';
      end;
  end;

  FRestResponseDataSetAdapter.ResponseJSON := FRestResponse;
  FRestResponseDataSetAdapter.RootElement := lRootElement;
  FRestResponseDataSetAdapter.DataSet := FMemTable;
  FRestResponseDataSetAdapter.Active := True;

end;

function TSincronizacaoWebService.UltimaVersaoDoSistemaNoWebService
  (pConfiguracao: TConfiguracao): Integer;
begin
  // exemplo json retorno
  // {"atualizacao":[{"versao":"171001","sistema":"3","descricao":"teste de ins"},{"versao":"171001","sistema":"1","descricao":"teste de ins"}]}

  Result := 0;

  ConfiguraRestClient(pConfiguracao);
  ConfiguraRestRequest(pConfiguracao, swUltimaAtualizacao);
  ConfiguraRestResponse(pConfiguracao, swUltimaAtualizacao);
  InicializaRestResponseDataSetAdapter;

  FRestRequest.Params.ParameterByName('cod_emp_cons').Value :=
    pConfiguracao.CodigoEmpresaLoginWebService.ToString;

  ExecutaConsultaNoWebService(pConfiguracao, swUltimaAtualizacao);

  FMemTable.Open;

  if (FMemTable.RecordCount > 0) then
  begin
    Result := StrToIntDef(FMemTable.FieldByName('versao').AsString, 0);
  end;
end;

constructor TSincronizacaoWebService.Create;
begin
  FMemTable := TFDMemTable.Create(nil);
  FRestClient := TRESTClient.Create('');
  FRestRequest := TRESTRequest.Create(nil);
  FRestResponse := TRESTResponse.Create(nil);
  FRestResponseDataSetAdapter := TRESTResponseDataSetAdapter.Create(nil);
end;

destructor TSincronizacaoWebService.Destroy;
begin
  FMemTable.Free;
  FRestClient.Free;
  FRestRequest.Free;
  FRestResponse.Free;
  FRestResponseDataSetAdapter.Free;

  inherited;
end;

function TSincronizacaoWebService.CadastraAtualizacaoNoWebService
  (pAtualizacao: TAtualizacao; pConfiguracao: TConfiguracao): boolean;
var
  lHoraInicial: TDateTime;
  lObjetoJson, lObjetoRaiz: TJSONObject;
  lJsonArray: TJSONArray;
  lContaRegistros: Integer;
  lRetornoDaRequisicaoAposCadastrar, lDiretorioPublicoApp, lNomeArquivoTxt,
    lCaminhoCompletoArquivo: string;
  FBackupTxt: TStringList;
begin
  Result := False;

  try
    lDiretorioPublicoApp := '';
    lCaminhoCompletoArquivo := '';

    lHoraInicial := Now;
    lContaRegistros := 0;

    lNomeArquivoTxt := 'bkp_log_erros_' + tfuncoes.DecodificarDataHora
      (Now) + '.txt';

    FBackupTxt := TStringList.Create;
    try
      // cria objetos json dos pedidos
      lJsonArray := TJSONArray.Create;
      lObjetoRaiz := TJSONObject.Create;
      lObjetoJson := TJSONObject.Create;
      try
        lObjetoJson.AddPair(TJSONPair.Create('VER', pAtualizacao.Versao));
        lObjetoJson.AddPair(TJSONPair.Create('SIS',
          TJSONNumber.Create(pAtualizacao.Sistema)));
        lObjetoJson.AddPair(TJSONPair.Create('DESC', pAtualizacao.Descricao));
        lObjetoJson.AddPair(TJSONPair.Create('COD_EMP',
          TJSONNumber.Create(pAtualizacao.CodigoEmpresa)));

        lJsonArray.AddElement(lObjetoJson);
      except
        raise;
      end;

      Inc(lContaRegistros);
      lObjetoRaiz.AddPair('atualizacao', lJsonArray);
      // ShowMessage(lObjetoRaiz.ToString); // para teste apenas

      try
        ConfiguraRestClient(pConfiguracao);
        ConfiguraRestRequest(pConfiguracao, swCadastraAtualizacao);
        ConfiguraRestResponse(pConfiguracao, swCadastraAtualizacao);
        InicializaRestResponseDataSetAdapter;

        // FRestRequest.Params.ParameterByName('cod_emp_cons').Value := pConfiguracao.CodigoEmpresaLoginWebService.ToString;
        FRestRequest.Params.ParameterByName('json').Value :=
          lObjetoRaiz.ToString;

        FRestRequest.Execute;

        lRetornoDaRequisicaoAposCadastrar := UpperCase(FRestResponse.Content);
      except
        on E: Exception do
        begin
          lRetornoDaRequisicaoAposCadastrar := UpperCase(E.Message);
        end;
      end;

    except
      raise;
    end;

  finally
    FBackupTxt.Free;
  end;

end;

function TSincronizacaoWebService.CadastraListaDeLogDeErroNoWebService
  (pConfiguracao: TConfiguracao; pConexao: TFDConnection): string;
var
  lHoraInicial: TDateTime;
  lObjetoJson, lObjetoRaiz: TJSONObject;
  lJsonArray: TJSONArray;
  lContaRegistros: Integer;
  lRetornoDaRequisicaoAposCadastrar, lDiretorioPublicoApp, lNomeArquivoTxt,
    lCaminhoCompletoArquivo: string;
  FBackupTxt: TStringList;
  lLogErrosTransporte: TLogErros; // 4.1 // #774
  lLogErros: TLogErros;
  lTamanhoArquivoString, lTamanhoArquivoCompactadoString: string;
begin
  Result := '';
  lTamanhoArquivoString := '';
  lTamanhoArquivoCompactadoString := '';

  lLogErrosTransporte := TLogErros.Create(pConexao);
  lLogErrosTransporte.CarregaListaDeLogDeErrosNaoEnviadosParaServidor;

  if not(lLogErrosTransporte.ListaDeLogsDeErroNaoEnviadosParaServidor.
    RecordCount > 0) then
  begin
    Result := 'N�o existem logs de erros para serem enviados...';
  end
  else
  begin
    try
      lDiretorioPublicoApp := '';
      lCaminhoCompletoArquivo := '';

      lHoraInicial := Now;
      lContaRegistros := 0;

      lNomeArquivoTxt := 'bkp_log_erros_' + tfuncoes.DecodificarDataHora
        (Now) + '.txt';
      lLogErros := TLogErros.Create(pConexao);
      try
        // FDataModule.AbreQueryConfiguracao;
        // Configuracao.Carregar;
        try
          FBackupTxt := TStringList.Create;
          try
            // cria objetos json dos pedidos
            lJsonArray := TJSONArray.Create;
            lObjetoRaiz := TJSONObject.Create;

            while not lLogErrosTransporte.
              ListaDeLogsDeErroNaoEnviadosParaServidor.Eof do
            begin
              lObjetoJson := TJSONObject.Create;

              if lLogErrosTransporte.EnviadoParaServidor <> 'S' then
              begin
                try
                  lLogErrosTransporte.Id :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('ID_LOG_ERROS').AsInteger;
                  lLogErrosTransporte.DataHora :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('DATA_HORA').AsDateTime;
                  lLogErrosTransporte.MensagemErro :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('MENSAGEM_ERRO').AsString;
                  lLogErrosTransporte.Classe :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('CLASSE').AsString;

                  lLogErrosTransporte.ClasseErro :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('CLASSE_ERRO').AsString;
                  lLogErrosTransporte.VersaoApp :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('VERSAO_APP').AsString;

                  lLogErrosTransporte.Metodo :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('METODO').AsString;

                  lObjetoJson.AddPair(TJSONPair.Create('ID',
                    TJSONNumber.Create(lLogErrosTransporte.Id)));
                  lObjetoJson.AddPair(TJSONPair.Create('DT',
                    FormatDateTime('Y-m-d h:n:s',
                    lLogErrosTransporte.DataHora)));
                  lObjetoJson.AddPair(TJSONPair.Create('MSG',
                    lLogErrosTransporte.MensagemErro));
                  lObjetoJson.AddPair(TJSONPair.Create('CLASSE',
                    lLogErrosTransporte.Classe));
                  lObjetoJson.AddPair(TJSONPair.Create('CLASSE_ERRO',
                    lLogErrosTransporte.ClasseErro));
                  lObjetoJson.AddPair(TJSONPair.Create('VERSAO',
                    lLogErrosTransporte.VersaoApp));
                  lObjetoJson.AddPair(TJSONPair.Create('METODO',
                    lLogErrosTransporte.Metodo));

                  lJsonArray.AddElement(lObjetoJson);
                except
                  raise;
                end;

              end;

              Inc(lContaRegistros);
              lLogErrosTransporte.ListaDeLogsDeErroNaoEnviadosParaServidor.Next;
            end;
            // envia json pedidos

            lObjetoRaiz.AddPair('logerros', lJsonArray);
            // ShowMessage(lObjetoRaiz.ToString); // para teste apenas

            FBackupTxt.Text := lObjetoRaiz.ToString;
            lDiretorioPublicoApp := ExtractFilePath(application.exeName) +
              'Log_Erros\';
            lCaminhoCompletoArquivo := lDiretorioPublicoApp + lNomeArquivoTxt;
            // ShowMessage(lCaminhoDocumentos);

            try
              if not DirectoryExists(lDiretorioPublicoApp) then
              begin
                ForceDirectories(lDiretorioPublicoApp);
              end;

              if DirectoryExists(lDiretorioPublicoApp) then
              begin
                FBackupTxt.SaveToFile(lCaminhoCompletoArquivo);
              end;
            except
              // n�o faz nada em caso de exce��o pois isso � apenas um log para maior seguran�a
            end;

            try
              ConfiguraRestClient(pConfiguracao);
              ConfiguraRestRequest(pConfiguracao, swCadastraLogErros);
              ConfiguraRestResponse(pConfiguracao, swCadastraLogErros);
              InicializaRestResponseDataSetAdapter;
              FRestRequest.Params.ParameterByName('json').Value :=
                lObjetoRaiz.ToString;
              // FRestRequest.Params.ParameterByName('cod_empresa').Value := pCodigoEmpresa.ToString;

              FRestRequest.Execute;

              lRetornoDaRequisicaoAposCadastrar :=
                UpperCase(FRestResponse.Content);
            except
              on E: Exception do
              begin
                lRetornoDaRequisicaoAposCadastrar := UpperCase(E.Message);
              end;
            end;
            // ShowMessage(lRetornoDaRequisicaoAposCadastrar);

            if (lRetornoDaRequisicaoAposCadastrar = 'OK') then
            begin
              lLogErrosTransporte.
                TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;

              Result := 'Foram enviados ' + lContaRegistros.ToString +
                ' logs de erros para a nuvem.' + sLineBreak + 'Hora Inicial: ' +
                DateTimeToStr(lHoraInicial) + sLineBreak + 'Hora Final: ' +
                DateTimeToStr(Now);
            end
            else
            begin
              Result := 'Problemas ao tentar enviar logs de erros para o servidor, por gentileza tente novamente!'
                + sLineBreak + DateTimeToStr(lHoraInicial) + sLineBreak +
                'Hora Final: ' + DateTimeToStr(Now);
            end;

          except
            raise;
          end;

        finally
          FBackupTxt.Free;
        end;
      except
        on E: Exception do
        begin
          lLogErros.ClasseErro := E.ClassName;
          lLogErros.MensagemErro := E.Message;
          // lLogErros.VersaoApp := FDataModule.VersaoApp;
          lLogErros.Metodo := 'CadastraListaDeLogDeErroNoWebService';
          lLogErros.Classe := Self.ClassName;
          lLogErros.GravaLog;
        end;
      end;
    finally
      lLogErros.Free;
      lLogErrosTransporte.Free;
    end;
  end;

end;

function TSincronizacaoWebService.CadastraLogDeErroNoWebService
  (pConfiguracao: TConfiguracao; pId: Integer; pConexao: TFDConnection): string;
var
  lHoraInicial: TDateTime;
  lObjetoJson, lObjetoRaiz: TJSONObject;
  lJsonArray: TJSONArray;
  lContaRegistros: Integer;
  lRetornoDaRequisicaoAposCadastrar, lDiretorioPublicoApp, lNomeArquivoTxt,
    lCaminhoCompletoArquivo: string;
  FBackupTxt: TStringList;
  lLogErrosTransporte: TLogErros; // 4.1 // #774
  lLogErros: TLogErros;
  lTamanhoArquivoString, lTamanhoArquivoCompactadoString: string;
begin
  Result := '';
  lTamanhoArquivoString := '';
  lTamanhoArquivoCompactadoString := '';

  lLogErrosTransporte := TLogErros.Create(pConexao);
  lLogErrosTransporte.CarregaLogDeErrosNaoEnviadosParaServidorPeloId(pId);

  if not(lLogErrosTransporte.ListaDeLogsDeErroNaoEnviadosParaServidor.
    RecordCount > 0) then
  begin
    Result := 'N�o existem logs de erros para serem enviados...';
  end
  else
  begin
    try
      lDiretorioPublicoApp := '';
      lCaminhoCompletoArquivo := '';

      lHoraInicial := Now;
      lContaRegistros := 0;

      lNomeArquivoTxt := 'bkp_log_erros_' + tfuncoes.DecodificarDataHora
        (Now) + '.txt';
      lLogErros := TLogErros.Create(pConexao);
      try
        // FDataModule.AbreQueryConfiguracao;
        // Configuracao.Carregar;
        try
          FBackupTxt := TStringList.Create;
          try
            // cria objetos json dos pedidos
            lJsonArray := TJSONArray.Create;
            lObjetoRaiz := TJSONObject.Create;

            while not lLogErrosTransporte.
              ListaDeLogsDeErroNaoEnviadosParaServidor.Eof do
            begin
              lObjetoJson := TJSONObject.Create;

              if lLogErrosTransporte.EnviadoParaServidor <> 'S' then
              begin
                try
                  lLogErrosTransporte.Id :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('ID_LOG_ERROS').AsInteger;
                  lLogErrosTransporte.DataHora :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('DATA_HORA').AsDateTime;
                  lLogErrosTransporte.MensagemErro :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('MENSAGEM_ERRO').AsString;
                  lLogErrosTransporte.Classe :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('CLASSE').AsString;

                  lLogErrosTransporte.ClasseErro :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('CLASSE_ERRO').AsString;
                  lLogErrosTransporte.VersaoApp :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('VERSAO_APP').AsString;

                  lLogErrosTransporte.Metodo :=
                    lLogErrosTransporte.
                    ListaDeLogsDeErroNaoEnviadosParaServidor.FieldByName
                    ('METODO').AsString;

                  lObjetoJson.AddPair(TJSONPair.Create('ID',
                    TJSONNumber.Create(lLogErrosTransporte.Id)));
                  lObjetoJson.AddPair(TJSONPair.Create('DT',
                    FormatDateTime('Y-m-d h:n:s',
                    lLogErrosTransporte.DataHora)));
                  lObjetoJson.AddPair(TJSONPair.Create('MSG',
                    lLogErrosTransporte.MensagemErro));
                  lObjetoJson.AddPair(TJSONPair.Create('CLASSE',
                    lLogErrosTransporte.Classe));
                  lObjetoJson.AddPair(TJSONPair.Create('CLASSE_ERRO',
                    lLogErrosTransporte.ClasseErro));
                  lObjetoJson.AddPair(TJSONPair.Create('VERSAO',
                    lLogErrosTransporte.VersaoApp));
                  lObjetoJson.AddPair(TJSONPair.Create('METODO',
                    lLogErrosTransporte.Metodo));

                  lJsonArray.AddElement(lObjetoJson);
                except
                  raise;
                end;

              end;

              Inc(lContaRegistros);
              lLogErrosTransporte.ListaDeLogsDeErroNaoEnviadosParaServidor.Next;
            end;
            // envia json pedidos

            lObjetoRaiz.AddPair('logerros', lJsonArray);
            // ShowMessage(lObjetoRaiz.ToString); // para teste apenas

            FBackupTxt.Text := lObjetoRaiz.ToString;
            lDiretorioPublicoApp := ExtractFilePath(application.exeName) +
              'Log_Erros\';
            lCaminhoCompletoArquivo := lDiretorioPublicoApp + lNomeArquivoTxt;
            // ShowMessage(lCaminhoDocumentos);

            try
              if not DirectoryExists(lDiretorioPublicoApp) then
              begin
                ForceDirectories(lDiretorioPublicoApp);
              end;

              if DirectoryExists(lDiretorioPublicoApp) then
              begin
                FBackupTxt.SaveToFile(lCaminhoCompletoArquivo);
              end;
            except
              // n�o faz nada em caso de exce��o pois isso � apenas um log para maior seguran�a
            end;

            try
              ConfiguraRestClient(pConfiguracao);
              ConfiguraRestRequest(pConfiguracao, swCadastraLogs);
              ConfiguraRestResponse(pConfiguracao, swCadastraLogs);
              InicializaRestResponseDataSetAdapter;
              FRestRequest.Params.ParameterByName('json').Value :=
                lObjetoRaiz.ToString;
              // FRestRequest.Params.ParameterByName('cod_empresa').Value := pCodigoEmpresa.ToString;

              FRestRequest.Execute;

              lRetornoDaRequisicaoAposCadastrar :=
                UpperCase(FRestResponse.Content);
            except
              on E: Exception do
              begin
                lRetornoDaRequisicaoAposCadastrar := UpperCase(E.Message);
              end;
            end;
            // ShowMessage(lRetornoDaRequisicaoAposCadastrar);

            if (lRetornoDaRequisicaoAposCadastrar = 'OK') then
            begin
              lLogErrosTransporte.TrocaSituacaoDoLogParaEnviadoParaServidor
                (lLogErrosTransporte.Id);

              Result := 'Foram enviados ' + lContaRegistros.ToString +
                ' logs para a nuvem.' + sLineBreak + 'Hora Inicial: ' +
                DateTimeToStr(lHoraInicial) + sLineBreak + 'Hora Final: ' +
                DateTimeToStr(Now);
            end
            else
            begin
              Result := 'Problemas ao tentar enviar logs para o servidor, por gentileza tente novamente!'
                + sLineBreak + DateTimeToStr(lHoraInicial) + sLineBreak +
                'Hora Final: ' + DateTimeToStr(Now);
            end;

          except
            raise;
          end;

        finally
          FBackupTxt.Free;
        end;
      except
        on E: Exception do
        begin
          lLogErros.ClasseErro := E.ClassName;
          lLogErros.MensagemErro := E.Message;
          // lLogErros.VersaoApp := FDataModule.VersaoApp;
          lLogErros.Metodo := 'CadastraLogDeErroNoWebService';
          lLogErros.Classe := Self.ClassName;
          lLogErros.GravaLog;
        end;
      end;
    finally
      lLogErros.Free;
      lLogErrosTransporte.Free;
    end;
  end;

end;

function TSincronizacaoWebService.CadastraLogLoginNoWebService
  (pLogLoginNuvem: TLogLoginNuvem; pConfiguracao: TConfiguracao): boolean;
var
  lHoraInicial: TDateTime;
  lObjetoJson, lObjetoRaiz: TJSONObject;
  lJsonArray: TJSONArray;
  lContaRegistros: Integer;
  lRetornoDaRequisicaoAposCadastrar, lDiretorioPublicoApp, lNomeArquivoTxt,
    lCaminhoCompletoArquivo: string;
  FBackupTxt: TStringList;

begin
  Result := False;

  try
    lDiretorioPublicoApp := '';
    lCaminhoCompletoArquivo := '';

    lHoraInicial := Now;
    lContaRegistros := 0;

    lNomeArquivoTxt := 'bkp_log_erros_' + tfuncoes.DecodificarDataHora
      (Now) + '.txt';

    FBackupTxt := TStringList.Create;
    try
      // cria objetos json dos pedidos
      lJsonArray := TJSONArray.Create;
      lObjetoRaiz := TJSONObject.Create;
      lObjetoJson := TJSONObject.Create;
      try
        // lObjetoJson.AddPair(TJSONPair.Create('COD_EMPRESA', TJSONNumber.Create(pLogLoginNuvem.CodigoEmpresa)));
        lObjetoJson.AddPair(TJSONPair.Create('CH_REG',
          pLogLoginNuvem.ChaveRegistro));
        lObjetoJson.AddPair(TJSONPair.Create('DATA_HORA',
          FormatDateTime('Y-m-d h:n:s', pLogLoginNuvem.DataHora)));
        lObjetoJson.AddPair(TJSONPair.Create('VERSAO',
          TJSONNumber.Create(pLogLoginNuvem.NumeroVersao)));
        lObjetoJson.AddPair(TJSONPair.Create('NOME_COMPUTADOR',
          pLogLoginNuvem.NomeComputador));
        lObjetoJson.AddPair(TJSONPair.Create('CODIGO_APP',
          TJSONNumber.Create(pLogLoginNuvem.CodigoSistema)));
        lObjetoJson.AddPair(TJSONPair.Create('CODIGO_USUARIO',
          TJSONNumber.Create(pLogLoginNuvem.CodigoUsuario)));
        lObjetoJson.AddPair(TJSONPair.Create('MCNOMEREL',
          pLogLoginNuvem.NomeRel)); // 17.11.01

        lJsonArray.AddElement(lObjetoJson);
      except
        raise;
      end;

      Inc(lContaRegistros);
      lObjetoRaiz.AddPair('log_login', lJsonArray);
      // ShowMessage(lObjetoRaiz.ToString); // para teste apenas

      // FBackupTxt.Text := lObjetoRaiz.ToString;
      // lDiretorioPublicoApp := ExtractFilePath(application.exeName) + 'Log_Erros\';
      // lCaminhoCompletoArquivo := lDiretorioPublicoApp + lNomeArquivoTxt;
      // ShowMessage(lCaminhoDocumentos);

      // try
      // if not DirectoryExists(lDiretorioPublicoApp) then
      // begin
      // ForceDirectories(lDiretorioPublicoApp);
      // end;
      //
      // if DirectoryExists(lDiretorioPublicoApp) then
      // begin
      // FBackupTxt.SaveToFile(lCaminhoCompletoArquivo);
      // end;
      // except
      // // n�o faz nada em caso de exce��o pois isso � apenas um log para maior seguran�a
      // end;

      try
        ConfiguraRestClient(pConfiguracao);
        ConfiguraRestRequest(pConfiguracao, swCadastraLogLogin);
        ConfiguraRestResponse(pConfiguracao, swCadastraLogLogin);
        InicializaRestResponseDataSetAdapter;

        // FRestRequest.Params.ParameterByName('cod_emp_cons').Value := pConfiguracao.CodigoEmpresaLoginWebService.ToString;
        FRestRequest.Params.ParameterByName('json').Value :=
          lObjetoRaiz.ToString;

        FRestRequest.Execute;

        lRetornoDaRequisicaoAposCadastrar := UpperCase(FRestResponse.Content);
      except
        on E: Exception do
        begin
          lRetornoDaRequisicaoAposCadastrar := UpperCase(E.Message);
        end;
      end;

      FRestClient.Disconnect;


      // ShowMessage(lRetornoDaRequisicaoAposCadastrar);

      // if (lRetornoDaRequisicaoAposCadastrar = 'OK') then
      // begin
      // lLogErrosTransporte.TrocaSituacaoDeTodosNaoEnviadosParaEnviadosParaServidor;
      //
      // Result := 'Foram enviados ' + lContaRegistros.ToString + ' logs de erros para a nuvem.' + sLineBreak + 'Hora Inicial: ' +
      // DateTimeToStr(lHoraInicial) + sLineBreak + 'Hora Final: ' + DateTimeToStr(Now);
      // end
      // else
      // begin
      // Result := 'Problemas ao tentar enviar logs de erros para o servidor, por gentileza tente novamente!' + sLineBreak + DateTimeToStr(lHoraInicial) +
      // sLineBreak + 'Hora Final: ' + DateTimeToStr(Now);
      // end;

    except
      raise;
    end;

  finally
    FBackupTxt.Free;
  end;

end;

class function TSincronizacaoWebService.ExecutaCadastraAtualizacaoNoWebService
  (pAtualizacao: TAtualizacao; pConfiguracao: TConfiguracao): boolean;
var
  lObjeto: TSincronizacaoWebService;
begin
  lObjeto := TSincronizacaoWebService.Create;
  try
    Result := lObjeto.CadastraAtualizacaoNoWebService(pAtualizacao,
      pConfiguracao);
  finally
    lObjeto.Free;
  end;
end;

class function TSincronizacaoWebService.
  ExecutaCadastraListaDeLogErrosNoWebService(pConfiguracao: TConfiguracao;
  pConexao: TFDConnection): string;
var
  lObjeto: TSincronizacaoWebService;
begin
  // pCodigoEmpresa = c�digo da empresa na configura��o geral do aplicativo
  // pConexao = TFDConnection, conex�o com o banco local do aplicativo
  lObjeto := TSincronizacaoWebService.Create;
  try
    Result := lObjeto.CadastraListaDeLogDeErroNoWebService(pConfiguracao,
      pConexao);
  finally
    lObjeto.Free;
  end;
end;

class function TSincronizacaoWebService.
  ExecutaCadastraLogAtualizacaoNoWebService(pLogAtualizacao: TLogAtualizacao;
  pConfiguracao: TConfiguracao): boolean;
var
  lObjeto: TSincronizacaoWebService;
begin
  lObjeto := TSincronizacaoWebService.Create;
  try
    Result := lObjeto.CadastraLogAtualizacaoNoWebService(pLogAtualizacao,
      pConfiguracao);
  finally
    lObjeto.Free;
  end;
end;

class procedure TSincronizacaoWebService.ExecutaCadastraLogErroNoWebService
  (pConfiguracao: TConfiguracao; pId: Integer; pConexao: TFDConnection);
var
  lObjeto: TSincronizacaoWebService;
begin
  // pId = Id do Log
  // pCodigoEmpresa = c�digo da empresa na configura��o geral do aplicativo
  // pConexao = TFDConnection, conex�o com o banco local do aplicativo
  lObjeto := TSincronizacaoWebService.Create;
  try
    lObjeto.CadastraLogDeErroNoWebService(pConfiguracao, pId, pConexao);
  finally
    lObjeto.Free;
  end;
end;

class function TSincronizacaoWebService.ExecutaCadastraLogLoginNoWebService
  (pLogLoginNuvem: TLogLoginNuvem; pConfiguracao: TConfiguracao): boolean;
var
  lObjeto: TSincronizacaoWebService;
begin
  lObjeto := TSincronizacaoWebService.Create;
  try
    Result := lObjeto.CadastraLogLoginNoWebService(pLogLoginNuvem,
      pConfiguracao);
  finally
    lObjeto.Free;
  end;

end;

class function TSincronizacaoWebService.ExecutaUltimaVersaoDoSistemaNoWebService
  (pConfiguracao: TConfiguracao): Integer;
var
  lObjeto: TSincronizacaoWebService;
begin
  lObjeto := TSincronizacaoWebService.Create;
  try
    Result := lObjeto.UltimaVersaoDoSistemaNoWebService(pConfiguracao);
  finally
    lObjeto.Free;
  end;
end;

class function TSincronizacaoWebService.ExecutaConsultaEmpresasNoWebService
  (pConfiguracao: TConfiguracao): boolean;
var
  lObjeto: TSincronizacaoWebService;
begin
  lObjeto := TSincronizacaoWebService.Create;
  try
    Result := lObjeto.ConsultaEmpresasNoWebService(pConfiguracao);
  finally
    lObjeto.Free;
  end;
end;

class procedure TSincronizacaoWebService.ExecutaCadastraLogNoWebService
  (pConfiguracao: TConfiguracao; pConexao: TFDConnection);
var
  lObjeto: TSincronizacaoWebService;
begin
  // pId = Id do Log
  // pCodigoEmpresa = c�digo da empresa na configura��o geral do aplicativo
  // pConexao = TFDConnection, conex�o com o banco local do aplicativo
  lObjeto := TSincronizacaoWebService.Create;
  try
    lObjeto.CadastraLogNoWebService(pConfiguracao, pConexao);
  finally
    lObjeto.Free;
  end;
end;

procedure TSincronizacaoWebService.ExecutaConsultaNoWebService
  (pConfiguracao: TConfiguracao; pTipoConsulta: TServicoWebService);
begin
  // ConfiguraRestClient(pConfiguracao);
  // ConfiguraRestRequest(pConfiguracao, pTipoConsulta);
  // ConfiguraRestResponse(pConfiguracao, pTipoConsulta);
  // InicializaRestResponseDataSetAdapter;
  ConsultaNoWebService(pConfiguracao, pTipoConsulta);
end;

procedure TSincronizacaoWebService.ExecutarRequisicao;
begin
  FRestRequest.Execute;
end;

procedure TSincronizacaoWebService.InicializaRestResponseDataSetAdapter;
begin
  FRestResponseDataSetAdapter.ResetToDefaults;
  FRestResponseDataSetAdapter.ResponseJSON := nil;
  FRestResponseDataSetAdapter.RootElement := '';
  FRestResponseDataSetAdapter.DataSet := nil;
end;

end.
