unit URelease;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls;

type
  TfrmRelease = class(TForm)
    pnlTituloMelhoria: TPanel;
    DBGrid1: TDBGrid;
    pnlTituloCorrecao: TPanel;
    DBGrid2: TDBGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelease: TfrmRelease;

implementation

{$R *.dfm}

end.
