unit uFuncoes;

interface

uses
  System.Classes,
  System.Inifiles,
  Vcl.Forms,
  System.SysUtils,
  IdCoder,
  IdCoder3to4,
  IdCoderMIME,
  IdBaseComponent,
  System.DateUtils,
  Vcl.Dialogs,
  IdStackWindows,
  Winapi.Windows,
  System.Win.Registry,
  Winapi.TlHelp32,
  IdTCPClient,
  System.ZLib;

type
  TFuncoes = class
    private



    public
      class procedure CompactarArquivoUsandoZlib(pArquivo: string);
      class procedure DescompactarArquivoUsandoZlib(pArquivo: string);

      class function CriptografarDados(pValor: string): string;
      class function DescriptografarDados(pValor: string): string;
      class procedure CriaEAcessaFormulario(pClasseFormulario: TComponentClass; pFormulario: TForm); static;
      class function RemoveAcentos(const s: string): string;
      class function DecodificarDataHora(pDataHora: TDateTime): string;
      class function TamanhoDoArquivo(pArquivo: string): double;
      class function NomeComputador: string;
      class function ProcessadorComputador: string;
      class function EnderecosIpComputador: string;
      class function InformacoesWindows: string;
      class function NomeAplicativo: string;
      class procedure DefineAmbienteFormatoWebService;
      class function DiretorioDaAplicacao: string;
      class function EncerrarTarefaDoExecutavelNoWindows(pNomeExecutavel: string): integer;
      class function ExisteConexaoComInternet: Boolean;
  end;

implementation

class function TFuncoes.ExisteConexaoComInternet: Boolean;
var
  lIdTCPClient: TIdTCPClient;
begin
  result := false;
  lIdTCPClient := TIdTCPClient.Create(nil);
  try
    try
      lIdTCPClient.ReadTimeout := 2000;
      lIdTCPClient.ConnectTimeout := 2000;
      lIdTCPClient.Port := 80;
      lIdTCPClient.Host := 'google.com';
      lIdTCPClient.Connect;
      lIdTCPClient.Disconnect;
      result := true;
    except
      result := false;
    end;
  finally
    lIdTCPClient.Free;
  end;
end;

class function TFuncoes.DiretorioDaAplicacao: string;
var
  lDiretorio: string;
begin
  lDiretorio := ExtractFilePath(Application.ExeName);
  if Copy(lDiretorio, Length(lDiretorio), 1) <> '\' then
    lDiretorio := lDiretorio + '\';
  result := lDiretorio;
end;

class procedure TFuncoes.DefineAmbienteFormatoWebService;
begin
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  FormatSettings.DateSeparator := '-';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.TimeAMString := 'M';
  FormatSettings.TimePMString := 'T';
  FormatSettings.DecimalSeparator := ',';
  FormatSettings.ThousandSeparator := '.';
  FormatSettings.CurrencyFormat := 0;
  FormatSettings.NegCurrFormat := 0;
end;

class procedure TFuncoes.CriaEAcessaFormulario(pClasseFormulario: TComponentClass; pFormulario: TForm);
begin
  Application.CreateForm(pClasseFormulario, pFormulario);
  try
    TForm(pFormulario).ShowModal;
  finally
    // FreeAndNil(TForm(pFormulario));
  end;
end;

class function TFuncoes.CriptografarDados(pValor: string): string;
var
  lEncoder: TIdEncoderMIME;
begin
  result := EmptyStr;
  lEncoder := TIdEncoderMIME.Create(nil);
  try
    result := lEncoder.EncodeString(pValor);
  finally
    lEncoder.Free;
  end;
end;

class function TFuncoes.DecodificarDataHora(pDataHora: TDateTime): string;
var
  lAno, lMes, lDia, lHora, lMinuto, lSegundo, lMilisegundo: Word;
begin
  decodedatetime(Now, lAno, lMes, lDia, lHora, lMinuto, lSegundo, lMilisegundo);
  result := lAno.ToString + FormatFloat('00', lMes) + FormatFloat('00', lDia) + FormatFloat('00', lHora) + FormatFloat('00', lMinuto) +
    FormatFloat('00', lSegundo);

end;

class function TFuncoes.DescriptografarDados(pValor: string): string;
var
  lDecoder: TIdDecoderMIME;
begin
  result := EmptyStr;
  lDecoder := TIdDecoderMIME.Create(nil);
  try
    result := lDecoder.DecodeString(pValor);
  finally
    lDecoder.Free;
  end;
end;

class function TFuncoes.EncerrarTarefaDoExecutavelNoWindows(pNomeExecutavel: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(pNomeExecutavel)) or
      (UpperCase(FProcessEntry32.szExeFile) = UpperCase(pNomeExecutavel))) then
      result := integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);

end;

class function TFuncoes.EnderecosIpComputador: string;
var
  IdStackWin: TIdStackWindows;
  lIndice: integer;
begin
  result := '';
  lIndice := 0;
  IdStackWin := TIdStackWindows.Create;
  try
    result := IdStackWin.LocalAddresses.DelimitedText;
  finally
    IdStackWin.Free;
  end;

end;

class function TFuncoes.InformacoesWindows: string;
var
  lNome, lVersao, lCurrentBuild: String;
  lRegistro: TRegistry;
begin
  result := '';
  lRegistro := TRegistry.Create; // Criando um Registro na Memória
  try
    lRegistro.Access := KEY_READ; // Colocando nosso Registro em modo Leitura
    lRegistro.RootKey := HKEY_LOCAL_MACHINE; // Definindo a Raiz
    // Abrindo a chave desejada
    lRegistro.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion\', true);
    // Obtendo os Parâmetros desejados
    lNome := lRegistro.ReadString('ProductName');
    lVersao := lRegistro.ReadString('CurrentVersion');
    lCurrentBuild := lRegistro.ReadString('CurrentBuild');
    // Montando uma String com a versao e detalhes
    result := 'Nome : ' + lNome + ' - Versão : ' + lVersao + ' - Build : ' + lCurrentBuild;
  finally
    lRegistro.Free;
  end;

end;

class function TFuncoes.NomeAplicativo: string;
begin
  result := ChangeFileExt(ExtractFileName(Application.ExeName), '');
end;

class function TFuncoes.NomeComputador: string;
var
  lBuffer: Array [0 .. 255] of char;
  lSize: Dword;
begin
  lSize := 256;
  if GetComputerName(lBuffer, lSize) then
  begin
    result := lBuffer;
  end
  else
  begin
    result := '';
  end;

end;

class function TFuncoes.ProcessadorComputador: string;
var
  lRegistro: TRegistry;
begin
  result := '';
  lRegistro := TRegistry.Create;
  try
    lRegistro.RootKey := HKEY_LOCAL_MACHINE;
    lRegistro.OpenKeyReadOnly('HARDWARE\DESCRIPTION\System\CentralProcessor\0');
    result := lRegistro.ReadString('ProcessorNameString');
    lRegistro.CloseKey;
  finally
    lRegistro.Free;
  end;

end;

class function TFuncoes.RemoveAcentos(const s: string): string;
var
  i: integer;
  lCaracteresComAcento, lCaracteresSemAcento: string;

const
  CARACTERES_COM_ACENTO: array [1 .. 50] of string = ('á', 'à', 'ä', 'â', 'ã', 'å', 'Á', 'À', 'Ä', 'Â', 'Ã', 'Å', 'é', 'è', 'ë', 'ê', 'É', 'È', 'Ë', 'Ê', 'í',
    'ì', 'ï', 'î', 'Í', 'Ì', 'Ï', 'Î', 'ó', 'ò', 'ö', 'ô', 'õ', 'Ó', 'Ò', 'Ö', 'Ô', 'Õ', 'ú', 'ù', 'ü', 'û', 'Ú', 'Ù', 'Ü', 'Û', 'ç', 'Ç', 'ñ', 'Ñ');

const
  CARACTERES_SEM_ACENTO: array [1 .. 50] of string = ('a', 'a', 'a', 'a', 'a', 'a', 'A', 'A', 'A', 'A', 'A', 'A', 'e', 'e', 'e', 'e', 'E', 'E', 'E', 'E', 'i',
    'i', 'i', 'i', 'I', 'I', 'I', 'I', 'o', 'o', 'o', 'o', 'o', 'O', 'O', 'O', 'O', 'O', 'u', 'u', 'u', 'u', 'U', 'U', 'U', 'U', 'c', 'C', 'n', 'N');
begin

  // Assert(Length(OldPattern) = Length(NewPattern));
  result := s;
  for i := Low(CARACTERES_COM_ACENTO) to High(CARACTERES_SEM_ACENTO) do
    result := StringReplace(result, CARACTERES_COM_ACENTO[i], CARACTERES_SEM_ACENTO[i], [rfReplaceAll]);
end;

class function TFuncoes.TamanhoDoArquivo(pArquivo: string): double;
var
  FileHandle: THandle;
  FileSize: LongWord;
begin
  // retorna tamanho de um arquivo em bytes

  result := 0;
  // a- Get file size
  FileHandle := CreateFile(PChar(pArquivo), GENERIC_READ, 0, { exclusive }
    nil, { security }
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  FileSize := GetFileSize(FileHandle, nil);
  result := FileSize;
  CloseHandle(FileHandle);


  // ShowMessage(Result.ToString);  para testes

end;

class procedure TFuncoes.CompactarArquivoUsandoZlib(pArquivo: string);
var
  lFileIni, lFileOut: TFileStream;
  lZip: TCompressionStream;
begin
  if (Length(Trim(pArquivo)) > 0) then
  begin
    // compacta o arquivo
    // ProgressBar1.Position := 60;
    // Sleep(100);

    lFileIni := TFileStream.Create(pArquivo, fmOpenRead and fmShareExclusive);
    lFileOut := TFileStream.Create(Copy(pArquivo, 1, Length(pArquivo) - 4) + '.ZMC', fmCreate or fmShareExclusive);
    lZip := TCompressionStream.Create(clMax, lFileOut);
    lZip.CopyFrom(lFileIni, lFileIni.Size);
    // ProgressBar1.Position := 100;
    // Sleep(200);

    lZip.Free;
    lFileOut.Free;
    lFileIni.Free;
  end;
end;

class procedure TFuncoes.DescompactarArquivoUsandoZlib(pArquivo:string);
var
  lFileIni, lFileOut: TFileStream;
  lDeZip: TDecompressionStream;
  i: Integer;
  lBuf: array [0 .. 1023] of Byte;
begin
  if (Length(Trim(pArquivo)) > 0) then
  begin
    // descompacta o arquivo
    lFileIni := TFileStream.Create(pArquivo, fmOpenRead and
      fmShareExclusive);

    lFileOut := TFileStream.Create(Copy(pArquivo, 1,
      Length(pArquivo) - 4) + '.exe', fmCreate or fmShareExclusive);

    lDeZip := TDecompressionStream.Create(lFileIni);
    repeat
      i := lDeZip.Read(lBuf, SizeOf(lBuf));
      if i <> 0 then
        lFileOut.Write(lBuf, i);
    until i <= 0;

    lDeZip.Free;
    lFileOut.Free;
    lFileIni.Free;
  end;
end;

end.
