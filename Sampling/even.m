%even.m

%Author: Tymon Herzyk
%Last Editied: 21/08/2024
%Version: 1.0
%MATLAB Version: R2020b
%License:

%START EVEN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NS,dataFilename,Log] = even(MainParameters, loadPath)
fprintf('EVEN STARTED \n')
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set import settings for loading function parameters from user spreadsheet
importFilename = 'samplingParameters.xlsx';
opts = detectImportOptions(importFilename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'even';
%Load function parameters from user spreadsheet as table
FunctionParametersTable = readtable(importFilename,opts);
%Change function parameters to correct data types
for i = 1:height(FunctionParametersTable)
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
%Store function parameters in local data structure
FunctionParameters.startTime = FunctionParametersTable.Value{1};
FunctionParameters.endTime = FunctionParametersTable.Value{2};
FunctionParameters.sampleFrequency = FunctionParametersTable.Value{3};   
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load NS data
load(loadPath,'NS');
originalNS = NS;
clear NS
%Extract file naming identifier
originalFilename = extractAfter(loadPath,MainParameters.userFilePath);
originalDataIdentifier = extractBefore(originalFilename,'_');
%Calculate indexing variables
indexStartTimeArray = find(originalNS(:,2)>=FunctionParameters.startTime);
indexStartTime = indexStartTimeArray(1,1);
indexEndTimeArray = find(originalNS(:,2)<=FunctionParameters.endTime);
indexEndTime = indexEndTimeArray(end,1);
indexSampleFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.sampleFrequency));
%Copy data points from original NS to new array
NS(:,1) = originalNS(indexStartTime:indexSampleFrequency:indexEndTime, 1);
NS(:,2) = originalNS(indexStartTime:indexSampleFrequency:indexEndTime, 2);
%Check for decimal places in sample frequency
dpCheck = regexp(num2str(FunctionParameters.sampleFrequency),'\.','split');
if length(dpCheck) == 2
    dp = length(dpCheck{2});
else
    dp = 0;
end
NS(:,2) = round(NS(:,2)-NS(1,2),dp);
%Calculate total samples and total time
totalSamples = height(NS);
totalTime = NS(end,2);
%Check for decimal places in total time
dpCheck = regexp(num2str(totalTime),'\.','split');
%Set number of sig figs for total time
if length(dpCheck) == 2
    dp = length(dpCheck{2});
else
    dp = 0;
end
%Create data filename
dataFilename = sprintf('%s%s_T%.*f_S%d.mat',originalDataIdentifier, MainParameters.saveDataIdentifier,dp, totalTime, totalSamples);
%START LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Log.FunctionParameters = FunctionParameters;
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('EVEN FINISHED \n')
end
%END EVEN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%