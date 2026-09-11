object FrmAgenda: TFrmAgenda
  Left = 0
  Top = 0
  Caption = 'PontoMonitor - Agenda de Batidas'
  ClientHeight = 420
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 15
  object pgcPrincipal: TPageControl
    Left = 0
    Top = 0
    Width = 640
    Height = 420
    Align = alClient
    TabOrder = 0
    OnChange = pgcPrincipalChange
    object tsHistorico: TTabSheet
      Caption = 'Hist'#243'rico'
      object pnlFiltroHistorico: TPanel
        Left = 0
        Top = 0
        Width = 632
        Height = 48
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblPeriodo: TLabel
          Left = 8
          Top = 16
          Width = 45
          Height = 18
          Caption = 'Per'#237'odo:'
        end
        object lblPeriodoAte: TLabel
          Left = 208
          Top = 16
          Width = 26
          Height = 18
          Caption = 'at'#233
        end
        object dtHistDe: TDateTimePicker
          Left = 64
          Top = 12
          Width = 130
          Height = 23
          Date = 45000.000000000000000000
          Time = 45000.000000000000000000
          Kind = dtkDate
          TabOrder = 0
        end
        object dtHistAte: TDateTimePicker
          Left = 240
          Top = 12
          Width = 130
          Height = 23
          Date = 45000.000000000000000000
          Time = 45000.000000000000000000
          Kind = dtkDate
          TabOrder = 1
        end
        object btnFiltrarHistorico: TButton
          Left = 384
          Top = 11
          Width = 90
          Height = 25
          Caption = 'Filtrar'
          TabOrder = 2
          OnClick = btnFiltrarHistoricoClick
        end
        object btnHoje: TButton
          Left = 482
          Top = 11
          Width = 80
          Height = 25
          Caption = 'Hoje'
          TabOrder = 3
          OnClick = btnHojeClick
        end
        object btnEstaSemana: TButton
          Left = 568
          Top = 11
          Width = 110
          Height = 25
          Caption = 'Esta semana'
          TabOrder = 4
          OnClick = btnEstaSemanaClick
        end
      end
      object sgHistorico: TStringGrid
        Left = 0
        Top = 48
        Width = 692
        Height = 343
        Align = alClient
        ColCount = 4
        DefaultColWidth = 140
        DefaultRowHeight = 22
        FixedCols = 0
        RowCount = 2
        FixedRows = 1
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
        PopupMenu = mnuHistorico
        TabOrder = 1
        OnDblClick = sgHistoricoDblClick
        OnMouseDown = sgHistoricoMouseDown
        ColWidths = (
          120
          80
          130
          140)
      end
      object pnlRodapeHistorico: TPanel
        Left = 0
        Top = 371
        Width = 692
        Height = 84
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object btnAdicionarManual: TButton
          Left = 8
          Top = 18
          Width = 180
          Height = 28
          Caption = '+ Adicionar registro manual'
          TabOrder = 0
          OnClick = btnAdicionarManualClick
        end
        object btnEditarHistorico: TButton
          Left = 196
          Top = 18
          Width = 100
          Height = 28
          Caption = 'Editar'
          TabOrder = 2
          OnClick = btnEditarHistoricoClick
        end
        object pnlCardTotal: TPanel
          Left = 412
          Top = 0
          Width = 280
          Height = 84
          Align = alRight
          BevelInner = bvRaised
          BevelOuter = bvLowered
          TabOrder = 1
          object lblCardTotal: TLabel
            Left = 12
            Top = 6
            Width = 100
            Height = 18
            Caption = 'Total: 0h00m'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblCardMeta: TLabel
            Left = 12
            Top = 26
            Width = 90
            Height = 18
            Caption = 'Meta: 0h00m'
          end
          object lblCardFalta: TLabel
            Left = 12
            Top = 44
            Width = 90
            Height = 18
            Caption = 'Falta: 0h00m'
          end
          object lblCardPrevisao: TLabel
            Left = 12
            Top = 62
            Width = 256
            Height = 18
            Caption = 'Previs'#227'o: --:--'
          end
        end
      end
    end
    object tsAgenda: TTabSheet
      Caption = 'Agenda'
      ImageIndex = 1
      object lvAgendas: TListView
        Left = 0
        Top = 0
        Width = 632
        Height = 343
        Align = alClient
        Columns = <
          item
            Caption = 'Dias'
            Width = 140
          end
          item
            Caption = 'Entrada 1'
            Width = 70
          end
          item
            Caption = 'Sa'#237'da 1'
            Width = 70
          end
          item
            Caption = 'Entrada 2'
            Width = 70
          end
          item
            Caption = 'Sa'#237'da 2'
            Width = 70
          end
          item
            Caption = 'Entrada 3'
            Width = 70
          end
          item
            Caption = 'Sa'#237'da 3'
            Width = 70
          end
          item
            Alignment = taCenter
            Caption = 'Horas/dia'
            Width = 90
          end
          item
            Caption = 'Situa'#231#227'o'
            Width = 108
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvAgendasDblClick
      end
      object pnlRodape: TPanel
        Left = 0
        Top = 343
        Width = 632
        Height = 48
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object lblTotal: TLabel
          Left = 424
          Top = 16
          Width = 200
          Height = 18
          Anchors = [akTop, akRight]
          Alignment = taRightJustify
          AutoSize = True
          Caption = 'Total semanal: 0h00m'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object btnNovo: TButton
          Left = 8
          Top = 10
          Width = 100
          Height = 28
          Caption = '+ Nova agenda'
          TabOrder = 0
          OnClick = btnNovoClick
        end
        object btnEditar: TButton
          Left = 114
          Top = 10
          Width = 90
          Height = 28
          Caption = 'Editar'
          TabOrder = 1
          OnClick = btnEditarClick
        end
        object btnExcluir: TButton
          Left = 210
          Top = 10
          Width = 90
          Height = 28
          Caption = 'Excluir'
          TabOrder = 2
          OnClick = btnExcluirClick
        end
        object btnConfiguracoes: TButton
          Left = 316
          Top = 10
          Width = 110
          Height = 28
          Caption = 'Configura'#231#245'es'
          TabOrder = 3
          OnClick = btnConfiguracoesClick
        end
      end
    end
  end
  object tmrMonitor: TTimer
    Interval = 30000
    OnTimer = tmrMonitorTimer
    Left = 560
    Top = 16
  end
  object trayIcon: TTrayIcon
    PopupMenu = mnuBandeja
    Hint = 'PontoMonitor'
    Visible = False
    OnDblClick = trayIconDblClick
    Left = 592
    Top = 16
  end
  object mnuBandeja: TPopupMenu
    Left = 560
    Top = 56
    object miAbrir: TMenuItem
      Caption = 'Abrir'
      Default = True
      OnClick = miAbrirClick
    end
    object miSair: TMenuItem
      Caption = 'Sair'
      OnClick = miSairClick
    end
  end
  object mnuHistorico: TPopupMenu
    Left = 496
    Top = 56
    object miExcluirHistorico: TMenuItem
      Caption = 'Excluir registro'
      OnClick = miExcluirHistoricoClick
    end
  end
end
