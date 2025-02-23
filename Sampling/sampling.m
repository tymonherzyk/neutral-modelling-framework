%sampling.m

%Author: Tymon Alexander Herzyk
%Github: 
%Last Editied: 21/02/2025
%Version: 1.0
%MATLAB Version: R2020b
%License: https://creativecommons.org/licenses/by/4.0/

%START SAMPLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear %clear workspace
tstartSim = tic; %start timer
fprintf('SAMPLING STARTED \n') %print start message
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
importFilename = 'samplingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'sampling';
MainParametersTable = readtable(importFilename,opts); %load parameters from user spreadsheet as table
for i = 1:height(MainParametersTable) %change parameters to correct data types
    if strcmpi('number',MainParametersTable.Type{i}) 
        MainParametersTable.Value{i} = sscanf(MainParametersTable.Value{i},'%f*');
    end
end
MainParameters.function = MainParametersTable.Value{1}; %store parameters in local data structure
MainParameters.loadDataPath = MainParametersTable.Value{2};
MainParameters.saveDataIdentifier = MainParametersTable.Value{3};
MainParameters.saveDataPath = MainParametersTable.Value{4};
MainParameters.saveLogPath = MainParametersTable.Value{5};
fprintf(">>>> Select files for sampling \n")
[MainParameters.userFileNames,MainParameters.userFilePath] = uigetfile(MainParameters.loadDataPath,"Multiselect","on"); %open dialog box to select data files
if ~iscell(MainParameters.userFileNames) %store filenames of selected data files
    MainParameters.userFileNames={MainParameters.userFileNames};
end
MainParameters.userFileTotal = length(MainParameters.userFileNames); %store total number of selected data files
fprintf(">>>> Files Selected: \n")
for i = 1:MainParameters.userFileTotal %print selected files to user
    fprintf(">>>> %s \n", string(MainParameters.userFileNames(i)))
end
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:MainParameters.userFileTotal %for total number of files
    tstartRun = tic; %start timer and store date and time
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('\nFILE %d OF %d STARTED \n',i,MainParameters.userFileTotal) %print start message 
    loadDataFullPath = fullfile(MainParameters.userFilePath,MainParameters.userFileNames(i)); %define data file load path
    loadDataFullPath = string(loadDataFullPath);
    if strcmpi('even',MainParameters.function) %run function defined by user and pass parameters
        [NS,dataFilename,Log] = even(MainParameters,loadDataFullPath);
    elseif strcmpi('burst',MainParameters.function)
        [NS,dataFilename,Log] = burst(MainParameters,loadDataFullPath);
    end
    tendRun = toc(tstartRun); 
%START SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename); %build full path for saving data
    save(saveDataFullPath,'NS') %save data
    fprintf('>>>> Data Saved As: %s \n',dataFilename) %print save filename to user
    fprintf('>>>> Data Saved In: %s \n',MainParameters.saveDataPath) %print save location to user
%END SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    logFilename = sprintf('Log_%s',dataFilename); %build full path for saving log
    saveLogFullPath = append(MainParameters.saveLogPath,logFilename);
    Log.RunParameters.originalDataFilename = MainParameters.userFileNames(i); %add additonal variables to log
    Log.RunParameters.totalTime = str2double(extractBetween(dataFilename,'_T','_S'));
    Log.RunParameters.totalSamples = str2double(extractBetween(dataFilename,'_S','.mat'));
    Log.RunParameters.dataFilename = dataFilename;
    Log.RunParameters.dataPath = MainParameters.saveDataPath;
    Log.RunParameters.logFilename = logFilename;
    Log.RunParameters.logPath = MainParameters.saveLogPath;
    Log.RunParameters.runtime = tendRun;
    Log.RunParameters.datetime = dateTimeRun;
    Log.MainParameters = MainParameters;
    Log = orderfields(Log);
    save(saveLogFullPath,'Log') %save log
    fprintf('>>>> Log Saved As: %s \n',logFilename) %print save filename to user
    fprintf('>>>> Log Saved In: %s \n',MainParameters.saveLogPath) %print save location to user
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('FILE %d OF %d FINISHED \n',i,MainParameters.userFileTotal) %print end message
end
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nSAMPLING FINISHED \n') %print end message
%END SAMPLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
