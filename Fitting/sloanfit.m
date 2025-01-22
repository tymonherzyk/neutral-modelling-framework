%sloanfit.m

%START INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Tymon Herzyk
%Last Editied: 05/09/2021
%Version: 1.0
%MATLAB Version: R2020b
%License:
%END INTRODUCTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%START BURST%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Results,dataFilename,Log] = sloanfit(MainParameters,loadPath)
%Print start message
fprintf('SLOANFIT STARTED \n')
%START SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Set import settings for loading function parameters from user spreadsheet
importFilename = 'fittingParameters.xlsx';
opts = detectImportOptions(importFilename);
opts = setvartype(opts,'char');
opts.RowNamesRange = 'A2';
opts.VariableNamesRange = 'B1';
opts.DataRange = 'B2';
opts.Sheet = 'sloanfit';
%Load function parameters from user spreadsheet as table
FunctionParametersTable = readtable(importFilename,opts);
%Change function parameters to correct data types
for i = 1:height(FunctionParametersTable)
    if strcmpi('number',FunctionParametersTable.Type{i}) 
        FunctionParametersTable.Value{i} = sscanf(FunctionParametersTable.Value{i},'%f*');
    end
end
%Store function parameters in data structure
FunctionParameters.fixednt = FunctionParametersTable.Value{1};
FunctionParameters.fixedeta = FunctionParametersTable.Value{2};
FunctionParameters.fixedm = FunctionParametersTable.Value{3};
FunctionParameters.fixedp = FunctionParametersTable.Value{4};
FunctionParameters.fixedalpha = FunctionParametersTable.Value{5};
FunctionParameters.startnt = FunctionParametersTable.Value{6};
FunctionParameters.starteta = FunctionParametersTable.Value{7};
FunctionParameters.startm = FunctionParametersTable.Value{8};
FunctionParameters.startp = FunctionParametersTable.Value{9};
FunctionParameters.startalpha = FunctionParametersTable.Value{10};
FunctionParameters.lowernt = FunctionParametersTable.Value{11};
FunctionParameters.lowereta = FunctionParametersTable.Value{12};
FunctionParameters.lowerm = FunctionParametersTable.Value{13};
FunctionParameters.lowerp = FunctionParametersTable.Value{14};
FunctionParameters.loweralpha = FunctionParametersTable.Value{15};
FunctionParameters.uppernt = FunctionParametersTable.Value{16};
FunctionParameters.uppereta = FunctionParametersTable.Value{17};
FunctionParameters.upperm = FunctionParametersTable.Value{18};
FunctionParameters.upperp = FunctionParametersTable.Value{19};
FunctionParameters.upperalpha = FunctionParametersTable.Value{20};
FunctionParameters.funvalcheck = FunctionParametersTable.Value{21};
FunctionParameters.display = FunctionParametersTable.Value{22};
FunctionParameters.maxfunevals = FunctionParametersTable.Value{23};
FunctionParameters.maxiter = FunctionParametersTable.Value{24};
%END SETUP%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LOAD DATA
%Load data
load(loadPath, 'NS');
%Extract naming data
originalFilename = extractAfter(loadPath,MainParameters.userFilePath);
originalFilePath = extractBefore(loadPath,originalFilename);
originalDataIdentifier = extractBefore(originalFilename,'_T');
originalTotalTime = extractBetween(originalFilename,'_T','_S');
originalTotalSamplePoints = extractBetween(originalFilename,'_S','.mat');
x = NS(1:end-1,1);
dx = NS(2:end,1) - NS(1:end-1,1);
dt = NS(2:end,2) - NS(1:end-1,2);

i = 1; 
if isempty(FunctionParameters.fixednt) == 1
    fittingStart(i) = FunctionParameters.startnt;
    fittingLowerBound(i) = FunctionParameters.lowernt;
    fittingUpperBound(i) = FunctionParameters.uppernt;
    i = i + 1;
elseif isempty(FunctionParameters.fixednt) == 0
end
if isempty(FunctionParameters.fixedeta) == 1
    fittingStart(i) = FunctionParameters.starteta;
    fittingLowerBound(i) = FunctionParameters.lowereta;
    fittingUpperBound(i) = FunctionParameters.uppereta;
    i = i + 1;
elseif isempty(FunctionParameters.fixedeta) == 0
end
if isempty(FunctionParameters.fixedm) == 1
    fittingStart(i) = FunctionParameters.startm;
    fittingLowerBound(i) = FunctionParameters.lowerm;
    fittingUpperBound(i) = FunctionParameters.upperm;
    i = i + 1;
elseif isempty(FunctionParameters.fixedm) == 0
end
if isempty(FunctionParameters.fixedp) == 1
    fittingStart(i) = FunctionParameters.startp;
    fittingLowerBound(i) = FunctionParameters.lowerp;
    fittingUpperBound(i) = FunctionParameters.upperp;
    i = i + 1;
elseif isempty(FunctionParameters.fixedp) == 0
end
if isempty(FunctionParameters.fixedalpha) == 1
    fittingStart(i) = FunctionParameters.startalpha;
    fittingLowerBound(i) = FunctionParameters.loweralpha;
    fittingUpperBound(i) = FunctionParameters.upperalpha;
    i = i + 1;
elseif isempty(FunctionParameters.fixedalpha) == 0
end
[phat,pci,nll,output] = mlefit(dx,'nloglf',@nloglf_none,'start',fittingStart,'LowerBound',fittingLowerBound,'UpperBound',fittingUpperBound,'Options',statset('FunValCheck',FunctionParameters.funvalcheck,'Display',FunctionParameters.display,'MaxFunEvals',FunctionParameters.maxfunevals,'MaxIter',FunctionParameters.maxiter));
fixedParameters = '_fixed';
i = 1;
if isempty(FunctionParameters.fixednt) == 1
    Results.nt = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixednt) == 0
    Results.nt = '#';
    fixedParameters = append(fixedParameters,'nt');
end
if isempty(FunctionParameters.fixedeta) == 1
    Results.eta = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedeta) == 0
    Results.eta = '#';
    fixedParameters = append(fixedParameters,'eta');
end
if isempty(FunctionParameters.fixedm) == 1
    Results.m = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedm) == 0
    Results.m = '#';
    fixedParameters = append(fixedParameters,'m');
end
if isempty(FunctionParameters.fixedp) == 1
    Results.p = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedp) == 0
    Results.p = '#';
    fixedParameters = append(fixedParameters,'p');
end
if isempty(FunctionParameters.fixedalpha) == 1
    Results.alpha = phat(i);
    i = i + 1;
elseif isempty(FunctionParameters.fixedalpha) == 0
    Results.alpha = '#';
    fixedParameters = append(fixedParameters,'alpha');
end  
Results.fval = nll;
Results.funcCount = output.funcCount;
Results.iterations = output.iterations;
Results.algorithm = output.algorithm;
Results.message = output.message;
dataFilename = sprintf('%s%s%s_T%s_S%s.mat',originalDataIdentifier, MainParameters.saveDataIdentifier, fixedParameters,  originalTotalTime, originalTotalSamplePoints);
Log.FunctionParameters = FunctionParameters;

function r = nloglf_none(params,data,cens,freq,trunc)
j = 1;
if isempty(FunctionParameters.fixednt) == 1
    nt = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixednt) == 0
    nt = FunctionParameters.fixednt;
end
if isempty(FunctionParameters.fixedeta) == 1
    eta = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedeta) == 0
    eta = FunctionParameters.fixedeta;
end
if isempty(FunctionParameters.fixedm) == 1
    m = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedm) == 0
    m = FunctionParameters.fixedm;
end
if isempty(FunctionParameters.fixedp) == 1
    p = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedp) == 0
    p = FunctionParameters.fixedp;
end
if isempty(FunctionParameters.fixedalpha) == 1
    alpha = params(j);
    j = j + 1;
elseif isempty(FunctionParameters.fixedalpha) == 0
    alpha = FunctionParameters.fixedalpha;
end
if strcmpi('sloanfit',MainParameters.function) 
    mu = ((m.*(p-x)+2*alpha*(1-m).*x.*(1-x))./nt).*(dt./eta);
    sigma = sqrt((2.*x.*(1-x)+m.*(p-x).*(1-2.*x))./nt^2).*sqrt(dt./eta);
elseif strcmpi('sloansimpfit',MainParameters.function) 
    mu = ((m.*(p-x)+2*alpha*(1-m).*x.*(1-x))./nt).*(dt./eta);
    sigma = sqrt(2.*x.*(1-x)./nt^2).*sqrt(dt./eta);
end
r = -sum(log(pdf('norm',data,mu,sigma)));
end
end

