unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, Vcl.StdCtrls, math, Assignment;

type
  TMainView = class(TForm)
    BinaryChart: TChart;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    EditProbability: TEdit;
    EditBeta: TEdit;
    EditParameterK: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    procedure OnGetMarkText(Sender: TChartSeries;
  ValueIndex: Integer; var MarkText: string);
  public
    { Public declarations }
  end;

  TCustomLineSeries = class(TLineSeries)
  protected
    procedure DrawValue(ValueIndex:Integer); override;
  end;

  TBetaStar = array of array of array of double;

  TAlgorithmResult = record
    Answer: double;
    BetaStarMatrix: TBetaStar;
  end;

  TValueArrayX = array of double;
var
  MainView: TMainView;
  NrStages: integer;
  NrSteps: integer;
  ProbabilityUp: double;
  BetaValue: double;
  K_parameter: integer;
  X: TValueArrayX;
  CalledByProcedure: boolean;
  GlobalNrStage: integer;
  Y_intermediate: array of  TValueArrayX;
  FinalBetaStar: Assignment.TBetaStar;
  procedure ClearChart();
implementation

{$R *.dfm}

procedure TCustomLineSeries.DrawValue(ValueIndex:Integer);
begin
  //set up the series to draw all the pointers but only some segments
  inherited;
  self.Color := RGB(9, 21, 237);
end;

procedure DrawBinaryTree(X:TValueArrayX);
var i, j, ChartSeriesIndex: integer;
begin
  NrStages := Length(X);
  for i := 0 to NrStages - 1 do
  begin
    j := (i ) mod 2; //If i is odd, 0, else 1
    while(j <= i) AND (i>0) do
    begin
      MainView.BinaryChart.AddSeries(TCustomLineSeries); //Create new Series for line segment
      ChartSeriesIndex := MainView.BinaryChart.SeriesList.Count - 1; //Get the index of the new series
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i - 1, j - 1); //First draw previous point
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i, j); //Then draw stage point

      MainView.BinaryChart.AddSeries(TCustomLineSeries);
      ChartSeriesIndex := MainView.BinaryChart.SeriesList.Count - 1; //Get the index of the new series
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i - 1, j - 1);
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i, j - 2);

      MainView.BinaryChart.AddSeries(TCustomLineSeries);
      ChartSeriesIndex := MainView.BinaryChart.SeriesList.Count - 1; //Get the index of the new series
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i - 1, -j + 1); //Transform over x-axis
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i, - j);

      MainView.BinaryChart.AddSeries(TCustomLineSeries);
      ChartSeriesIndex := MainView.BinaryChart.SeriesList.Count - 1; //Get the index of the new series
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i - 1, -j + 1);//Transform over x-axis
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i, - j + 2);

      Inc(j, 2); // Draw two lines per j, so increment j with two.
    end;
  end;
end;

//Draws the marks next to the chart points
procedure ShowPointValues();
var
  i, j, yValue, ChartSeriesIndex:Integer;
begin
  for i := 0 to NrStages - 1 do
  begin
    MainView.BinaryChart.AddSeries(TPointSeries);
    for j := 0 to i do
    begin
      yValue := i - 2 * j;
      ChartSeriesIndex := MainView.BinaryChart.SeriesList.Count - 1;
      MainView.BinaryChart.Series[ChartSeriesIndex].AddXY(i, yValue);
      MainView.BinaryChart.Series[ChartSeriesIndex].Marks.Visible := True;
      MainView.BinaryChart.Series[ChartSeriesIndex].Marks.Transparent := False;
      MainView.BinaryChart.Series[ChartSeriesIndex].Marks.BackColor := clwhite;
      CalledByProcedure := True;
      MainView.BinaryChart.Series[ChartSeriesIndex].OnGetMarkText := MainView.OnGetMarkText;
      CalledByProcedure := False;
    end;
  end;
end;

//Determines the upper and lower bound of a column vector
function getBorderByStageNr(StageNr:integer):integer;
var
  i, SumValues: integer;
begin
  SumValues := 0;
  for i := 1 to StageNr - 1 do
  begin
    SumValues := SumValues + i;
  end;
  Result := SumValues;
end;

//Determines the stage number by counting the nr of calls of this method
function getStageNumberByValue(Value:integer):integer;
var
  i, ReturnValue :Integer;
begin
  ReturnValue := 0;
  for i := 1 to NrStages do
  begin
    if (getBorderByStageNr(i) <= Value) AND (getBorderByStageNr(i + 1) > Value)  then
    begin
      ReturnValue := i;
      break;
    end;
  end;
  Result := ReturnValue;
end;

//Filling an array with zeroes
procedure emptyArrayWithZeroes(var Arr: TValueArrayX);
var i: integer;
begin
  for i := 0 to High(Arr) do
  begin
    Arr[i] := 0;
  end;
end;

// Builds the content in the mark, is a method pointer.
procedure TMainView.OnGetMarkText(Sender: TChartSeries; ValueIndex: Integer; var MarkText: string);
var
  StageNr:integer;
  BetaValue, Y_Value:double;
begin
  StageNr := getStageNumberByValue(GlobalNrStage);
  if not CalledByProcedure then
  begin
    if StageNr < NrStages then
    begin
      MarkText := '';
      if (Length(FinalBetaStar) > 0) then //Do not draw any Beta's if there arent any
      begin
        BetaValue := FinalBetaStar[high(FinalBetaStar),StageNr - 1, GlobalNrStage - getBorderByStageNr(StageNr)];
        MarkText := ' β*: '+ FloatToStr(BetaValue);
      end;
      Y_Value := Y_Intermediate[StageNr - 1, GlobalNrStage - getBorderByStageNr(StageNr)];
      MarkText := 'Value: ' + Format('%.2f',[Y_Value]) + MarkText;
    end;
    if StageNr = NrStages then
    begin
      Y_Value := Y_Intermediate[StageNr - 1, GlobalNrStage - getBorderByStageNr(StageNr)];
      MarkText := 'Value: ' + Format('%.2f',[Y_Value]);
      setLength(FinalBetaStar,0);
    end;
    If (GlobalNrStage > (getBorderByStageNr(NrStages + 1) - 1)) then
    begin
      GlobalNrStage := 0;
    end;
    GlobalNrStage := GlobalNrStage + 1;
  end;
end;

//Removes all ChartSeries from chart
procedure ClearChart();
var
  i: integer;
begin
  if (MainView.BinaryChart.SeriesList.Count) > 0 then
  begin
    for i := 0 to MainView.BinaryChart.SeriesList.Count - 1 do
    begin
      MainView.BinaryChart.Series[i].Clear;
    end;
  end;
end;

// Copies the Array with data type Main to data type of Assignment
procedure CopyMainArrayToAssignmentArray(MainArray:TValueArrayX;var  AssignmentArray:Assignment.TValueArrayX);
var i:integer;
begin
  for i := 0 to high(MainArray) do
  begin
    AssignmentArray[i] := MainArray[i];
  end;
end;

// Copies the Array with data type of Assignment to data type of Main
procedure CopyAssignmentArrayToMainArray(var MainArray:TValueArrayX; AssignmentArray:Assignment.TValueArrayX);
var i:integer;
begin
  for i := 0 to high(AssignmentArray) do
  begin
    MainArray[i] := AssignmentArray[i];
  end;
end;

// Copies the Array of Array with data type of Assignment to data type of array of array in Main
procedure CopyAssignmentArrayArrayToMainArrayArray(var MainArrayArray:
  Array of TValueArrayX; AssignmentArrayArray:Array of Assignment.TValueArrayX);
var
  i, j:integer;
begin
  for i := 0 to high(AssignmentArrayArray) do
  begin
    for j := 0 to high(AssignmentArrayArray[i]) do
    begin
      MainArrayArray[i,j] := AssignmentArrayArray[i,j];
    end;
  end;
end;

// is used to run the first assignment
procedure TMainView.Button2Click(Sender: TObject);
var
  Input: Assignment.TValueArrayX;
  AlgorithmResult : array of Assignment.TValueArrayX;
  i: Integer;
begin
  GlobalNrStage := 0; //Initialize global counting parameter for plotting the graph as this is done by a method pointer
  ClearChart();  //Clean the chart from old results
  ProbabilityUp := StrToFloat(MainView.EditProbability.Text);
  BetaValue := StrToFloat(MainView.EditBeta.Text);
  K_parameter := StrToInt(MainView.EditParameterK.Text);
  setLength(Input, length(X));
  CopyMainArrayToAssignmentArray(X, Input);
  setLength(AlgorithmResult,length(X));
  setLength(Y_InterMediate, 0);
  setLength(Y_InterMediate, Length(X));
  for i := 0 to High(X) do
  begin
    setLength(AlgorithmResult[i], i+1);
    setLength(Y_intermediate[i],i+1);
  end;
  AlgorithmResult[high(X)] := Input;
  AssignmentA(ProbabilityUp, Input,AlgorithmResult);
  CopyAssignmentArrayToMainArray(X, Input);
  CopyAssignmentArrayArrayToMainArrayArray(Y_Intermediate,AlgorithmResult);
  DrawBinaryTree(X);
  ShowPointValues();
end;

//is used for the second assignment
procedure TMainView.Button3Click(Sender: TObject);
var
  Input: Assignment.TValueArrayX;
  AlgorithmResult : array of Assignment.TValueArrayX;
  i: Integer;
begin
  GlobalNrStage := 0; //Initialize global counting parameter for plotting the graph as this is done by a method pointer
  ClearChart();  //Clean the chart from old results
  ProbabilityUp := StrToFloat(MainView.EditProbability.Text);
  BetaValue := StrToFloat(MainView.EditBeta.Text);
  K_parameter := StrToInt(MainView.EditParameterK.Text);
  setLength(Input, length(X));
  CopyMainArrayToAssignmentArray(X, Input);
  setLength(AlgorithmResult,length(X));
  setLength(Y_InterMediate, 0);
  setLength(Y_InterMediate, Length(X));
  for i := 0 to High(X) do
  begin
    setLength(AlgorithmResult[i], i + 1);
    setLength(Y_intermediate[i],i + 1);
  end;
  AlgorithmResult[high(X)] := Input;
  AssignmentB(ProbabilityUp, BetaValue,Input, AlgorithmResult);
  CopyAssignmentArrayToMainArray(X, Input);
  CopyAssignmentArrayArrayToMainArrayArray(Y_Intermediate,AlgorithmResult);
  DrawBinaryTree(X);
  ShowPointValues();
end;

//Is used to run the third assignment
procedure TMainView.Button1Click(Sender: TObject);
var
  T, tt, K, kk, i: integer;
  Input: Assignment.TValueArrayX;
  AlgorithmResult : array of Assignment.TValueArrayX;
  BetaStar: Assignment.TBetaStar;
begin
  GlobalNrStage := 0; //Initialize global counting parameter for plotting the graph as this is done by a method pointer
  ClearChart();  //Clean the chart from old results
  ProbabilityUp := StrToFloat(MainView.EditProbability.Text);
  BetaValue := StrToFloat(MainView.EditBeta.Text);
  K := StrToInt(MainView.EditParameterK.Text);
  setLength(Input, length(X));
  CopyMainArrayToAssignmentArray(X, Input);
  T := high(X);
  setLength(FinalBetaStar, 0);
  setLength(BetaStar, K + 1);
  for kk := 0 to K do
  begin
    setLength(BetaStar[kk],T);
    for tt := 0 to T - 1 do
    begin
      setLength(BetaStar[kk, tt], T);
    end;
  end;
  setLength(AlgorithmResult, length(X));
  setLength(Y_InterMediate, 0);
  setLength(Y_InterMediate, Length(X));
  for i := 0 to High(X) do
  begin
    setLength(AlgorithmResult[i], i + 1);
    setLength(Y_intermediate[i],i + 1);
  end;
  AlgorithmResult[high(X)] := Input;
  AssignmentC(ProbabilityUp, BetaValue, K, Input, AlgorithmResult, BetaStar);
  CopyAssignmentArrayToMainArray(X, Input);
  CopyAssignmentArrayArrayToMainArrayArray(Y_Intermediate, AlgorithmResult);
  DrawBinaryTree(X);
  FinalBetaStar := BetaStar;
  ShowPointValues(); //Draw marks
end;

procedure TMainView.FormCreate(Sender: TObject);
begin
  MainView.BinaryChart.Hover.Visible := False;
  MainView.BinaryChart.Zoom.Allow := False;
  MainView.BinaryChart.Title.Caption := 'Binary tree';
  System.SysUtils.FormatSettings.DecimalSeparator := '.'; //Set the decimalSeparator to a dot
  ProbabilityUp := StrToFloat(MainView.EditProbability.Text);
  BetaValue := StrToFloat(MainView.EditBeta.Text);
  K_parameter := StrToInt(MainView.EditParameterK.Text);
  X := [0, 0, 0, 0, 0, -10, 0, 0, 0, 0, 0];  //Array with values
end;

end.
