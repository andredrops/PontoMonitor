object FrmConfig: TFrmConfig
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configura'#231#245'es'
  ClientHeight = 424
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 15
  object chkExecutarPrograma: TCheckBox
    Left = 16
    Top = 16
    Width = 380
    Height = 21
    Caption = 'Executar um programa externo ao bater o ponto'
    TabOrder = 0
    OnClick = chkExecutarProgramaClick
  end
  object lblCaminhoExe: TLabel
    Left = 16
    Top = 48
    Width = 148
    Height = 18
    Caption = 'Execut'#225'vel do ponto (.exe)'
  end
  object lblTolerancia: TLabel
    Left = 16
    Top = 112
    Width = 149
    Height = 18
    Caption = 'Toler'#226'ncia (minutos)'
  end
  object lblMetaHorasDia: TLabel
    Left = 16
    Top = 176
    Width = 158
    Height = 18
    Caption = 'Meta de horas di'#225'rias'
  end
  object lblSom: TLabel
    Left = 16
    Top = 240
    Width = 89
    Height = 18
    Caption = 'Som do alarme'
  end
  object edtCaminhoExe: TEdit
    Left = 16
    Top = 72
    Width = 312
    Height = 23
    TabOrder = 1
  end
  object btnProcurarExe: TButton
    Left = 334
    Top = 71
    Width = 30
    Height = 25
    Caption = '...'
    TabOrder = 2
    OnClick = btnProcurarExeClick
  end
  object seTolerancia: TSpinEdit
    Left = 16
    Top = 136
    Width = 80
    Height = 24
    MaxValue = 15
    MinValue = 1
    TabOrder = 3
    Value = 2
  end
  object dtMetaHorasDia: TDateTimePicker
    Left = 16
    Top = 200
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 4
  end
  object cbSom: TComboBox
    Left = 16
    Top = 264
    Width = 220
    Height = 23
    Style = csDropDownList
    TabOrder = 5
    OnChange = cbSomChange
    Items.Strings = (
      'Padr'#227'o do Windows (Asterisco)'
      'Exclama'#231#227'o'
      'Cr'#237'tico (Erro)'
      'Simples (Beep)'
      'Arquivo MP3 personalizado')
  end
  object btnTestarSom: TButton
    Left = 246
    Top = 263
    Width = 118
    Height = 25
    Caption = 'Testar som'
    TabOrder = 6
    OnClick = btnTestarSomClick
  end
  object edtSomMp3: TEdit
    Left = 16
    Top = 296
    Width = 270
    Height = 23
    TabOrder = 7
  end
  object btnProcurarMp3: TButton
    Left = 292
    Top = 295
    Width = 42
    Height = 25
    Caption = '...'
    TabOrder = 8
    OnClick = btnProcurarMp3Click
  end
  object chkIniciarComWindows: TCheckBox
    Left = 16
    Top = 332
    Width = 300
    Height = 21
    Caption = 'Iniciar automaticamente com o Windows'
    TabOrder = 9
  end
  object btnSalvar: TButton
    Left = 132
    Top = 376
    Width = 110
    Height = 30
    Caption = 'Salvar'
    Default = True
    TabOrder = 10
    OnClick = btnSalvarClick
  end
  object btnFechar: TButton
    Left = 250
    Top = 376
    Width = 110
    Height = 30
    Cancel = True
    Caption = 'Fechar'
    ModalResult = 2
    TabOrder = 11
  end
  object dlgAbrirExe: TOpenDialog
    Filter = 'Execut'#225'veis (*.exe)|*.exe|Todos os arquivos (*.*)|*.*'
    Title = 'Selecione o execut'#225'vel do ponto'
    Left = 360
    Top = 16
  end
  object dlgAbrirMp3: TOpenDialog
    Filter = 'Arquivos MP3 (*.mp3)|*.mp3|Todos os arquivos (*.*)|*.*'
    Title = 'Selecione o som do alarme'
    Left = 360
    Top = 56
  end
  object tmrTestarSom: TTimer
    Enabled = False
    Interval = 1500
    OnTimer = tmrTestarSomTimer
    Left = 360
    Top = 96
  end
end
