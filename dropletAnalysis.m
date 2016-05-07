function path_root = dropletAnalysis(path_root)

%% Set Default path of the head file
path_root = 'F:\Documents\Doc-Research\Doc-20150324-Tau Droplet\data\042016';

if ~exist('path_root', 'var')
    path_root = uigetdir('C:/', 'Choose directory where the head.csv is');    %Choose directory containing TIFF files.
end

% Head Filename
headfilename = 'head';

%%
% processTifs([path_root, '\\raw']);

%% Size Distribution
bwlabelpara = 4;  % lookup bwlabel.m
Eccentricity = 1;  % Threshold for Eccentricity
thrd_adjust = -20;  % Intensity threshold offset
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
    headfilename, 12)
%%

group.Salt = [0 10 20 30 50 100 150 500];
group.Tau = [15 50 80 144 160];
group.RNA = [50 63 70 150 240 480];
group.Glry = [15];

Axis.xLim = [0 12];
Axis.yLim = [0 150];
Axis.Units = {'mM', 'uM', 'ug/mL', '%'};
Axis.xLabel = 'Equivalent Diameter /\mum';
Axis.yLabel = 'Count #';
Instruction.col = [2 8 6 10];
Instruction.names = {'NaCl', 'Tau', 'RNA', 'Glycerol'};
DivCell = struct2cell(group);
%%
Instruction.comparision = [1 2 3 4];
compareDim(path_root, DivCell, Instruction, Axis, headfilename);
% Selection = [2 1 1];
% compareDimThat(path_root, DivCell, Instruction, Axis, Selection, headfilename);
% 
end
