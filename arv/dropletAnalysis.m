function path_root = dropletAnalysis(path_root)
% Ver 16042101


%% Set Default path of the head file
path_root = 'F:\Documents\Doc-Research\Doc-20150324-Tau Droplet\data\test';

if ~exist('path_root', 'var')
    path_root = uigetdir('C:/', 'Choose directory where the head.csv is');    %Choose directory containing TIFF files.
end

% Head Filename
headfilename = 'head';

%%
% processTifs([path_root, '\\raw']);

%% Generate Size Distribution
bwlabelpara = 4;  % lookup bwlabel.m
Eccentricity = 0.9;
thrd_adjust = -100; 
numberOfBins = 50; % Or whatever you want.
ifgroupon = 1;  % 1: average distribution of the regions
minDiam = 0/0.322;
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

group.Salt = [0 20 40 60 100];
group.Tau = [160];
group.RNA = [480];
group.glycerol = [0.15];

Axis.xLim = [0 10];
Axis.yLim = [0 100];
Axis.Units = {'mM', 'uM', 'ugmL', 'vv'};
Instruction.col = [2 3 4 5];
Instruction.names = {'NaCl', 'Tau', 'RNA', 'Glycerol'};
DivCell = struct2cell(group);
%%
Instruction.comparision = [1 2 3 4];
compareDim(path_root, DivCell, Instruction, Axis, headfilename);
%%
Selection = [4 4];
Axis.xLim = [0 10];
Axis.yLim = [0 60];
compareDimThis(path_root, DivCell, Instruction, Axis, Selection, headfilename);
%%
Instruction.comparision = [3 2 1 4];
compareDim(path_root, DivCell, Instruction, Axis, headfilename);
%%
Selection = [3 1];
Axis.xLim = [0 10];
Axis.yLim = [0 200];
compareDimThis(path_root, DivCell, Instruction, Axis, Selection, headfilename);
Selection = [2 1];
Axis.xLim = [0 10];
Axis.yLim = [0 200];
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
