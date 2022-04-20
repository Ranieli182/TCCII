unit UEnvioEmailCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, DConexao, UCadastroVersoes, SendMail, frxExportPDF,
  shellapi,
  frxClass, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Datasnap.DBClient;

type
  TfrmEnvioEmailCliente = class(TForm)
    pnlTitulo: TPanel;
    pnlPesquisa: TPanel;
    dbgSistemas: TDBGrid;
    edtPesquisar: TEdit;
    pnlBotoes: TPanel;
    btnCancelar: TButton;
    btnEnviar: TButton;
    btnPesquisar: TButton;
    cbnTipoDePesquisa: TComboBox;
    lblPesquisa: TLabel;
    dtsClientes: TDataSource;
    frxRelatorio: TfrxReport;
    email: TMAPIMail;
    chkSelecionarTodos: TCheckBox;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure edtPesquisarChange(Sender: TObject);
    procedure chkSelecionarTodosClick(Sender: TObject);
  private
    procedure Pesquisar(pTexto: String);
    procedure ImprimirEmPDF(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEnvioEmailCliente: TfrmEnvioEmailCliente;

implementation

{$R *.dfm}

procedure TfrmEnvioEmailCliente.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEnvioEmailCliente.btnPesquisarClick(Sender: TObject);
begin
  Pesquisar(edtPesquisar.Text);
end;

procedure TfrmEnvioEmailCliente.chkSelecionarTodosClick(Sender: TObject);
var
  vlLinha: Integer;
begin
  if chkSelecionarTodos.Checked then
  begin
    with dbgSistemas.DataSource.DataSet do
    begin
      First;
      for vlLinha := 0 to RecordCount - 1 do
      begin
        dbgSistemas.SelectedRows.CurrentRowSelected := True;
        Next;
      end;
    end;
    dbgSistemas.SelectedRows.Refresh;
  end
  else
  begin
    dtmConexao.qryclientes.Close;
    dtmConexao.qryclientes.Open;
  end;

end;

procedure TfrmEnvioEmailCliente.Pesquisar(pTexto: String);
var
  lCampo: String;
begin

  case cbnTipoDePesquisa.ItemIndex of
    0:
      begin
        lCampo := 'IDCODIGOVERSAO';
      end;
    1:
      begin
        lCampo := 'DESCRICAOVERSAO';
      end;
  end;
  dtmConexao.qryclientes.Open('SELECT * FROM mc01cliente WHERE ' + lCampo +
    ' LIKE ' + QuotedStr('%' + pTexto + '%'));

end;

procedure TfrmEnvioEmailCliente.btnEnviarClick(Sender: TObject);
var
  cCaminho, cArquivo, cEmail: string;
  cData: string;
  i: Integer;
begin
  // rotina para anexar os PDF das OS no gerenciador de e-mail - 14.02.04

  cCaminho := '';
  cData := DateToStr(Now);
  cCaminho := 'D:\Projetos';
  cArquivo := 'Modificações.pdf';
  // #829 14.5.0 // mudei o caminho para unidade D
  if FileExists(cCaminho + '\' + cArquivo) then
  begin
    if messagedlG('Deseja anexar PDF para enviar por email ?', mtConfirmation,
      [mbyes, mbno], 1) = mryes then
    begin
      email.Subject := 'Nova Atualização Disponível! ';
      email.Body := 'Data : ' + cData + '<br>' +
        'Olá, pode atualizar o seu sistema. Segue em anexo o PDF com as modificações disponíveis na nova versão!';
      email.Attachments.clear;
      email.Recipients.clear;

      // fazer select nos clientes

      // dtmConexao.qryclientes.Close;
      // dtmConexao.qryclientes.sql.clear;
      // dtmConexao.qryclientes.sql.add
      // ('select * from mc01cliente order by mc01email');
      // dtmConexao.qryclientes.Open;
      dtmConexao.qryclientes.First;

      // percorrer com while a query clientes dando recipients.add
      // for i := 0 to dbgSistemas.SelectedRows.Count - 1 do
      // begin
      // dbgSistemas.datasource.dataset.GotoBookmark(Pointer(dbgSistemas.SelectedRows.Items[i])); //   vai para a linha selecionada
      // email.Recipients.Add(dbgSistemas.datasource.dataset.fieldbyname('mc01email').asstring);
      // end;

      while not dtmConexao.qryclientes.eof do
      begin
        if dbgSistemas.SelectedRows.CurrentRowSelected = True then
        begin
          email.Recipients.add('BCC:' + dtmConexao.qryclientes.fieldbyname
            ('mc01email').asstring);
        end;
        dtmConexao.qryclientes.Next;
      end;

      email.Attachments.add(cCaminho + '\' + cArquivo);

      email.Send;

    end;
  end;

end;

procedure TfrmEnvioEmailCliente.edtPesquisarChange(Sender: TObject);
begin
  Pesquisar(edtPesquisar.Text);
end;

procedure TfrmEnvioEmailCliente.FormShow(Sender: TObject);
begin
  dtmConexao.qryclientes.Open;
end;

procedure TfrmEnvioEmailCliente.ImprimirEmPDF(Sender: TObject);
var
  cCaminho, cArquivo: string;
  ExportaParaPDF: tFrxPDFExport;
begin

  cCaminho := 'D:\Projetos'; // #829 14.5.0 // mudei o caminho para unidade D
  // verifica se existe ou não existe a pasta , se não existe cria a pasta de cargas
  if not DirectoryExists(cCaminho) then
    ForceDirectories(cCaminho);

  cArquivo := 'Modificações';

  // aqui o teu codigo que gera o relatorio mas sem abrir na tela

  ExportaParaPDF := tFrxPDFExport.Create(Self);
  try
    frxRelatorio.PrepareReport();
    ExportaParaPDF.FileName := cArquivo + '.pdf';
    ExportaParaPDF.DefaultPath := cCaminho + '\';
    ExportaParaPDF.ShowDialog := False;
    ExportaParaPDF.ShowProgress := False;
    ExportaParaPDF.OverwritePrompt := False;
    frxRelatorio.Export(ExportaParaPDF);

    ShellExecute(Handle, nil, PwideChar(cCaminho + '\' + cArquivo + '.pdf'),
      nil, nil, SW_SHOWMAXIMIZED);
  finally
    ExportaParaPDF.Free;
  end;

end;

end.
