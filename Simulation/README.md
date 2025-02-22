# The Simulation Package
## Introduction
The simulation package acts to simulate the relative abundance od a single species within a community. Within the current state community dynamics can be simulated based on two common neutral models:
1. __Hubbell's purley neutral model__ [[1]](#1).
2. __Sloan et al.'s near-neutral model__ [[2]](#2)

Descriptions of these models are supplied at the associated references. Here the discrete version of each model is used. To simulate the change in abudnance simulations proceed through descrete replacement events with outcomes weighted using the transitional proability equations of each model. A more indepth expalnation of this process is provided in the thesis "_Towards a general theory within wastewater treatment: computational and experimental examples utilising fundamental laws to describe microbial community structure in wastewater treatment systems_".

The architecture of this package is given below:
![Copy of Framework_architecture2](https://github.com/user-attachments/assets/a899504b-72f3-4155-8a40-9d161e42f63d)
_Created in  https://BioRender.com_

Users define the model used to govern community dyanmics alongside operational parameters within the _simulationParameters.xlsx_ spreadsheet. The primary script can then be executed (_simulation.m_) which facilitates the importing of user variables and executes the function pertaining to the model chosen (_hubbelsim.m_ or _sloansim.m_) to facilitate the simulation of the species' relative abundance. Two files are returned by the pacakge, where one is the data file that holds the change in relative abundance of the monitored species, while the other is a log file that houses logged variables. These are saved in the location defined by the user. Below is an in-depth description of each of the files within this package. 

## simulationParameters.xlsx
This spreadsheet holds all user input variables which must be defined for the package to operate. It is made up of three sheets:
* __simulation__
* __hubbellsim__
* __sloansim__

Each sheet holds input variables for the specific script or function of the same name. A full list of all variables and descriptions of these variables are provided below:
![InputVariablesSimulation (1)](https://github.com/user-attachments/assets/e72965dc-cc8b-4a62-bf27-aa5b66fa7a9e)
_Created in  https://BioRender.com_

## simulation.m
This script acts as the sole executable within the fitting package and is tasked with:
1. __Loading input variables from sheet _simulation_ within _simulationParameters.xlsx_.__
3. __Running the chosen function by the user (_hubbellsim_, _sloansim_).__
4. __Saving data and log files__

The _simulation.m_ script begins by loading input variables from the simulation sheet within _simulationParameters.xlsx_. This is achieved through the block of code highlighted below:
```matlab
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
```
Within this code the command `readtable` is used to import variables from the file designated in variable `importFilename`. Importing options defined within the 'opts' data structure. Under default conditions 'readtable' will import all values as string arrays, and thus number variables are converted to number data types through the 'sscanf' command.

The main body of the _simulation.m_ script handles calling the function defined by the user. This is achieved using the following code:
```matlab
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
```
The function (`hubbellsim` or `sloansim`) can be executed multiple times as defined by the variable `runs`, thus multiple relaisations of the simulated dyanmics can be generated.

Once the function has completed running, outputs `NS`, `dataFilename`, and `Log` are passed back to the workspace. The simulated data output `NS` is saved at the location provided by the input variable `saveDataPath`. Additional variables are appended to the `Log` data structure before this is saved. The location where the log file is saved is governed by the string stored within the `saveLogPath` variable. It is important to note that all saving is conducted within the function call loop. This ensures that data is saved after each function call, limiting the loss of data if the package crashes. The code used for saving outputs is provided below:
```matlab
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename); %build full path for saving data
    save(saveDataFullPath,'NS') %save data
```
```matlab
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
```
