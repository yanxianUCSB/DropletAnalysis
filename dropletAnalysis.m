function path_root = dropletAnalysis(path_root)

%% Set path of the head file
if ~exist('path_root', 'var')
    path_root = uigetdir('C:/', 'Choose directory where the head.csv is');    %Choose directory containing TIFF files.
end

% Head Filename
headfilename = 'head';

%% process Tifs
processTifs([path_root, '\\raw']);

%% Calculate Size Distribution
bwlabelpara = 8;  % lookup bwlabel.m
Eccentricity = 0.9;  % Threshold for Eccentricity
thrd_adjust = -200;  % Intensity threshold offset
numberOfBins = 18; % Or whatever you want.
ifgroupon = 1;  % 1: average distribution of the regions
SCALE = 0.322 / 2;
minDiam = 1 / SCALE;
maxDiam = 19 / SCALE;

set(0,'DefaultFigureVisible','off');

% sizeDist(path_root, ifgroupon, thrd_adjust, ...
%     bwlabelpara,...
%     Eccentricity, ...
%     numberOfBins,...
%     SCALE, ...
%     minDiam, maxDiam,...
%     headfilename)

AreaCount(path_root, ifgroupon, thrd_adjust, ...
    bwlabelpara, ...
    Eccentricity, ...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam, headfilename)

end
