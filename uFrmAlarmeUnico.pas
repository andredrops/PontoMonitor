unit uFrmAlarmeUnico;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, uPontoDB;

type
  TFrmAlarmeUnico = class(TForm)
    lblData: TLabel;
    dtData: TDateTimePicker;
    lblHora: TLabel;
    dtHora: TDateTimePicker;
    lblTipo: TLabel;
    cbTipo: TComboBox;
    btnOK: TButton;
    btnCancelar: TButton;
    procedure btnOKClick(Sender: TObject);
  private
    FAlarmeId: Integer;
  public
    procedure PrepararNovo(ADataHoraSugerida: TDateTime; const ATipoSugerido: string);
    procedure PrepararEdicao(const A: TAlarmeUnico);
  end;

implementation

{$R *.dfm}

const
  TiposBatida: array[0..5] of string = (TIPO_ENTRADA1, TIPO_SAIDA1, TIPO_ENTRADA2, TIPO_SAIDA2,
    TIPO_ENTRADA3, TIPO_SAIDA3);

procedure TFrmAlarmeUnico.PrepararNovo(ADataHoraSugerida: TDateTime; const ATipoSugerido: string);
var
  I: Integer;
begin
  FAlarmeId := 0;
  Caption := 'Criar alarme '#250'nico';
  dtData.Date := Trunc(ADataHoraSugerida);
  dtHora.Time := Frac(ADataHoraSugerida);
  cbTipo.ItemIndex := 0;
  for I := 0 to High(TiposBatida) do
    if TiposBatida[I] = ATipoSugerido then
    begin
      cbTipo.ItemIndex := I;
      Break;
    end;
end;

procedure TFrmAlarmeUnico.PrepararEdicao(const A: TAlarmeUnico);
var
  I: Integer;
begin
  FAlarmeId := A.Id;
  Caption := 'Editar alarme '#250'nico';
  dtData.Date := Trunc(A.DataHora);
  dtHora.Time := Frac(A.DataHora);
  cbTipo.ItemIndex := 0;
  for I := 0 to High(TiposBatida) do
    if TiposBatida[I] = A.TipoBatida then
    begin
      cbTipo.ItemIndex := I;
      Break;
    end;
end;

procedure TFrmAlarmeUnico.btnOKClick(Sender: TObject);
var
  DataHora: TDateTime;
begin
  if cbTipo.ItemIndex < 0 then
  begin
    ShowMessage('Selecione o tipo de batida.');
    Exit;
  end;

  DataHora := dtData.Date + Frac(dtHora.Time);
  if DataHora <= Now then
  begin
    ShowMessage('A data/hora do alarme deve ser no futuro.');
    Exit;
  end;

  if FAlarmeId = 0 then
    TPontoDB.InserirAlarmeUnico(DataHora, TiposBatida[cbTipo.ItemIndex])
  else
    TPontoDB.AtualizarAlarmeUnico(FAlarmeId, DataHora, TiposBatida[cbTipo.ItemIndex]);

  ModalResult := mrOk;
end;

end.
