# The Simulation Package
## Introduction
The simulation package acts to simulate the relative abundance od a single species within a community. Within the current state community dynamics can be simulated based on two common neutral models:
1. __Hubbell's purley neutral model__ [[1]](#1).
2. __Sloan et al.'s near-neutral model__ [[2]](#2)

Descriptions of these models are supplied at the associated references. Here the discrete version of each model is used. To simulate the change in abudnance simulations proceed through descrete replacement events with outcomes weighted using the transitional proability equations of each model. A more indepth expalnation of this process is provided in the thesis "_Towards a general theory within wastewater treatment: computational and experimental examples utilising fundamental laws to describe microbial community structure in wastewater treatment systems_".

The architecture of this package is given below:
![Copy of Framework_architecture2](https://github.com/user-attachments/assets/a899504b-72f3-4155-8a40-9d161e42f63d)
_Created in  https://BioRender.com_

Users define the model used to govern community dyanmics alongside operational parameters within the _simulationParameters.xlsx_ spreadsheet. The primary script can then be executed (_simulation.m_) which facilitates the importing of user variables and executes the function pertaining to the model chosen (_hubbelsim.m_ or _sloansim.m_) to facilitate the simulation of the species' relative abundance. Two files are returned by the pacakge, where one is the data file that holds the relative abundance of the monitored species, while the other is a log file that houses logged variables. These are saved in the location defined by the user. Below is an in-depth description of each of the files within this package:
* [simulationParameters.xlsx](#simulationparametersxlsx)
* [simulation.m](#simulationm)
* [hubbellsim.m](#hubbellsimm)
* [sloansim.m](#sloansimm)

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


## hubbellsim.m
The _hubbellsim.m_ function simulates the change in the relative abundance of a single species within a community governed by the dynamics described by Hubbell's neutral model [[1]](#1). The function begins by loading parameters from the _hubbellsim_ sheet within _simulationParameters.xlsx_. These parameters are stored locally in a data structure named `FunctionParameters` as shown below:
```matlab
importFilename = 'simulationParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'hubbellsim';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.nt = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.eta = FunctionParametersTable.Value{2};
FunctionParameters.m = FunctionParametersTable.Value{3};
FunctionParameters.p = FunctionParametersTable.Value{4};
FunctionParameters.sra = FunctionParametersTable.Value{5};
```

Before changes in relative abundance can be simulated some local variables must be defined. Firstly, the random number generator is initialised by setting its control based on input parameters `seed` and `generator`. As simulation occurs based on discrete replace evens the total number of events must be defined by dividing the desired simulation period `simtime` by the average time between replacement events `eta`. The array for holding the simulated data `NS` is then initialised and the starting abundance of the monitored species `NS(1,1)` is set using the variable `sra` defined by the user. These processes areachieved using the following code:
```matlab
randomSeed = rng(MainParameters.seed,MainParameters.generator); %set random seed
replaceNo = MainParameters.simtime/FunctionParameters.eta; %calculate number of replacement events
i = 1;
NS = zeros(replaceNo+1, 2); %intialise NS
NS(i,1) = FunctionParameters.sra*FunctionParameters.nt; %set starting value
```

The function operates in distinct replacement events refering to a change in time of length `eta`. Each replacement event can envoke a possibility of three unique changes in the abundance of the monitored species: the abundance increases by an individual, stays the same, or decreases by an individual. The probability that each outcome will occur within a community is governed by the transitional probability equations relating to Hubbell's neutral model. The abundace of the monitored species after each repalcement event is stored in `NS` alongside the time that has passed. This process is achieved using the following code:
```matlab
for i = 2:replaceNo+1 %for number of replacement events
    ni = NS(i-1,1); %define current abundance value
    prob1=((FunctionParameters.nt-ni)/FunctionParameters.nt)*((FunctionParameters.m*FunctionParameters.p)+(1-FunctionParameters.m)*(ni/(FunctionParameters.nt-1))); %calculate transitional probabilities
    prob2=(ni/FunctionParameters.nt)*((FunctionParameters.m*(1-FunctionParameters.p))+(1-FunctionParameters.m)*((FunctionParameters.nt-ni)/(FunctionParameters.nt-1))); %calculate transitional probabilities
    prob3=1-prob1-prob2; %calculate transitional probabilities
    x = rand(); %define random number
    if x <= prob1
        NS(i,1) = ni+1; %species abundance increases by 1
    elseif x > prob1 && x <= prob1+prob2
        NS(i,1) = ni-1; %species abundance decreases by 1
    elseif x > prob1+prob2 && x <= prob1+prob2+prob3
        NS(i,1) = ni; %species abundance stays the same
    end
    timeTaken = (i-1)*FunctionParameters.eta; %calculate and print current timestep
    NS(i,2) = timeTaken; %store current time step
    fprintf('>>>> Simulation Time: %.2f \n',timeTaken) %print current time step
end
```

All function variables alongside, the total number of individual replacements, the total number of data points and the generator seed used, are then stored within a new data structure named `Log` as shown below:
```matlab
Log.FunctionParameters = FunctionParameters; %store parameters for log
Log.RunParameters.randomSeed = randomSeed;
Log.RunParameters.totalReplacements = replaceNo;
Log.RunParameters.totalSamplePoints = i;
```

The `Log` data structure, the data filename variable `dataFilename` and the `NS` array are passed back to _simulation.m_ after completion of the function.

## sloansim.m
The _sloansim.m_ function simulates the change in the relative abundance of a single species within a community governed by the dynamics described by Sloan et al.'s near-neutral model [[2]](#2). The function begins by loading parameters from the _sloansim_ sheet within _simulationParameters.xlsx_. These parameters are stored locally in a data structure named `FunctionParameters` as shown below:
```matlab
importFilename = 'simulationParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'sloansim';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.nt = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.eta = FunctionParametersTable.Value{2};
FunctionParameters.m = FunctionParametersTable.Value{3};
FunctionParameters.p = FunctionParametersTable.Value{4};
FunctionParameters.alpha = FunctionParametersTable.Value{5};
FunctionParameters.sra = FunctionParametersTable.Value{6};
```

Before changes in relative abundance can be simulated some local variables must be defined. Firstly, the random number generator is initialised by setting its control based on input parameters `seed` and `generator`. As simulation occurs based on discrete replace evens the total number of events must be defined by dividing the desired simulation period `simtime` by the average time between replacement events `eta`. The array for holding the simulated data `NS` is then initialised and the starting abundance of the monitored species `NS(1,1)` is set using the variable `sra` defined by the user. These processes areachieved using the following code:
```matlab
randomSeed = rng(MainParameters.seed,MainParameters.generator); %set random seed
replaceNo = MainParameters.simtime/FunctionParameters.eta; %calculate number of replacement events
i = 1;
NS = zeros(replaceNo+1, 2); %intialise NS
NS(i,1) = FunctionParameters.sra*FunctionParameters.nt; %set starting value 
```

The function operates in distinct replacement events refering to a change in time of length `eta`. Each replacement event can envoke a possibility of three unique changes in the abundance of the monitored species: the abundance increases by an individual, stays the same, or decreases by an individual. The probability that each outcome will occur within a community is governed by the transitional probability equations relating to Sloan et al.'s neutral model. The abundace of the monitored species after each repalcement event is stored in `NS` alongside the time that has passed. This process is achieved using the following code:
```matlab
for i = 2:replaceNo+1 %for number of replacement events
    ni = NS(i-1,1); %define current abundance value
    prob1=((FunctionParameters.nt-ni)/FunctionParameters.nt)*((FunctionParameters.m*FunctionParameters.p)+(1+FunctionParameters.alpha)*(1-FunctionParameters.m)*(ni/(FunctionParameters.nt-1))); %calculate transitional probabilities
    prob2=(ni/FunctionParameters.nt)*((FunctionParameters.m*(1-FunctionParameters.p))+(1-FunctionParameters.alpha)*(1-FunctionParameters.m)*((FunctionParameters.nt-ni)/(FunctionParameters.nt-1))); %calculate transitional probabilities
    prob3=1-prob1-prob2; %calculate transitional probabilities
    %Change abundance as required given where random number falls
    x = rand(); %define random number
    if x <= prob1
        NS(i,1) = ni+1; %species abundance increases by 1
    elseif x > prob1 && x <= prob1+prob2
        NS(i,1) = ni-1; %species abundance decreases by 1
    elseif x > prob1+prob2 && x <= prob1+prob2+prob3
        NS(i,1) = ni; %species abundance stays the same
    end
    timeTaken = (i-1)*FunctionParameters.eta; %calculate and print current timestep
    NS(i,2) = timeTaken; %store current time step
    fprintf('>>>> Simulation Time: %.2f \n',timeTaken) %print current time step
end
```

All function variables alongside, the total number of individual replacements, the total number of data points and the generator seed used, are then stored within a new data structure named `Log` as shown below:
```matlab
Log.FunctionParameters = FunctionParameters; %store parameters for log
Log.RunParameters.randomSeed = randomSeed;
Log.RunParameters.totalReplacements = replaceNo;
Log.RunParameters.totalSamplePoints = i;
```

The `Log` data structure, the data filename variable `dataFilename` and the `NS` array are passed back to _simulation.m_ after completion of the function.

## References
<a id="1">[1]</a> 
Hubbell, S. (2001). The Unified Neutral Theory of Biodiversity and Biogeography, _Monographs in Population Biology_ (Vol. 32).

<a id="2">[2]</a> 
Sloan, W. T., Lunn, M., Woodcock, S., Head, I. M., Nee, S., & Curtis, T. P. (2006). Quantifying the roles of im-
migration and chance in shaping prokaryote community structure, _Environmental Microbiology_, 8(4), 732–740. 
