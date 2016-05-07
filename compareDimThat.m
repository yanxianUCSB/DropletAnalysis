function compareDimThat(path_root, Group, Intruct, Axis, selectedCol, headfilename)
% Ver 4.0
% comparision = [dim1 dim2 dim3 dim4] showing the way to present data

analtype = 'compareDim';
inputtype = 'diameterDist';

%% Make Output Dir
pathnameSave = [ analtype, '\'];
mkdir([path_root, '\', pathnameSave]);

%% Load head.csv
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

csvfilename = [path_root, '\' inputtype,'\', headfilename, '.csv'];
chead = read_mixed_csv(csvfilename, ',');
chead(all(cellfun('isempty',chead),2),:) = [];

head = cell2table(chead(2:size(chead,1), :));
head.Properties.VariableNames = chead(1,:);

%% Get header and body
header = head.Properties.VariableNames;
body = chead(2:size(chead, 1),:);

%% Update Header
if sum(cellfun(cellfind(analtype), header)) == 0,
    %     header = [header, {analtype}];
end
thisInputCol = find(cellfun(cellfind(inputtype), header));
thisOutputCol = find(cellfun(cellfind(analtype), header));

%% Subset body
for divi = 1:length(Group)
    tc = table2cell(head(:, Intruct.col(divi)));
    DIV1 = Group{divi};
    [thisdiv, ~, thisdivIndex] = uniquetol2(str2double(tc), DIV1);
    body = [body, strtrim(cellstr(num2str(thisdiv(thisdivIndex))))];
    header = [header, {['DivIndex', num2str(divi)]}];
    divIndexCell{divi} = thisdivIndex;
end
newHead = [header; body];

%%
dimi = Intruct.comparision(1);
dimx = Intruct.comparision(2);
dimy = Intruct.comparision(3);
dimz = Intruct.comparision(4);
subplotsx = length(Group{dimx});
subplotsy = length(Group{dimy});
subplotsz = length(Group{dimz});




for zi = 1:subplotsz
    if zi ~= selectedCol(3)
        continue
    end
    %% parameters for figure and panel size
    plotheight=20;
    plotwidth=16;
    %setting the Matlab figure
    f=figure('visible','off');
    clf(f);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [plotwidth plotheight]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);
    
    %% create axes
    xi=selectedCol(1);
    yi=selectedCol(2);
    ax=axes();
    set(ax,'yLim', Axis.yLim);
    set(ax,'xLim', Axis.xLim);
    xlabel(ax, Axis.xLabel);
    ylabel(ax, Axis.yLabel);
    
    subbody = body((xi == divIndexCell{dimx}) & ...
        (yi == divIndexCell{dimy}) &...
        (zi == divIndexCell{dimz}), :);
    
    if size(subbody, 1) == 0
        continue
    end
    %% sort subbody
    for iii = 1:length(subbody(:,2));
        subbodytt(iii) = str2num(subbody{iii, 2});
    end
    [~, kkk] = sort(subbodytt);
    subbody = subbody(kkk, :);
    clear iii kkk subbodytt;
    %% filenames
    filenames = subbody(:, thisInputCol);
    %% Load Data
    meanDiam = [];
    stdDiam = [];
    binDiameters = [];
    for iiii = 1:length(filenames)
        [filenamePath, filenameSample] = fileparts(filenames{iiii});
        load([path_root, '\', filenamePath, '\', filenameSample, '.mat'], 'S');
        %% read S
        meanDiam = [meanDiam; S.meanDiam];
        stdDiam = [stdDiam; S.stdDiam];
        binDiameters = [binDiameters; S.binDiameters];
    end
    %% Plot size dist
%     hold all;
%     for iiii = 1:size(meanDiam,1),
%         
%         lineProps.width = 1.5;
%         lineProps.col = {getColor(iiii)};
%         transparent = 1;
% %         mseb(binDiameters(iiii, :), meanDiam(iiii, :), stdDiam(iiii, :), lineProps, transparent);
%             plot(binDiameters(iiii, :), meanDiam(iiii, :), ...
%                 'LineWidth', 1.5, 'Color', getColor(iiii));
%         
%     end
% 
%     thislegendi = Intruct.col(Intruct.comparision(1));
%     salts = round(100*cellfun(@str2num, subbody(:,thislegendi))) / 100;
%     for kim = 1:size(subbody(:,thislegendi), 1)
%         LG{kim} = strjoin([{Intruct.names{dimi}},...
%             {' = '}, {num2str(salts(kim))}, {' '}, ...
%             {Axis.Units{dimi}}]);
%     end
%     legend([LG], 'Location', 'NorthEast');
%     
%     for iiii = 1:size(meanDiam,1)
%         errorbar(binDiameters(iiii, :), meanDiam(iiii, :), stdDiam(iiii, :), 'Color', getColor(iiii));
%     end
    
createfigure(binDiameters(1,:)', meanDiam', binDiameters', meanDiam', stdDiam');
    
    %Saving eps with matlab and then producing pdf and png with system commands
    %     dimi = Instruction.comparision(1);
    dc = Group{dimz};
    filenameSample = ([Intruct.names{Intruct.comparision(4)}, num2str(dc(zi))]);
    %     filenameSample = ([Instruction.names{dimz}, ' ', num2str(Selection), ' ', ...
    %         num2str(round(dc(zi)*100)/100),' ', Axis.Units{dimz}]);
    
    %% F_cking Title
%     [ax h] = suplabel(['Size Distribution of ', Intruct.names{dimz}, ' at ', ...
%         filenameSample],'t');
    %% Save pdf
    display(['saving ', filenameSample]);
    filenameSave = [pathnameSave, filenameSample];
    export_fig([path_root, '\', filenameSave], gcf);
    print(gcf, '-dpdf','-loose',[path_root, '\', filenameSave,'.pdf']);
    print(gcf, '-depsc',[path_root, '\', filenameSave,'.eps']);
    display(['saved']);
    
%     close all;
end

%% Save newHead
newds = cell2dataset([header; body]);
newcsvfilename = [path_root, '\', pathnameSave, headfilename, '.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',');
