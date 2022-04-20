unit DConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.StdCtrls, Vcl.Forms, Vcl.Dialogs, IniFiles;

type
  TdtmConexao = class(TDataModule)
    cnnConexao: TFDConnection;
    trsTransacao: TFDTransaction;
    qryConsulta: TFDQuery;
    qryUsuarios: TFDQuery;
    qryUsuariosIDCODIGOUSUARIO: TIntegerField;
    qryUsuariosDESCRICAOUSUARIO: TStringField;
    qryUsuariosSENHAUSUARIO: TStringField;
    qryUsuariosTIPOUSUARIO: TStringField;
    qryUsuariosDATAUSUARIO: TDateField;
    qrySistema: TFDQuery;
    qrySistemaIDCODIGOSISTEMA: TIntegerField;
    qrySistemaDESCRICAOSISTEMA: TStringField;
    qrySistemaDATASISTEMA: TDateField;
    qryVersoes: TFDQuery;
    qryVersoesIDCODIGOVERSAO: TIntegerField;
    qryVersoesDESCRICAOVERSAO: TStringField;
    qryVersoesDATAVERSAO: TDateField;
    qrySubversoes: TFDQuery;
    qrySubversoesIDCODIGOSUBVERSAO: TIntegerField;
    qrySubversoesDESCRICAOSUBVERSAO: TStringField;
    qrySubversoesDATASUBVERSAO: TDateField;
    qrySubversoesIDCODIGOVERSAO: TIntegerField;
    qryModificacoes: TFDQuery;
    qryModificacoesIDCODIGOMODIFICACAO: TIntegerField;
    qryModificacoesDESCRICAOMODIFICACAO: TStringField;
    qryModificacoesDATAMODIFICACAO: TDateField;
    qryModificacoesTIPOMODIFICACAO: TStringField;
    qryModificacoesIDCODIGOVERSAO: TIntegerField;
    qryModificacoesIDCODIGOSUBVERSAO: TIntegerField;
    qryModificacoesIDCODIGOSISTEMA: TIntegerField;
    qryModificacoesDESCRICAOVERSAO: TStringField;
    qryModificacoesDESCRICAOSUBVERSAO: TStringField;
    qryModificacoesDESCRICAOSISTEMA: TStringField;
    qrySubversoesDESCRICAOVERSAO: TStringField;
    qryClientes: TFDQuery;
    qryClientesMC01CODIGO: TIntegerField;
    qryClientesMC01NOME: TStringField;
    qryClientesMC01FANTASIA: TStringField;
    qryClientesMC01EMAIL: TStringField;
    procedure qryclientesError(ASender, AInitiator: TObject;
      var AException: Exception);

  private
    FCodigoDoUsuario: Integer;

    { Private declarations }
  public
    { Public declarations }
    property CodigoDoUsuario: Integer read FCodigoDoUsuario
      write FCodigoDoUsuario;
    procedure CarregaCombo(pComboBox: TComboBox;
      pNomeTabela, pDescricao, pCodigo: String; pCodigoDaTabela: Integer);
    function RetornaCodigoDoCombo(pComboBox: TComboBox): Integer;
    function IniciaConexao: boolean;
    procedure ValidaSeEstaLiberado(pForm: Tform);
  end;

var
  dtmConexao: TdtmConexao;

implementation

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

procedure TdtmConexao.CarregaCombo(pComboBox: TComboBox; pNomeTabela: String;
  pDescricao: String; pCodigo: String; pCodigoDaTabela: Integer);

var
  li, lCodigoSelecionado: Integer;
begin
  lCodigoSelecionado := 0;
  li := 0;
  qryConsulta.Open('SELECT * FROM ' + pNomeTabela);
  pComboBox.Items.Clear;
  while not qryConsulta.Eof do
  begin
    pComboBox.Items.AddObject(qryConsulta.FieldByName(pDescricao).AsString,
      TObject(Integer(qryConsulta.FieldByName(pCodigo).AsInteger)));
    Inc(li);
    if (pCodigoDaTabela = qryConsulta.FieldByName(pCodigo).AsInteger) then
    begin
      lCodigoSelecionado := li;
    end;
    qryConsulta.Next;
  end;
  pComboBox.ItemIndex := lCodigoSelecionado - 1;
end;

function TdtmConexao.IniciaConexao: boolean;
var
  lArquivoTexto: TextFile;
  banco, host: string;
  lCaminhoArquivo: string;
begin
  lCaminhoArquivo := ExtractFilePath(Application.ExeName) + '\banco.ini';
  try
    AssignFile(lArquivoTexto, lCaminhoArquivo);
    Reset(lArquivoTexto);
    Readln(lArquivoTexto, host);
    Readln(lArquivoTexto, banco);
    CloseFile(lArquivoTexto);
    cnnConexao.Params.Values['database'] := copy(banco, 7, 255);
    cnnConexao.Params.Values['server'] := copy(host, 6, 15);
    cnnConexao.Params.Values['protocol'] := 'TCPIP';
    cnnConexao.Open;
    result := cnnConexao.Connected;
  except on e:exception do
  begin
    ShowMessage('Erro ao se conectar com o Banco de Dados!'+sLineBreak+e.Message);
    Application.Terminate;
  end;

  end;
end;

procedure TdtmConexao.qryclientesError(ASender, AInitiator: TObject;
  var AException: Exception);
begin
  showmessage(AException.Message);
end;

function TdtmConexao.RetornaCodigoDoCombo(pComboBox: TComboBox): Integer;
begin
  result := Integer(pComboBox.Items.Objects[pComboBox.ItemIndex]);
end;

procedure TdtmConexao.ValidaSeEstaLiberado(pForm: Tform);
var
  I: Integer;
  lLiberado: boolean;
begin
  qryConsulta.Open('select tipousuario from usuarios where idcodigousuario = ' +
    inttostr(FCodigoDoUsuario));
  lLiberado := (qryConsulta.FieldByName('tipousuario').AsString = 'G');

  for I := 0 to pForm.ComponentCount - 1 do
  begin
    if pForm.Components[I] is TButton then
    begin
      if pForm.Components[I] is TButton then
      begin
        if (pForm.Components[I].Name = 'btnIncluir') OR
          (pForm.Components[I].Name = 'btnEditar') OR
          (pForm.Components[I].Name = 'btnExcluir') OR
          (pForm.Components[I].Name = 'btnEnviarEmail') OR
          (pForm.Components[I].Name = 'btnEnviarModificacao') then
        begin
          TButton(pForm.Components[I]).Enabled := lLiberado;
        end;

      end;

    end;

  end;

end;

end.
