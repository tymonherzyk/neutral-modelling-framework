# Fitting
## Introduction

![Framework_architecture_fitting](https://github.com/user-attachments/assets/4c933336-4790-4e7c-9666-fe65eea1bcf9)
_Created in  https://BioRender.com_

## fittingParameters.xlsx
This spreadsheet holds all user input variables wich must be defined for the package to operate. It is made up of three sheets:
* __fitting__
* __hubbellfit__
* __sloanfit__


Each sheet holds input variables for the spefic script or function of the same name. A full list of all variables and descriptions of these variables are provided below:
![InputVariablesFitting (1)](https://github.com/user-attachments/assets/bd319d54-5104-49d8-a93a-df17419459bd)
_Created in  https://BioRender.com_

Variables _nt_,_eta_,_m_,_p_ and _alpha_ do not need to be defined for the package to operate. If these are left empty the pacakge will estimate them. Thus by providing values or leaving these empty the number and type of model parameters to be estimated can be selected. It is important to not that for any of these varibales left unknown associated _start_, _lower_ and _upper_ variables must be defined.

## fitting.m
This script acts as the sole executable within the fitting package and is tasked with:
1. __Loading input variables from sheet _fitting_ within _fittingParameters.xlsx_.__
2. __Importing desired data files selected by the user.__
3. __Running the chosen function by the user (_hubellfit_, _hubbellsimpfit_, _sloanfit_, _sloansimpfit_).__

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



Within the function calling loop, four values of \textit{function} are catered for. These are, "hubbellfit", "hubbellfitsimp", "sloanfit" and "sloanfitsimp". If \textit{function} is equal to strings "hubbellfit" or "hubbellfitsimp" then the function hubbellfit.m is executed. If \textit{function} is equal to strings "sloanfit" or "sloanfitsimp" then the sloanfit.m function is executed. Similarly to sampling.m the number of iterations of the function calling loop is defined by \textit{userFileTotal} and both functions accept inputs of \textit{MainParameters} and \textit{userFileTotal}. Function outputs are consistent with that shown in figure \ref{simulation_code2}, where \textit{NS}, \textit{dataFilename} and \textit{Log} are returned. After the appropriate function is called, the handling of function outputs and the process of saving these are carried out using the same format previously defined in figure \ref{simulation_code3}, where field \textit{RunParameters} is appended as required.
