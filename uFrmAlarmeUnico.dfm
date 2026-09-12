object FrmAlarmeUnico: TFrmAlarmeUnico
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Criar alarme '#250'nico'
  ClientHeight = 200
  ClientWidth = 320
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
  object lblData: TLabel
    Left = 16
    Top = 16
    Width = 29
    Height = 18
    Caption = 'Data'
  end
  object lblHora: TLabel
    Left = 168
    Top = 16
    Width = 29
    Height = 18
    Caption = 'Hora'
  end
  object lblTipo: TLabel
    Left = 16
    Top = 80
    Width = 33
    Height = 18
    Caption = 'Tipo'
  end
  object dtData: TDateTimePicker
    Left = 16
    Top = 40
    Width = 130
    Height = 23
    Date = 45000.000000000000000000
    Time = 45000.000000000000000000
    Kind = dtkDate
    TabOrder = 0
  end
  object dtHora: TDateTimePicker
    Left = 168
    Top = 40
    Width = 130
    Height = 23
    Format = 'HH:mm'
    Kind = dtkTime
    TabOrder = 1
  end
  object cbTipo: TComboBox
    Left = 16
    Top = 104
    Width = 282
    Height = 23
    Style = csDropDownList
    TabOrder = 2
    Items.Strings = (
      'Entrada 1'
      'Sa'#237'da 1'
      'Entrada 2'
      'Sa'#237'da 2'
      'Entrada 3'
      'Sa'#237'da 3')
  end
  object btnOK: TButton
    Left = 60
    Top = 152
    Width = 90
    Height = 30
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancelar: TButton
    Left = 168
    Top = 152
    Width = 90
    Height = 30
    Cancel = True
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 4
  end
end
