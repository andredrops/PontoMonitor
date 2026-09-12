unit uPontoDB;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.DateUtils,
  System.Variants, System.Generics.Collections, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Def, FireDAC.Stan.Async,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.DApt,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.VCLUI.Wait;

type
  TAgenda = record
    Id: Integer;
    Entrada1: TTime;
    Saida1: TTime;
    Entrada2: TTime;
    Saida2: TTime;
    Entrada3: TTime;
    Saida3: TTime;
    TemSegundoPar: Boolean;
    TemTerceiroPar: Boolean;   // so pode ser True se TemSegundoPar tambem for
    Ativo: Boolean;
    Dias: TArray<Integer>;   // 1=Seg ... 7=Dom
  end;

  TRegistroPonto = record
    Id: Integer;
    DataHora: TDateTime;
    TipoBatida: string;
    Origem: string;
  end;

  // Alarme avulso: dispara uma unica vez num data/hora especifico, fora da
  // agenda semanal recorrente. Some sozinho quando confirmado (a existencia
  // da linha JA significa "pendente" - nao precisa de flag de confirmado).
  TAlarmeUnico = record
    Id: Integer;
    DataHora: TDateTime;
    TipoBatida: string;
  end;

const
  NomeDiaSemana: array[1..7] of string = ('Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom');

  TIPO_ENTRADA1 = 'Entrada1';
  TIPO_SAIDA1 = 'Saida1';
  TIPO_ENTRADA2 = 'Entrada2';
  TIPO_SAIDA2 = 'Saida2';
  TIPO_ENTRADA3 = 'Entrada3';
  TIPO_SAIDA3 = 'Saida3';

  ORIGEM_AUTOMATICO = 'Automatico';
  ORIGEM_MANUAL = 'Manual';

function HorasDoDia(const A: TAgenda): Double;
function DescricaoDias(const ADias: TArray<Integer>): string;
function FormatarHoras(AHoras: Double): string;
function DescricaoTipoBatida(const ATipo: string): string;
function TipoBatidaDaDescricao(const ADescricao: string): string;
function TotalHorasRegistradas(const ARegistros: TArray<TRegistroPonto>): Double;
function TodosRegistrosMesmoDia(const ARegistros: TArray<TRegistroPonto>): Boolean;
function ObterSessaoAberta(const ARegistros: TArray<TRegistroPonto>;
  out AHorarioAbertura: TDateTime; out ATipoSaidaEsperado: string): Boolean;

type
  TPontoDB = class
  private
    class var FConexao: TFDConnection;
    class procedure CriarEsquema;
    class function CaminhoBanco: string;
    class function ColunaExiste(const ATabela, AColuna: string): Boolean;
    class procedure MigrarRemoverColunaMeta;
    class procedure MigrarAdicionarColunasTerceiroPar;
  public
    class procedure Inicializar;
    class procedure Finalizar;
    class function Conexao: TFDConnection;

    // Agenda
    class function ListarAgendas: TArray<TAgenda>;
    class function DiaEstaLivre(ADia: Integer; AIgnorarAgendaId: Integer = 0): Boolean;
    class function InserirAgenda(const A: TAgenda): Integer;
    class procedure AtualizarAgenda(const A: TAgenda);
    class procedure ExcluirAgenda(AId: Integer);
    class function TotalHorasSemanais: Double;

    // Configuração (chave/valor)
    class function ObterConfig(const AChave: string; const APadrao: string = ''): string;
    class procedure SalvarConfig(const AChave, AValor: string);

    // Registro de ponto (espelho local das batidas)
    class procedure RegistrarBatida(const ATipoBatida, AOrigem: string);
    class function BatidaJaDisparadaHoje(const ATipoBatida: string): Boolean;
    class function ObterHorarioBatidaHoje(const ATipoBatida: string; out AHorario: TDateTime): Boolean;
    class function ListarRegistros(ADataInicio, ADataFim: TDate): TArray<TRegistroPonto>;
    class procedure ExcluirRegistro(AId: Integer);
    class function InserirRegistroManual(ADataHora: TDateTime;
      const ATipoBatida, AOrigem: string): Integer;
    class procedure AtualizarRegistro(AId: Integer; ADataHora: TDateTime;
      const ATipoBatida, AOrigem: string);

    // Alarmes avulsos (unicos, fora da agenda semanal)
    class function ListarAlarmesUnicos: TArray<TAlarmeUnico>;
    class function ListarAlarmesUnicosFuturos: TArray<TAlarmeUnico>;
    class function InserirAlarmeUnico(ADataHora: TDateTime; const ATipoBatida: string): Integer;
    class procedure AtualizarAlarmeUnico(AId: Integer; ADataHora: TDateTime;
      const ATipoBatida: string);
    class procedure ExcluirAlarmeUnico(AId: Integer);
  end;

implementation

function HorasDoDia(const A: TAgenda): Double;
begin
  Result := (A.Saida1 - A.Entrada1) * 24;
  if A.TemSegundoPar then
    Result := Result + (A.Saida2 - A.Entrada2) * 24;
  if A.TemTerceiroPar then
    Result := Result + (A.Saida3 - A.Entrada3) * 24;
end;

function DescricaoDias(const ADias: TArray<Integer>): string;
var
  D: Integer;
begin
  Result := '';
  for D in ADias do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + NomeDiaSemana[D];
  end;
end;

function FormatarHoras(AHoras: Double): string;
var
  Horas, Minutos: Integer;
begin
  Horas := Trunc(AHoras);
  Minutos := Round(Frac(AHoras) * 60);
  Result := Format('%dh%.2dm', [Horas, Minutos]);
end;

function DescricaoTipoBatida(const ATipo: string): string;
begin
  if ATipo = TIPO_ENTRADA1 then Result := 'Entrada 1'
  else if ATipo = TIPO_SAIDA1 then Result := 'Sa'#237'da 1'
  else if ATipo = TIPO_ENTRADA2 then Result := 'Entrada 2'
  else if ATipo = TIPO_SAIDA2 then Result := 'Sa'#237'da 2'
  else if ATipo = TIPO_ENTRADA3 then Result := 'Entrada 3'
  else if ATipo = TIPO_SAIDA3 then Result := 'Sa'#237'da 3'
  else Result := ATipo;
end;

function TipoBatidaDaDescricao(const ADescricao: string): string;
begin
  if ADescricao = 'Entrada 1' then Result := TIPO_ENTRADA1
  else if ADescricao = 'Sa'#237'da 1' then Result := TIPO_SAIDA1
  else if ADescricao = 'Entrada 2' then Result := TIPO_ENTRADA2
  else if ADescricao = 'Sa'#237'da 2' then Result := TIPO_SAIDA2
  else if ADescricao = 'Entrada 3' then Result := TIPO_ENTRADA3
  else if ADescricao = 'Sa'#237'da 3' then Result := TIPO_SAIDA3
  else Result := '';
end;

function TotalHorasRegistradas(const ARegistros: TArray<TRegistroPonto>): Double;
var
  DiasMap: TObjectDictionary<string, TDictionary<string, TDateTime>>;
  MapaDia: TDictionary<string, TDateTime>;
  R: TRegistroPonto;
  ChaveDia: string;
  Entrada, Saida: TDateTime;
begin
  Result := 0;
  DiasMap := TObjectDictionary<string, TDictionary<string, TDateTime>>.Create([doOwnsValues]);
  try
    for R in ARegistros do
    begin
      ChaveDia := FormatDateTime('yyyy-mm-dd', R.DataHora);
      if not DiasMap.TryGetValue(ChaveDia, MapaDia) then
      begin
        MapaDia := TDictionary<string, TDateTime>.Create;
        DiasMap.Add(ChaveDia, MapaDia);
      end;
      MapaDia.AddOrSetValue(R.TipoBatida, R.DataHora);
    end;

    for MapaDia in DiasMap.Values do
    begin
      if MapaDia.TryGetValue(TIPO_ENTRADA1, Entrada) and MapaDia.TryGetValue(TIPO_SAIDA1, Saida) then
        Result := Result + (Saida - Entrada) * 24;
      if MapaDia.TryGetValue(TIPO_ENTRADA2, Entrada) and MapaDia.TryGetValue(TIPO_SAIDA2, Saida) then
        Result := Result + (Saida - Entrada) * 24;
      if MapaDia.TryGetValue(TIPO_ENTRADA3, Entrada) and MapaDia.TryGetValue(TIPO_SAIDA3, Saida) then
        Result := Result + (Saida - Entrada) * 24;
    end;
  finally
    DiasMap.Free;
  end;
end;

function TodosRegistrosMesmoDia(const ARegistros: TArray<TRegistroPonto>): Boolean;
var
  I: Integer;
begin
  Result := Length(ARegistros) > 0;
  if not Result then
    Exit;
  for I := 1 to High(ARegistros) do
    if Trunc(ARegistros[I].DataHora) <> Trunc(ARegistros[0].DataHora) then
      Exit(False);
end;

function ObterSessaoAberta(const ARegistros: TArray<TRegistroPonto>;
  out AHorarioAbertura: TDateTime; out ATipoSaidaEsperado: string): Boolean;
const
  TiposEntrada: array[0..2] of string = (TIPO_ENTRADA1, TIPO_ENTRADA2, TIPO_ENTRADA3);
  TiposSaida: array[0..2] of string = (TIPO_SAIDA1, TIPO_SAIDA2, TIPO_SAIDA3);
var
  Mapa: TDictionary<string, TDateTime>;
  R: TRegistroPonto;
  I: Integer;
  Entrada: TDateTime;
  Encontradas: Integer;
begin
  Encontradas := 0;
  Mapa := TDictionary<string, TDateTime>.Create;
  try
    for R in ARegistros do
      Mapa.AddOrSetValue(R.TipoBatida, R.DataHora);

    for I := 0 to High(TiposEntrada) do
      if Mapa.TryGetValue(TiposEntrada[I], Entrada) and not Mapa.ContainsKey(TiposSaida[I]) then
      begin
        Inc(Encontradas);
        AHorarioAbertura := Entrada;
        ATipoSaidaEsperado := TiposSaida[I];
      end;

    // Mais de um turno aberto ao mesmo tempo e ambiguo - nao arrisca previsao
    Result := Encontradas = 1;
  finally
    Mapa.Free;
  end;
end;

// Converte 'yyyy-mm-dd hh:nn:ss' para TDateTime sem depender do locale do
// Windows (StrToDateTime usaria o separador/ordem configurados no sistema).
function DataHoraISOParaDateTime(const S: string): TDateTime;
begin
  Result := EncodeDateTime(
    StrToInt(Copy(S, 1, 4)), StrToInt(Copy(S, 6, 2)), StrToInt(Copy(S, 9, 2)),
    StrToInt(Copy(S, 12, 2)), StrToInt(Copy(S, 15, 2)), StrToInt(Copy(S, 18, 2)), 0);
end;

{ TPontoDB }

class function TPontoDB.CaminhoBanco: string;
var
  Pasta: string;
begin
  Pasta := TPath.Combine(GetEnvironmentVariable('APPDATA'), 'PontoAgenda');
  if not TDirectory.Exists(Pasta) then
    TDirectory.CreateDirectory(Pasta);
  Result := TPath.Combine(Pasta, 'ponto.db');
end;

class procedure TPontoDB.Inicializar;
begin
  if Assigned(FConexao) then
    Exit;

  FConexao := TFDConnection.Create(nil);
  FConexao.DriverName := 'SQLite';
  FConexao.Params.Database := CaminhoBanco;
  FConexao.Params.Add('OpenMode=CreateUTF8');
  FConexao.LoginPrompt := False;
  FConexao.Connected := True;

  // SQLite ignora ON DELETE CASCADE por padrão em cada conexão nova
  FConexao.ExecSQL('PRAGMA foreign_keys = ON');

  CriarEsquema;
end;

class procedure TPontoDB.Finalizar;
begin
  if Assigned(FConexao) then
  begin
    FConexao.Connected := False;
    FreeAndNil(FConexao);
  end;
end;

class function TPontoDB.Conexao: TFDConnection;
begin
  if not Assigned(FConexao) then
    Inicializar;
  Result := FConexao;
end;

class function TPontoDB.ColunaExiste(const ATabela, AColuna: string): Boolean;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open('PRAGMA table_info(' + ATabela + ')');
    Result := False;
    while not Qry.Eof do
    begin
      if SameText(Qry.FieldByName('name').AsString, AColuna) then
        Exit(True);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

class procedure TPontoDB.MigrarRemoverColunaMeta;
begin
  // O SQLite embutido no FireDAC desta versao do Delphi (3.9.x) e anterior ao
  // suporte a ALTER TABLE ... DROP COLUMN (só chegou na 3.35), entao a
  // migracao precisa recriar a tabela do jeito classico.
  if not ColunaExiste('agenda', 'meta_horas_dia') then
    Exit;

  FConexao.ExecSQL('PRAGMA foreign_keys = OFF');
  FConexao.StartTransaction;
  try
    FConexao.ExecSQL(
      'CREATE TABLE agenda_novo (' +
      '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
      '  entrada1 TEXT NOT NULL,' +
      '  saida1 TEXT NOT NULL,' +
      '  entrada2 TEXT,' +
      '  saida2 TEXT,' +
      '  ativo INTEGER NOT NULL DEFAULT 1' +
      ')');
    FConexao.ExecSQL(
      'INSERT INTO agenda_novo (id, entrada1, saida1, entrada2, saida2, ativo) ' +
      'SELECT id, entrada1, saida1, entrada2, saida2, ativo FROM agenda');
    FConexao.ExecSQL('DROP TABLE agenda');
    FConexao.ExecSQL('ALTER TABLE agenda_novo RENAME TO agenda');
    FConexao.Commit;
  except
    FConexao.Rollback;
    FConexao.ExecSQL('PRAGMA foreign_keys = ON');
    raise;
  end;
  FConexao.ExecSQL('PRAGMA foreign_keys = ON');
end;

class procedure TPontoDB.MigrarAdicionarColunasTerceiroPar;
begin
  // ALTER TABLE ... ADD COLUMN e suportado ate por SQLite bem antigo, entao
  // aqui nao precisa do truque de recriar a tabela (diferente do DROP COLUMN).
  if not ColunaExiste('agenda', 'entrada3') then
    FConexao.ExecSQL('ALTER TABLE agenda ADD COLUMN entrada3 TEXT');
  if not ColunaExiste('agenda', 'saida3') then
    FConexao.ExecSQL('ALTER TABLE agenda ADD COLUMN saida3 TEXT');
end;

class procedure TPontoDB.CriarEsquema;
begin
  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS agenda (' +
    '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  entrada1 TEXT NOT NULL,' +
    '  saida1 TEXT NOT NULL,' +
    '  entrada2 TEXT,' +
    '  saida2 TEXT,' +
    '  entrada3 TEXT,' +
    '  saida3 TEXT,' +
    '  ativo INTEGER NOT NULL DEFAULT 1' +
    ')');

  MigrarRemoverColunaMeta;
  MigrarAdicionarColunasTerceiroPar;

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS agenda_dia (' +
    '  dia_semana INTEGER PRIMARY KEY,' +
    '  agenda_id INTEGER NOT NULL REFERENCES agenda(id) ON DELETE CASCADE' +
    ')');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS registro_ponto (' +
    '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  data_hora TEXT NOT NULL,' +
    '  tipo_batida TEXT NOT NULL,' +
    '  origem TEXT NOT NULL,' +
    '  confirmado INTEGER NOT NULL DEFAULT 0' +
    ')');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS configuracao (' +
    '  chave TEXT PRIMARY KEY,' +
    '  valor TEXT' +
    ')');

  FConexao.ExecSQL(
    'CREATE TABLE IF NOT EXISTS alarme_unico (' +
    '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    '  data_hora TEXT NOT NULL,' +
    '  tipo_batida TEXT NOT NULL' +
    ')');
end;

class function TPontoDB.ListarAgendas: TArray<TAgenda>;
var
  Qry, QryDias: TFDQuery;
  Lista: TList<TAgenda>;
  A: TAgenda;
  Dias: TList<Integer>;
begin
  Lista := TList<TAgenda>.Create;
  Qry := TFDQuery.Create(nil);
  QryDias := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    QryDias.Connection := Conexao;
    Qry.Open('SELECT * FROM agenda ORDER BY id');
    while not Qry.Eof do
    begin
      A.Id := Qry.FieldByName('id').AsInteger;
      A.Entrada1 := StrToTime(Qry.FieldByName('entrada1').AsString);
      A.Saida1 := StrToTime(Qry.FieldByName('saida1').AsString);
      A.TemSegundoPar := not Qry.FieldByName('entrada2').IsNull;
      if A.TemSegundoPar then
      begin
        A.Entrada2 := StrToTime(Qry.FieldByName('entrada2').AsString);
        A.Saida2 := StrToTime(Qry.FieldByName('saida2').AsString);
      end
      else
      begin
        A.Entrada2 := 0;
        A.Saida2 := 0;
      end;
      A.TemTerceiroPar := not Qry.FieldByName('entrada3').IsNull;
      if A.TemTerceiroPar then
      begin
        A.Entrada3 := StrToTime(Qry.FieldByName('entrada3').AsString);
        A.Saida3 := StrToTime(Qry.FieldByName('saida3').AsString);
      end
      else
      begin
        A.Entrada3 := 0;
        A.Saida3 := 0;
      end;
      A.Ativo := Qry.FieldByName('ativo').AsInteger = 1;

      Dias := TList<Integer>.Create;
      try
        QryDias.Open('SELECT dia_semana FROM agenda_dia WHERE agenda_id = :id ORDER BY dia_semana',
          [A.Id]);
        while not QryDias.Eof do
        begin
          Dias.Add(QryDias.FieldByName('dia_semana').AsInteger);
          QryDias.Next;
        end;
        A.Dias := Dias.ToArray;
      finally
        Dias.Free;
      end;

      Lista.Add(A);
      Qry.Next;
    end;
    Result := Lista.ToArray;
  finally
    Qry.Free;
    QryDias.Free;
    Lista.Free;
  end;
end;

class function TPontoDB.DiaEstaLivre(ADia: Integer; AIgnorarAgendaId: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open('SELECT agenda_id FROM agenda_dia WHERE dia_semana = :dia', [ADia]);
    Result := Qry.IsEmpty or (Qry.FieldByName('agenda_id').AsInteger = AIgnorarAgendaId);
  finally
    Qry.Free;
  end;
end;

class function TPontoDB.InserirAgenda(const A: TAgenda): Integer;
var
  Qry: TFDQuery;
  D: Integer;
begin
  Result := 0;
  Conexao.StartTransaction;
  Qry := TFDQuery.Create(nil);
  try
    try
      Qry.Connection := Conexao;
      Qry.SQL.Text :=
        'INSERT INTO agenda (entrada1, saida1, entrada2, saida2, entrada3, saida3, ativo) ' +
        'VALUES (:entrada1, :saida1, :entrada2, :saida2, :entrada3, :saida3, :ativo)';
      Qry.ParamByName('entrada1').AsString := FormatDateTime('hh:nn', A.Entrada1);
      Qry.ParamByName('saida1').AsString := FormatDateTime('hh:nn', A.Saida1);
      if A.TemSegundoPar then
      begin
        Qry.ParamByName('entrada2').AsString := FormatDateTime('hh:nn', A.Entrada2);
        Qry.ParamByName('saida2').AsString := FormatDateTime('hh:nn', A.Saida2);
      end
      else
      begin
        Qry.ParamByName('entrada2').DataType := ftString;
        Qry.ParamByName('entrada2').Value := Null;
        Qry.ParamByName('saida2').DataType := ftString;
        Qry.ParamByName('saida2').Value := Null;
      end;
      if A.TemTerceiroPar then
      begin
        Qry.ParamByName('entrada3').AsString := FormatDateTime('hh:nn', A.Entrada3);
        Qry.ParamByName('saida3').AsString := FormatDateTime('hh:nn', A.Saida3);
      end
      else
      begin
        Qry.ParamByName('entrada3').DataType := ftString;
        Qry.ParamByName('entrada3').Value := Null;
        Qry.ParamByName('saida3').DataType := ftString;
        Qry.ParamByName('saida3').Value := Null;
      end;
      Qry.ParamByName('ativo').AsInteger := Ord(A.Ativo);
      Qry.ExecSQL;

      Result := Conexao.GetLastAutoGenValue('agenda');

      for D in A.Dias do
      begin
        Qry.SQL.Text := 'INSERT INTO agenda_dia (dia_semana, agenda_id) VALUES (:dia, :agenda_id)';
        Qry.ParamByName('dia').AsInteger := D;
        Qry.ParamByName('agenda_id').AsInteger := Result;
        Qry.ExecSQL;
      end;

      Conexao.Commit;
    except
      Conexao.Rollback;
      raise;
    end;
  finally
    Qry.Free;
  end;
end;

class procedure TPontoDB.AtualizarAgenda(const A: TAgenda);
var
  Qry: TFDQuery;
  D: Integer;
begin
  Conexao.StartTransaction;
  Qry := TFDQuery.Create(nil);
  try
    try
      Qry.Connection := Conexao;
      Qry.SQL.Text :=
        'UPDATE agenda SET entrada1=:entrada1, saida1=:saida1, entrada2=:entrada2, ' +
        'saida2=:saida2, entrada3=:entrada3, saida3=:saida3, ativo=:ativo WHERE id=:id';
      Qry.ParamByName('entrada1').AsString := FormatDateTime('hh:nn', A.Entrada1);
      Qry.ParamByName('saida1').AsString := FormatDateTime('hh:nn', A.Saida1);
      if A.TemSegundoPar then
      begin
        Qry.ParamByName('entrada2').AsString := FormatDateTime('hh:nn', A.Entrada2);
        Qry.ParamByName('saida2').AsString := FormatDateTime('hh:nn', A.Saida2);
      end
      else
      begin
        Qry.ParamByName('entrada2').DataType := ftString;
        Qry.ParamByName('entrada2').Value := Null;
        Qry.ParamByName('saida2').DataType := ftString;
        Qry.ParamByName('saida2').Value := Null;
      end;
      if A.TemTerceiroPar then
      begin
        Qry.ParamByName('entrada3').AsString := FormatDateTime('hh:nn', A.Entrada3);
        Qry.ParamByName('saida3').AsString := FormatDateTime('hh:nn', A.Saida3);
      end
      else
      begin
        Qry.ParamByName('entrada3').DataType := ftString;
        Qry.ParamByName('entrada3').Value := Null;
        Qry.ParamByName('saida3').DataType := ftString;
        Qry.ParamByName('saida3').Value := Null;
      end;
      Qry.ParamByName('ativo').AsInteger := Ord(A.Ativo);
      Qry.ParamByName('id').AsInteger := A.Id;
      Qry.ExecSQL;

      Qry.SQL.Text := 'DELETE FROM agenda_dia WHERE agenda_id = :id';
      Qry.ParamByName('id').AsInteger := A.Id;
      Qry.ExecSQL;

      for D in A.Dias do
      begin
        Qry.SQL.Text := 'INSERT INTO agenda_dia (dia_semana, agenda_id) VALUES (:dia, :agenda_id)';
        Qry.ParamByName('dia').AsInteger := D;
        Qry.ParamByName('agenda_id').AsInteger := A.Id;
        Qry.ExecSQL;
      end;

      Conexao.Commit;
    except
      Conexao.Rollback;
      raise;
    end;
  finally
    Qry.Free;
  end;
end;

class procedure TPontoDB.ExcluirAgenda(AId: Integer);
begin
  // agenda_dia é removida em cascata (PRAGMA foreign_keys habilitado em Inicializar)
  Conexao.ExecSQL('DELETE FROM agenda WHERE id = :id', [AId]);
end;

class function TPontoDB.TotalHorasSemanais: Double;
var
  A: TAgenda;
begin
  Result := 0;
  for A in ListarAgendas do
    if A.Ativo then
      Result := Result + HorasDoDia(A) * Length(A.Dias);
end;

class function TPontoDB.ObterConfig(const AChave: string; const APadrao: string): string;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open('SELECT valor FROM configuracao WHERE chave = :chave', [AChave]);
    if Qry.IsEmpty then
      Result := APadrao
    else
      Result := Qry.FieldByName('valor').AsString;
  finally
    Qry.Free;
  end;
end;

class procedure TPontoDB.SalvarConfig(const AChave, AValor: string);
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open('SELECT chave FROM configuracao WHERE chave = :chave', [AChave]);
    if Qry.IsEmpty then
      Conexao.ExecSQL('INSERT INTO configuracao (chave, valor) VALUES (:chave, :valor)',
        [AChave, AValor])
    else
      Conexao.ExecSQL('UPDATE configuracao SET valor = :valor WHERE chave = :chave',
        [AValor, AChave]);
  finally
    Qry.Free;
  end;
end;

class procedure TPontoDB.RegistrarBatida(const ATipoBatida, AOrigem: string);
begin
  Conexao.ExecSQL(
    'INSERT INTO registro_ponto (data_hora, tipo_batida, origem, confirmado) ' +
    'VALUES (:data_hora, :tipo, :origem, 0)',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), ATipoBatida, AOrigem]);
end;

class function TPontoDB.BatidaJaDisparadaHoje(const ATipoBatida: string): Boolean;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open(
      'SELECT 1 FROM registro_ponto ' +
      'WHERE tipo_batida = :tipo AND date(data_hora) = date(''now'', ''localtime'')',
      [ATipoBatida]);
    Result := not Qry.IsEmpty;
  finally
    Qry.Free;
  end;
end;

class function TPontoDB.ObterHorarioBatidaHoje(const ATipoBatida: string;
  out AHorario: TDateTime): Boolean;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open(
      'SELECT data_hora FROM registro_ponto ' +
      'WHERE tipo_batida = :tipo AND date(data_hora) = date(''now'', ''localtime'') ' +
      'ORDER BY data_hora DESC LIMIT 1',
      [ATipoBatida]);
    Result := not Qry.IsEmpty;
    if Result then
      AHorario := DataHoraISOParaDateTime(Qry.FieldByName('data_hora').AsString);
  finally
    Qry.Free;
  end;
end;

class function TPontoDB.ListarRegistros(ADataInicio, ADataFim: TDate): TArray<TRegistroPonto>;
var
  Qry: TFDQuery;
  Lista: TList<TRegistroPonto>;
  R: TRegistroPonto;
begin
  Lista := TList<TRegistroPonto>.Create;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open(
      'SELECT id, data_hora, tipo_batida, origem FROM registro_ponto ' +
      'WHERE date(data_hora) BETWEEN date(:dini) AND date(:dfim) ' +
      'ORDER BY data_hora DESC',
      [FormatDateTime('yyyy-mm-dd', ADataInicio), FormatDateTime('yyyy-mm-dd', ADataFim)]);
    while not Qry.Eof do
    begin
      R.Id := Qry.FieldByName('id').AsInteger;
      R.DataHora := DataHoraISOParaDateTime(Qry.FieldByName('data_hora').AsString);
      R.TipoBatida := Qry.FieldByName('tipo_batida').AsString;
      R.Origem := Qry.FieldByName('origem').AsString;
      Lista.Add(R);
      Qry.Next;
    end;
    Result := Lista.ToArray;
  finally
    Qry.Free;
    Lista.Free;
  end;
end;

class procedure TPontoDB.ExcluirRegistro(AId: Integer);
begin
  Conexao.ExecSQL('DELETE FROM registro_ponto WHERE id = :id', [AId]);
end;

class function TPontoDB.InserirRegistroManual(ADataHora: TDateTime;
  const ATipoBatida, AOrigem: string): Integer;
begin
  Conexao.ExecSQL(
    'INSERT INTO registro_ponto (data_hora, tipo_batida, origem, confirmado) ' +
    'VALUES (:data_hora, :tipo, :origem, 1)',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', ADataHora), ATipoBatida, AOrigem]);
  Result := Conexao.GetLastAutoGenValue('registro_ponto');
end;

class procedure TPontoDB.AtualizarRegistro(AId: Integer; ADataHora: TDateTime;
  const ATipoBatida, AOrigem: string);
begin
  Conexao.ExecSQL(
    'UPDATE registro_ponto SET data_hora = :data_hora, tipo_batida = :tipo, origem = :origem ' +
    'WHERE id = :id',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', ADataHora), ATipoBatida, AOrigem, AId]);
end;

class function TPontoDB.ListarAlarmesUnicos: TArray<TAlarmeUnico>;
var
  Qry: TFDQuery;
  Lista: TList<TAlarmeUnico>;
  A: TAlarmeUnico;
begin
  Lista := TList<TAlarmeUnico>.Create;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conexao;
    Qry.Open('SELECT id, data_hora, tipo_batida FROM alarme_unico ORDER BY data_hora');
    while not Qry.Eof do
    begin
      A.Id := Qry.FieldByName('id').AsInteger;
      A.DataHora := DataHoraISOParaDateTime(Qry.FieldByName('data_hora').AsString);
      A.TipoBatida := Qry.FieldByName('tipo_batida').AsString;
      Lista.Add(A);
      Qry.Next;
    end;
    Result := Lista.ToArray;
  finally
    Qry.Free;
    Lista.Free;
  end;
end;

class function TPontoDB.ListarAlarmesUnicosFuturos: TArray<TAlarmeUnico>;
var
  Todos: TArray<TAlarmeUnico>;
  Lista: TList<TAlarmeUnico>;
  A: TAlarmeUnico;
begin
  Lista := TList<TAlarmeUnico>.Create;
  try
    Todos := ListarAlarmesUnicos;
    for A in Todos do
      if A.DataHora > Now then
        Lista.Add(A);
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

class function TPontoDB.InserirAlarmeUnico(ADataHora: TDateTime; const ATipoBatida: string): Integer;
begin
  Conexao.ExecSQL(
    'INSERT INTO alarme_unico (data_hora, tipo_batida) VALUES (:data_hora, :tipo)',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', ADataHora), ATipoBatida]);
  Result := Conexao.GetLastAutoGenValue('alarme_unico');
end;

class procedure TPontoDB.AtualizarAlarmeUnico(AId: Integer; ADataHora: TDateTime;
  const ATipoBatida: string);
begin
  Conexao.ExecSQL(
    'UPDATE alarme_unico SET data_hora = :data_hora, tipo_batida = :tipo WHERE id = :id',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss', ADataHora), ATipoBatida, AId]);
end;

class procedure TPontoDB.ExcluirAlarmeUnico(AId: Integer);
begin
  Conexao.ExecSQL('DELETE FROM alarme_unico WHERE id = :id', [AId]);
end;

end.
