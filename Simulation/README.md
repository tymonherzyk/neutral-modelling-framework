# The Simulation Package
## Introduction
The simulation package acts to simulate the relative abundance od a single species within a community. Within the current state community dynamics can be simulated based on two common neutral models:
1. __Hubbell's purley neutral model__ [[1]](#1).
2. __Sloan et al.'s near-neutral model__ [[2]](#2)

Descriptions of these models are supplied at the associated references. Here the discrete version of each model is used. To simulate the change in abudnance simulations proceed through descrete replacement events with outcomes weighted using the transitional proability equations of each model. A more indepth expalnation of this process is provided in the thesis "_Towards a general theory within wastewater treatment: computational and experimental examples utilising fundamental laws to describe microbial community structure in wastewater treatment systems_".

The architecture of this package is given below:
![Copy of Framework_architecture2](https://github.com/user-attachments/assets/a899504b-72f3-4155-8a40-9d161e42f63d)
_Created in  https://BioRender.com_

Users define the model used to govern community dyanmics alongside operational parameters within the _simulationParameters.xlsx_ spreadsheet. The primary script can then be executed (_simulation.m_) which facilitates the importing of user variables and prompts the user to. The function pertaining to the model chosen (_hubbelsim.m_ or _sloansim.m_) is then run to facilitate the simulation of the species' relative abundance. Two files are returned by the pacakge, where one is the data file that holds the change in relative abundance of the monitored species, while the other is a log file that houses logged variables. These are saved in the location defined by the user. Below is an in-depth description of each of the files within this package. 

## simulation.m
