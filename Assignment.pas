unit Assignment;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  Vcl.ExtCtrls, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, Vcl.StdCtrls, math;

type
  TValueArrayX = array of double;
  TBetaStar = array of array of array of double;

procedure AssignmentA(p: double; X:TValueArrayX; var ResultArray: array of TValueArrayX);
procedure AssignmentB(p, Beta: double; X:TValueArrayX; var ResultArray: array of TValueArrayX);
procedure AssignmentC(p, beta: double; K:integer; X:TValueArrayX; var ResultArray: Array of TValueArrayX; var BetaStar: TBetaStar);


//OWN FUNCTIONS
function CalculateValueOfNode(val_node_1, val_node_2 : double;  probability_up : double):double;
implementation
// This procedure runs when the Button "Run Assignment 1" is pressed
// Determine the expected value of X
// write result to ResultArray
procedure AssignmentA(p: double; X:TValueArrayX; var ResultArray: array of TValueArrayX);
var number_of_columns, current_col, current_col_length, index : integer;
    val1, val2 : double;
    col_index: Integer; //Values of the next nodes
begin
  current_col := Length(ResultArray) - 2;
  while current_col >= 0 do
  begin


    //Calculate 1 column
    current_col_length := Length(ResultArray[current_col]);
    for index := 0 to current_col_length - 1 do
    begin
      val1 := ResultArray[current_col + 1][index];
      val2 := ResultArray[current_col + 1][index + 1];
      ResultArray[current_col][index] := CalculateValueOfNode(val1, val2, p);
    end;
    //Proceed to next column:
    current_col := current_col - 1;
  end;
end;

function EntropicRiskMeasure(X_input:TValueArrayX; Beta, p: double):TValueArrayX; //With p the probability for an up-branch, Beta the stress unit
var
  N, i: integer;
  Xu, Xd, M: TValueArrayX;
begin
  //Initialize
  N := Length(X_input);
  setLength(Xu, N - 1);
  setLength(Xd, N - 1);
  Xu := Copy(X_input, 0, N - 1);
  Xd := Copy(X_input, 1, N);
  setLength(M, N-1);
  for i := 0 to N - 2 do
  begin // take conditional mean out of exponential to avoid numerical problems
    M[i] := p * Xu[i] + (1-p) * Xd[i];
  end;
  if Beta = 0 then //If there is no risk parameter beta then this is just the result
  begin
    Result := M;
  end
  else
  begin
    for i := 0 to N - 2 do
    begin
      Xu[i] := p * Exp(-Beta * (Xu[i] - M[i])); //A vector with the expected values for the price to go up
      Xd[i] := (1 - p) * Exp(-Beta * (Xd[i] - M[i])); //A vector with the expected values for the price to go down
      M[i] := M[i] - (Ln(Xu[i] + Xd[i])/Beta);
    end;
    Result := M;
  end;
end;

// Next procedure runs when the Button "Run Assignment 2" is pressed
// Determine the expected value of X using the Entropic Risk Measure
// write result to ResultArray
procedure AssignmentB(p, Beta: double; X:TValueArrayX; var ResultArray: array of TValueArrayX);
var output_array : TValueArrayX;
    number_of_columns, current_col, current_col_length, index : integer;
    val1, val2 : double;
    col_index: Integer;
    length_index: Integer; //Values of the next nodes
begin
  current_col := Length(ResultArray) - 2;
  while current_col >= 0 do
    begin
    //X is the input array
    //output_array is the output array of the function, which is in column X - 1;
    output_array := EntropicRiskMeasure(X, Beta, p);
    //Calculate 1 column
    current_col_length := Length(ResultArray[current_col]);
    for index := 0 to current_col_length - 1 do
    begin
      ResultArray[current_col][index] := output_array[index];
    end;
    SetLength(X, current_col + 1);
    for length_index := 0 to current_col - 1 do
      X[length_index] := ResultArray[current_col][length_index];
    current_col := current_col - 1;
  end;
end;

// This procedure runs when the Button "Run Assignment 3" is pressed
// Determine the expected value of X
// write result to ResultArray, BetaStar
procedure AssignmentC(p, beta: double; K:integer; X:TValueArrayX; var ResultArray: Array of TValueArrayX; var BetaStar: TBetaStar);
var
budget : double; //budget is beta
spending_size : double; //Spending size;
division_factor : integer; //Division factor
beta_wallet : array of double; //Wallet-like object;
index: Integer; //Wallet for beta budget
time_steps : Integer; //Tracks number of steps
current_time_step : Integer; //Index for time steps;





ValueHere : TValueArrayX;

//OWN VARIABLES
begin
  //Initialization, check parameters
  //1. Check that Beta >0, K > 0, X has at least two values
  if beta <= 0 then
    ShowMessage('Beta is not larger than zero.');

  if K <= 0 then
    ShowMessage('K is not larger than zero.');

  if Length(X) < 2 then
    ShowMessage('X does not contain two or more values');







    //Set budget, spending size, beta_wallet
    budget := beta;
    division_factor := K;
    spending_size := beta / division_factor;

    //Inialize wallet based on budget and spelding size.
    setLength(beta_wallet, division_factor + 1);
    for index := 0 to division_factor do
    begin
      beta_wallet[index] := index * spending_size;
    end;


    //Determine how many time steps the model has
    time_steps := Length(X) - 1; //Determine the number of time steps by using the length of column X, which is the column with results.


    //If the model only has 1 time step, the solution is trivial.
    //The trivial solution is:
    setLength(ValueHere, time_steps);
    if time_steps = 1 then
    begin
      ValueHere := EntropicRiskMeasure(X, beta, p);
    end;



    ShowMessage('K is not larger than zero.');



end;



//OWN FUNCTIONS
//Function that calculates the value of a certain node based on the next two nodes.
function CalculateValueOfNode(val_node_1, val_node_2 : double;  probability_up : double):double;
begin
  result := val_node_1 * probability_up + val_node_2 * (1 - probability_up);
end;

end.

