# The Sampling Package
The sampling package acts to sample single species relative abundance time series. Within the current sampling can be undertaken using two different regimes:
1. __Even__
2. __Burst__

where even sampling samples the time series evenly between two points selected by the user for using given frequency. Burts sampling samples in burts of which the frequency and size of burts can be defined by the user between a start and end point. The frequency of samples within a burts can also be defined by the user.

The architecture of this package is given below:
![Copy of Framework_architecture2 (1)](https://github.com/user-attachments/assets/455c3c7d-7278-4ed8-a2f6-acc6003de868)
_Created in  https://BioRender.com_

Users define the sampling regime to be used alongside operational parameters within the _samplingParameters.xlsx_ spreadsheet. The primary script can then be executed (_sampling.m_) which facilitates the importing of user variables and executes the function pertaining to the regime chosen (_even.m_ or _burst.m_). After sampling has been undertaken two files are returned by the pacakge, where one is the data file that holds the sampled relative abundance of the monitored species, while the other is a log file that houses logged variables. These are saved in the location defined by the user. Below is an in-depth description of each of the files within this package:
* [samplingParameters.xlsx](#samplingParameters.xlsx)
* [sampling.m](#sampling.m)
* [even.m](#even.m)
* [burst.m](#burst.m)

## samplingParameters.xlsx
This spreadsheet holds all user input variables which must be defined for the package to operate. It is made up of three sheets:
* __sampling__
* __even__
* __burst__

Each sheet holds input variables for the specific script or function of the same name. A full list of all variables and descriptions of these variables are provided below:
![InputVariablesSampling (1)](https://github.com/user-attachments/assets/2d564368-ee6d-4fd8-b559-1c7f663e9416)
_Created in  https://BioRender.com_

## sampling.m



## even.m

## burst.m
