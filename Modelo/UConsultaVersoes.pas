unit UConsultaVersoes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, DConexao, UCadastroVersoes;

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
    rbtnSelecionarTodos: TRadioButton;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure edtPesquisarChange(Sender: TObject);
  private
    procedure Pesquisar(pTexto: String);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEnvioEmailCliente: TfrmEnvioEmailCliente;

implementation

{$R *.dfm}

procedure TfrmEnvioEmailCliente.btnEditarClick(Sender: TObject);
begin
  dtmConexao.qryVersoes.Edit;
  frmCadastroVersoes.ShowModal;
  dtmConexao.qryVersoes.Refresh;
end;

procedure TfrmEnvioEmailCliente.btnExcluirClick(Sender: TObject);
begin
  // apaga tudooo     tem que adicionar uma pergunta ao usuario aqui      nas

  if Application.MessageBox('Tem certeza que deseja excluir o registro selecionado?', 'Confirmação', mb_yesNO + mb_iconQuestion + MB_DEFBUTTON2) = idYes
  then
  if dtmConexao.qryVersoes.State in [dsBrowse] then
  begin
    dtmConexao.qryVersoes.Delete;
  end;
end;

procedure TfrmEnvioEmailCliente.btnCancelarClick(Sender: TObject);
begin
  Close;
end;
procedure TfrmEnvioEmailCliente.btnPesquisarClick(Sender: TObject);
begin
  Pesquisar(edtPesquisar.Text);
end;

procedure  TfrmEnvioEmailCliente.Pesquisar(pTexto:String);
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
  dtmConexao.qryVersoes.Open('SELECT * FROM VERSOES WHERE '+lCampo +' LIKE '+ QuotedStr('%'+ pTexto+'%') );

end;

procedure TfrmEnvioEmailCliente.btnEnviarClick(Sender: TObject);
begin

  dtmConexao.qryVersoes.Insert;
  frmCadastroVersoes.ShowModal;
  dtmConexao.qryVersoes.Refresh;

end;

procedure TfrmEnvioEmailCliente.edtPesquisarChange(Sender: TObject);
begin
  Pesquisar(edtPesquisar.Text);
end;

procedure TfrmEnvioEmailCliente.FormShow(Sender: TObject);
begin
  dtmConexao.qryVersoes.Open;
end;

end.
