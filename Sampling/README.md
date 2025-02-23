# The Sampling Package
The sampling package acts to sample single species relative abundance time series. Within the current sampling can be undertaken using two different regimes:
1. __Even__
2. __Burst__

where even sampling samples the time series evenly between two points selected by the user for using given frequency. Burts sampling samples in burts of which the frequency and size of burts can be defined by the user between a start and end point. The frequency of samples within a burts can also be defined by the user.

The architecture of this package is given below:
![Copy of Framework_architecture2 (1)](https://github.com/user-attachments/assets/455c3c7d-7278-4ed8-a2f6-acc6003de868)
_Created in  https://BioRender.com_

Users define the sampling regime to be used alongside operational parameters within the _samplingParameters.xlsx_ spreadsheet. The primary script can then be executed (_sampling.m_) which facilitates the importing of user variables and executes the function pertaining to the regime chosen (_even.m_ or _burst.m_). After sampling has been undertaken two files are returned by the pacakge, where one is the data file that holds the sampled relative abundance of the monitored species, while the other is a log file that houses logged variables. These are saved in the location defined by the user. Below is an in-depth description of each of the files within this package:
* [samplingParameters.xlsx](#samplingparametersxlsx)
* [sampling.m](#samplingm)
* [even.m](#evenm)
* [burst.m](#burstm)

## samplingParameters.xlsx
This spreadsheet holds all user input variables which must be defined for the package to operate. It is made up of three sheets:
* __sampling__
* __even__
* __burst__

Each sheet holds input variables for the specific script or function of the same name. A full list of all variables and descriptions of these variables are provided below:
![InputVariablesSampling (1)](https://github.com/user-attachments/assets/2d564368-ee6d-4fd8-b559-1c7f663e9416)
_Created in  https://BioRender.com_

## sampling.m
This script acts as the sole executable within the sampling package and is tasked with:
1. __Loading input variables from sheet _sampling_ within _samplingParameters.xlsx_.__
2. __Importing desired data files selected by the user.__
3. __Running the chosen function by the user (_even_, _burst_).__
4. __Saving results and log files__

The first of these tasks is achieved through the section of code below:
```matlab
importFilename = 'samplingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'sampling';
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
Here `importFilename` referes to the input variable spreadsheet _samplingParameters.xlsx_ with `opts.Sheet` defining the specific sheet _sampling_. `opts` defines multiple options on how the data is loading, defining exact range of cells to import. All data is stored in `MainParameters` data structure and converted to their respective data types. 

Importing of data files is handled by:
```matlab
[MainParameters.userFileNames,MainParameters.userFilePath] = uigetfile(MainParameters.loadDataPath,"Multiselect","on"); %open dialog box to select data files
if ~iscell(MainParameters.userFileNames) %store filenames of selected data files
    MainParameters.userFileNames={MainParameters.userFileNames};
end
MainParameters.userFileTotal = length(MainParameters.userFileNames); %store total number of selected data files
```
where the inbuilt `uigetfile` function opens a dialog box for users to select data files. Multiple data files can be selected at once. The total number of files selected is stored in `userFileTotal`.

The execution of the chosen sampling regime is undertaken within the loop:
```matlab
for i = 1:MainParameters.userFileTotal %for total number of files
    tstartRun = tic; %start timer and store date and time
    dateTimeRun = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('\nFILE %d OF %d STARTED \n',i,MainParameters.userFileTotal) %print start message 
    loadDataFullPath = fullfile(MainParameters.userFilePath,MainParameters.userFileNames(i)); %define data file load path
    loadDataFullPath = string(loadDataFullPath);
    if strcmpi('even',MainParameters.function) %run function defined by user and pass parameters
        [NS,dataFilename,Log] = even(MainParameters,loadDataFullPath);
    elseif strcmpi('burst',MainParameters.function)
        [NS,dataFilename,Log] = burst(MainParameters,loadDataFullPath);
    end
    tendRun = toc(tstartRun); 
```
Within this loop, two values of `function` are catered for. These are, `'even'` and `'burst'`. If `function` is equal to `'even'` then the function _even.m_ is executed. If `function` is equal to `'burst'` then the _burst.m_ function is executed. The number of iterations of the loop is defined by the number of datafiles selected by the user, stored in `userFileTotal`. Function inputs are `MainParameters` and 'loadDataFullPath', and outputs are `NS`, `dataFilename` and `Log`.

`NS` and `Log` are saved using the inbuilt `save` function as shown below:
```matlab
    saveDataFullPath = append(MainParameters.saveDataPath,dataFilename); %build full path for saving data
    save(saveDataFullPath,'NS') %save data
```
```matlab
logFilename = sprintf('Log_%s',dataFilename); %build full path for saving log
    saveLogFullPath = append(MainParameters.saveLogPath,logFilename);
    Log.RunParameters.originalDataFilename = MainParameters.userFileNames(i); %add additonal variables to log
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
    save(saveLogFullPath,'Log') %save log
```

## even.m
The aim of the _even.m_ function is to sample single species relative abundance time series using an even sampling regime. Thus sampling is conducted using a constant frequency between a start and end point. In the first instance these user defined variables must be imported into the function,as shown below:
```matlab
importFilename = 'samplingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'even';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.startTime = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.endTime = FunctionParametersTable.Value{2};
FunctionParameters.sampleFrequency = FunctionParametersTable.Value{3};
```
Where`importFilename` referes to the input variable spreadsheet _samplingParameters.xlsx_ with `opts.Sheet` defining the specific sheet _burst_. The user defined parameters are stored in `FunctionParameters` after being converted to their respective data types. 

The single species relative abundance data file is then loaded from the `loadpath` passed to the function, as shown below:
```matlab
load(loadPath,'NS'); %load data
originalNS = NS; %save copy of data
clear NS
```
Here a copy of `NS` is made and the original array cleared.

From this point the user defined `startTime` and `endTime` are searched for within the copied `originalNS` array. If an exact match connot be found the next time point is used. Once these points have been established the number of datapoint between each sample point to be skipped is calculated from the user defined `samplingFrequency`. Using these values a new `NS` array is constructed by copying the desired data points from the copy of the original data `originalNS`. This entire process is achieved using the code below:
```matlab
ndexStartTimeArray = find(originalNS(:,2)>=FunctionParameters.startTime); %find sampling start point
indexStartTime = indexStartTimeArray(1,1); %set sampling start point
indexEndTimeArray = find(originalNS(:,2)<=FunctionParameters.endTime); %find sampling end point
indexEndTime = indexEndTimeArray(end,1); %set sampling end point
indexSampleFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.sampleFrequency)); %calculate sampling frequency
NS(:,1) = originalNS(indexStartTime:indexSampleFrequency:indexEndTime, 1); %copy desired data points from original NS to new array
NS(:,2) = originalNS(indexStartTime:indexSampleFrequency:indexEndTime, 2); %copy desired time points from original NS to new array
```

Finally the total amount of samples `totalSamples` and the total time period sampled over `totalTime` are calculated. These are used to build the data filename `dataFilename`. `FunctionParameters` are stored wihtin the `Log` data structure. Again the code for achieving is given below:
```matlab
totalSamples = height(NS); %calculate total samples
totalTime = NS(end,2); %calculate total time
```
```matlab
dataFilename = sprintf('%s%s_T%.*f_S%d.mat',originalDataIdentifier, MainParameters.saveDataIdentifier,dp, totalTime, totalSamples); %create data filename
Log.FunctionParameters = FunctionParameters; %log function paramaters
```

`NS`, `dataFilename` and `Log` are passed back to _sampling.m_ on completion of the function.

## burst.m
The aim of the _burst.m_ function is to sample single species relative abundance time series using bursts. Bursts of sampling are spaced evenly apart at constant frequency between a start and end point. The size of burst i.e the number of samples within a burst is defined by the user. The frequency of samples within a burst can also be defined. In the first instance these user defined variables must be imported into the function. This is achieved as shown below:
```matlab
importFilename = 'samplingParameters.xlsx'; %set import filename for loading parameters from user spreadsheet
opts = detectImportOptions(importFilename); %set import settings for loading parameters from user spreadsheet
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'burst';
FunctionParametersTable = readtable(importFilename,opts); %load function parameters from user spreadsheet as table
for i = 1:height(FunctionParametersTable) %change function parameters to correct data types
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
FunctionParameters.startTime = FunctionParametersTable.Value{1}; %store function parameters in data structure
FunctionParameters.endTime = FunctionParametersTable.Value{2};
FunctionParameters.burstFrequency = FunctionParametersTable.Value{3};
FunctionParameters.burstSize = FunctionParametersTable.Value{4};
FunctionParameters.sampleFrequency = FunctionParametersTable.Value{5};
```
Where`importFilename` referes to the input variable spreadsheet _samplingParameters.xlsx_ with `opts.Sheet` defining the specific sheet _even_. The user defined parameters are stored in `FunctionParameters` after being converted to their respective data types. 

The single species relative abundance data file is then loaded from the `loadpath` passed to the function, as shown below:
```matlab
load(loadPath,'NS'); %load data
originalNS = NS; %save copy of data
clear NS
```
Here a copy of `NS` is made and the original array cleared.

The user defined `startTime` and `endTime` are searched for within the copied `originalNS` array. If an exact match connot be found the next time point is used. Once these points have been established the frequnecy of bursts and the frequency of samples wihtin a burst are determined based on the number of data points skipped. This is done using the code:
```matlab
indexStartTimeArray = find(originalNS(:,2)>=FunctionParameters.startTime); %find sampling start point
indexStartTime = indexStartTimeArray(1,1); %set sampling start point
indexEndTimeArray = find(originalNS(:,2)<=FunctionParameters.endTime); %find sampling end point
indexEndTime = indexEndTimeArray(end,1); %set sampling end point
indexSampleFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.sampleFrequency)); %calculate sampling frequency
indexBurstFrequency = height(find(originalNS(:,2)>0 & originalNS(:,2)<=FunctionParameters.burstFrequency)); %calculate burst frequency
indexBurstSize = FunctionParameters.burstSize*indexSampleFrequency; %calculate burst size
```

Based on these values the total number of burts achievable is calculated following:
```matlab
count = 0;
burstTotal = 0;
for i = indexStartTime:indexBurstFrequency:indexEndTime %calculate total number of bursts
    indexBurstTotal = indexStartTime+(indexBurstFrequency*count)+indexBurstSize;
    if indexBurstTotal <= indexEndTime
        burstTotal=burstTotal+1;
    end
    count=count+1;
end
```

For each of these bursts the desired data points are copied into the new data array `NS`. This is achieved using:
```matlab
for i = 1:burstTotal %for each burst
    indexStartBurst = indexStartTime+(indexBurstFrequency*(i-1)); %calculate start and end points
    indexEndBurst = indexStartBurst+indexBurstSize-1;
    NSEnd = NSStart+FunctionParameters.burstSize-1;
    NS(NSStart:NSEnd,1) = originalNS(indexStartBurst:indexSampleFrequency:indexEndBurst,1); %copy desired data points from original NS to new array
    NS(NSStart:NSEnd,2) = originalNS(indexStartBurst:indexSampleFrequency:indexEndBurst,2); %copy desired time points from original NS to new array
    NSStart = NSEnd+1; %set start point for next burst
end
```

Finally the total samples `totalSamples` and total time `totalTime` are calculated and used to build the data filename `dataFilename`. `FunctionParameters` is stored in the `Log` data structure, as shown below:
```matlab
totalSamples = height(NS); %calculate total samples
totalTime = NS(end,2)-NS(1,2); %calculate total time
```
```matlab
dataFilename = sprintf('%s%s_T%.*f_S%d.mat',originalDataIdentifier, MainParameters.additionalIdentifier,dp, totalTime, totalSamples); %create data filename
Log.FunctionParameters = FunctionParameters; %log function paramaters
```

`NS`, `dataFilename` and `Log` are passed back to _sampling.m_ on completion of the function.
