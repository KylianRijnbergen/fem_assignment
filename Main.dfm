object MainView: TMainView
  Left = 0
  Top = 0
  Caption = 'IEM RO FEM Programming'
  ClientHeight = 569
  ClientWidth = 1205
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 568
    Top = 525
    Width = 140
    Height = 13
    Caption = 'Probability that price goes up'
  end
  object Label2: TLabel
    Left = 776
    Top = 525
    Width = 114
    Height = 13
    Caption = 'Risk tuning budget Beta'
  end
  object Label3: TLabel
    Left = 1000
    Top = 525
    Width = 59
    Height = 13
    Caption = 'Parameter K'
  end
  object BinaryChart: TChart
    Left = 8
    Top = 0
    Width = 1177
    Height = 505
    Legend.Visible = False
    MarginLeft = 4
    Title.Text.Strings = (
      'TChart')
    BottomAxis.Automatic = False
    BottomAxis.AutomaticMinimum = False
    BottomAxis.Increment = 1.000000000000000000
    LeftAxis.ExactDateTime = False
    LeftAxis.Grid.Visible = False
    LeftAxis.Increment = 1.000000000000000000
    LeftAxis.Visible = False
    TopAxis.Automatic = False
    TopAxis.AutomaticMinimum = False
    View3D = False
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
    DefaultCanvas = 'TGDIPlusCanvas'
    ColorPaletteIndex = 13
  end
  object Button1: TButton
    Left = 400
    Top = 520
    Width = 137
    Height = 25
    Caption = 'Run Assignment 3'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 56
    Top = 520
    Width = 137
    Height = 25
    Caption = 'Run Assignment 1'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 232
    Top = 520
    Width = 129
    Height = 25
    Caption = 'Run Assignment 2'
    TabOrder = 3
    OnClick = Button3Click
  end
  object EditProbability: TEdit
    Left = 714
    Top = 522
    Width = 41
    Height = 21
    TabOrder = 4
    Text = '0.5'
  end
  object EditBeta: TEdit
    Left = 904
    Top = 522
    Width = 41
    Height = 21
    TabOrder = 5
    Text = '100'
  end
  object EditParameterK: TEdit
    Left = 1065
    Top = 522
    Width = 41
    Height = 21
    TabOrder = 6
    Text = '100'
  end
end
