unit UMenuPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Menus, System.Actions, Vcl.ActnList,
  ULogin, UConsultaSistemas, UCadastroVersoes, UConsultaVersoes,
  UConsultaUsuarios,
  dImagens, UCadastroModificacao, UCadastroSistemas, UCadastroSubversao,
  UCadastroUsuarios, UConsultaSubversoes, UConsultaModificacoes, DConexao,
  Vcl.Imaging.jpeg, Vcl.ExtCtrls, URelatorio, UConsultaClientes,
  UCadastroClientes, URelease;

type
  TfrmMenuPrincipal = class(TForm)
    ToolBar1: TToolBar;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    Usurios1: TMenuItem;
    Modificacoes1: TMenuItem;
    Versoes1: TMenuItem;
    Subversoes1: TMenuItem;
    Sistemas1: TMenuItem;
    Relatrios1: TMenuItem;
    Image1: TImage;
    Clientes1: TMenuItem;
    Sair1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Sistemas1Click(Sender: TObject);
    procedure Versoes1Click(Sender: TObject);
    procedure Usurios1Click(Sender: TObject);
    procedure Subversoes1Click(Sender: TObject);
    procedure Modificacoes1Click(Sender: TObject);
    procedure Relatrios1Click(Sender: TObject);
    procedure Clientes1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenuPrincipal: TfrmMenuPrincipal;

implementation

{$R *.dfm}

procedure TfrmMenuPrincipal.FormCreate(Sender: TObject);
begin
  Application.CreateForm(TfrmLogin, frmLogin);
  frmLogin.ShowModal;
  FreeAndNil(frmLogin);
end;

procedure TfrmMenuPrincipal.Modificacoes1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmConsultadeModificacoes, frmConsultadeModificacoes);
  frmConsultadeModificacoes.ShowModal;
  FreeAndNil(frmConsultadeModificacoes);
end;

procedure TfrmMenuPrincipal.Relatrios1Click(Sender: TObject);
begin
  frmRelatorio.ShowModal;
end;

procedure TfrmMenuPrincipal.Sair1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMenuPrincipal.Sistemas1Click(Sender: TObject);
begin
  frmConsultaDeSistemas.ShowModal;
end;

procedure TfrmMenuPrincipal.Subversoes1Click(Sender: TObject);
begin
  frmConsultaDeSubversoes.ShowModal;
end;

procedure TfrmMenuPrincipal.Usurios1Click(Sender: TObject);
begin
  frmConsultaDeUsuarios.ShowModal;
end;

procedure TfrmMenuPrincipal.Versoes1Click(Sender: TObject);
begin
  frmConsultaDeVersoes.ShowModal;
end;

procedure TfrmMenuPrincipal.Clientes1Click(Sender: TObject);
begin
  frmConsultaDeClientes.ShowModal;
end;

end.
