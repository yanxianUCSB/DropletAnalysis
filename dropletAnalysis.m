function path_root = dropletAnalysis(path_root)
% Ver 16042101


%% Set Default path of the head file
% path_root = 'F:\Documents\Doc-Research\Doc-20150324-Tau Droplet\data\041316';

if ~exist('path_root', 'var')
    path_root = uigetdir('C:/', 'Choose directory where the head.csv is');    %Choose directory containing TIFF files.
end

%%
processTifs([path_root, '\\raw']);

%% Generate Size Distribution
bwlabelpara = 8;  % lookup bwlabel.m
Eccentricity = 1;
thrd_adjust = -20; 
numberOfBins = 60; % Or whatever you want.
ifgroupon = 1;  % 1: average distribution of the regions
minDiam = 1/0.322;
maxDiam = 15/0.322;
SCALE = 0.322 / 2;


set(0,'DefaultFigureVisible','off');

sizeDist(path_root, ifgroupon, thrd_adjust, ...
    bwlabelpara,...
    Eccentricity, ...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam)
%%

% yLimMax = 50;
% group.Salt = [0 10 20 30 50 100 150 500];
% group.Tau = [15 50 80 160];
% group.RNA = [50 70 150 240 480];
% group.glycerol = [0.15];

group.Salt = [0 10 20 30 100 200];
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


Axis.xLim = [0 15/2];
Axis.yLim = [0 100];
Axis.Units = {'mM', 'uM', 'ug_mL', 'vv'};
Instruction.col = [2 3 4 5];
Instruction.names = {'salt', 'tau', 'rna', 'glycerol'};
Instruction.comparision = [3 2 1 4];
DivCell = struct2cell(group);
compareDim(path_root, DivCell, Instruction, Axis);
Selection = [3 1];
compareDimThis(path_root, DivCell, Instruction, Axis, Selection);
end
