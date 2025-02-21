# Fitting
## Introduction

![Framework_architecture_fitting (1)](https://github.com/user-attachments/assets/f54ab39b-2233-4208-86d4-09eac0dd6dbb)
Created in  https://BioRender.com_

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
Here `importFilename` referes to the input variable spreadsheet _fittingParameters_ with `opts.Sheet` defining the specific sheet _fitting_. `opts` defines multiple options on how the data is loading, defining exact range of cells to import. All data is stored in `MainParameters` data structure and converted to their respective data types. 

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

`Results` and 'Log' are saved using the inbuilt 'save' function as shown below:
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
