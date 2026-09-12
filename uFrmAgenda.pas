unit uFrmAgenda;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Variants,
  System.Classes, System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.Grids, uPontoDB;

type
  TFrmAgenda = class(TForm)
    pgcPrincipal: TPageControl;
    tsHistorico: TTabSheet;
    tsAgenda: TTabSheet;
    pnlFiltroHistorico: TPanel;
    lblPeriodo: TLabel;
    dtHistDe: TDateTimePicker;
    lblPeriodoAte: TLabel;
    dtHistAte: TDateTimePicker;
    btnFiltrarHistorico: TButton;
    btnHoje: TButton;
    btnEstaSemana: TButton;
    btnAdicionarManual: TButton;
    btnEditarHistorico: TButton;
    sgHistorico: TStringGrid;
    mnuHistorico: TPopupMenu;
    miExcluirHistorico: TMenuItem;
    pnlRodapeHistorico: TPanel;
    pnlCardTotal: TPanel;
    lblCardTotal: TLabel;
    lblCardMeta: TLabel;
    lblCardFalta: TLabel;
    lblCardPrevisao: TLabel;
    btnCriarAlarme: TButton;
    lvAgendas: TListView;
    lvAlarmesUnicos: TListView;
    mnuAlarmesUnicos: TPopupMenu;
    miExcluirAlarmeUnico: TMenuItem;
    pnlRodape: TPanel;
    btnNovo: TButton;
    btnEditar: TButton;
    btnExcluir: TButton;
    btnConfiguracoes: TButton;
    lblTotal: TLabel;
    tmrMonitor: TTimer;
    trayIcon: TTrayIcon;
    mnuBandeja: TPopupMenu;
    miAbrir: TMenuItem;
    miSair: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pgcPrincipalChange(Sender: TObject);
    procedure btnFiltrarHistoricoClick(Sender: TObject);
    procedure btnHojeClick(Sender: TObject);
    procedure btnEstaSemanaClick(Sender: TObject);
    procedure btnAdicionarManualClick(Sender: TObject);
    procedure btnEditarHistoricoClick(Sender: TObject);
    procedure sgHistoricoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgHistoricoDblClick(Sender: TObject);
    procedure miExcluirHistoricoClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnConfiguracoesClick(Sender: TObject);
    procedure lvAgendasDblClick(Sender: TObject);
    procedure btnCriarAlarmeClick(Sender: TObject);
    procedure lvAlarmesUnicosDblClick(Sender: TObject);
    procedure lvAlarmesUnicosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miExcluirAlarmeUnicoClick(Sender: TObject);
    procedure tmrMonitorTimer(Sender: TObject);
    procedure trayIconDblClick(Sender: TObject);
    procedure miAbrirClick(Sender: TObject);
    procedure miSairClick(Sender: TObject);
  private
    FSaindo: Boolean;
    FRegistros: TArray<TRegistroPonto>;
    FPrevisaoValida: Boolean;
    FPrevisaoDataHora: TDateTime;
    FPrevisaoTipo: string;
    procedure CarregarGrid;
    procedure CarregarHistorico;
    procedure CarregarAlarmesUnicos;
    procedure EditarAlarmeUnicoSelecionado;
    function FiltroRepresentaUmDia: Boolean;
    procedure AtualizarCardTotais;
    procedure EditarRegistroSelecionado;
    procedure AbrirEdicao(AAgendaId: Integer);
    procedure VerificarBatida(AHorario: TTime; const ATipo: string; AToleranciaMin: Integer);
    procedure VerificarParBatidas(AEntradaAgenda, ASaidaAgenda: TTime;
      const ATipoEntrada, ATipoSaida: string; AToleranciaMin: Integer);
    procedure VerificarAlarmesUnicos(AToleranciaMin: Integer);
    procedure DispararAlarme(const ATipo: string; AHorario: TTime; AAlarmeUnicoId: Integer = 0);
    procedure AbrirExecutavelPonto;
  end;

var
  FrmAgenda: TFrmAgenda;

implementation

{$R *.dfm}

uses
  uFrmAgendaItem, uFrmConfig, uFrmConfirmacao, uFrmRegistroManual, uFrmAlarmeUnico;

function DiaSemanaAtual: Integer;
begin
  // Delphi: DayOfWeek = 1 (Dom) .. 7 (Sab). Nosso padrao: 1 (Seg) .. 7 (Dom).
  Result := ((DayOfWeek(Now) + 5) mod 7) + 1;
end;

function ContemDia(const ADias: TArray<Integer>; ADia: Integer): Boolean;
var
  D: Integer;
begin
  for D in ADias do
    if D = ADia then
      Exit(True);
  Result := False;
end;

procedure TFrmAgenda.FormCreate(Sender: TObject);
begin
  TPontoDB.Inicializar;
  CarregarGrid;
  CarregarAlarmesUnicos;
  sgHistorico.Cells[0, 0] := 'Data';
  sgHistorico.Cells[1, 0] := 'Hora';
  sgHistorico.Cells[2, 0] := 'Batida';
  sgHistorico.Cells[3, 0] := 'Origem';
  btnHojeClick(Sender);
  pgcPrincipal.ActivePage := tsHistorico;
  trayIcon.Icon := Application.Icon;
  trayIcon.Visible := True;
end;

procedure TFrmAgenda.pgcPrincipalChange(Sender: TObject);
begin
  if pgcPrincipal.ActivePage = tsHistorico then
    CarregarHistorico;
end;

procedure TFrmAgenda.btnFiltrarHistoricoClick(Sender: TObject);
begin
  CarregarHistorico;
end;

procedure TFrmAgenda.btnHojeClick(Sender: TObject);
begin
  dtHistDe.Date := Date;
  dtHistAte.Date := Date;
  CarregarHistorico;
end;

procedure TFrmAgenda.btnEstaSemanaClick(Sender: TObject);
begin
  // DiaSemanaAtual: 1=Seg..7=Dom - volta ate a segunda-feira da semana atual
  dtHistDe.Date := Date - (DiaSemanaAtual - 1);
  dtHistAte.Date := Date;
  CarregarHistorico;
end;

function TFrmAgenda.FiltroRepresentaUmDia: Boolean;
begin
  // Sem registros ainda (ex: "Hoje" logo de manha), usa o proprio intervalo
  // escolhido no filtro; com registros, confia nas datas deles (assim um
  // filtro manual que so trouxe resultado de 1 dia tambem conta).
  if Length(FRegistros) = 0 then
    Result := Trunc(dtHistDe.Date) = Trunc(dtHistAte.Date)
  else
    Result := TodosRegistrosMesmoDia(FRegistros);
end;

procedure TFrmAgenda.AtualizarCardTotais;
var
  Total, Meta, Falta: Double;
  HorarioAbertura, Previsao: TDateTime;
  TipoSaidaEsperado: string;
begin
  Total := TotalHorasRegistradas(FRegistros);

  if FiltroRepresentaUmDia then
  begin
    Meta := ObterMetaHorasDia;
    Falta := Meta - Total;
    lblCardTotal.Caption := 'Registrado: ' + FormatarHoras(Total);
    lblCardMeta.Caption := 'Meta di'#225'ria: ' + FormatarHoras(Meta);
    if Falta > 0 then
      lblCardFalta.Caption := 'Falta: ' + FormatarHoras(Falta)
    else
      lblCardFalta.Caption := 'Meta batida!';
    lblCardMeta.Visible := True;
    lblCardFalta.Visible := True;

    FPrevisaoValida := False;
    if ObterSessaoAberta(FRegistros, HorarioAbertura, TipoSaidaEsperado) then
    begin
      if Falta <= 0 then
        lblCardPrevisao.Caption := DescricaoTipoBatida(TipoSaidaEsperado) +
          ': meta j'#225' atingida, pode encerrar quando quiser'
      else
      begin
        Previsao := HorarioAbertura + (Falta / 24);
        lblCardPrevisao.Caption := 'Previs'#227'o ' + DescricaoTipoBatida(TipoSaidaEsperado) +
          ': ' + FormatDateTime('hh:nn', Previsao);
        // So faz sentido oferecer "Criar alarme" quando ha um horario de
        // verdade sugerido (nao quando a meta ja foi batida).
        FPrevisaoValida := True;
        FPrevisaoDataHora := Previsao;
        FPrevisaoTipo := TipoSaidaEsperado;
      end;
      lblCardPrevisao.Visible := True;
    end
    else
      lblCardPrevisao.Visible := False;
    btnCriarAlarme.Visible := FPrevisaoValida;
  end
  else
  begin
    lblCardTotal.Caption := 'Total de horas no per'#237'odo: ' + FormatarHoras(Total);
    lblCardMeta.Visible := False;
    lblCardFalta.Visible := False;
    lblCardPrevisao.Visible := False;
    btnCriarAlarme.Visible := False;
  end;
end;

procedure TFrmAgenda.CarregarHistorico;
var
  I: Integer;
begin
  FRegistros := TPontoDB.ListarRegistros(dtHistDe.Date, dtHistAte.Date);

  // FixedRows (1) precisa ser sempre menor que RowCount, entao com 0
  // registros a grade fica com 1 linha em branco em vez de nenhuma.
  if Length(FRegistros) = 0 then
  begin
    sgHistorico.RowCount := 2;
    sgHistorico.Cells[0, 1] := '';
    sgHistorico.Cells[1, 1] := '';
    sgHistorico.Cells[2, 1] := '';
    sgHistorico.Cells[3, 1] := '';
  end
  else
  begin
    sgHistorico.RowCount := Length(FRegistros) + 1;
    for I := 0 to High(FRegistros) do
    begin
      sgHistorico.Cells[0, I + 1] := FormatDateTime('dd/mm/yyyy', FRegistros[I].DataHora);
      sgHistorico.Cells[1, I + 1] := FormatDateTime('hh:nn', FRegistros[I].DataHora);
      sgHistorico.Cells[2, I + 1] := DescricaoTipoBatida(FRegistros[I].TipoBatida);
      sgHistorico.Cells[3, I + 1] := FRegistros[I].Origem;
    end;
  end;

  AtualizarCardTotais;
end;

procedure TFrmAgenda.btnCriarAlarmeClick(Sender: TObject);
var
  Frm: TFrmAlarmeUnico;
begin
  if not FPrevisaoValida then
    Exit;
  Frm := TFrmAlarmeUnico.Create(Self);
  try
    Frm.PrepararNovo(FPrevisaoDataHora, FPrevisaoTipo);
    if Frm.ShowModal = mrOk then
      CarregarAlarmesUnicos;
  finally
    Frm.Free;
  end;
end;

procedure TFrmAgenda.CarregarAlarmesUnicos;
var
  Alarmes: TArray<TAlarmeUnico>;
  A: TAlarmeUnico;
  Item: TListItem;
begin
  lvAlarmesUnicos.Items.BeginUpdate;
  try
    lvAlarmesUnicos.Items.Clear;
    Alarmes := TPontoDB.ListarAlarmesUnicosFuturos;
    for A in Alarmes do
    begin
      Item := lvAlarmesUnicos.Items.Add;
      Item.Caption := FormatDateTime('dd/mm/yyyy', A.DataHora);
      Item.SubItems.Add(FormatDateTime('hh:nn', A.DataHora));
      Item.SubItems.Add(DescricaoTipoBatida(A.TipoBatida));
      Item.Data := Pointer(A.Id);
    end;
  finally
    lvAlarmesUnicos.Items.EndUpdate;
  end;
end;

procedure TFrmAgenda.EditarAlarmeUnicoSelecionado;
var
  A: TAlarmeUnico;
  Id: Integer;
  Frm: TFrmAlarmeUnico;
begin
  if not Assigned(lvAlarmesUnicos.Selected) then
    Exit;
  Id := Integer(lvAlarmesUnicos.Selected.Data);
  for A in TPontoDB.ListarAlarmesUnicosFuturos do
    if A.Id = Id then
    begin
      Frm := TFrmAlarmeUnico.Create(Self);
      try
        Frm.PrepararEdicao(A);
        if Frm.ShowModal = mrOk then
          CarregarAlarmesUnicos;
      finally
        Frm.Free;
      end;
      Exit;
    end;
end;

procedure TFrmAgenda.lvAlarmesUnicosDblClick(Sender: TObject);
begin
  EditarAlarmeUnicoSelecionado;
end;

procedure TFrmAgenda.lvAlarmesUnicosMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
begin
  if Button = mbRight then
  begin
    Item := lvAlarmesUnicos.GetItemAt(X, Y);
    if Assigned(Item) then
      Item.Selected := True;
  end;
end;

procedure TFrmAgenda.miExcluirAlarmeUnicoClick(Sender: TObject);
var
  Id: Integer;
begin
  if not Assigned(lvAlarmesUnicos.Selected) then
    Exit;
  if MessageDlg('Excluir este alarme '#250'nico?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  Id := Integer(lvAlarmesUnicos.Selected.Data);
  TPontoDB.ExcluirAlarmeUnico(Id);
  CarregarAlarmesUnicos;
end;

procedure TFrmAgenda.btnAdicionarManualClick(Sender: TObject);
var
  Frm: TFrmRegistroManual;
begin
  Frm := TFrmRegistroManual.Create(Self);
  try
    if Frm.ShowModal = mrOk then
      CarregarHistorico;
  finally
    Frm.Free;
  end;
end;

procedure TFrmAgenda.EditarRegistroSelecionado;
var
  Idx: Integer;
  Frm: TFrmRegistroManual;
begin
  Idx := sgHistorico.Row - 1;
  if (Idx < 0) or (Idx > High(FRegistros)) then
  begin
    ShowMessage('Selecione um registro na lista.');
    Exit;
  end;
  Frm := TFrmRegistroManual.Create(Self);
  try
    Frm.PrepararEdicao(FRegistros[Idx]);
    if Frm.ShowModal = mrOk then
      CarregarHistorico;
  finally
    Frm.Free;
  end;
end;

procedure TFrmAgenda.btnEditarHistoricoClick(Sender: TObject);
begin
  EditarRegistroSelecionado;
end;

procedure TFrmAgenda.sgHistoricoDblClick(Sender: TObject);
begin
  EditarRegistroSelecionado;
end;

procedure TFrmAgenda.sgHistoricoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
begin
  // Garante que o botao direito selecione a linha sob o cursor antes do
  // menu de contexto abrir (senao o "Excluir" agiria na selecao antiga).
  if Button = mbRight then
  begin
    sgHistorico.MouseToCell(X, Y, ACol, ARow);
    if ARow >= 1 then
      sgHistorico.Row := ARow;
  end;
end;

procedure TFrmAgenda.miExcluirHistoricoClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := sgHistorico.Row - 1;
  if (Idx < 0) or (Idx > High(FRegistros)) then
    Exit;
  if MessageDlg('Excluir este registro do hist'#243'rico?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  TPontoDB.ExcluirRegistro(FRegistros[Idx].Id);
  CarregarHistorico;
end;

procedure TFrmAgenda.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FSaindo then
    Exit;
  CanClose := False;
  Hide;
end;

procedure TFrmAgenda.trayIconDblClick(Sender: TObject);
begin
  miAbrirClick(Sender);
end;

procedure TFrmAgenda.miAbrirClick(Sender: TObject);
begin
  Show;
  WindowState := wsNormal;
  Application.BringToFront;
end;

procedure TFrmAgenda.miSairClick(Sender: TObject);
begin
  FSaindo := True;
  Close;
end;

procedure TFrmAgenda.CarregarGrid;
var
  Agendas: TArray<TAgenda>;
  A: TAgenda;
  Item: TListItem;
begin
  lvAgendas.Items.BeginUpdate;
  try
    lvAgendas.Items.Clear;
    Agendas := TPontoDB.ListarAgendas;
    for A in Agendas do
    begin
      Item := lvAgendas.Items.Add;
      Item.Caption := DescricaoDias(A.Dias);
      Item.SubItems.Add(FormatDateTime('hh:nn', A.Entrada1));
      Item.SubItems.Add(FormatDateTime('hh:nn', A.Saida1));
      if A.TemSegundoPar then
      begin
        Item.SubItems.Add(FormatDateTime('hh:nn', A.Entrada2));
        Item.SubItems.Add(FormatDateTime('hh:nn', A.Saida2));
      end
      else
      begin
        Item.SubItems.Add('-');
        Item.SubItems.Add('-');
      end;
      if A.TemTerceiroPar then
      begin
        Item.SubItems.Add(FormatDateTime('hh:nn', A.Entrada3));
        Item.SubItems.Add(FormatDateTime('hh:nn', A.Saida3));
      end
      else
      begin
        Item.SubItems.Add('-');
        Item.SubItems.Add('-');
      end;
      Item.SubItems.Add(FormatarHoras(HorasDoDia(A)));
      if HorasDoDia(A) + 0.0001 >= ObterMetaHorasDia then
        Item.SubItems.Add('OK')
      else
        Item.SubItems.Add('Abaixo da meta');
      Item.Data := Pointer(A.Id);
    end;
  finally
    lvAgendas.Items.EndUpdate;
  end;
  lblTotal.Caption := 'Total semanal: ' + FormatarHoras(TPontoDB.TotalHorasSemanais);
end;

procedure TFrmAgenda.AbrirEdicao(AAgendaId: Integer);
var
  Frm: TFrmAgendaItem;
begin
  Frm := TFrmAgendaItem.Create(Self);
  try
    Frm.CarregarAgenda(AAgendaId);
    if Frm.ShowModal = mrOk then
      CarregarGrid;
  finally
    Frm.Free;
  end;
end;

procedure TFrmAgenda.btnNovoClick(Sender: TObject);
begin
  AbrirEdicao(0);
end;

procedure TFrmAgenda.btnEditarClick(Sender: TObject);
begin
  if Assigned(lvAgendas.Selected) then
    AbrirEdicao(Integer(lvAgendas.Selected.Data))
  else
    ShowMessage('Selecione uma agenda na lista.');
end;

procedure TFrmAgenda.btnExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  if not Assigned(lvAgendas.Selected) then
  begin
    ShowMessage('Selecione uma agenda na lista.');
    Exit;
  end;
  if MessageDlg('Excluir esta agenda?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  Id := Integer(lvAgendas.Selected.Data);
  TPontoDB.ExcluirAgenda(Id);
  CarregarGrid;
end;

procedure TFrmAgenda.btnConfiguracoesClick(Sender: TObject);
var
  Frm: TFrmConfig;
begin
  Frm := TFrmConfig.Create(Self);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

procedure TFrmAgenda.lvAgendasDblClick(Sender: TObject);
begin
  btnEditarClick(Sender);
end;

procedure TFrmAgenda.tmrMonitorTimer(Sender: TObject);
var
  DiaHoje: Integer;
  Agendas: TArray<TAgenda>;
  A, AgendaHoje: TAgenda;
  ToleranciaMin: Integer;
  TemAgendaHoje: Boolean;
begin
  ToleranciaMin := StrToIntDef(TPontoDB.ObterConfig(CFG_TOLERANCIA_MIN, '2'), 2);

  // Alarmes avulsos sao independentes da agenda semanal - verifica sempre,
  // mesmo em dias sem nenhuma agenda recorrente.
  VerificarAlarmesUnicos(ToleranciaMin);

  DiaHoje := DiaSemanaAtual;
  TemAgendaHoje := False;
  Agendas := TPontoDB.ListarAgendas;
  for A in Agendas do
    if A.Ativo and ContemDia(A.Dias, DiaHoje) then
    begin
      AgendaHoje := A;
      TemAgendaHoje := True;
      Break;
    end;

  if not TemAgendaHoje then
    Exit;

  VerificarParBatidas(AgendaHoje.Entrada1, AgendaHoje.Saida1, TIPO_ENTRADA1, TIPO_SAIDA1,
    ToleranciaMin);
  if AgendaHoje.TemSegundoPar then
    VerificarParBatidas(AgendaHoje.Entrada2, AgendaHoje.Saida2, TIPO_ENTRADA2, TIPO_SAIDA2,
      ToleranciaMin);
  if AgendaHoje.TemTerceiroPar then
    VerificarParBatidas(AgendaHoje.Entrada3, AgendaHoje.Saida3, TIPO_ENTRADA3, TIPO_SAIDA3,
      ToleranciaMin);
end;

procedure TFrmAgenda.VerificarParBatidas(AEntradaAgenda, ASaidaAgenda: TTime;
  const ATipoEntrada, ATipoSaida: string; AToleranciaMin: Integer);
var
  HorarioRealEntrada: TDateTime;
  DuracaoPadrao: Double;
  SaidaEfetiva: TTime;
begin
  VerificarBatida(AEntradaAgenda, ATipoEntrada, AToleranciaMin);

  // So cobra a saida depois que a entrada desse turno realmente aconteceu -
  // e se ela atrasou (ex: dia com horario especial), a saida esperada
  // desliza junto, usando a duracao padrao do proprio turno (vinda da
  // agenda) como referencia. Sem isso, um turno que comeca mais tarde do
  // que o normal fica "atrasado" pra saida antes mesmo de ter comecado.
  if not TPontoDB.ObterHorarioBatidaHoje(ATipoEntrada, HorarioRealEntrada) then
    Exit;

  DuracaoPadrao := ASaidaAgenda - AEntradaAgenda;
  SaidaEfetiva := Frac(HorarioRealEntrada) + DuracaoPadrao;
  if SaidaEfetiva < ASaidaAgenda then
    SaidaEfetiva := ASaidaAgenda; // nunca antecipa, so' atrasa se a entrada atrasou

  VerificarBatida(SaidaEfetiva, ATipoSaida, AToleranciaMin);
end;

procedure TFrmAgenda.VerificarBatida(AHorario: TTime; const ATipo: string;
  AToleranciaMin: Integer);
var
  MinutosAtraso: Double;
begin
  if TPontoDB.BatidaJaDisparadaHoje(ATipo) then
    Exit;

  // A tolerância abre uma pequena janela ANTES do horário (aviso alguns
  // minutos adiantado), mas sem limite superior de propósito: uma vez que o
  // horário chegou (ou passou) e a batida ainda não foi confirmada, ela
  // continua "devida" e o alarme dispara de novo a cada 30s até o usuário
  // confirmar - isso cobre tanto o disparo no horário certo quanto o
  // lembrete de bater esquecida (o timer fica parado enquanto outro aviso
  // está na tela, então sem isso essa batida ficaria pra sempre sem avisar).
  MinutosAtraso := (Time - AHorario) * 24 * 60;
  if MinutosAtraso >= -AToleranciaMin then
    DispararAlarme(ATipo, AHorario);
end;

procedure TFrmAgenda.VerificarAlarmesUnicos(AToleranciaMin: Integer);
var
  Alarmes: TArray<TAlarmeUnico>;
  A: TAlarmeUnico;
  MinutosAtraso: Double;
begin
  // Nao reaproveita VerificarBatida aqui de proposito: alarme unico tem
  // DATA marcada (nao so hora, pode ser um dia diferente de hoje) e "ja
  // disparou" e' simplesmente a linha nao existir mais (apagada ao
  // confirmar) - usar BatidaJaDisparadaHoje aqui poderia silenciar o
  // alarme por causa de uma batida da agenda recorrente do mesmo tipo, sem
  // nunca confirmar (e apagar) o alarme unico de verdade.
  Alarmes := TPontoDB.ListarAlarmesUnicos;
  for A in Alarmes do
  begin
    MinutosAtraso := (Now - A.DataHora) * 24 * 60;
    if MinutosAtraso >= -AToleranciaMin then
      DispararAlarme(A.TipoBatida, Frac(A.DataHora), A.Id);
  end;
end;

procedure TFrmAgenda.AbrirExecutavelPonto;
var
  Caminho: string;
begin
  if not DeveExecutarPrograma then
    Exit;
  Caminho := TPontoDB.ObterConfig(CFG_CAMINHO_EXE, '');
  if (Caminho <> '') and FileExists(Caminho) then
    ShellExecute(0, 'open', PChar(Caminho), '', '', SW_SHOWNORMAL);
end;

procedure TFrmAgenda.DispararAlarme(const ATipo: string; AHorario: TTime;
  AAlarmeUnicoId: Integer);
var
  Frm: TFrmConfirmacao;
begin
  // O TTimer continua entregando WM_TIMER mesmo dentro do loop de mensagens
  // do ShowModal - sem desligar aqui, cada novo tick reabriria outro alarme
  // para a mesma batida enquanto o usuario ainda nao confirmou a anterior.
  tmrMonitor.Enabled := False;
  try
    AbrirExecutavelPonto;
    Frm := TFrmConfirmacao.Create(Self);
    try
      Frm.Preparar(ATipo, AHorario, AAlarmeUnicoId);
      Frm.ShowModal;
    finally
      Frm.Free;
    end;
  finally
    tmrMonitor.Enabled := True;
  end;
end;

end.
