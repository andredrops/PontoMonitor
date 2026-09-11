# PontoMonitor

Despertador + espelho de ponto para quem trabalha home office.

## Sobre

Trabalhando remoto é comum precisar lidar com sistemas de ponto diferentes a
cada empresa/cliente — cada um com sua própria ferramenta, sem alarme, sem
histórico fácil de consultar. O **PontoMonitor** não substitui o sistema de
ponto oficial: ele roda em paralelo, do seu lado, com dois papéis:

1. **Despertador** — avisa (som + tela) exatamente na hora de bater cada
   entrada/saída da sua agenda, e abre automaticamente o executável do
   sistema de ponto da empresa.
2. **Espelho** — mantém um histórico local (independente da empresa) de tudo
   que foi batido, editável, com meta diária configurável e previsão de
   horário de saída para fechar a jornada.

Fica na bandeja do Windows, inicia com o sistema, e não depende de internet
nem de nenhum serviço externo — tudo local.

## Funcionalidades

- Agenda semanal com combinações de dias e até **3 turnos** por dia
  (entrada/saída 1, 2 e 3), cada dia da semana pertencendo a uma única
  agenda.
- Meta mínima de horas por dia, configurável, validada ao montar a agenda.
- Monitor em segundo plano: dispara alarme sonoro (som padrão do Windows ou
  um MP3 escolhido por você) e abre o executável do ponto no horário
  agendado — e continua avisando enquanto a batida não for confirmada
  (cobre também bater esquecida).
- Histórico de batidas editável: adicionar registro manual, editar ou
  excluir qualquer linha, filtrar por período (Hoje / Esta semana /
  intervalo customizado).
- Card de totais no Histórico: horas registradas, meta do dia, quanto falta
  — e, com um turno em aberto no mesmo dia, previsão do horário em que a
  próxima saída bate a meta.
- Início automático com o Windows (minimizado, só na bandeja).

## Tutorial rápido

1. **Configurações** (botão na aba Agenda): informe o caminho do executável
   do sistema de ponto da sua empresa (ou desmarque a opção se não quiser
   que nenhum programa seja aberto automaticamente), a tolerância em
   minutos, a meta de horas diárias e o som do alarme.
2. **Aba Agenda**: clique em "+ Nova agenda", marque os dias da semana e
   preencha os horários de cada turno. Repita para combinações diferentes
   de dias (ex.: uma agenda pra Seg-Sex, outra pro Sábado).
3. Deixe o app rodando — pode fechar a janela (ele minimiza pra bandeja, não
   encerra). Nos horários agendados ele avisa e abre o ponto da empresa.
4. **Aba Histórico**: acompanhe o que foi registrado, ajuste horários que
   saíram errados, adicione batidas manuais e veja a previsão de quando
   encerrar o turno atual.

## Banco de dados

O projeto foi concebido para **SQLite**, acessado via FireDAC. Essa é a
recomendação — trocar de engine exigiria reescrever a camada de acesso a
dados (`uPontoDB.pas`), então não há motivo pra usar outro banco aqui e
evita ajustes/conflitos.

Um detalhe específico desta combinação Delphi/FireDAC: o driver SQLite vem
**compilado estaticamente dentro do FireDAC** (SQLite ~3.9.x) — o app não
carrega um `sqlite3.dll` externo, então não precisa (nem adianta) substituir
esse arquivo para "atualizar" a versão do SQLite.

- **Caminho do banco**: `%APPDATA%\PontoAgenda\ponto.db` (criado
  automaticamente).
- **Criação do esquema**: o app cria e migra as tabelas sozinho na primeira
  execução (`uPontoDB.pas`, `TPontoDB.Inicializar`) — não precisa rodar nada
  manualmente para usar o app normalmente.
- **[`sql/schema.sql`](sql/schema.sql)**: script de referência com a
  estrutura completa das tabelas, para quem quiser inspecionar o banco ou
  recriá-lo manualmente fora do app (DB Browser for SQLite, `sqlite3` CLI,
  etc.).

## Requisitos para compilar

- Delphi 10.2 Tokyo (ou compatível) com FireDAC.
- Windows (usa APIs nativas: bandeja do sistema, MCI para tocar MP3,
  registro do Windows para iniciar com o sistema).

## Estrutura do código

| Unit | Responsabilidade |
|---|---|
| `uPontoDB.pas` | Acesso a dados (SQLite/FireDAC), schema, migrações |
| `uAlarmeSom.pas` | Reprodução do som do alarme (beep/MP3 via MCI) |
| `uFrmAgenda.pas` | Tela principal — abas Histórico e Agenda, monitor em background |
| `uFrmAgendaItem.pas` | Diálogo de criar/editar uma agenda |
| `uFrmConfig.pas` | Tela de Configurações |
| `uFrmConfirmacao.pas` | Tela de aviso/confirmação de batida |
| `uFrmRegistroManual.pas` | Diálogo de adicionar/editar registro no histórico |
