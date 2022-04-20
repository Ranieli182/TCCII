unit ULogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, DConexao, Vcl.Mask,
  Vcl.DBCtrls, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TfrmLogin = class(TForm)
    btnConfirmarLogin: TButton;
    btnCancelarLogin: TButton;
    Label1: TLabel;
    dtsLogin: TDataSource;
    Label2: TLabel;
    edtCodigoLogin: TEdit;
    edtSenhaLogin: TEdit;
    iml24x24: TImageList;
    Image1: TImage;
    procedure btnConfirmarLoginClick(Sender: TObject);
    procedure btnCancelarLoginClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
    function VerificaUsuarioNoBancoDeDados(pCodigo, pSenha: string): Boolean;
  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.dfm}

procedure TfrmLogin.btnCancelarLoginClick(Sender: TObject);
begin
  // dtmConexao.qryUsuarios.Cancel;
  // close;
  Application.Terminate;
end;

procedure TfrmLogin.btnConfirmarLoginClick(Sender: TObject);
begin
  dtmConexao.IniciaConexao;
  if edtCodigoLogin.text = '' then
  begin
    ShowMessage
      ('Campo obrigatório não informado, favor preencher o Código do Usuário!');
    edtCodigoLogin.setFocus;
    exit;
  end
  else if edtSenhaLogin.text = '' then
  begin
    ShowMessage
      ('Campo obrigatório não informado, favor preencher a Senha do Usuário!');
    edtSenhaLogin.setFocus;
    exit;
  end
  else
  begin
    if VerificaUsuarioNoBancoDeDados(edtCodigoLogin.text, edtSenhaLogin.text)
    then
    begin
      dtmConexao.CodigoDoUsuario := strToInt(edtCodigoLogin.text);
      close;
    end
    else
    begin
      edtCodigoLogin.setFocus;
      ShowMessage('Dados de login invalidos!');
    end;
  end;

end;

procedure TfrmLogin.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
  begin
    Key := #0;
    Perform(WM_NEXTDLGCTL, 0, 0);
  end;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
begin
  edtCodigoLogin.text := '';
  edtSenhaLogin.text := '';
  edtCodigoLogin.setFocus;
end;

function TfrmLogin.VerificaUsuarioNoBancoDeDados(pCodigo,
  pSenha: string): Boolean;
var
  lQryUsuario: TFDQuery;
begin
  Result := False;
  lQryUsuario := TFDQuery.Create(nil);
  try
    lQryUsuario.Connection := dtmConexao.cnnConexao;
    lQryUsuario.close;
    lQryUsuario.SQL.Clear;
    lQryUsuario.SQL.Add
      ('SELECT * FROM USUARIOS WHERE IDCODIGOUSUARIO = :PARAMETRO_CODIGO AND SENHAUSUARIO = :PARAMETRO_SENHA ');
    lQryUsuario.ParamByName('PARAMETRO_CODIGO').AsString := pCodigo;
    lQryUsuario.ParamByName('PARAMETRO_SENHA').AsString := pSenha;
    lQryUsuario.Open;

    if lQryUsuario.RecordCount > 0 then
    begin
      Result := True;
    end;
    // else
    // begin
    // ShowMessage('Usuário não cadastrado!');
    // end;
  finally
    lQryUsuario.Free;
  end;
end;

end.
