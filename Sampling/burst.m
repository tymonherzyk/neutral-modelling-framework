%burst.m

%Author: Tymon Herzyk
%Last Editied: 21/08/2024
%Version: 1.0
%MATLAB Version: R2020b
%License:


%START BURST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NS,dataFilename,Log] = burst(MainParameters, loadPath)
%Print start message
fprintf('BURST STARTED \n')
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set import settings for loading function parameters from user spreadsheet
importFilename = 'samplingParameters.xlsx';
opts = detectImportOptions(importFilename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'burst';
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
FunctionParameters.burstFrequency = FunctionParametersTable.Value{3};
FunctionParameters.burstSize = FunctionParametersTable.Value{4};
FunctionParameters.sampleFrequency = FunctionParametersTable.Value{5};
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load NS data
load(loadPath, 'NS');
originalNS = NS;
clear NS;
%Extract file naming identifier
originalFilename = extractAfter(loadPath,MainParameters.userFilePath);
originalDataIdentifier = extractBefore(originalFilename,'_');
%Calculate indexing variables
indexStartTimeArray = find(originalNS(:,2)>=FunctionParameters.startTime);
indexStartTime = indexStartTimeArray(1,1);
indexEndTimeArray = find(originalNS(:,2)<=FunctionParameters.endTime);
indexEndTime = indexEndTimeArray(end,1);
indexSampleFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.sampleFrequency));
indexBurstFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.burstFrequency));
indexBurstSize = FunctionParameters.burstSize*indexSampleFrequency;
count = 0;
burstTotal = 0;
for i = indexStartTime:indexBurstFrequency:indexEndTime
    indexBurstTotal = indexStartTime+(indexBurstFrequency*count)+indexBurstSize;
    if indexBurstTotal <= indexEndTime
        burstTotal=burstTotal+1;
    end
    count=count+1;
end
%Initialise NS
 NSTotal = burstTotal*FunctionParameters.burstSize;
 NS(NSTotal,:) = 0;
 NSStart = 1;
%For each burst
for i = 1:burstTotal
    %Calculate start and end point indexing
    indexStartBurst = indexStartTime+(indexBurstFrequency*(i-1));
    indexEndBurst = indexStartBurst+indexBurstSize-1;
    %Calculate NS end point
    NSEnd = NSStart+FunctionParameters.burstSize-1;
    %Copy data points from original NS to new array
    NS(NSStart:NSEnd,1) = originalNS(indexStartBurst:indexSampleFrequency:indexEndBurst,1);
    NS(NSStart:NSEnd,2) = originalNS(indexStartBurst:indexSampleFrequency:indexEndBurst,2);
    %Calculate NS start point for next burst
    NSStart = NSEnd+1;
end
%Calculate total samples and total time
totalSamples = height(NS);
totalTime = NS(end,2)-NS(1,2);
%Check for decimal places in total time
dpCheck = regexp(num2str(totalTime),'\.','split');
%Set number of sig figs for total time
if length(dpCheck) == 2
    dp = length(dpCheck{2});
else
    dp = 0;
end
%Create data filename
dataFilename = sprintf('%s%s_T%.*f_S%d.mat',originalDataIdentifier, MainParameters.additionalIdentifier,dp, totalTime, totalSamples);
%START LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add any required variables to log
Log.FunctionParameters = FunctionParameters;
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('BURST FINISHED \n')
end
%END BURST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%