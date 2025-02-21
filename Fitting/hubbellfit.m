%hubbellfit.m

%Author: Tymon Alexander Herzyk
%Github: 
%Last Editied: 21/02/2025
%Version: 1.0
%MATLAB Version: R2020b
%License: https://creativecommons.org/licenses/by/4.0/

%START HUBBELLFIT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Results,dataFilename,Log] = hubbellfit(MainParameters,loadPath) %start function
fprintf('HUBBELLFIT STARTED \n') %print start message
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(loadPath, 'NS'); %load data
x = NS(1:end-1,1); %calculate x
dx = NS(2:end,1) - NS(1:end-1,1); %calculate dx 
dt = NS(2:end,2) - NS(1:end-1,2); %calculate dt 
originalFilename = extractAfter(loadPath,MainParameters.userFilePath); %extract naming data
originalFilePath = extractBefore(loadPath,originalFilename);
originalDataIdentifier = extractBefore(originalFilename,'_T');
originalTotalTime = extractBetween(originalFilename,'_T','_S');
originalTotalSamplePoints = extractBetween(originalFilename,'_S','.mat');
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
[phat,pci,nll,output] = mlefit(dx,'nloglf',@nloglf_none,'start',fittingStart,'LowerBound',fittingLowerBound,'UpperBound',fittingUpperBound,'Options',statset('FunValCheck',FunctionParameters.funvalcheck,'Display',FunctionParameters.display,'MaxFunEvals',FunctionParameters.maxfunevals,'MaxIter',FunctionParameters.maxiter)); %run maximum likelihood estimation
fixedParameters = '_fixed';
i = 1;
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
%START MAIN BODY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START CUSTOM NLOGF FUNCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%END CUSTOM NLOGF FUNCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%END HUBBELLFIT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
