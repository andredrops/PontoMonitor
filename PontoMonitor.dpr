program PontoMonitor;

uses
  Vcl.Forms,
  System.SysUtils,
  uPontoDB in 'uPontoDB.pas',
  uAlarmeSom in 'uAlarmeSom.pas',
  uFrmAgenda in 'uFrmAgenda.pas' {FrmAgenda},
  uFrmAgendaItem in 'uFrmAgendaItem.pas' {FrmAgendaItem},
  uFrmConfig in 'uFrmConfig.pas' {FrmConfig},
  uFrmConfirmacao in 'uFrmConfirmacao.pas' {FrmConfirmacao},
  uFrmRegistroManual in 'uFrmRegistroManual.pas' {FrmRegistroManual};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  if FindCmdLineSwitch('min', ['/', '-'], True) then
    Application.ShowMainForm := False;
  Application.CreateForm(TFrmAgenda, FrmAgenda);
  Application.Run;
end.
