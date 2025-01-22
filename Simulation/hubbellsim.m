%hubbellsim.m

%INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description: This function will simulate a set number of individual 
%replacements within a population
%Author: Tymon Herzyk
%Last Editied: 05/09/2021
%Version: 1.0
%MATLAB Version: R2020b
%License:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%INITIALISATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NS,dataFilename,Log] = hubbellsim(MainParameters,run)
%Print hubbell start message
fprintf('HUBBELL STARTED \n')
%Set import settings for loading function parameters from user spreadsheet
filename = 'simulationParameters.xlsx';
opts = detectImportOptions(filename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'hubbellsim';
%Load function parameters from user spreadsheet as table
functionParamsTable = readtable(filename,opts);
%Change function parameters to correct data types
for i = 1:height(functionParamsTable)
    if strcmpi('number',functionParamsTable.Type{i}) 
        functionParamsTable.Value{i} = sscanf(functionParamsTable.Value{i},'%f*');
    end
end
%Store function parameters in data structure
FunctionParameters.nt = functionParamsTable.Value{1};
FunctionParameters.eta = functionParamsTable.Value{2};
FunctionParameters.m = functionParamsTable.Value{3};
FunctionParameters.p = functionParamsTable.Value{4};
FunctionParameters.sra = functionParamsTable.Value{5};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%MAIN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Define Local Variables
randomSeed = rng(MainParameters.seed,MainParameters.generator);
replaceNo = MainParameters.simtime/FunctionParameters.eta;
i = 1;
NS = zeros(replaceNo+1, 2);
NS(i,1) = FunctionParameters.sra*FunctionParameters.nt; 
%For number of replacement events
for i = 2:replaceNo+1
    %Define abundance value
    ni = NS(i-1,1);
    %Calculate transitional probabilities
    prob1=((FunctionParameters.nt-ni)/FunctionParameters.nt)*((FunctionParameters.m*FunctionParameters.p)+(1-FunctionParameters.m)*(ni/(FunctionParameters.nt-1)));
    prob2=(ni/FunctionParameters.nt)*((FunctionParameters.m*(1-FunctionParameters.p))+(1-FunctionParameters.m)*((FunctionParameters.nt-ni)/(FunctionParameters.nt-1)));
    prob3=1-prob1-prob2;
    %Change abundance as required given where random number falls
    x = rand();
    %Species abundance increases by 1
    if x <= prob1
        NS(i,1) = ni+1;
    %Species abundance decreases by 1
    elseif x > prob1 && x <= prob1+prob2
        NS(i,1) = ni-1;
    %Species abundance stays the same
    elseif x > prob1+prob2 && x <= prob1+prob2+prob3
        NS(i,1) = ni;
    end
    %Calculate and print current timestep
    timeTaken = (i-1)*FunctionParameters.eta;
    NS(i,2) = timeTaken;
    fprintf('>>>> Simulation Time: %.2f \n',timeTaken)
end
NS(:,1) = NS(:,1)/FunctionParameters.nt;
%Calculate total samples and total time
totalSamples = height(NS);
totalTime = MainParameters.simtime;
%Check for decimal places in total time
dpCheck = regexp(num2str(totalTime),'\.','split');
%Set number of sig figs for total time
if length(dpCheck) == 2
    dp = length(dpCheck{2});
else
    dp = 0;
end
%Create data filename
dataFilename = sprintf('%srun%d_T%.*f_S%d.mat',MainParameters.saveDataIdentifier, run, dp, totalTime, totalSamples);
%Store parameters for log
Log.FunctionParameters = FunctionParameters;
Log.RunParameters.randomSeed = randomSeed;
Log.RunParameters.totalReplacements = replaceNo;
Log.RunParameters.totalSamplePoints = i;
%Print hubbell end message
fprintf('HUBBELL FINISHED \n')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%