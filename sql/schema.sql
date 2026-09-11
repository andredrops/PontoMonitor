-- PontoMonitor - estrutura do banco SQLite
--
-- O app cria e migra esse esquema sozinho na primeira execucao
-- (uPontoDB.pas, TPontoDB.Inicializar/CriarEsquema) - rodar esse script
-- manualmente NAO e necessario no uso normal.
--
-- Serve como referencia da estrutura atual e para quem quiser inspecionar
-- ou recriar o banco do zero manualmente (ex.: fora do app, com o
-- DB Browser for SQLite ou o sqlite3 CLI).
--
-- Banco alvo: SQLite. Caminho usado pelo app: %APPDATA%\PontoAgenda\ponto.db

PRAGMA foreign_keys = ON;

-- Agendas de batida (horarios previstos por combinacao de dias da semana).
-- Ate 3 turnos por agenda; o 2o e 3o par sao opcionais (NULL = nao usado).
-- O 3o par so faz sentido com o 2o preenchido (regra aplicada pela
-- aplicacao, nao pelo banco).
CREATE TABLE IF NOT EXISTS agenda (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  entrada1        TEXT NOT NULL,   -- 'HH:MM'
  saida1          TEXT NOT NULL,   -- 'HH:MM'
  entrada2        TEXT,            -- 'HH:MM' ou NULL
  saida2          TEXT,            -- 'HH:MM' ou NULL
  entrada3        TEXT,            -- 'HH:MM' ou NULL
  saida3          TEXT,            -- 'HH:MM' ou NULL
  ativo           INTEGER NOT NULL DEFAULT 1
);

-- Associa cada dia da semana (1=Segunda ... 7=Domingo) a UMA agenda.
-- dia_semana como chave primaria garante, no proprio banco, que um dia
-- nunca pertenca a mais de uma agenda ao mesmo tempo.
CREATE TABLE IF NOT EXISTS agenda_dia (
  dia_semana      INTEGER PRIMARY KEY,
  agenda_id       INTEGER NOT NULL REFERENCES agenda(id) ON DELETE CASCADE
);

-- Espelho local das batidas - registradas automaticamente pelo monitor
-- (quando o alarme e confirmado) ou manualmente pela aba Historico.
CREATE TABLE IF NOT EXISTS registro_ponto (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  data_hora       TEXT NOT NULL,   -- 'yyyy-mm-dd HH:MM:SS'
  tipo_batida     TEXT NOT NULL,   -- Entrada1 | Saida1 | Entrada2 | Saida2 | Entrada3 | Saida3
  origem          TEXT NOT NULL,   -- Automatico | Manual
  confirmado      INTEGER NOT NULL DEFAULT 0
);

-- Configuracoes do app, formato chave/valor (tela de Configuracoes).
-- Chaves usadas hoje: caminho_exe_ponto, executar_programa,
-- tolerancia_minutos, meta_horas_dia, som_alarme, som_mp3_caminho.
CREATE TABLE IF NOT EXISTS configuracao (
  chave           TEXT PRIMARY KEY,
  valor           TEXT
);
