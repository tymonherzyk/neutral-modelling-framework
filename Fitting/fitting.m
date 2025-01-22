%fitting.m

%Author: Tymon Herzyk
%Last Editied: 05/09/2021
%Version: 1.0
%MATLAB Version: R2020b
%License:
%END INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%START FITTING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Clear workspace
clear
%Start timer
tstartSim = tic;
%Print start message
fprintf('FITTING STARTED \n')
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set import settings for loading parameters from user spreadsheet
importFilename = 'fittingParameters.xlsx';
opts = detectImportOptions(importFilename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'fitting';
%Load parameters from user spreadsheet as table
MainParametersTable = readtable(importFilename,opts);
%Change parameters to correct data types
for i = 1:height(MainParametersTable)
    if strcmpi('number',MainParametersTable.Type{i}) 
        MainParametersTable.Value{i} = sscanf(MainParametersTable.Value{i},'%f*');
    end
end
%Store parameters in local data structure
MainParameters.function = MainParametersTable.Value{1};  
MainParameters.loadDataPath = MainParametersTable.Value{2};
MainParameters.saveDataIdentifier = MainParametersTable.Value{3};
MainParameters.saveDataPath = MainParametersTable.Value{4};
MainParameters.saveLogPath = MainParametersTable.Value{5};
fprintf(">>>> Select files for fitting \n")
[MainParameters.userFileNames,MainParameters.userFilePath] = uigetfile(MainParameters.loadDataPath,"Multiselect","on");
if ~iscell(MainParameters.userFileNames)
    MainParameters.userFileNames={MainParameters.userFileNames};
end
MainParameters.userFileTotal = length(MainParameters.userFileNames);
fprintf(">>>> Files Selected: \n")
for i = 1:MainParameters.userFileTotal
    fprintf(">>>> %s \n", string(MainParameters.userFileNames(i)))
end
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%For number of runs
for i = 1:MainParameters.userFileTotal
    %Start timer and store date and time
    tstartRun = tic;
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    %Print start message 
    fprintf('\nFILE %d OF %d STARTED \n',i,MainParameters.userFileTotal)
    %Define file load path
    loadDataFullPath = fullfile(MainParameters.userFilePath,MainParameters.userFileNames(i));
    loadDataFullPath = string(loadDataFullPath);
    %run function defined by user and pass parameters
    if strcmpi('hubbellfit',MainParameters.function)
        [Results,dataFilename,Log] = hubbellfit(MainParameters,loadDataFullPath);
    elseif strcmpi('hubbellsimpfit',MainParameters.function)
        [Results,dataFilename,Log] = hubbellfit(MainParameters,loadDataFullPath);
    elseif strcmpi('sloanfit',MainParameters.function)
        [Results,dataFilename,Log] = sloanfit(MainParameters,loadDataFullPath);
    elseif strcmpi('sloansimpfit',MainParameters.function)
        [Results,dataFilename,Log] = sloanfit(MainParameters,loadDataFullPath);
    end
    %End timer
    tendRun = toc(tstartRun);
%START SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename);
    save(saveDataFullPath,'Results')
    fprintf('>>>> Data Saved As: %s \n',dataFilename)
    fprintf('>>>> Data Saved In: %s \n',MainParameters.saveDataPath)
%END SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Create filename and path for saving log
    logFilename = sprintf('Log_%s',dataFilename);
    saveLogFullPath = append(MainParameters.saveLogPath,logFilename);
    %Add any required variables to log
    Log.RunParameters.originalDataFilename = MainParameters.userFileNames(i);
    Log.RunParameters.dataFilename = dataFilename;
    Log.RunParameters.dataPath = MainParameters.saveDataPath;
    Log.RunParameters.fixedParameters = extractBetween(dataFilename,'fixed','_T');
    Log.RunParameters.logFilename = logFilename;
    Log.RunParameters.logPath = MainParameters.saveLogPath;
    Log.RunParameters.runtime = tendRun;
    Log.RunParameters.datetime = dateTimeRun;
    Log.MainParameters = MainParameters;
    Log = orderfields(Log);
    %Save log
    save(saveLogFullPath,'Log')
    fprintf('>>>> Log Saved As: %s \n',logFilename)
    fprintf('>>>> Log Saved In: %s \n',MainParameters.saveLogPath)
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('FILE %d OF %d FINISHED \n',i,MainParameters.userFileTotal)
end
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nFITTING FINISHED \n')
%END SAMPLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
