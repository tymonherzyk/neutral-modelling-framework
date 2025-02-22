# The Fitting Package
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

Within the function calling loop, four values of `function` are catered for. These are, _hubbellfit_, _hubbellfitsimp_, _sloanfit_ and _sloanfitsimp_. If `function` is equal to `'hubbellfit'` or `'hubbellfitsimp'` then the function _hubbellfit.m_ is executed. If `function` is equal to `'sloanfit'` or `'sloanfitsimp'` then the _sloanfit.m_ function is executed. The number of iterations of the function calling loop is defined by the number of datafiles selected by the user, stored in 'userFileTotal'. Function inputs are `MainParameters` and 'loadDataFullPath', and outputs are `Results`, `dataFilename` and `Log`.

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

Data array `NS` is then loaded from the file defined by `loadPath`. From `NS` model data arrays `x`, `dx` and `dt` are calculated following the code:
```matlab
load(loadPath, 'NS'); %load data
x = NS(1:end-1,1); %calculate x
dx = NS(2:end,1) - NS(1:end-1,1); %calculate dx 
dt = NS(2:end,2) - NS(1:end-1,2); %calculate dt
```

Prior to fitting the model, a check is undertaken to only define starting values and limits for variables that are unknown. This is achieved using the `isempty` command as shown below. If this returns true (1) then bounds are defined from the corresponding input variables stored in `FunctionParameters`.
```matlab
i = 1; 
if isempty(FunctionParameters.fixednt) == 1 %set starting values and limits for nt if unknown
    fittingStart(i) = FunctionParameters.startnt;
    fittingLowerBound(i) = FunctionParameters.lowernt;
    fittingUpperBound(i) = FunctionParameters.uppernt;
    i = i + 1;
elseif isempty(FunctionParameters.fixednt) == 0
end
if isempty(FunctionParameters.fixedeta) == 1 %set starting values and limits for eta if unknown
    fittingStart(i) = FunctionParameters.starteta;
    fittingLowerBound(i) = FunctionParameters.lowereta;
    fittingUpperBound(i) = FunctionParameters.uppereta;
    i = i + 1;
elseif isempty(FunctionParameters.fixedeta) == 0
end
if isempty(FunctionParameters.fixedm) == 1 %set starting values and limits for m if unknown
    fittingStart(i) = FunctionParameters.startm;
    fittingLowerBound(i) = FunctionParameters.lowerm;
    fittingUpperBound(i) = FunctionParameters.upperm;
    i = i + 1;
elseif isempty(FunctionParameters.fixedm) == 0
end
if isempty(FunctionParameters.fixedp) == 1 %set starting values and limits for p if unknown
    fittingStart(i) = FunctionParameters.startp;
    fittingLowerBound(i) = FunctionParameters.lowerp;
    fittingUpperBound(i) = FunctionParameters.upperp;
    i = i + 1;
elseif isempty(FunctionParameters.fixedp) == 0
end
```

To estimate the unknown model parameters, maximum likelihood estimation (MLE) is used by calling the function _mlefit.m_. The line of code below demonstrates the execution of this function:
```matlab
[phat,pci,nll,output] = mlefit(dx,'nloglf',@nloglf_none,'start',fittingStart,'LowerBound',fittingLowerBound,'UpperBound',fittingUpperBound,'Options',statset('FunValCheck',FunctionParameters.funvalcheck,'Display',FunctionParameters.display,'MaxFunEvals',FunctionParameters.maxfunevals,'MaxIter',FunctionParameters.maxiter)); %run maximum likelihood estimation
```
As illustrated, the function returns four output variables:
1. `phat`: Final values for each unknown parameter.
2. `pci`: Confidence intervals for the parameter estimates.
3. `nll`: The minimum negative logliklihood value arrived at by the optimisation process.
4. `output`: Optimisation output parameters.

The function call also specifies five input fields, in addition to the data vector _dx_. These input fields are:
1. `'nloglf'`: Specifies the custom negative log-likelihood function. Here, the function handle `@nloglf_none` is passed.
2. `'start'`: Defines the starting values set for each unknown parameter within the optimisation process. This is passed the array `fittingStart`.
3. `'LowerBound'`: Defines the lower limit for each unknown parameter within the optimisation process. This is passed the array `fittingLowerBound`
4. `'UpperBound'`: Defines the upper limit for each unknown parameter within the optimisation process. This is passed the array `fittingUpperBound`
5. `'Options': Specifies optimisation settings using `statset`. The fields within `Options` are:
   - `'FunValCheck'`: Enables function value validation, set using the input variable funvalcheck stored in the FunctionParameters data structure.
   - `'Display'`: Controls optimisation output display, set using the input variable display stored in the FunctionParameters data structure.
   - `'MaxFunEvals'`: Maximum number of function evaluations, set using the input variable maxfunevals stored in the FunctionParameters data structure.
   - `'MaxIter'`: Maximum number of iterations, set using the input variable maxiter stored in the FunctionParameters data structure.

Here _mlefit.m_ is operated in such a way to minimise the custom negative loglikelihood function defined by `nloglf_none` This minimisation is performed by the MATLAB function `fminsearch`. This function performs minimisation using the Nelder-Mead simplex algorithm. A mathematical explanation of the exact algorithm used within `fminsearch` is given by Lagarias et al. (1998) [[3]](#3) . Further information can also be found within MATLAB documentation. 

The custom negative loglikelihood function used to optimise model parameters is defined within the nested function `nlogf_none` provided at the end of  _hubbellfit.m_. This function is provided below:
```matlab
    function r = nloglf_none(params,data,cens,freq,trunc) %define function
j = 1;
if isempty(FunctionParameters.fixednt) == 1 %define nt for estimation if unknown 
    nt = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixednt) == 0 %define nt as fixed value if known 
    nt = FunctionParameters.fixednt;
end
if isempty(FunctionParameters.fixedeta) == 1 %define eta for estimation if unknown 
    eta = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedeta) == 0 %define eta as fixed value if known 
    eta = FunctionParameters.fixedeta;
end
if isempty(FunctionParameters.fixedm) == 1 %define m for estimation if unknown 
    m = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedm) == 0 %define m as fixed value if known 
    m = FunctionParameters.fixedm;
end
if isempty(FunctionParameters.fixedp) == 1 %define p for estimation if unknown 
    p = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedp) == 0 %define p as fixed value if known 
    p = FunctionParameters.fixedp;
end
if strcmpi('hubbellfit',MainParameters.function) %if function selected is hubbellfit
    mu = (m.*(p-x)./nt).*(dt./eta); %define mu
    sigma = sqrt((2.*x.*(1-x)+m.*(p-x).*(1-2.*x))./nt^2).*sqrt(dt./eta); %define sigma
elseif strcmpi('hubbellsimpfit',MainParameters.function) %if function selected is hubbellsimpfit
    mu = (m.*(p-x)./nt).*(dt./eta); %define mu
    sigma = sqrt(2.*x.*(1-x)./nt^2).*sqrt(dt./eta); %define sigma
end
r = -sum(log(pdf('norm',data,mu,sigma))); %calculate negative log likelihood
end
```
The function returns a single output `r` which holds the negative loglikelihood value calculated. This value is calculated as the negative sum of the log of the probability density function assumed to be normally distributed and defined by mean `mu` and variance `sigma` for data `dx`. Equations describing `mu` and `sigma` can be lifted directly from the SDE that governs the continuous version of Hubbell's model. Two versions of these identities can be selected between, a truncated version and a non-truncated version. The choice of which version is used is made by the user within the definition of the `function` input variable. Both versions utilise the same model parameters. As any number of these parameters can be estimated, a check is written into the function to assign parameter values to either their input variable value stored in `FunctionParamaetrs` or the value assigned to them by the optimisation method stored in `params`. Variables `x` and `dt` hold the arrays assigned to them previously. Once `r` is calculated, it is passed back to the optimisation method to compare against previous iterations of this quantity. Searching of the minimum value of `r` is undertaken until the termination criteria and convergence criteria is reached, or until the number of iteration or function evaluations exceeds the maximum of these quantities as set by the user. 

After the optimisation process has been completed, outputs from _mlefit.m_ are stored using the following code:
```matlab
if isempty(FunctionParameters.fixednt) == 1 %store estimation result of nt
    Results.nt = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixednt) == 0
    Results.nt = '#';
    fixedParameters = append(fixedParameters,'nt');
end
if isempty(FunctionParameters.fixedeta) == 1 %store estimation result of eta
    Results.eta = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedeta) == 0
    Results.eta = '#';
    fixedParameters = append(fixedParameters,'eta');
end
if isempty(FunctionParameters.fixedm) == 1 %store estimation result of m
    Results.m = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedm) == 0
    Results.m = '#';
    fixedParameters = append(fixedParameters,'m');
end
if isempty(FunctionParameters.fixedp) == 1 %store estimation result of p
    Results.p = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedp) == 0
    Results.p = '#';
    fixedParameters = append(fixedParameters,'p');
end  
Results.fval = nll; %store result of negative log likelihood value
Results.funcCount = output.funcCount; %store result of function count
Results.iterations = output.iterations; %store result of iterations
Results.algorithm = output.algorithm; %store result of algorithm
Results.message = output.message; %store result of message
dataFilename = sprintf('%s%s%s_T%s_S%s.mat',originalDataIdentifier, MainParameters.saveDataIdentifier, fixedParameters,  originalTotalTime, originalTotalSamplePoints); %build new data filename
Log.FunctionParameters = FunctionParameters; %store function parameters used in log file
```
The series of `if` statements determines wheteher each model parameter has been estimated or was fixed within the optimisation. The appropriate result is then stored in the `Results` data structure. Variables `nll`, `funcCount`, `iterations`, `algorithm` and `message` are also stored in `Results`. All variables stored in the `FunctionParameters` are passed into the `Log` data structure. `Results` and `Log` are passed back to _fitting.m_ on completion of _hubbellfit.m_.


## sloanfit.m


## mlefit.m

## mlecustomfit.m

## References
<a id="1">[1]</a> 
Hubbell, S. (2001). The Unified Neutral Theory of Biodiversity and Biogeography, _Monographs in Population Biology_ (Vol. 32).

<a id="2">[2]</a> 
Sloan, W. T., Lunn, M., Woodcock, S., Head, I. M., Nee, S., & Curtis, T. P. (2006). Quantifying the roles of im-
migration and chance in shaping prokaryote community structure, _Environmental Microbiology_, 8(4), 732–740. 

<a id="3">[3]</a> 
Lagarias, J. C., J. A. Reeds, M. H. Wright, and P. E. Wright. Convergence Properties of the Nelder-Mead Simplex Method in Low Dimensions. _SIAM Journal of Optimization._ Vol. 9, Number 1, 1998, pp. 112–147
