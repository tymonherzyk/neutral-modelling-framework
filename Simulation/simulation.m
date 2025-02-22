%simulation.m

%Author: Tymon Alexander Herzyk
%Github: 
%Last Editied: 21/02/2025
%Version: 1.0
%MATLAB Version: R2020b
%License: https://creativecommons.org/licenses/by/4.0/

%START SIMULATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear %clear workspace
tstartSim = tic; %start timer
fprintf('SIMULATION STARTED \n') %print start message
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
importFilename = 'simulationParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'simulation';
MainParametersTable = readtable(importFilename,opts); %load parameters from user spreadsheet as table
for i = 1:height(MainParametersTable) %change parameters to correct data types
    if strcmpi('number',MainParametersTable.Type{i}) 
        MainParametersTable.Value{i} = sscanf(MainParametersTable.Value{i},'%f*');
    end
end
MainParameters.function = MainParametersTable.Value{1}; %store parameters in local data structure  
MainParameters.runs = MainParametersTable.Value{2};
MainParameters.simtime = MainParametersTable.Value{3};
MainParameters.seed = MainParametersTable.Value{4};
MainParameters.generator = MainParametersTable.Value{5};
MainParameters.saveDataIdentifier = MainParametersTable.Value{6};
MainParameters.saveDataPath = MainParametersTable.Value{7};
MainParameters.saveLogPath = MainParametersTable.Value{8};
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:MainParameters.runs %for number of runs
    fprintf('RUN %d OF %d STARTED \n',i,MainParameters.runs) %start timer and store date and time
    tstartRun = tic; %start timer and store date and time
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    run = i;
    if strcmpi('hubbellsim',MainParameters.function) %run function defined by user and pass parameters
        [NS,dataFilename,Log] = hubbellsim(MainParameters,run);
    elseif strcmpi('sloansim',MainParameters.function)
        [NS,dataFilename,Log] = sloansim(MainParameters,run);
    end
    tendRun = toc(tstartRun); %end timer
%START SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename); %build full path for saving data
    save(saveDataFullPath,'NS') %save data
    fprintf('>>>> Data Saved As: %s \n',dataFilename) %print save filename to user
    fprintf('>>>> Data Saved In: %s \n',MainParameters.saveDataPath) %print save location to user
%END SAVING DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    logFilename = sprintf('Log_%s',dataFilename); %build full path for saving data
    saveLogFullPath = append(MainParameters.saveLogPath,logFilename);
    Log.RunParameters.dataFilename = dataFilename; %add additonal variables to log
    Log.RunParameters.dataPath = MainParameters.saveDataPath;
    Log.RunParameters.logName = logFilename;
    Log.RunParameters.logPath = MainParameters.saveLogPath;
    Log.RunParameters.runtime = tendRun;
    Log.RunParameters.datetime = dateTimeRun;
    Log.RunParameters.run = i;
    Log.MainParameters = MainParameters;
    Log = orderfields(Log); %order log
    save(saveLogFullPath,'Log') %save log
    fprintf('>>>> Log Saved As: %s \n',logFilename) %print save filename to user
    fprintf('>>>> Log Saved In: %s \n',MainParameters.saveLogPath) %print save location to user
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('RUN %d OF %d FINISHED \n',i,MainParameters.runs) %print end message
end
%END MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('SIMULATION FINISHED \n') %print end message
%END SIMULATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
