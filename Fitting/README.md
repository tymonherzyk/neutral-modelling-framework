# Fitting
## Introduction
## fitting.m
This script acts as the sole executable within the fitting package and is tasked with:
1. Loading input variables from sheet _fitting_ within _fittingParameters.xlsx_.
2. Importing desired data files selected by the user.
3. Running the chosen function by the user (_hubellfit_, _hubbellsimpfit_, _sloanfit_, _sloansimpfit_).

The first of these tasked is achieved through:
'''matlab
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
fprintf(">>>> Select files for fitting \n")
[MainParameters.userFileNames,MainParameters.userFilePath] = uigetfile(MainParameters.loadDataPath,"Multiselect","on"); %open dialog box to select data files
if ~iscell(MainParameters.userFileNames) %store filenames of selected data files
    MainParameters.userFileNames={MainParameters.userFileNames};
end
MainParameters.userFileTotal = length(MainParameters.userFileNames); %store total number of selected data files
fprintf(">>>> Files Selected: \n")
for i = 1:MainParameters.userFileTotal %print selected files to user
    fprintf(">>>> %s \n", string(MainParameters.userFileNames(i)))
end
'''
loading input variables from , load input data file, run . Importing of desired input variables and data files is handled in the same way as shown in figures \ref{simulation_code1} and \ref{sampling_code1}. Once again the \textit{filename} and \textit{opts.Sheet} variables are altered to match the layout shown in figure \ref{framework_architecture}. These are therefore given the values "fitting.xlsx" and "fitting" respectively. The \textit{MainParameters} data structure is also adapted to reflect the parameters stored within the "fitting" sheet. The code for importing data files is identical to that presented in figure \ref{sampling_code1}.\\ 

Within the function calling loop, four values of \textit{function} are catered for. These are, "hubbellfit", "hubbellfitsimp", "sloanfit" and "sloanfitsimp". If \textit{function} is equal to strings "hubbellfit" or "hubbellfitsimp" then the function hubbellfit.m is executed. If \textit{function} is equal to strings "sloanfit" or "sloanfitsimp" then the sloanfit.m function is executed. Similarly to sampling.m the number of iterations of the function calling loop is defined by \textit{userFileTotal} and both functions accept inputs of \textit{MainParameters} and \textit{userFileTotal}. Function outputs are consistent with that shown in figure \ref{simulation_code2}, where \textit{NS}, \textit{dataFilename} and \textit{Log} are returned. After the appropriate function is called, the handling of function outputs and the process of saving these are carried out using the same format previously defined in figure \ref{simulation_code3}, where field \textit{RunParameters} is appended as required.
