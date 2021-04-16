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
var current_col, current_col_length, index : integer;
    val1, val2 : double;
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
var N, i: integer;
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
    current_col, current_col_length, index : integer;
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
    begin
      X[length_index] := ResultArray[current_col][length_index];
    end;
    current_col := current_col - 1;
  end;
end;

// This procedure runs when the Button "Run Assignment 3" is pressed
// Determine the expected value of X
// write result to ResultArray, BetaStar
procedure AssignmentC(p, beta: double; K:integer; X:TValueArrayX; var ResultArray: Array of TValueArrayX; var BetaStar: TBetaStar);
//OWN VARIABLES
var division_factor, nodes, time_steps, current_time_step, current_funds_index, partial_spendings_index: integer;
    spending_size, lowest_value, lowest_beta_star : double;
    beta_wallet : array of double;
    trivial_cases, cases_for_k_bits, temporary_copy, cases_no_funds_spent : array of TValueArrayX;
begin
  //Initialization, check parameters
  //1. Check that Beta >0, K > 0, X has at least two values
  if beta <= 0 then
  begin
    ShowMessage('Beta is not larger than zero.');
  end;

  if K <= 0 then
  begin
    ShowMessage('K is not larger than zero.');
  end;

  if Length(X) < 2 then
  begin
    ShowMessage('X does not contain two or more values');
  end;

  //Set budget, spending size, beta_wallet
  division_factor := K;
  spending_size := beta / division_factor;

  //Inialize wallet based on budget and spelding size.
  setLength(beta_wallet, division_factor + 1);
  for current_funds_index := 0 to division_factor do
  begin
    beta_wallet[current_funds_index] := current_funds_index * spending_size;
  end;

  //Determine how many time steps the model has
  time_steps := Length(X) - 1; //Determine the number of time steps by using the length of column X, which is the column with results.
  //If the model only has 1 time step, the solution is trivial.
  //The trivial solution is:
  setLength(trivial_cases, time_steps + 1);
  trivial_cases[time_steps] := X;
  if time_steps = 1 then
  begin
    ResultArray[time_steps] := EntropicRiskMeasure(ResultArray[time_steps + 1], beta, p);
  end;

  //For all other cases (i.e. time_steps is greater than one, the solution is not trivial,
  //But it can be made trivial by reducing the size of the problem by solving the problem backwards.
  //Initialize BetaStar array to correct size.
  setLength(BetaStar, division_factor + 1);
  for current_funds_index := 0 to division_factor do
  begin
    setLength(BetaStar[current_funds_index], time_steps); //For each budget, there are a time_steps number of time steps available.
    for current_time_step := 0 to time_steps - 1 do
    begin
      setLength(BetaStar[current_funds_index][current_time_step], time_steps);
    end;
  end;

  //We gaan een stuk code schrijven dat voor de laatste tijdstap,
  //voor elk mogelijk budget, uitrekent wat er gebeurt als we een bedrag x uitgeven,
  //waarbij x een bedrag moet zijn wat in onze portemonnee kan zitten.
  setLength(cases_no_funds_spent, division_factor + 1);
  for current_funds_index := 1 to division_factor + 1 do
  begin
    //Compute, for all possible spendings, what the trivial cases would be.
    cases_no_funds_spent[current_funds_index - 1] := EntropicRiskMeasure(X, beta_wallet[current_funds_index - 1], p);
    for current_time_step := 0 to time_steps - 1 do
    begin
      BetaStar[current_funds_index - 1][time_steps - 1][current_time_step] := current_funds_index - 1; //
    end;
  end;

  //This part of the code handles the backwards recursion for non-trivial cases.
  trivial_cases[time_steps - 1] := cases_no_funds_spent[division_factor];
  ResultArray[time_steps - 1] := cases_no_funds_spent[division_factor];
  setLength(temporary_copy, division_factor + 1);
  //Go backwards in time
  for current_time_step := time_steps - 2 downto 0 do
  begin
    //Initialize the temporary array for cases where no beta is spent
    temporary_copy[0] := EntropicRiskMeasure(cases_no_funds_spent[0], 0, p);
    //Initialize the value of betastar to 0 for all nodes
    for nodes := 0 to current_time_step do
    begin
      BetaStar[0][current_time_step][nodes] := 0;
    end;

    //For every possible scenario for the budget left do:
    for current_funds_index := 2 to division_factor + 1 do
    begin
      setLength(cases_for_k_bits, current_funds_index);
      //partial_spendings_index indicates how much money to spend now.
      for partial_spendings_index := 1 to current_funds_index do
      begin //For each spendings and budget, calculate the entropic risk measure).
        cases_for_k_bits[partial_spendings_index - 1] := EntropicRiskMeasure(cases_no_funds_spent[current_funds_index - partial_spendings_index], beta_wallet[partial_spendings_index - 1], p);
      end;

      //For all nodes, calculate:
      for nodes := 0 to current_time_step do
      begin
        //Initialize the minimum value to a high number, and the lowest value for beta star to 0.
        lowest_value := 100;
        lowest_beta_star := 0;

        //For all spendings do:
        for partial_spendings_index := 1 to current_funds_index do
        begin
          //If the new value is lower than the current minimum
          if cases_for_k_bits[partial_spendings_index - 1][nodes] < lowest_value then
          begin
            //Set the new value for the minimum
            lowest_value := cases_for_k_bits[partial_spendings_index - 1][nodes];
            lowest_beta_star := beta_wallet[partial_spendings_index - 1];
          end;
        end;
        //Set array lengths to correct sizes
        setLength(temporary_copy[current_funds_index - 1], current_time_step + 1);
        //Set the lowest value in a temporary copy-array
        temporary_copy[current_funds_index - 1][nodes] := lowest_value;
        //Set optimal values for beta star
        BetaStar[current_funds_index - 1][current_time_step][nodes] := lowest_beta_star;
      end;
    end;
    //Set the input for the next iteration to match the scenario we just evaluated
    cases_no_funds_spent := copy(temporary_copy);
    //Write the results to the array
    ResultArray[current_time_step] := temporary_copy[division_factor];
  end;
end;

//OWN FUNCTIONS
//Function that calculates the value of a certain node based on the next two nodes.
function CalculateValueOfNode(val_node_1, val_node_2 : double;  probability_up : double):double;
begin
  result := val_node_1 * probability_up + val_node_2 * (1 - probability_up);
end;
end.
