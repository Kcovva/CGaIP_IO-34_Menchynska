object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'lab 3.5'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMenu = PopupMenu
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
  object PopupMenu: TPopupMenu
    Left = 32
    Top = 8
    object A1: TMenuItem
      Caption = '2.2'
      OnClick = A1Click
    end
    object B1: TMenuItem
      Tag = 1
      Caption = '2.3'
      OnClick = A1Click
    end
    object C1: TMenuItem
      Tag = 2
      Caption = '2.4'
      OnClick = A1Click
    end
    object N1: TMenuItem
      Tag = 3
      Caption = '2.5'
      OnClick = A1Click
    end
  end
end
