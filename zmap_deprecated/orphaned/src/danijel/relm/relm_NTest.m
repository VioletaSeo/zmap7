function [rRelmTest] = relm_NTest(vRatesH, vRatesN, nNumberSimulation, fMagThreshold, bOptimized, bDrawFigure)
% function [rRelmTest] = relm_NTest(vRatesH, vRatesN, nNumberSimulation, fMagThreshold, bOptimized, bDrawFigure)
% --------------------------------------------------------------------------------------------------------------
% Computation of the N-test for the RELM framework
%
% Input parameters:
%   vRatesH                       Matrix with rates of the test hypothesis
%   vRatesN                       Matrix with rates of the null hypothesis
%   nNumberSimulation             Number of random simulations
%   fMagThreshold                 Magnitude threshold (Use only bins with magnitude >= threshold
%   bOptimized                    0 (default): use a for loop, 1: matrix-wise calculation (needs a lot of memory)
%   bDrawFigure                   Draw the cumulative density plot after testing (default: off)
%
% Output paramters:
%   rRelmTest.fAlpha              Alpha-value of the cumulative density
%   rRelmTest.fBeta               Beta-value of the cumulative density
%   rRelmTest.vSimValues_H        Vector containing the sorted simulated numbers of events for the test hypothesis
%   rRelmTest.vSimValues_N        Vector containing the sorted simulated numbers of events for the null hypothesis
%   rRelmTest.nNumberSimulation   Number of random simulations
%   rRelmTest.fObservedData       Observed total number of events
%
% Danijel Schorlemmer
% October 4, 2002

% Exit on empty rate matrices
if isempty(vRatesH)  ||  isempty(vRatesN)
  rRelmTest.fAlpha = nan;
  rRelmTest.fBeta = nan;
  rRelmTest.vSimValues_H = nan;
  rRelmTest.vSimValues_N = nan;
  rRelmTest.nNumberSimulation = nan;
  rRelmTest.fObservedData = nan;
  return;
end

if ~exist('bDrawFigure')
  bDrawFigure = 0;
end

if ~exist('bOptimized')
  bOptimized = 0;
end

% Randomize
rand('state',sum(100*clock));

% Get the necessary data from the rate matrices and weight them properly
[vLambdaH, vLambdaN, vNumberQuake] = relm_PrepareData(vRatesH, vRatesN, fMagThreshold);
nNumberQuake = sum(vNumberQuake);

% Get the number of bins (rows)
[nRow, nColumn] = size(vLambdaH);

if bOptimized
  % Create the random numbers for the simulation
  vRandom = rand(nRow, nNumberSimulation);

  % Replicate the rate vectors
  vLambdaH = repmat(vLambdaH, 1, nNumberSimulation);
  vLambdaN = repmat(vLambdaN, 1, nNumberSimulation);

  % Compute the simulated number of events and sum them up
  vNum_H = poissinv(vRandom, vLambdaH);
  vNum_N = poissinv(vRandom, vLambdaN);
  vSimNum_H = sum(vNum_H);
  vSimNum_N = sum(vNum_N);
else
  % Create empty vectors for the total number of events
  vSimNum_H = [];
  vSimNum_N = [];

  % Loop over the simulations
  for nCnt = 1:nNumberSimulation
    % Create the random numbers for the simulation
    vRandom = rand(nRow, 1);

    % Compute the simulated number of events and sum them up
    vNum_H = poissinv(vRandom, vLambdaH);
    vNum_N = poissinv(vRandom, vLambdaN);
    vSimNum_H = [vSimNum_H; nansum(vNum_H)];
    vSimNum_N = [vSimNum_N; nansum(vNum_N)];
  end
end

% Sort them for the cumulative density plot
rRelmTest.vSimValues_H = sort(vSimNum_H);
rRelmTest.vSimValues_N = sort(vSimNum_N);

% Compute Alpha and Beta and store the important parameters
rRelmTest.fAlpha = sum(rRelmTest.vSimValues_N > nNumberQuake)/nNumberSimulation;
rRelmTest.fBeta = sum(rRelmTest.vSimValues_H < nNumberQuake)/nNumberSimulation;
rRelmTest.nNumberSimulation = nNumberSimulation;
rRelmTest.fObservedData = nNumberQuake;

if bDrawFigure
  relm_PaintCumPlot(rRelmTest, 'Number of earthquakes');
end


