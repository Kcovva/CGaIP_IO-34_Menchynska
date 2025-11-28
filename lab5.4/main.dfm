object FMain: TFMain
  Left = 0
  Top = 0
  Caption = 'Lab5.4'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
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
end
