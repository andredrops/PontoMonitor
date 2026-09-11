unit uAlarmeSom;

interface

const
  CFG_SOM_ALARME = 'som_alarme';
  CFG_SOM_MP3_CAMINHO = 'som_mp3_caminho';

  CHAVE_SOM_ASTERISCO = 'asterisco';
  CHAVE_SOM_EXCLAMACAO = 'exclamacao';
  CHAVE_SOM_CRITICO = 'critico';
  CHAVE_SOM_SIMPLES = 'simples';
  CHAVE_SOM_MP3 = 'mp3';

type
  TConfigSom = record
    Chave: string;
    CaminhoMp3: string;
  end;

function ChaveParaSom(const AChave: string): Cardinal;

// Le a configuracao de som UMA VEZ no banco. Usar o resultado com
// IniciarAlarme/ContinuarAlarme evita consultar o banco a cada beep do
// timer (isso deixava a UI "travando" enquanto o alarme repetia).
function ObterConfigSom: TConfigSom;
procedure IniciarAlarme(const AConfig: TConfigSom);
procedure ContinuarAlarme(const AConfig: TConfigSom);
procedure PararAlarme;

// Toca uma vez, consultando o banco na hora - só para o botao "Testar som"
// da tela de Configuracoes, que nao repete em loop.
procedure TocarAlarme;

implementation

uses
  System.SysUtils, Winapi.Windows, Winapi.MMSystem, uPontoDB;

const
  ALIAS_MP3 = 'alarmemp3';

function ChaveParaSom(const AChave: string): Cardinal;
begin
  if AChave = CHAVE_SOM_EXCLAMACAO then
    Result := MB_ICONEXCLAMATION
  else if AChave = CHAVE_SOM_CRITICO then
    Result := MB_ICONHAND
  else if AChave = CHAVE_SOM_SIMPLES then
    Result := MB_OK
  else
    Result := MB_ICONASTERISK;
end;

function ObterConfigSom: TConfigSom;
begin
  Result.Chave := TPontoDB.ObterConfig(CFG_SOM_ALARME, CHAVE_SOM_ASTERISCO);
  Result.CaminhoMp3 := TPontoDB.ObterConfig(CFG_SOM_MP3_CAMINHO, '');
end;

function AbrirEIniciarMp3(const ACaminho: string): Boolean;
begin
  mciSendString('close ' + ALIAS_MP3, nil, 0, 0);
  Result := mciSendString(PChar(Format('open "%s" type mpegvideo alias %s',
    [ACaminho, ALIAS_MP3])), nil, 0, 0) = 0;
  if Result then
    mciSendString('play ' + ALIAS_MP3, nil, 0, 0);
end;

procedure IniciarAlarme(const AConfig: TConfigSom);
begin
  if AConfig.Chave = CHAVE_SOM_MP3 then
  begin
    if not ((AConfig.CaminhoMp3 <> '') and FileExists(AConfig.CaminhoMp3) and
      AbrirEIniciarMp3(AConfig.CaminhoMp3)) then
      MessageBeep(MB_ICONASTERISK);
  end
  else
    MessageBeep(ChaveParaSom(AConfig.Chave));
end;

procedure ContinuarAlarme(const AConfig: TConfigSom);
var
  Buf: array[0..127] of Char;
begin
  if AConfig.Chave = CHAVE_SOM_MP3 then
  begin
    // O mp3 ja esta tocando desde o IniciarAlarme - so reinicia quando ele
    // realmente tiver terminado, em vez de cortar e reabrir a cada tick.
    FillChar(Buf, SizeOf(Buf), 0);
    mciSendString('status ' + ALIAS_MP3 + ' mode', Buf, (SizeOf(Buf) div SizeOf(Char)) - 1, 0);
    if SameText(Trim(Buf), 'stopped') then
    begin
      mciSendString('seek ' + ALIAS_MP3 + ' to start', nil, 0, 0);
      mciSendString('play ' + ALIAS_MP3, nil, 0, 0);
    end;
  end
  else
    MessageBeep(ChaveParaSom(AConfig.Chave));
end;

procedure PararAlarme;
begin
  // So o mp3 tocado via MCI precisa ser parado explicitamente; um MessageBeep
  // ja terminou sozinho no momento em que o usuario clica em silenciar.
  mciSendString('stop ' + ALIAS_MP3, nil, 0, 0);
  mciSendString('close ' + ALIAS_MP3, nil, 0, 0);
end;

procedure TocarAlarme;
begin
  IniciarAlarme(ObterConfigSom);
end;

end.
