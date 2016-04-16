function dropletAnalysis()
% Ver 16041501


%% Set Default path of the head file
% path_root = 'F:\Documents\Doc-Research\Doc-20150324-Tau Droplet\data\041316';

if ~exist('path_root', 'var')
    path_root = uigetdir('C:/', 'Choose directory where the head.csv is');    %Choose directory containing TIFF files.
end

%%
processTifs([path_root, '\\raw']);

%% Generate Size Distribution
bwlabelpara = 4;  % lookup bwlabel.m
thrd_adjust = -20; 
numberOfBins = 60; % Or whatever you want.
ifgroupon = 1;  % 1: average distribution of the regions
minDiam = 1;
maxDiam = 15;
SCALE = 0.322;

set(0,'DefaultFigureVisible','off');

sizeDist(path_root, ifgroupon, thrd_adjust, ...
    bwlabelpara,...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam)
%%
yLimMax = 100;
group.Salt = [0.000, 150, 260];
group.Tau = [86, 129, 172, 214, 257];
group.RNA = [11, 120, 240, 360, 480, 600, 720];
group.glycerol = [0.1, 0.3];
% 
% yLimMax = 50;
% group.Salt = [0 150 300];
% group.Tau = [0 20 40 60];
% group.RNA = [0 20 40 60];
% group.glycerol = [0 0.05 0.1 0.15];

% yLimMax = 50;
% group.Salt = [0 70 150 500 2000 3000];
% group.Tau = [0 10 20 80 100 140 180];
% group.RNA = [0 10 40 120 240 480];
% group.glycerol = [0 0.01 0.05 0.1 0.3 0.5];

compareSalt(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
compareTau(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);

comparePolyA(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
compareSaltWithGlycerol(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);
compareGlycerol(path_root, group.Salt, group.Tau, group.RNA, group.glycerol, yLimMax);


end
