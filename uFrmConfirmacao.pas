unit uFrmConfirmacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, uPontoDB, uAlarmeSom;

type
  TFrmConfirmacao = class(TForm)
    lblMensagem: TLabel;
    btnConfirmar: TButton;
    btnSilenciar: TButton;
    tmrBeep: TTimer;
    procedure FormShow(Sender: TObject);
    procedure tmrBeepTimer(Sender: TObject);
    procedure btnConfirmarClick(Sender: TObject);
    procedure btnSilenciarClick(Sender: TObject);
  private
    FTipoBatida: string;
    FConfigSom: TConfigSom;
    FAlarmeUnicoId: Integer;
  public
    procedure Preparar(const ATipoBatida: string; AHorario: TTime; AAlarmeUnicoId: Integer = 0);
  end;

implementation

{$R *.dfm}

procedure TFrmConfirmacao.Preparar(const ATipoBatida: string; AHorario: TTime;
  AAlarmeUnicoId: Integer);
begin
  FTipoBatida := ATipoBatida;
  FAlarmeUnicoId := AAlarmeUnicoId;
  lblMensagem.Caption := Format('Voc'#234' esqueceu de registrar:'#13#10'%s (previsto para %s)',
    [DescricaoTipoBatida(ATipoBatida), FormatDateTime('hh:nn', AHorario)]);
  // Le a configuracao do som UMA VEZ aqui - o timer do beep so reproduz o
  // que ja foi lido, sem voltar a consultar o banco a cada 1,5s.
  FConfigSom := ObterConfigSom;
end;

procedure TFrmConfirmacao.FormShow(Sender: TObject);
begin
  IniciarAlarme(FConfigSom);
  tmrBeep.Enabled := True;
end;

procedure TFrmConfirmacao.tmrBeepTimer(Sender: TObject);
begin
  ContinuarAlarme(FConfigSom);
end;

procedure TFrmConfirmacao.btnSilenciarClick(Sender: TObject);
begin
  tmrBeep.Enabled := False;
  PararAlarme;
end;

procedure TFrmConfirmacao.btnConfirmarClick(Sender: TObject);
begin
  tmrBeep.Enabled := False;
  PararAlarme;
  TPontoDB.RegistrarBatida(FTipoBatida, ORIGEM_AUTOMATICO);
  if FAlarmeUnicoId <> 0 then
    TPontoDB.ExcluirAlarmeUnico(FAlarmeUnicoId);
  ModalResult := mrOk;
end;

end.
