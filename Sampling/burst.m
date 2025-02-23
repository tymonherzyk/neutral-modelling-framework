%burst.m

%Author: Tymon Alexander Herzyk
%Github: 
%Last Editied: 21/02/2025
%Version: 1.0
%MATLAB Version: R2020b
%License: https://creativecommons.org/licenses/by/4.0/


%START BURST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NS,dataFilename,Log] = burst(MainParameters, loadPath) %start function
fprintf('BURST STARTED \n') %print start message
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
importFilename = 'samplingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'burst';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.startTime = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.endTime = FunctionParametersTable.Value{2};
FunctionParameters.burstFrequency = FunctionParametersTable.Value{3};
FunctionParameters.burstSize = FunctionParametersTable.Value{4};
FunctionParameters.sampleFrequency = FunctionParametersTable.Value{5};
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(loadPath, 'NS'); %load data
originalNS = NS; %save copy of data
clear NS;
originalFilename = extractAfter(loadPath,MainParameters.userFilePath); %extract file name
originalDataIdentifier = extractBefore(originalFilename,'_');
indexStartTimeArray = find(originalNS(:,2)>=FunctionParameters.startTime); %find sampling start point
indexStartTime = indexStartTimeArray(1,1); %set sampling start point
indexEndTimeArray = find(originalNS(:,2)<=FunctionParameters.endTime); %find sampling end point
indexEndTime = indexEndTimeArray(end,1); %set sampling end point
indexSampleFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.sampleFrequency)); %calculate sampling frequency
indexBurstFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.burstFrequency)); %calculate burst frequency
indexBurstSize = FunctionParameters.burstSize*indexSampleFrequency; %calculate burst size
count = 0;
burstTotal = 0;
for i = indexStartTime:indexBurstFrequency:indexEndTime %calculate total number of bursts
    indexBurstTotal = indexStartTime+(indexBurstFrequency*count)+indexBurstSize;
    if indexBurstTotal <= indexEndTime
        burstTotal=burstTotal+1;
    end
    count=count+1;
end
 NSTotal = burstTotal*FunctionParameters.burstSize; %calculate total number of sample points
 NS(NSTotal,:) = 0;
 NSStart = 1;
for i = 1:burstTotal %for each burst
    indexStartBurst = indexStartTime+(indexBurstFrequency*(i-1)); %calculate start and end points
    indexEndBurst = indexStartBurst+indexBurstSize-1;
    NSEnd = NSStart+FunctionParameters.burstSize-1;
    NS(NSStart:NSEnd,1) = originalNS(indexStartBurst:indexSampleFrequency:indexEndBurst,1); %copy desired data points from original NS to new array
    NS(NSStart:NSEnd,2) = originalNS(indexStartBurst:indexSampleFrequency:indexEndBurst,2); %copy desired time points from original NS to new array
    NSStart = NSEnd+1; %set start point for next burst
end
totalSamples = height(NS); %calculate total samples
totalTime = NS(end,2)-NS(1,2); %calculate total time
dpCheck = regexp(num2str(totalTime),'\.','split'); %check for decimal places
if length(dpCheck) == 2 %set number of sig figs
    dp = length(dpCheck{2});
else
    dp = 0;
end
dataFilename = sprintf('%s%s_T%.*f_S%d.mat',originalDataIdentifier, MainParameters.additionalIdentifier,dp, totalTime, totalSamples); %create data filename
Log.FunctionParameters = FunctionParameters; %log function paramaters
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('BURST FINISHED \n') %print end message
end
%END BURST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
