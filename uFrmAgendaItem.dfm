object FrmAgendaItem: TFrmAgendaItem
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Agenda de batidas'
  ClientHeight = 508
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 15
  object lblDias: TLabel
    Left = 16
    Top = 16
    Width = 96
    Height = 18
    Caption = 'Dias da semana'
  end
  object lblEntrada1: TLabel
    Left = 16
    Top = 172
    Width = 60
    Height = 18
    Caption = 'Entrada 1'
  end
  object lblSaida1: TLabel
    Left = 16
    Top = 204
    Width = 47
    Height = 18
    Caption = 'Sa'#237'da 1'
  end
  object lblParcial1: TLabel
    Left = 272
    Top = 204
    Width = 90
    Height = 18
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0h00m'
  end
  object lblEntrada2: TLabel
    Left = 16
    Top = 268
    Width = 60
    Height = 18
    Caption = 'Entrada 2'
  end
  object lblSaida2: TLabel
    Left = 16
    Top = 300
    Width = 47
    Height = 18
    Caption = 'Sa'#237'da 2'
  end
  object lblParcial2: TLabel
    Left = 272
    Top = 300
    Width = 90
    Height = 18
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0h00m'
    Visible = False
  end
  object lblEntrada3: TLabel
    Left = 16
    Top = 364
    Width = 60
    Height = 18
    Caption = 'Entrada 3'
  end
  object lblSaida3: TLabel
    Left = 16
    Top = 396
    Width = 47
    Height = 18
    Caption = 'Sa'#237'da 3'
  end
  object lblParcial3: TLabel
    Left = 272
    Top = 396
    Width = 90
    Height = 18
    Alignment = taRightJustify
    AutoSize = False
    Caption = '0h00m'
    Visible = False
  end
  object lblHorasCalculadas: TLabel
    Left = 16
    Top = 428
    Width = 348
    Height = 20
    AutoSize = False
    Caption = 'Horas por dia: 0h00m'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object clbDias: TCheckListBox
    Left = 16
    Top = 40
    Width = 348
    Height = 122
    ItemHeight = 18
    Items.Strings = (
      'Segunda-feira'
      'Ter'#231'a-feira'
      'Quarta-feira'
      'Quinta-feira'
      'Sexta-feira'
      'S'#225'bado'
      'Domingo')
    TabOrder = 0
  end
  object dtEntrada1: TDateTimePicker
    Left = 160
    Top = 168
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 1
    OnChange = AtualizarHorasCalculadas
  end
  object dtSaida1: TDateTimePicker
    Left = 160
    Top = 200
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 2
    OnChange = AtualizarHorasCalculadas
  end
  object chkSegundoPar: TCheckBox
    Left = 16
    Top = 236
    Width = 348
    Height = 21
    Caption = 'Segundo par de batidas (entrada/sa'#237'da extra)'
    TabOrder = 3
    OnClick = chkSegundoParClick
  end
  object dtEntrada2: TDateTimePicker
    Left = 160
    Top = 264
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 4
    OnChange = AtualizarHorasCalculadas
  end
  object dtSaida2: TDateTimePicker
    Left = 160
    Top = 296
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 5
    OnChange = AtualizarHorasCalculadas
  end
  object chkTerceiroPar: TCheckBox
    Left = 16
    Top = 332
    Width = 348
    Height = 21
    Caption = 'Terceiro par de batidas (entrada/sa'#237'da extra)'
    TabOrder = 6
    OnClick = chkTerceiroParClick
  end
  object dtEntrada3: TDateTimePicker
    Left = 160
    Top = 360
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 7
    OnChange = AtualizarHorasCalculadas
  end
  object dtSaida3: TDateTimePicker
    Left = 160
    Top = 392
    Width = 100
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 8
    OnChange = AtualizarHorasCalculadas
  end
  object btnOK: TButton
    Left = 132
    Top = 462
    Width = 110
    Height = 30
    Caption = 'OK'
    Default = True
    TabOrder = 9
    OnClick = btnOKClick
  end
  object btnCancelar: TButton
    Left = 250
    Top = 462
    Width = 114
    Height = 30
    Cancel = True
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 10
  end
end
