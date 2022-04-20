unit dImagens;

interface

uses
  System.SysUtils, System.Classes, Vcl.ImgList, Vcl.Controls, System.ImageList;

type
  TdtmImagens = class(TDataModule)
    iml16x16: TImageList;
    iml24x24: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dtmImagens: TdtmImagens;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
