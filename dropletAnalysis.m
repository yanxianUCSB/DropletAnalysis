function path_root = dropletAnalysis(path_root)
% Ver 16042101


%% Set Default path of the head file
% path_root = 'F:\Documents\Doc-Research\Doc-20150324-Tau Droplet\data\041316';

if ~exist('path_root', 'var')
    path_root = uigetdir('C:/', 'Choose directory where the head.csv is');    %Choose directory containing TIFF files.
end

% Head Filename
headfilename = 'head-O3';

%%
% processTifs([path_root, '\\raw']);

%% Generate Size Distribution
bwlabelpara = 4;  % lookup bwlabel.m
Eccentricity = 1;
thrd_adjust = -100; 
numberOfBins = 50; % Or whatever you want.
ifgroupon = 1;  % 1: average distribution of the regions
minDiam = 2/0.322;
maxDiam = 30/0.322;
SCALE = 0.322 / 2;


set(0,'DefaultFigureVisible','off');

sizeDist(path_root, ifgroupon, thrd_adjust, ...
    bwlabelpara,...
    Eccentricity, ...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam,...
    headfilename)
%%

% yLimMax = 50;
% group.Salt = [0 10 20 30 50 100 150 500];
% group.Tau = [15 50 80 160];
% group.RNA = [50 70 150 240 480];
% group.glycerol = [0.15];

group.Salt = [-1 0 1 2 3 6 12 22 50];
group.Tau = [15 50 80 160];
group.RNA = [50 150 240 480];
group.glycerol = [0.15];
% 
% compareSalt(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
% compareTau(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
% 
% comparePolyA(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
% compareSaltWithGlycerol(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
% compareGlycerol(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);


Axis.xLim = [1.2 10];
Axis.yLim = [0 100];
Axis.Units = {'min', 'uM', 'ugmL', 'vv'};
Instruction.col = [8 3 4 5];
Instruction.names = {'Time', 'Tau', 'RNA', 'Glycerol'};
DivCell = struct2cell(group);
% %%
% Instruction.comparision = [1 2 3 4];
% compareDim(path_root, DivCell, Instruction, Axis);
% %
% Selection = [4 4];
% Axis.xLim = [1 15];
% Axis.yLim = [0 100];
% compareDimThis(path_root, DivCell, Instruction, Axis, Selection);
%%
Instruction.comparision = [1 2 3 4];
compareDim(path_root, DivCell, Instruction, Axis, headfilename);
%
Selection = [4 4];
Axis.xLim = [0 10];
Axis.yLim = [0 100];
compareDimThis(path_root, DivCell, Instruction, Axis, Selection, headfilename);

% %% comparision of tau-tRNA and tau-polyA 
% inputtype = 'diameterDist';
% prefix = 'untitled';
% Axis.legends = {'tRNA', 'polyA'};
% 
% filenameIDs = [53 65];
% Axis.title = 'tau = 160 uM, RNA = 480 ug/mL';
% multi_plot(path_root, inputtype, prefix, filenameIDs, Axis)
% 
% filenameIDs = [35 15];
% Axis.title = 'tau = 77 uM, RNA = 150 ug/mL';
% multi_plot(path_root, inputtype, prefix, filenameIDs, Axis)
% 
% filenameIDs = [38 12];
% Axis.title = 'tau = 74 uM, RNA = 240 ug/mL';
% multi_plot(path_root, inputtype, prefix, filenameIDs, Axis)
% 
% filenameIDs = [59 68];
% Axis.title = 'tau = 154 uM, RNA = 461 ug/mL, NaCl = 20 mM';
% multi_plot(path_root, inputtype, prefix, filenameIDs, Axis)
end
