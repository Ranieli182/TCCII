unit URelatorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, frxClass, frxDBSet, Vcl.StdCtrls,
  DConexao, UEnvioEmailCliente,
  SendMail, frxExportPDF, Winapi.ShellAPI, UConsultaUsuarios, uAtualizacao,
  uConfiguracao, uSincronizacaoWebService;

type
  TfrmRelatorio = class(TForm)
    btnVisualizarRelatorio: TButton;
    btnSair: TButton;
    frxReportModificacoes: TfrxReport;
    frxModificacoes: TfrxDBDataset;
    edtSistema: TEdit;
    lblSistema: TLabel;
    edtVersao: TEdit;
    lblVersao: TLabel;
    edtTipo: TEdit;
    lblTipo: TLabel;
    btnEnviarEmail: TButton;
    btnEnviarModificacao: TButton;
    edtSubversao: TEdit;
    lblSubversao: TLabel;
    procedure btnVisualizarRelatorioClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure btnEnviarEmailClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnEnviarModificacaoClick(Sender: TObject);
  private
    procedure GeraRelatorioEmPDF;
    procedure EnviarModificacoesParaWebService;
    procedure LimpaCampos;
    { Private declarations }
  public
    procedure CarregaRelatorio(const pReport: TfrxReport);
  end;

var
  frmRelatorio: TfrmRelatorio;

implementation

{$R *.dfm}
{ TfrmRelatorio }

procedure TfrmRelatorio.btnEnviarEmailClick(Sender: TObject);
begin
  // antes de chamar a tela dos clientes iremos salvar o relatorio em pdf
  GeraRelatorioEmPDF;
  frmEnvioEmailCliente.ShowModal;
end;

procedure TfrmRelatorio.GeraRelatorioEmPDF;
var
  cCaminho, cArquivo: string;
  ExportaParaPDF: tFrxPDFExport;
begin

  cCaminho := 'D:\Projetos'; //
  // verifica se existe ou não existe a pasta , se não existe cria a pasta de cargas
  if not DirectoryExists(cCaminho) then
    ForceDirectories(cCaminho);

  cArquivo := 'MODIFICAÇÕES';

  // aqui o teu codigo que gera o relatorio mas sem abrir na tela
  CarregaRelatorio(frxReportModificacoes);

  ExportaParaPDF := tFrxPDFExport.Create(Self);
  try
    frxReportModificacoes.PrepareReport();
    ExportaParaPDF.FileName := cArquivo + '.pdf';
    ExportaParaPDF.DefaultPath := cCaminho + '\';
    ExportaParaPDF.ShowDialog := False;
    ExportaParaPDF.ShowProgress := False;
    ExportaParaPDF.OverwritePrompt := False;
    frxReportModificacoes.Export(ExportaParaPDF);

    ShellExecute(Handle, nil, PwideChar(cCaminho + '\' + cArquivo + '.pdf'),
      nil, nil, SW_SHOWMAXIMIZED);
  finally
    ExportaParaPDF.Free;
  end;

end;

procedure TfrmRelatorio.btnEnviarModificacaoClick(Sender: TObject);
begin
  if (application.MessageBox('Deseja enviar as Modificações via Web Service?',
    'Confirmação', mb_yesNO + mb_iconQuestion + MB_DEFBUTTON2) = idYes) then
  begin
    EnviarModificacoesParaWebService;
  end;

end;

procedure TfrmRelatorio.EnviarModificacoesParaWebService;
var
  lAtualizacao: TAtualizacao;
  lConfiguracao: TConfiguracao;
begin
  lAtualizacao := TAtualizacao.Create;
  lConfiguracao := TConfiguracao.Create('', '');
  try
    lConfiguracao.UsuarioWebService := 'mcdev';
    lConfiguracao.SenhaWebService := 'MTIzNDU2';
    lConfiguracao.HostWebService := 'http://webmc.com.br/ws/mcsistemas';
    lConfiguracao.CodigoEmpresaLoginWebService := 0;

    dtmConexao.qryModificacoes.first;

    while not dtmConexao.qryModificacoes.eof do
    begin
      lAtualizacao.Versao := dtmConexao.qryModificacoesDESCRICAOVERSAO.AsString;
      lAtualizacao.Sistema :=
        dtmConexao.qryModificacoesIDCODIGOSISTEMA.AsInteger;
      lAtualizacao.Descricao :=
        dtmConexao.qryModificacoesDESCRICAOMODIFICACAO.AsString;
      lAtualizacao.CodigoEmpresa := 0;

      TSincronizacaoWebService.ExecutaCadastraAtualizacaoNoWebService
        (lAtualizacao, lConfiguracao);

      dtmConexao.qryModificacoes.next;
    end;
  finally
    lConfiguracao.Free;
    lAtualizacao.Free;
  end;
end;

procedure TfrmRelatorio.btnSairClick(Sender: TObject);
begin
  close;
  LimpaCampos;
  //dtmConexao.qryModificacoes.Close;
  //dtmConexao.qryModificacoes.SQL.Clear;
end;

procedure TfrmRelatorio.btnVisualizarRelatorioClick(Sender: TObject);
begin
  CarregaRelatorio(frxReportModificacoes);
end;

procedure TfrmRelatorio.CarregaRelatorio(const pReport: TfrxReport);
begin
  dtmConexao.qryModificacoes.close;
  dtmConexao.qryModificacoes.SQL.Clear;
  dtmConexao.qryModificacoes.SQL.Add
    (' SELECT                                                      ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.IDCODIGOMODIFICACAO   ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.DESCRICAOMODIFICACAO  ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.DATAMODIFICACAO       ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.TIPOMODIFICACAO       ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.IDCODIGOVERSAO        ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.IDCODIGOSUBVERSAO     ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     M.IDCODIGOSISTEMA       ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('    -- V.IDCODIGOVERSAO        ,                             ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     V.DESCRICAOVERSAO       ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('    -- SV.IDCODIGOSUBVERSAO    ,                             ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     SV.DESCRICAOSUBVERSAO   ,                               ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     --S.IDCODIGOSISTEMA       ,                             ');
  dtmConexao.qryModificacoes.SQL.Add
    ('     S.DESCRICAOSISTEMA                                      ');

  dtmConexao.qryModificacoes.SQL.Add
    (' FROM     MODIFICACOES M                                     ');
  dtmConexao.qryModificacoes.SQL.Add
    (' INNER JOIN VERSOES     V                                    ');
  dtmConexao.qryModificacoes.SQL.Add
    (' ON ( M.IDCODIGOVERSAO = V.IDCODIGOVERSAO)                   ');
  dtmConexao.qryModificacoes.SQL.Add
    (' INNER JOIN SUBVERSOES     SV                                ');
  dtmConexao.qryModificacoes.SQL.Add
    (' ON ( M.IDCODIGOSUBVERSAO  = SV.IDCODIGOSUBVERSAO)           ');
  dtmConexao.qryModificacoes.SQL.Add
    (' INNER JOIN SISTEMAS     S                                   ');
  dtmConexao.qryModificacoes.SQL.Add
    (' ON ( M.IDCODIGOSISTEMA = S.IDCODIGOSISTEMA)                 ');

  dtmConexao.qryModificacoes.SQL.Add(' WHERE 1>0              ');
  if length(edtSistema.Text) > 0 then
  begin
    dtmConexao.qryModificacoes.SQL.Add('  AND  S.DESCRICAOSISTEMA = ' +
      QuotedStr(edtSistema.Text));
  end;
  if length(edtVersao.Text) > 0 then
  begin
    dtmConexao.qryModificacoes.SQL.Add('  AND  V.DESCRICAOVERSAO  = ' +
      QuotedStr(edtVersao.Text));
  end;
  if length(edtSubversao.Text) > 0 then
  begin
    dtmConexao.qryModificacoes.SQL.Add('  AND  SV.DESCRICAOSUBVERSAO  = ' +
      QuotedStr(edtSubversao.Text));
  end;
  if length(edtTipo.Text) > 0 then
  begin
    dtmConexao.qryModificacoes.SQL.Add('  AND  M.TIPOMODIFICACAO  = ' +
      QuotedStr(edtTipo.Text));
  end;
  // if length(edtSubversao.Text) > 0 then
  // begin
  // dtmConexao.qryModificacoes.SQL.Add('  AND  SV.DESCRICAOSUBVERSAO  = '+ QuotedStr(edtSubversao.Text));
  // end;
  // if length( Trim(edtFiiltroCodigoInicial.Text))>0 then
  // dtmConexao.qryModificacoes.SQL.Add('  and  IDCODIGOMODIFICACAO >= '+ edtFiiltroCodigoInicial.Text);
  // if length( Trim(edtFiiltroCodigoFinal.Text))>0 then
  // dtmConexao.qryModificacoes.SQL.Add('  and  IDCODIGOMODIFICACAO <= '+ QuotedStr(.Text));

  pReport.PrepareReport;
  pReport.ShowPreparedReport;
end;

procedure TfrmRelatorio.FormShow(Sender: TObject);
begin
  dtmConexao.ValidaSeEstaLiberado(Self);
end;

// Limpar edits
procedure TfrmRelatorio.LimpaCampos;
var
  i: Integer;
begin
  with Screen.ActiveForm do
  begin
    for i := 0 to ComponentCount - 1 do
    begin
      // Limpa Edits
      if Components[i] is TEdit then
        TEdit(Components[i]).Clear;

    end;
  end;
end;

end.
