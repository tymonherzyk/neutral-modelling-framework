# Fitting
## Introduction
The fitting package facilitates the calibration of neutral models to single species relative abundance time seires with the purpose of production estimates for distinct model parameters. Within the current state two common neutral models can be calibrated:
1. __Hubbell's purley neutral model__ [[1]](#1).
2. __Sloan et al.'s near-neutral model__ [[2]](#2)

Descriptions of these models are supplied at the associated references. Here the continous version of each model is calibrated. Mathematical derivations of these are provided in the thesis "_Towards a general theory within wastewater treatment: computational and experimental examples utilising fundamental laws to describe microbial community structure in wastewater treatment systems_". To produce parameter estimates maximum likelihood estimation is used. Once again refer to the previously given thesis for an in-depth mathematical explantion of this process.

The calibration of these models is achieved using the architecture shown below:
![Framework_architecture_fitting (1)](https://github.com/user-attachments/assets/f54ab39b-2233-4208-86d4-09eac0dd6dbb)
Created in  https://BioRender.com_

Users define the model to be calibrated alongside operational parameters within the _fittingParameters.xlsx_ spreadsheet. The primary script can then be executed (_fitting.m_) which facilitates the importing of user variables and prompts the user to select data files to use for the calibration. The function pertaining to the model chosen (_hubbelfit.m_ or _sloanfit.m_) is then run to facilitate the calibration of the model and estimation of unknown parameters. Two files, _results.m_ and _log.m_ are returned by the pacakge, where _results.m_ houses parameter estimates, while _log.m_ houses logged variables. These are saved in the location defined by the user. Below is an in-depth description of each of the files within this package. 

__IMPORTANT NOTE: files _mlefit.m_ and _mlecustomfit.m_ are required for the package to operate. These are not provided here as they are subject to copyright from The Mathworks, Inc (Copyright 1993-2012 The MathWorks, Inc). Guides on how to make these files are provided towards the end of the README. Please refer to these before trying to operate the package.__

## fittingParameters.xlsx
This spreadsheet holds all user input variables wich must be defined for the package to operate. It is made up of three sheets:
* __fitting__
* __hubbellfit__
* __sloanfit__


Each sheet holds input variables for the spefic script or function of the same name. A full list of all variables and descriptions of these variables are provided below:
![InputVariablesFitting (2)](https://github.com/user-attachments/assets/b15d3216-eb84-44a0-9861-1b6cd75848fe)
Created in  https://BioRender.com_

Variables _nt_, _eta_, _m_, _p_ and _alpha_ do not need to be defined for the package to operate. If these are left empty the pacakge will estimate them. Thus by providing values or leaving these empty the number and type of model parameters to be estimated can be selected. It is important to note that for any of these varibales left unknown associated _start_, _lower_ and _upper_ variables must be defined.

## fitting.m
This script acts as the sole executable within the fitting package and is tasked with:
1. __Loading input variables from sheet _fitting_ within _fittingParameters.xlsx_.__
2. __Importing desired data files selected by the user.__
3. __Running the chosen function by the user (_hubellfit_, _hubbellsimpfit_, _sloanfit_, _sloansimpfit_).__
4. __Saving results and log files__

The first of these tasks is achieved through the section of code below:
```matlab
importFilename = 'fittingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename);  %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'fitting';
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
```
Here `importFilename` referes to the input variable spreadsheet _fittingParameters.xlsx_ with `opts.Sheet` defining the specific sheet _fitting_. `opts` defines multiple options on how the data is loading, defining exact range of cells to import. All data is stored in `MainParameters` data structure and converted to their respective data types. 

Importing data files is handled by:
```matlab
[MainParameters.userFileNames,MainParameters.userFilePath] = uigetfile(MainParameters.loadDataPath,"Multiselect","on"); %open dialog box to select data files
if ~iscell(MainParameters.userFileNames) %store filenames of selected data files
    MainParameters.userFileNames={MainParameters.userFileNames};
end
MainParameters.userFileTotal = length(MainParameters.userFileNames); %store total number of selected data files
```
where the inbuilt 'uigetfile' function opens a dialog box for users to select data files. Multiple data files can be selected at once.

The execution of the chosen function is undertaken within the primary loop:
```matlab
for i = 1:MainParameters.userFileTotal %for number of runs
    tstartRun = tic; %start timer and store date and time
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('\nFILE %d OF %d STARTED \n',i,MainParameters.userFileTotal) %print start message 
    loadDataFullPath = fullfile(MainParameters.userFilePath,MainParameters.userFileNames(i)); %Define data file load path
    loadDataFullPath = string(loadDataFullPath);
    if strcmpi('hubbellfit',MainParameters.function) %run function defined by user and pass parameters
        [Results,dataFilename,Log] = hubbellfit(MainParameters,loadDataFullPath);
    elseif strcmpi('hubbellsimpfit',MainParameters.function)
        [Results,dataFilename,Log] = hubbellfit(MainParameters,loadDataFullPath);
    elseif strcmpi('sloanfit',MainParameters.function)
        [Results,dataFilename,Log] = sloanfit(MainParameters,loadDataFullPath);
    elseif strcmpi('sloansimpfit',MainParameters.function)
        [Results,dataFilename,Log] = sloanfit(MainParameters,loadDataFullPath);
    end
    tendRun = toc(tstartRun); %end timer
```

Within the function calling loop, four values of `function` are catered for. These are, _hubbellfit_, _hubbellfitsimp_, _sloanfit_ and _sloanfitsimp_. If `function` is equal to strings _hubbellfit_ or _hubbellfitsimp_ then the function _hubbellfit.m_ is executed. If `function` is equal to strings _sloanfit_ or _sloanfitsimp_ then the _sloanfit.m_ function is executed. The number of iterations of the function calling loop is defined by the number of datafiles selected by the user, stored in 'userFileTotal'. Function inputs are `MainParameters` and 'loadDataFullPath', and outputs are `Results`, `dataFilename` and `Log`.

`Results` and `Log` are saved using the inbuilt `save` function as shown below:
```matlab
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename); %build full path for saving data
    save(saveDataFullPath,'Results') %save data
```
```matlab
    logFilename = sprintf('Log_%s',dataFilename); %build full path for saving data
    saveLogFullPath = append(MainParameters.saveLogPath,logFilename);
    Log.RunParameters.originalDataFilename = MainParameters.userFileNames(i);  %add additonal variables to log
    Log.RunParameters.dataFilename = dataFilename;
    Log.RunParameters.dataPath = MainParameters.saveDataPath;
    Log.RunParameters.fixedParameters = extractBetween(dataFilename,'fixed','_T');
    Log.RunParameters.logFilename = logFilename;
    Log.RunParameters.logPath = MainParameters.saveLogPath;
    Log.RunParameters.runtime = tendRun;
    Log.RunParameters.datetime = dateTimeRun;
    Log.MainParameters = MainParameters;
    Log = orderfields(Log); %order log
    save(saveLogFullPath,'Log') %save log
```

## hubbellfit.m
The aim of the _hubbellfit.m_ function is to return estimates for unknown parameters within the continuous version of Hubbell's neutral model using single species relative abundance time series. The transition of Hubbell's model from the discrete mathematics, to one where numerous replacement events can occur between data points, is demonstrated in the thesis written by Tymon Alexander Herzyk. The result is a stochastic differential equation (SDE) that defines the change in relative abundance data ($dx$), in terms of $N_T$, $\eta$, $m$, $p$, $x$ and $dt$. The full mathematical representation of this equation, alongside parameter definitions, is given in the previously mentioned thesis. Within _hubbellfit.m_ parameters $N_T$, $\eta$, $m$, and $p$ refer to variables `nt`, `eta`, `m`, and `p` respectively. $dx$, $x$, and $dt$ are captured in variables of the same name (`dx`, `x`, and `dt`).

The first task achieved is loading input variables from the associated _hubbellsim_ spreadsheet. This is done using the code:
```matlab
importFilename = 'fittingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'hubbellfit';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.fixednt = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.fixedeta = FunctionParametersTable.Value{2};
FunctionParameters.fixedm = FunctionParametersTable.Value{3};
FunctionParameters.fixedp = FunctionParametersTable.Value{4};
FunctionParameters.startnt = FunctionParametersTable.Value{5};
FunctionParameters.starteta = FunctionParametersTable.Value{6};
FunctionParameters.startm = FunctionParametersTable.Value{7};
FunctionParameters.startp = FunctionParametersTable.Value{8};
FunctionParameters.lowernt = FunctionParametersTable.Value{9};
FunctionParameters.lowereta = FunctionParametersTable.Value{10};
FunctionParameters.lowerm = FunctionParametersTable.Value{11};
FunctionParameters.lowerp = FunctionParametersTable.Value{12};
FunctionParameters.uppernt = FunctionParametersTable.Value{13};
FunctionParameters.uppereta = FunctionParametersTable.Value{14};
FunctionParameters.upperm = FunctionParametersTable.Value{15};
FunctionParameters.upperp = FunctionParametersTable.Value{16};
FunctionParameters.funvalcheck = FunctionParametersTable.Value{17};
FunctionParameters.display = FunctionParametersTable.Value{18};
FunctionParameters.maxfunevals = FunctionParametersTable.Value{19};
FunctionParameters.maxiter = FunctionParametersTable.Value{20};
```
where the values of `importfilename`, `opts.Sheet` refer to spreadsheet _fittingParameters.xlsx_ and sheet _hubbellfit_. Variables from this sheet are converted to correct data types and stored in relevant fields within `FunctionParameters`.

Data array 'NS' is then loaded from the file defined by 'loadPath'. From 'NS' model data arrays 'x', 'dx' and 'dt' are calculated following the code:
```matlab
load(loadPath, 'NS'); %load data
x = NS(1:end-1,1); %calculate x
dx = NS(2:end,1) - NS(1:end-1,1); %calculate dx 
dt = NS(2:end,2) - NS(1:end-1,2); %calculate dt
```

## sloanfit.m


## mlefit.m

## mlecustomfit.m

## References
<a id="1">[1]</a> 
Hubbell, S. (2001). The Unified Neutral Theory of Biodiversity and Biogeography, _Monographs in Population Biology_ (Vol. 32).

<a id="2">[2]</a> 
Sloan, W. T., Lunn, M., Woodcock, S., Head, I. M., Nee, S., & Curtis, T. P. (2006). Quantifying the roles of im-
migration and chance in shaping prokaryote community structure, _Environmental Microbiology_, 8(4), 732–740. 
