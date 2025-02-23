%even.m

%Author: Tymon Alexander Herzyk
%Github: 
%Last Editied: 21/02/2025
%Version: 1.0
%MATLAB Version: R2020b
%License: https://creativecommons.org/licenses/by/4.0/

%START EVEN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NS,dataFilename,Log] = even(MainParameters, loadPath) %start function
fprintf('EVEN STARTED \n') %print start message
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
importFilename = 'samplingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'even';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.startTime = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.endTime = FunctionParametersTable.Value{2};
FunctionParameters.sampleFrequency = FunctionParametersTable.Value{3};   
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(loadPath,'NS'); %load data
originalNS = NS; %save copy of data
clear NS
originalFilename = extractAfter(loadPath,MainParameters.userFilePath); %extract file name
originalDataIdentifier = extractBefore(originalFilename,'_');
indexStartTimeArray = find(originalNS(:,2)>=FunctionParameters.startTime); %find sampling start point
indexStartTime = indexStartTimeArray(1,1); %set sampling start point
indexEndTimeArray = find(originalNS(:,2)<=FunctionParameters.endTime); %find sampling end point
indexEndTime = indexEndTimeArray(end,1); %set sampling end point
indexSampleFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.sampleFrequency)); %calculate sampling frequency
NS(:,1) = originalNS(indexStartTime:indexSampleFrequency:indexEndTime, 1); %copy desired data points from original NS to new array
NS(:,2) = originalNS(indexStartTime:indexSampleFrequency:indexEndTime, 2); %copy desired time points from original NS to new array
dpCheck = regexp(num2str(FunctionParameters.sampleFrequency),'\.','split'); %check for decimal places
if length(dpCheck) == 2 %set number of sig figs
    dp = length(dpCheck{2});
else
    dp = 0;
end
NS(:,2) = round(NS(:,2)-NS(1,2),dp);
totalSamples = height(NS); %calculate total samples
totalTime = NS(end,2); %calculate total time
dpCheck = regexp(num2str(totalTime),'\.','split'); %check for decimal places
if length(dpCheck) == 2 %set number of sig figs
    dp = length(dpCheck{2});
else
    dp = 0;
end
dataFilename = sprintf('%s%s_T%.*f_S%d.mat',originalDataIdentifier, MainParameters.saveDataIdentifier,dp, totalTime, totalSamples); %create data filename
Log.FunctionParameters = FunctionParameters; %log function paramaters
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('EVEN FINISHED \n') %print end message
end
%END EVEN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
