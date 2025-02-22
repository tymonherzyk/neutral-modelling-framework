%hubbellsim.m

%Author: Tymon Alexander Herzyk
%Github: 
%Last Editied: 21/02/2025
%Version: 1.0
%MATLAB Version: R2020b
%License: https://creativecommons.org/licenses/by/4.0/

%START HUBBELLSIM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NS,dataFilename,Log] = hubbellsim(MainParameters,run) %start function
fprintf('HUBBELL STARTED \n') %print hubbell start message
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
importFilename = 'simulationParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'hubbellsim';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.nt = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.eta = FunctionParametersTable.Value{2};
FunctionParameters.m = FunctionParametersTable.Value{3};
FunctionParameters.p = FunctionParametersTable.Value{4};
FunctionParameters.sra = FunctionParametersTable.Value{5};
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
randomSeed = rng(MainParameters.seed,MainParameters.generator); %set random seed
replaceNo = MainParameters.simtime/FunctionParameters.eta; %calculate number of replacement events
i = 1;
NS = zeros(replaceNo+1, 2); %intialise NS
NS(i,1) = FunctionParameters.sra*FunctionParameters.nt; %set starting value
for i = 2:replaceNo+1 %for number of replacement events
    ni = NS(i-1,1); %define current abundance value
    prob1=((FunctionParameters.nt-ni)/FunctionParameters.nt)*((FunctionParameters.m*FunctionParameters.p)+(1-FunctionParameters.m)*(ni/(FunctionParameters.nt-1))); %calculate transitional probabilities
    prob2=(ni/FunctionParameters.nt)*((FunctionParameters.m*(1-FunctionParameters.p))+(1-FunctionParameters.m)*((FunctionParameters.nt-ni)/(FunctionParameters.nt-1))); %calculate transitional probabilities
    prob3=1-prob1-prob2; %calculate transitional probabilities
    x = rand(); %define random number
    if x <= prob1
        NS(i,1) = ni+1; %species abundance increases by 1
    elseif x > prob1 && x <= prob1+prob2
        NS(i,1) = ni-1; %species abundance decreases by 1
    elseif x > prob1+prob2 && x <= prob1+prob2+prob3
        NS(i,1) = ni; %species abundance stays the same
    end
    timeTaken = (i-1)*FunctionParameters.eta; %calculate and print current timestep
    NS(i,2) = timeTaken; %store current time step
    fprintf('>>>> Simulation Time: %.2f \n',timeTaken) %print current time step
end
NS(:,1) = NS(:,1)/FunctionParameters.nt; %calculate total samples and total time
totalSamples = height(NS);
totalTime = MainParameters.simtime;
dpCheck = regexp(num2str(totalTime),'\.','split'); %check for decimal places in total time
if length(dpCheck) == 2 %set number of sig figs for total time
    dp = length(dpCheck{2});
else
    dp = 0;
end
dataFilename = sprintf('%srun%d_T%.*f_S%d.mat',MainParameters.saveDataIdentifier, run, dp, totalTime, totalSamples); %create data filename
Log.FunctionParameters = FunctionParameters; %store parameters for log
Log.RunParameters.randomSeed = randomSeed;
Log.RunParameters.totalReplacements = replaceNo;
Log.RunParameters.totalSamplePoints = i;
fprintf('HUBBELL FINISHED \n') %print hubbell end message
end
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END HUBBELLFIT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
