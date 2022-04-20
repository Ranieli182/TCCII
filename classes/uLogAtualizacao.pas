unit uLogAtualizacao;

interface

uses Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  System.DateUtils,
  System.Win.Registry,
  Data.DB,
  IdStackWindows,
  Vcl.ComCtrls,
  Vcl.DBCtrls,
  Vcl.ExtCtrls,
  Data.SqlExpr,
  uFuncoes;

type
  TLogAtualizacao = class
    private
      FId: Integer;
      FCodigoEmpresa: Integer;
      FDataHora: TDateTime;
      FNomeComputador: string;
      FProcessadorComputador: string;
      FEnderecosIpComputador: string;
      FInformacoesWindows: string;
      FCodigoSistema: Integer;
      FNumeroVersao: Integer;
      FChaveRegistro: string;
      function GetNomeComputador: string;
      procedure SetNomeComputador(const Value: string);
      function GetProcessadorComputador: string;
      procedure SetProcessadorComputador(const Value: string);
      function GetEnderecosIpComputador: string;
      procedure SetEnderecosIpComputador(const Value: string);
      function GetInformacoesWindows: string;
      procedure SetInformacoesWindows(const Value: string);

    public
      property Id: Integer read FId write FId;
      property CodigoEmpresa: Integer read FCodigoEmpresa write FCodigoEmpresa;
      property DataHora: TDateTime read FDataHora write FDataHora;
      property NomeComputador: string read GetNomeComputador write SetNomeComputador;
      property ProcessadorComputador: string read GetProcessadorComputador write SetProcessadorComputador;
      property EnderecosIpComputador: string read GetEnderecosIpComputador write SetEnderecosIpComputador;
      property InformacoesWindows: string read GetInformacoesWindows write SetInformacoesWindows;
      property CodigoSistema: Integer read FCodigoSistema write FCodigoSistema;
      property NumeroVersao: Integer read FNumeroVersao write FNumeroVersao;
      property ChaveRegistro: string read FChaveRegistro write FChaveRegistro;

      constructor Create;
  end;

implementation

{ TLogAtualizacao }

constructor TLogAtualizacao.Create;
begin
  NomeComputador := TFuncoes.NomeComputador;
  ProcessadorComputador := TFuncoes.ProcessadorComputador;
  EnderecosIpComputador := TFuncoes.EnderecosIpComputador;
  InformacoesWindows := TFuncoes.InformacoesWindows;
end;

function TLogAtualizacao.GetEnderecosIpComputador: string;
begin
  Result := FEnderecosIpComputador;
end;

function TLogAtualizacao.GetInformacoesWindows: string;
begin
  Result := FInformacoesWindows;
end;

function TLogAtualizacao.GetNomeComputador: string;
begin
  Result := FNomeComputador;
end;

function TLogAtualizacao.GetProcessadorComputador: string;
begin
  Result := FProcessadorComputador;
end;

procedure TLogAtualizacao.SetEnderecosIpComputador(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FEnderecosIpComputador := lTextoTratado;
end;

procedure TLogAtualizacao.SetInformacoesWindows(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FInformacoesWindows := lTextoTratado;

end;

procedure TLogAtualizacao.SetNomeComputador(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FNomeComputador := lTextoTratado;
end;

procedure TLogAtualizacao.SetProcessadorComputador(const Value: string);
var
  lTextoTratado: string;
begin
  lTextoTratado := StringReplace(Value, '''', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, '"', '', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #10, ' ', [rfReplaceAll]);
  lTextoTratado := StringReplace(lTextoTratado, #13#10, ' ', [rfReplaceAll]);
  lTextoTratado := TFuncoes.RemoveAcentos(lTextoTratado);

  FProcessadorComputador := lTextoTratado;

end;

end.
