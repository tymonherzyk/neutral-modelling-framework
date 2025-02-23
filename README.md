# neutral-modelling-framework
## Introduction
This framework was developed to facilitate the research presented in the thesis: "_Towards a general theory within wastewater treatment: computational and experimental examples utilising fundamental laws to describe microbial community structure in wastewater treatment systems_" written by Tymon Alexander Herzyk, submitted in fulfilment of the requirements for the Degree of Doctor of Philosophy in Civil Engineering, at the School of Engineering, College of Science and Engineering, University of Glasgow. The framework developed is shared here under the Creative Commons Attribution 4.0 International License (CC-BY) to offer transparency and allow others to make use of the framework developed for further research.

The framework is capable of producing relative abundance time series for a single monitored species from differing sets of community structuring processes, sampling the produced time series and calibrating common neutral models to these data sets with the purpose of producing estimates for distinct model parameters. The framework is split into three packages to achieve this, with the functionality of each package highlighted below:
* [__Simulation__](https://github.com/tymonherzyk/neutral-modelling-framework/tree/main/Simulation) - simulates a relative abundance time series of a single species within a community using a chosen model:
  - Hubbell's neutral model - Community dynamics are simulated based on random and discrete births, deaths and immigration as described by Hubbell's neutral model 
  - Sloan's near-neutral model - Community dynamics are simulated based on random and discrete births, deaths, immigration and local selection as described by Sloan et al.'s near neutral model 
* [__Sampling__](https://github.com/tymonherzyk/neutral-modelling-framework/tree/main/Sampling) - samples single species relative abundace time series using a regime chosen by the user:
  - Even sampling - samples evenly between a chosen start and end point with a chosen frequency.
  - Burst sampling - samples in bursts between chosen start and end point. Burst frequency, lentgh and the frequency of samples within a burst can also be set by the user.
* [__Fitting__ ](https://github.com/tymonherzyk/neutral-modelling-framework/tree/main/Fitting)- fits a chosen model to single species relative abundace time series using maximum likelihood estimation to provide estimate of distinct model parameters:
  - Hubbell's neutral model - Calibrates the continous version of Hubbell's neutral model providing estimates for each distinct model parameter ($N_T$, $\eta$, $m$ and $p$).
  - Sloan et al.'s near-neutral model - Calibrates the continous version of Sloan et al.'s near-neutral model providing estimates for each distinct model parameter ($N_T$, $\eta$, $m$, $p$ and $\alpha$).

Code for each of these packages is provided in respective folders and descriptions of how each package operates is provided in relative README.md files. All scripts and functions within these packages were written using MATLAB version R2020b in accordance with the academic license provided by the University of Glasgow. 

Provided below is additonal information on:
* [Framework architecture](#Framework-architecture)
* [Prerequisites](#Prerequisites)
* [Installation](#Installation)
* [User guide](#User-guide)
* [Data formatting](#Data-formatting)

For further information or help regarding this framework feel free to reach out to Tymon Alexander Herzyk at 2140584h@student.gla.ac.uk

## Framework architecture
The figure below lays out the overall architecture of the framework developed. The three dashed boxes indicate the remit of each package, the primary executable for each package is highlighted in the centre of these boxes. Pathways or files outwith the dashed boxes represent areas where user interaction is required. The movement of information within the framework is depicted using solid arrows, file names and types are indicated by coloured tags and key variables are portrayed through relevant abbreviations contained in clear tags. User input variables, required for the operation of each package, are stored in associated spreadsheets, these are represented by files _simulationParameters.xlsx_, _samplingParameters.xlsx_ and _fittingParameters.xlsx_.

![Framework_architecture2 (2)](https://github.com/user-attachments/assets/c45a9f65-c24e-4398-b656-906d5f84d97b)
_Created in https://BioRender.com_


The primary scripts are _simulation.m_, _sampling.m_ and _fitting.m_. The first task of these scripts is to load associated input variables from their corresponding sheet within each package spreadsheet (this process is marked as 1). For both _sampling.m_ and _fitting.m_ data files are also required, the user is prompted to select these files when the associated script is executed (this process is marked as 2). Once input variables and data files have been successfully imported, the functionality of the package is delegated to the relevant function (this proces is marked as 3). The choice of function is demonstrated through the 'or' operator within each package. The number of times a function is run is represented by a circular arrow, with the variable govenrning this highlighted. Functions load required input variables from their associated package spreadsheet, only the sheet pertaining to the function called is accessed. After execution of the relevant function outputs are passed back to the primary script which are then saved in a user defined location (this process is marked as 4).

The compartmentalisation of the code into separate packages within this framework allows users to tailor workflows as required. For example, data obtained from the Simulation Package can be further processed through the Sampling Package or passed directly to the Fitting Package. The segregation of package functionality acts to disentangle dependencies between portions of code and allows for standalone development. The partitioning of input variables also promotes independence across packages and functions and by only loading specific sheets, errors resulting from the crossover of variables are negated. The architecture of the framework has been engineered with transparency, usability and adaptability at the fore of the development process. External data can be incoporated into the framework and processed through the Sampling Package and the Fitting Package, please refer to section data formatting for information on how to achieve this.

## Prerequisites
The prerequisites to operating this framework are as follows:
1. MATLAB version R2020b or above
2. Statistics and Machine Learning Toolbox for MATLAB
3. Software for accessing and editing .xlsx files

## Installation
To install the framework:
1. Navigate to the GitHub repository [page](https://github.com/tymonherzyk/neutral-modelling-framework).
2. Click the green "Code" button.
3. Select "Download ZIP".
4. Extract to preferred. location
5. Create files _mlefit.m_ and _mlecustomfit.m_ and store in the Fitting folder. How to create these files is explained [here](https://github.com/tymonherzyk/neutral-modelling-framework/tree/main/Fitting)

## User guide
The Simulation Package
1. Install the Simulation Package.
2. Open _simulationParameters.xlsx_.
3. Edit input variables as desired, or use default values.
4. Save changes to _simulationParameters.xlsx_.
5. Run _simulation.m_.

The Sampling Package
1. Install the Sampling Package.
2. Open _samplingParameters.xlsx_.
3. Edit input variables as desired, or use default values.
4. Save changes to _samplingParameters.xlsx_.
5. Run _sampling.m_.

The Fitting Package
1. Install the Fitting Package and create files _mlefit.m_ and _mlecustomfit.m_
2. Open _fittingParameters.xlsx_.
3. Edit input variables as desired, or use default values.
4. Save changes to _fittingParameters.xlsx_.
5. Run _fitting.m_.

## Data formatting
External data can be sampled and used for model calibration using this the Sampling Package and Fitting Package respectivley. To use external data, the data must be saved in a spcefic format this is provided below:
1. Data must be stored as a .mat data file.
2. This data file must be an array with only two columns. The first that stores the relative abundance of the monitored species. The second stores the time passed since the first sample.
3. The array must be name 'NS'.
4. The data file must follow the naming convention: (custom string)\_T(total time in hours)\_S(total number of samples).mat. For example, testrun1\_T1000_S2500001.mat
