%sampling.m

%START INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description: This function will simulate a set number of individual
%replacements within a population
%Author: Tymon Herzyk
%Last Editied: 05/09/2021
%Version: 1.0
%MATLAB Version: R2020b
%License:
%END INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%START SAMPLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
tstartSim = tic;
fprintf('SAMPLING STARTED \n')
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
importFilename = 'samplingParameters.xlsx';
opts = detectImportOptions(importFilename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'sampling';
MainParametersTable = readtable(importFilename,opts);
for i = 1:height(MainParametersTable)
    if strcmpi('number',MainParametersTable.Type{i}) 
        MainParametersTable.Value{i} = sscanf(MainParametersTable.Value{i},'%f*');
    end
end
MainParameters.function = MainParametersTable.Value{1};  
MainParameters.loadDataPath = MainParametersTable.Value{2};
MainParameters.saveDataIdentifier = MainParametersTable.Value{3};
MainParameters.saveDataPath = MainParametersTable.Value{4};
MainParameters.saveLogPath = MainParametersTable.Value{5};
fprintf(">>>> Select files for sampling \n")
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
for i = 1:MainParameters.userFileTotal
    tstartRun = tic;
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('\nFILE %d OF %d STARTED \n',i,MainParameters.userFileTotal)
    loadDataFullPath = fullfile(MainParameters.userFilePath,MainParameters.userFileNames(i));
    loadDataFullPath = string(loadDataFullPath);
    if strcmpi('even',MainParameters.function) 
        [NS,dataFilename,Log] = even(MainParameters,loadDataFullPath);
    elseif strcmpi('burst',MainParameters.function)
        [NS,dataFilename,Log] = burst(MainParameters,loadDataFullPath);
    end
    tendRun = toc(tstartRun); 
%START SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename);
    save(saveDataFullPath,'NS')
    fprintf('>>>> Data Saved As: %s \n',dataFilename)
    fprintf('>>>> Data Saved In: %s \n',MainParameters.saveDataPath)
%END SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    logFilename = sprintf('Log_%s',dataFilename);
    saveLogFullPath = append(MainParameters.saveLogPath,logFilename);
    Log.RunParameters.originalDataFilename = MainParameters.userFileNames(i);
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
    save(saveLogFullPath,'Log')
    fprintf('>>>> Log Saved As: %s \n',logFilename)
    fprintf('>>>> Log Saved In: %s \n',MainParameters.saveLogPath)
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('FILE %d OF %d FINISHED \n',i,MainParameters.userFileTotal)
end
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('\nSAMPLING FINISHED \n')
%END SAMPLING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%