object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'Lab5.2'
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
    Tag = 1
    Left = 48
    Top = 8
    object a1: TMenuItem
      Caption = 'a'
      OnClick = a1Click
    end
    object b1: TMenuItem
      Tag = 1
      Caption = 'b'
      OnClick = a1Click
    end
  end
end
