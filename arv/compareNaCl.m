function compareNaCl(path_root)
% Ver 2.0

analtype = 'compareNaCl';
inputtype = 'diameterDist';
if ~exist('path_root', 'var'),
    path_root = uigetdir('C:/', analtype);    %Choose directory containing TIFF files.
end

%% Load head.csv
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
csvfilename = [path_root, '\' inputtype,'_\head', '.csv'];
head = read_mixed_csv(csvfilename, ',');
pathnameSave = [ analtype, '\'];
mkdir([path_root, '\', pathnameSave]);

%% Get header and body
header = head(1,:);
body = head(2:size(head,1),:);
[om1, om2] = size(head);

%% Update Header
if sum(cellfun(cellfind(analtype), header)) == 0,
    header(om2+1) = {analtype};
end
thisInputCol = find(cellfun(cellfind(inputtype), header));
thisOutputCol = find(cellfun(cellfind(analtype), header));

%% Subset body
subBodys = groupon(body, [3:6]);

for subbodyi = 1:length(subBodys)
    subbody = subBodys{subbodyi};
    
    %% filenames
    filenames = subbody(:, thisInputCol);
    NaCls = subbody(:, 2);
    
    
    %% Load Data
    kk = 1;
    meanDiam = [];
    stdDiam = [];
    binDiameters = [];
    for ii = 1:length(filenames)
        [filenamePath, filenameSample] = fileparts(filenames{ii});
        load([path_root, '\', filenamePath, '\', filenameSample, '.mat'], 'S');
        S = S;
        
        %% read S
        meanDiam = [meanDiam; S.meanDiam];
        stdDiam = [stdDiam; S.stdDiam];
        binDiameters = [binDiameters; S.binDiameters];
    end
    
    
    %% Plot size dist
    
    figDist = figure;
    hold all;
    
    plotTitle = [inputtype, ' ',filenameSample(end-3 : end)];
    
    for ii = 1:size(meanDiam,1),
        plot(binDiameters(ii, :), meanDiam(ii, :), 'LineWidth', 2.0);
        
    end
    
    nacls = [NaCls];
    legend(nacls, 'NorthEast');
    
    for ii = 1:size(meanDiam,1),
        errorbar(binDiameters(ii, :), meanDiam(ii, :), stdDiam(ii, :),'.');
    end
    
        xlim([0, 20]);
        ylim([0, 300]);
    xlabel('diameter/[\mum]');
    ylabel('#');
    title(plotTitle);
    
    %% Save
    filenameSave = [pathnameSave, filenameSample];
    export_fig([path_root, '\', filenameSave], figDist);
    display(filenameSave);
    
    close all;
    
    %% update
    % update head.csv
    newsubbody(1, :) = subbody(1, :);
    newsubbody(1, thisOutputCol) = {filenameSave};
    %% Combine new subbody
    if ~exist('newBody', 'var')
        newBody = {};
    end
    newBody = [newBody; newsubbody];
    clear newsubbody;
    
end

newds = cell2dataset([header; newBody]);
newcsvfilename = [path_root, '\', pathnameSave, 'head.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',')


