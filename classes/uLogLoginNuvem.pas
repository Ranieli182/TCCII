unit uLogLoginNuvem;

interface

uses
  Windows,
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
  TLogLoginNuvem = class
    private
      FId: Integer;
      FCodigoEmpresa: Integer;
      FDataHora: TDateTime;
      FNumeroVersao: Integer;
      FNomeComputador: string;
      FCodigoSistema: Integer;
      FCodigoUsuario: Integer;
      FChaveRegistro: string;
      FNomeRel: string;
      function GetNomeComputador: string;
      procedure SetNomeComputador(const Value: string);

    public
      property Id: Integer read FId write FId;
      property CodigoEmpresa: Integer read FCodigoEmpresa write FCodigoEmpresa;
      property DataHora: TDateTime read FDataHora write FDataHora;
      property NumeroVersao: Integer read FNumeroVersao write FNumeroVersao;
      property NomeComputador: string read GetNomeComputador write SetNomeComputador;
      property CodigoSistema: Integer read FCodigoSistema write FCodigoSistema;
      property CodigoUsuario: Integer read FCodigoUsuario write FCodigoUsuario;
      property ChaveRegistro: string read FChaveRegistro write FChaveRegistro;
      property NomeRel: string read FNomeRel write FNomeRel;

      constructor Create;
      destructor Destroy; override;

  end;

implementation

{ TVersoes }

constructor TLogLoginNuvem.Create;
begin
  NomeComputador := TFuncoes.NomeComputador;
end;

destructor TLogLoginNuvem.Destroy;
begin

  inherited;
end;

function TLogLoginNuvem.GetNomeComputador: string;
begin
  Result := FNomeComputador;
end;

procedure TLogLoginNuvem.SetNomeComputador(const Value: string);
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

end.
