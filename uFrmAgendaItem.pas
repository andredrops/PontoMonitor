unit uFrmAgendaItem;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.CheckLst, Vcl.ExtCtrls, System.Generics.Collections, uPontoDB, uFrmConfig;

type
  TFrmAgendaItem = class(TForm)
    clbDias: TCheckListBox;
    lblDias: TLabel;
    lblEntrada1: TLabel;
    dtEntrada1: TDateTimePicker;
    lblSaida1: TLabel;
    dtSaida1: TDateTimePicker;
    lblParcial1: TLabel;
    chkSegundoPar: TCheckBox;
    lblEntrada2: TLabel;
    dtEntrada2: TDateTimePicker;
    lblSaida2: TLabel;
    dtSaida2: TDateTimePicker;
    lblParcial2: TLabel;
    chkTerceiroPar: TCheckBox;
    lblEntrada3: TLabel;
    dtEntrada3: TDateTimePicker;
    lblSaida3: TLabel;
    dtSaida3: TDateTimePicker;
    lblParcial3: TLabel;
    lblHorasCalculadas: TLabel;
    btnOK: TButton;
    btnCancelar: TButton;
    procedure chkSegundoParClick(Sender: TObject);
    procedure chkTerceiroParClick(Sender: TObject);
    procedure AtualizarHorasCalculadas(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FAgendaId: Integer;
    function MontarAgenda: TAgenda;
  public
    procedure CarregarAgenda(AId: Integer);
  end;

implementation

{$R *.dfm}

procedure TFrmAgendaItem.CarregarAgenda(AId: Integer);
var
  Agendas: TArray<TAgenda>;
  A: TAgenda;
  D: Integer;
begin
  FAgendaId := AId;

  for D := 1 to 7 do
  begin
    clbDias.Checked[D - 1] := False;
    clbDias.ItemEnabled[D - 1] := TPontoDB.DiaEstaLivre(D, AId);
  end;

  dtEntrada1.Time := StrToTime('07:00');
  dtSaida1.Time := StrToTime('09:00');
  dtEntrada2.Time := StrToTime('16:00');
  dtSaida2.Time := StrToTime('18:00');
  dtEntrada3.Time := StrToTime('19:00');
  dtSaida3.Time := StrToTime('21:00');
  chkSegundoPar.Checked := False;
  chkTerceiroPar.Checked := False;

  if AId <> 0 then
  begin
    Agendas := TPontoDB.ListarAgendas;
    for A in Agendas do
      if A.Id = AId then
      begin
        for D in A.Dias do
          clbDias.Checked[D - 1] := True;
        dtEntrada1.Time := A.Entrada1;
        dtSaida1.Time := A.Saida1;
        chkSegundoPar.Checked := A.TemSegundoPar;
        if A.TemSegundoPar then
        begin
          dtEntrada2.Time := A.Entrada2;
          dtSaida2.Time := A.Saida2;
        end;
        chkTerceiroPar.Checked := A.TemTerceiroPar;
        if A.TemTerceiroPar then
        begin
          dtEntrada3.Time := A.Entrada3;
          dtSaida3.Time := A.Saida3;
        end;
        Break;
      end;
  end;

  chkSegundoParClick(nil);
  chkTerceiroParClick(nil);
  AtualizarHorasCalculadas(nil);
end;

function TFrmAgendaItem.MontarAgenda: TAgenda;
var
  D: Integer;
  Dias: TList<Integer>;
begin
  Result.Id := FAgendaId;
  // TDateTimePicker.Time devolve a data+hora inteira internamente, nao so a
  // fracao do horario - por isso o Frac() aqui (sem ele os calculos que
  // multiplicam por 24, como a meta, davam numeros absurdos).
  Result.Entrada1 := Frac(dtEntrada1.Time);
  Result.Saida1 := Frac(dtSaida1.Time);
  Result.TemSegundoPar := chkSegundoPar.Checked;
  if Result.TemSegundoPar then
  begin
    Result.Entrada2 := Frac(dtEntrada2.Time);
    Result.Saida2 := Frac(dtSaida2.Time);
  end
  else
  begin
    Result.Entrada2 := 0;
    Result.Saida2 := 0;
  end;
  // Terceiro par so existe se o segundo tambem existir (turnos sequenciais)
  Result.TemTerceiroPar := Result.TemSegundoPar and chkTerceiroPar.Checked;
  if Result.TemTerceiroPar then
  begin
    Result.Entrada3 := Frac(dtEntrada3.Time);
    Result.Saida3 := Frac(dtSaida3.Time);
  end
  else
  begin
    Result.Entrada3 := 0;
    Result.Saida3 := 0;
  end;
  Result.Ativo := True;

  Dias := TList<Integer>.Create;
  try
    for D := 1 to 7 do
      if clbDias.Checked[D - 1] then
        Dias.Add(D);
    Result.Dias := Dias.ToArray;
  finally
    Dias.Free;
  end;
end;

procedure TFrmAgendaItem.chkSegundoParClick(Sender: TObject);
begin
  dtEntrada2.Enabled := chkSegundoPar.Checked;
  dtSaida2.Enabled := chkSegundoPar.Checked;
  lblParcial2.Visible := chkSegundoPar.Checked;

  // Sem segundo par nao faz sentido ter terceiro (turnos sequenciais)
  chkTerceiroPar.Enabled := chkSegundoPar.Checked;
  if not chkSegundoPar.Checked then
    chkTerceiroPar.Checked := False;

  chkTerceiroParClick(Sender);
end;

procedure TFrmAgendaItem.chkTerceiroParClick(Sender: TObject);
begin
  dtEntrada3.Enabled := chkTerceiroPar.Checked;
  dtSaida3.Enabled := chkTerceiroPar.Checked;
  lblParcial3.Visible := chkTerceiroPar.Checked;
  AtualizarHorasCalculadas(Sender);
end;

procedure TFrmAgendaItem.AtualizarHorasCalculadas(Sender: TObject);
var
  A: TAgenda;
begin
  A := MontarAgenda;
  lblParcial1.Caption := FormatarHoras((A.Saida1 - A.Entrada1) * 24);
  if A.TemSegundoPar then
    lblParcial2.Caption := FormatarHoras((A.Saida2 - A.Entrada2) * 24);
  if A.TemTerceiroPar then
    lblParcial3.Caption := FormatarHoras((A.Saida3 - A.Entrada3) * 24);
  lblHorasCalculadas.Caption := 'Horas por dia: ' + FormatarHoras(HorasDoDia(A));
end;

procedure TFrmAgendaItem.btnOKClick(Sender: TObject);
var
  A: TAgenda;
  Meta: Double;
begin
  A := MontarAgenda;

  if Length(A.Dias) = 0 then
  begin
    ShowMessage('Selecione ao menos um dia da semana.');
    Exit;
  end;

  if A.Saida1 <= A.Entrada1 then
  begin
    ShowMessage('A sa'#237'da 1 deve ser depois da entrada 1.');
    Exit;
  end;

  if A.TemSegundoPar then
  begin
    if A.Saida2 <= A.Entrada2 then
    begin
      ShowMessage('A sa'#237'da 2 deve ser depois da entrada 2.');
      Exit;
    end;
    if A.Entrada2 < A.Saida1 then
    begin
      ShowMessage('A entrada 2 deve ser depois (ou igual) da sa'#237'da 1.');
      Exit;
    end;
  end;

  if A.TemTerceiroPar then
  begin
    if A.Saida3 <= A.Entrada3 then
    begin
      ShowMessage('A sa'#237'da 3 deve ser depois da entrada 3.');
      Exit;
    end;
    if A.Entrada3 < A.Saida2 then
    begin
      ShowMessage('A entrada 3 deve ser depois (ou igual) da sa'#237'da 2.');
      Exit;
    end;
  end;

  Meta := ObterMetaHorasDia;
  if HorasDoDia(A) + 0.0001 < Meta then
  begin
    if MessageDlg(Format('Essa combina'#231#227'o soma %s, abaixo da meta de %s por dia ' +
      '(configurada em Configura'#231#245'es).'#13#10#13#10'Gravar mesmo assim?',
      [FormatarHoras(HorasDoDia(A)), FormatarHoras(Meta)]), mtWarning, [mbYes, mbNo], 0) <> mrYes then
      Exit;
  end;

  if FAgendaId = 0 then
    TPontoDB.InserirAgenda(A)
  else
  begin
    A.Id := FAgendaId;
    TPontoDB.AtualizarAgenda(A);
  end;

  ModalResult := mrOk;
end;

end.
