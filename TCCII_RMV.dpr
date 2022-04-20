program TCCII_RMV;

uses
  Vcl.Forms,
  ULogin in 'ULogin.pas' {frmLogin},
  UMenuPrincipal in 'UMenuPrincipal.pas' {frmMenuPrincipal},
  UCadastroVersoes in 'UCadastroVersoes.pas' {frmCadastroVersoes},
  UCadastroSubversao in 'UCadastroSubversao.pas' {frmCadastroSubversao},
  UCadastroSistemas in 'UCadastroSistemas.pas' {frmCadastroSistemas},
  UCadastroUsuarios in 'UCadastroUsuarios.pas' {frmCadastroUsuarios},
  UCadastroModificacao in 'UCadastroModificacao.pas' {frmCadastroModificacao},
  DConexao in 'DConexao.pas' {dtmConexao: TDataModule},
  UConsultaVersoes in 'UConsultaVersoes.pas' {frmConsultaDeVersoes},
  UConsultaUsuarios in 'UConsultaUsuarios.pas' {frmConsultaDeUsuarios},
  UConsultaSubversoes in 'UConsultaSubversoes.pas' {frmConsultaDeSubversoes},
  dImagens in 'dImagens.pas' {dtmImagens: TDataModule},
  UConsultaSistemas in 'UConsultaSistemas.pas' {frmConsultaDeSistemas},
  UConsultaModificacoes in 'UConsultaModificacoes.pas' {frmConsultaDeModificacoes},
  URelease in 'URelease.pas' {frmRelease},
  URelatorio in 'URelatorio.pas' {frmRelatorio},
  UConsultaClientes in 'UConsultaClientes.pas' {frmConsultaDeClientes},
  UCadastroClientes in 'UCadastroClientes.pas' {frmCadastroCliente},
  UEnvioEmailCliente in 'UEnvioEmailCliente.pas' {frmEnvioEmailCliente},
  uClassTypeAtualizador in 'classes\uClassTypeAtualizador.pas',
  uConfiguracao in 'classes\uConfiguracao.pas',
  uEmpresa in 'classes\uEmpresa.pas',
  uLogAtualizacao in 'classes\uLogAtualizacao.pas',
  uLogErros in 'classes\uLogErros.pas',
  uLogLoginNuvem in 'classes\uLogLoginNuvem.pas',
  uLogs in 'classes\uLogs.pas',
  uSincronizacaoWebService in 'classes\uSincronizacaoWebService.pas',
  uFuncoes in 'classes\uFuncoes.pas',
  uAtualizacao in 'classes\uAtualizacao.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdtmConexao, dtmConexao);
  Application.CreateForm(TfrmMenuPrincipal, frmMenuPrincipal);
  Application.CreateForm(TfrmCadastroVersoes, frmCadastroVersoes);
  Application.CreateForm(TfrmCadastroSubversao, frmCadastroSubversao);
  Application.CreateForm(TfrmCadastroSistemas, frmCadastroSistemas);
  Application.CreateForm(TfrmCadastroUsuarios, frmCadastroUsuarios);
  Application.CreateForm(TfrmCadastroModificacao, frmCadastroModificacao);
  Application.CreateForm(TfrmRelease, frmRelease);
  Application.CreateForm(TfrmRelatorio, frmRelatorio);
  Application.CreateForm(TfrmConsultaDeClientes, frmConsultaDeClientes);
  Application.CreateForm(TfrmCadastroCliente, frmCadastroCliente);
  Application.CreateForm(TfrmEnvioEmailCliente, frmEnvioEmailCliente);
  //  Application.CreateForm(TfrmConsultadeModificacoes, frmConsultadeModificacoes);
  Application.CreateForm(TfrmConsultaDeSistemas, frmConsultaDeSistemas);
  Application.CreateForm(TfrmConsultaDeVersoes, frmConsultaDeVersoes);
  Application.CreateForm(TfrmConsultaDeUsuarios, frmConsultaDeUsuarios);
  Application.CreateForm(TfrmConsultaDeSubversoes, frmConsultaDeSubversoes);
  Application.CreateForm(TdtmImagens, dtmImagens);

  Application.CreateForm(TfrmConsultaDeSistemas, frmConsultaDeSistemas);
  Application.Run;

end.
