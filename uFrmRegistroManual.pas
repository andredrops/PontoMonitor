unit uFrmRegistroManual;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, uPontoDB;

type
  TFrmRegistroManual = class(TForm)
    lblData: TLabel;
    dtData: TDateTimePicker;
    lblHora: TLabel;
    dtHora: TDateTimePicker;
    lblTipo: TLabel;
    cbTipo: TComboBox;
    lblOrigem: TLabel;
    edtOrigem: TEdit;
    btnOK: TButton;
    btnCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FRegistroId: Integer;
  public
    procedure PrepararEdicao(const R: TRegistroPonto);
  end;

implementation

{$R *.dfm}

const
  TiposBatida: array[0..5] of string = (TIPO_ENTRADA1, TIPO_SAIDA1, TIPO_ENTRADA2, TIPO_SAIDA2,
    TIPO_ENTRADA3, TIPO_SAIDA3);

procedure TFrmRegistroManual.FormCreate(Sender: TObject);
begin
  FRegistroId := 0;
  dtData.Date := Date;
  dtHora.Time := Time;
  cbTipo.ItemIndex := 0;
  edtOrigem.Text := ORIGEM_MANUAL;
end;

procedure TFrmRegistroManual.PrepararEdicao(const R: TRegistroPonto);
var
  I: Integer;
begin
  FRegistroId := R.Id;
  Caption := 'Editar registro';
  dtData.Date := Trunc(R.DataHora);
  dtHora.Time := Frac(R.DataHora);
  cbTipo.ItemIndex := 0;
  for I := 0 to High(TiposBatida) do
    if TiposBatida[I] = R.TipoBatida then
    begin
      cbTipo.ItemIndex := I;
      Break;
    end;
  edtOrigem.Text := R.Origem;
end;

procedure TFrmRegistroManual.btnOKClick(Sender: TObject);
var
  DataHora: TDateTime;
  Origem: string;
begin
  if cbTipo.ItemIndex < 0 then
  begin
    ShowMessage('Selecione o tipo de batida.');
    Exit;
  end;

  DataHora := dtData.Date + Frac(dtHora.Time);
  Origem := edtOrigem.Text;
  if Origem = '' then
    Origem := ORIGEM_MANUAL;

  if FRegistroId = 0 then
    TPontoDB.InserirRegistroManual(DataHora, TiposBatida[cbTipo.ItemIndex], Origem)
  else
    TPontoDB.AtualizarRegistro(FRegistroId, DataHora, TiposBatida[cbTipo.ItemIndex], Origem);

  ModalResult := mrOk;
end;

end.
