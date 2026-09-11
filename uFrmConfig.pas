unit uFrmConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, System.Win.Registry, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Samples.Spin,
  uPontoDB, uAlarmeSom;

const
  CFG_CAMINHO_EXE = 'caminho_exe_ponto';
  CFG_EXECUTAR_PROGRAMA = 'executar_programa';
  CFG_TOLERANCIA_MIN = 'tolerancia_minutos';
  CFG_META_HORAS_DIA = 'meta_horas_dia';

  REG_RUN_KEY = 'Software\Microsoft\Windows\CurrentVersion\Run';
  REG_RUN_VALUE = 'PontoMonitor';

  IndiceComboSom: array[0..4] of string = (CHAVE_SOM_ASTERISCO, CHAVE_SOM_EXCLAMACAO,
    CHAVE_SOM_CRITICO, CHAVE_SOM_SIMPLES, CHAVE_SOM_MP3);

function IniciaComWindows: Boolean;
procedure DefinirIniciaComWindows(AAtivar: Boolean);
function ObterMetaHorasDia: Double;
function DeveExecutarPrograma: Boolean;

type
  TFrmConfig = class(TForm)
    chkExecutarPrograma: TCheckBox;
    lblCaminhoExe: TLabel;
    edtCaminhoExe: TEdit;
    btnProcurarExe: TButton;
    lblTolerancia: TLabel;
    seTolerancia: TSpinEdit;
    lblMetaHorasDia: TLabel;
    dtMetaHorasDia: TDateTimePicker;
    lblSom: TLabel;
    cbSom: TComboBox;
    btnTestarSom: TButton;
    edtSomMp3: TEdit;
    btnProcurarMp3: TButton;
    chkIniciarComWindows: TCheckBox;
    btnSalvar: TButton;
    btnFechar: TButton;
    dlgAbrirExe: TOpenDialog;
    dlgAbrirMp3: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure chkExecutarProgramaClick(Sender: TObject);
    procedure btnProcurarExeClick(Sender: TObject);
    procedure btnProcurarMp3Click(Sender: TObject);
    procedure cbSomChange(Sender: TObject);
    procedure btnTestarSomClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    procedure AtualizarCamposMp3;
    procedure AtualizarCamposExe;
  end;

implementation

{$R *.dfm}

function IniciaComWindows: Boolean;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Result := Reg.OpenKeyReadOnly(REG_RUN_KEY) and Reg.ValueExists(REG_RUN_VALUE);
  finally
    Reg.Free;
  end;
end;

procedure DefinirIniciaComWindows(AAtivar: Boolean);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(REG_RUN_KEY, True) then
    begin
      if AAtivar then
        Reg.WriteString(REG_RUN_VALUE, '"' + ParamStr(0) + '" /min')
      else if Reg.ValueExists(REG_RUN_VALUE) then
        Reg.DeleteValue(REG_RUN_VALUE);
    end;
  finally
    Reg.Free;
  end;
end;

function ObterMetaHorasDia: Double;
begin
  Result := StrToTimeDef(TPontoDB.ObterConfig(CFG_META_HORAS_DIA, '04:00'), StrToTime('04:00')) * 24;
end;

function DeveExecutarPrograma: Boolean;
begin
  Result := TPontoDB.ObterConfig(CFG_EXECUTAR_PROGRAMA, '1') = '1';
end;

procedure TFrmConfig.FormCreate(Sender: TObject);
var
  Chave: string;
  I: Integer;
begin
  chkExecutarPrograma.Checked := DeveExecutarPrograma;
  edtCaminhoExe.Text := TPontoDB.ObterConfig(CFG_CAMINHO_EXE, '');
  AtualizarCamposExe;
  seTolerancia.Value := StrToIntDef(TPontoDB.ObterConfig(CFG_TOLERANCIA_MIN, '2'), 2);
  dtMetaHorasDia.Time := StrToTimeDef(TPontoDB.ObterConfig(CFG_META_HORAS_DIA, '04:00'),
    StrToTime('04:00'));

  Chave := TPontoDB.ObterConfig(CFG_SOM_ALARME, CHAVE_SOM_ASTERISCO);
  cbSom.ItemIndex := 0;
  for I := 0 to High(IndiceComboSom) do
    if IndiceComboSom[I] = Chave then
    begin
      cbSom.ItemIndex := I;
      Break;
    end;
  edtSomMp3.Text := TPontoDB.ObterConfig(CFG_SOM_MP3_CAMINHO, '');

  chkIniciarComWindows.Checked := IniciaComWindows;
  AtualizarCamposMp3;
end;

procedure TFrmConfig.AtualizarCamposExe;
begin
  edtCaminhoExe.Enabled := chkExecutarPrograma.Checked;
  btnProcurarExe.Enabled := chkExecutarPrograma.Checked;
end;

procedure TFrmConfig.chkExecutarProgramaClick(Sender: TObject);
begin
  AtualizarCamposExe;
end;

procedure TFrmConfig.btnProcurarExeClick(Sender: TObject);
begin
  if edtCaminhoExe.Text <> '' then
    dlgAbrirExe.FileName := edtCaminhoExe.Text;
  if dlgAbrirExe.Execute then
    edtCaminhoExe.Text := dlgAbrirExe.FileName;
end;

procedure TFrmConfig.AtualizarCamposMp3;
var
  EhMp3: Boolean;
begin
  EhMp3 := cbSom.ItemIndex = 4;
  edtSomMp3.Enabled := EhMp3;
  btnProcurarMp3.Enabled := EhMp3;
end;

procedure TFrmConfig.cbSomChange(Sender: TObject);
begin
  AtualizarCamposMp3;
end;

procedure TFrmConfig.btnProcurarMp3Click(Sender: TObject);
begin
  if edtSomMp3.Text <> '' then
    dlgAbrirMp3.FileName := edtSomMp3.Text;
  if dlgAbrirMp3.Execute then
    edtSomMp3.Text := dlgAbrirMp3.FileName;
end;

procedure TFrmConfig.btnTestarSomClick(Sender: TObject);
begin
  if (cbSom.ItemIndex = 4) and (edtSomMp3.Text = '') then
  begin
    ShowMessage('Selecione um arquivo MP3 primeiro.');
    Exit;
  end;
  TPontoDB.SalvarConfig(CFG_SOM_ALARME, IndiceComboSom[cbSom.ItemIndex]);
  TPontoDB.SalvarConfig(CFG_SOM_MP3_CAMINHO, edtSomMp3.Text);
  TocarAlarme;
end;

procedure TFrmConfig.btnSalvarClick(Sender: TObject);
begin
  if chkExecutarPrograma.Checked then
  begin
    if edtCaminhoExe.Text = '' then
    begin
      ShowMessage('Informe o execut'#225'vel do ponto, ou desmarque "Executar um programa externo".');
      Exit;
    end;
    if not FileExists(edtCaminhoExe.Text) then
    begin
      if MessageDlg('O arquivo informado n'#227'o existe no caminho indicado. Salvar mesmo assim?',
        mtWarning, [mbYes, mbNo], 0) <> mrYes then
        Exit;
    end;
  end;

  if (cbSom.ItemIndex = 4) and (edtSomMp3.Text <> '') and not FileExists(edtSomMp3.Text) then
  begin
    ShowMessage('O arquivo MP3 informado n'#227'o existe.');
    Exit;
  end;

  if chkExecutarPrograma.Checked then
    TPontoDB.SalvarConfig(CFG_EXECUTAR_PROGRAMA, '1')
  else
    TPontoDB.SalvarConfig(CFG_EXECUTAR_PROGRAMA, '0');
  TPontoDB.SalvarConfig(CFG_CAMINHO_EXE, edtCaminhoExe.Text);
  TPontoDB.SalvarConfig(CFG_TOLERANCIA_MIN, IntToStr(seTolerancia.Value));
  TPontoDB.SalvarConfig(CFG_META_HORAS_DIA, FormatDateTime('hh:nn', dtMetaHorasDia.Time));
  TPontoDB.SalvarConfig(CFG_SOM_ALARME, IndiceComboSom[cbSom.ItemIndex]);
  TPontoDB.SalvarConfig(CFG_SOM_MP3_CAMINHO, edtSomMp3.Text);
  DefinirIniciaComWindows(chkIniciarComWindows.Checked);

  ModalResult := mrOk;
end;

end.
