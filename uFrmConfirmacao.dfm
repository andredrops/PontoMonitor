object FrmConfirmacao: TFrmConfirmacao
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Registro de ponto'
  ClientHeight = 160
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object lblMensagem: TLabel
    Left = 16
    Top = 20
    Width = 308
    Height = 60
    Alignment = taCenter
    AutoSize = False
    Caption = 'lblMensagem'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object btnSilenciar: TButton
    Left = 60
    Top = 100
    Width = 110
    Height = 32
    Caption = 'Silenciar'
    TabOrder = 0
    OnClick = btnSilenciarClick
  end
  object btnConfirmar: TButton
    Left = 180
    Top = 100
    Width = 110
    Height = 32
    Caption = 'Confirmar'
    Default = True
    TabOrder = 1
    OnClick = btnConfirmarClick
  end
  object tmrBeep: TTimer
    Enabled = False
    Interval = 1500
    OnTimer = tmrBeepTimer
    Left = 280
    Top = 16
  end
end
