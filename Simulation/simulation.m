%simulation.m

%START INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Description: This function will simulate a set number of individual
%replacements within a population
%Author: Tymon Herzyk
%Last Editied: 05/09/2021
%Version: 1.0
%MATLAB Version: R2020b
%License:
%END INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%START SIMULATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
tstartSim = tic;
fprintf('SIMULATION STARTED \n')
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = 'simulationParameters.xlsx';
opts = detectImportOptions(filename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'simulation';
MainParametersTable = readtable(filename,opts);
for i = 1:height(MainParametersTable)
    if strcmpi('number',MainParametersTable.Type{i}) 
        MainParametersTable.Value{i} = sscanf(MainParametersTable.Value{i},'%f*');
    end
end
MainParameters.function = MainParametersTable.Value{1};  
MainParameters.runs = MainParametersTable.Value{2};
MainParameters.simtime = MainParametersTable.Value{3};
MainParameters.seed = MainParametersTable.Value{4};
MainParameters.generator = MainParametersTable.Value{5};
MainParameters.saveDataIdentifier = MainParametersTable.Value{6};
MainParameters.saveDataPath = MainParametersTable.Value{7};
MainParameters.saveLogPath = MainParametersTable.Value{8};
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:MainParameters.runs
    fprintf('RUN %d OF %d STARTED \n',i,MainParameters.runs)
    tstartRun = tic;
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    run = i;
    if strcmpi('hubbellsim',MainParameters.function) 
        [NS,dataFilename,Log] = hubbellsim(MainParameters,run);
    elseif strcmpi('sloansim',MainParameters.function)
        [NS,dataFilename,Log] = sloansim(MainParameters,run);
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
    Log.RunParameters.dataFilename = dataFilename;
    Log.RunParameters.dataPath = MainParameters.saveDataPath;
    Log.RunParameters.logName = logFilename;
    Log.RunParameters.logPath = MainParameters.saveLogPath;
    Log.RunParameters.runtime = tendRun;
    Log.RunParameters.datetime = dateTimeRun;
    Log.RunParameters.run = i;
    Log.MainParameters = MainParameters;
    Log = orderfields(Log);
    save(saveLogFullPath,'Log')
    fprintf('>>>> Log Saved As: %s \n',logFilename)
    fprintf('>>>> Log Saved In: %s \n',MainParameters.saveLogPath)
%END LOGGING%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('RUN %d OF %d FINISHED \n',i,MainParameters.runs)
end
fprintf('SIMULATION FINISHED \n')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%