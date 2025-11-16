object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'FMain'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMenu = PopupMenu1
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnResize = FormResize
  TextHeight = 15
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Left = 40
    Top = 8
    object N11: TMenuItem
      Caption = '-1'
      OnClick = N11Click
    end
    object N12: TMenuItem
      Tag = 1
      Caption = '0.5'
      OnClick = N11Click
    end
    object N0751: TMenuItem
      Tag = 2
      Caption = '0.75'
      OnClick = N11Click
    end
    object N0752: TMenuItem
      Tag = 3
      Caption = '1'
      Default = True
      OnClick = N11Click
    end
    object N151: TMenuItem
      Tag = 4
      Caption = '1.5'
      OnClick = N11Click
    end
    object N152: TMenuItem
      Tag = 5
      Caption = '4'
      OnClick = N11Click
    end
  end
end
