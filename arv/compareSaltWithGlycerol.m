function compareSaltWithGlycerol(path_root, DIV1, DIV2, DIV3, DIV4, yLimMax)
% Ver 3.0


analtype = 'compareSaltWithGlycerol';
inputtype = 'diameterDist';
if ~exist('path_root', 'var'),
    path_root = uigetdir('C:/', analtype);    %Choose directory containing TIFF files.
end

%% Make Output Dir
pathnameSave = [ analtype, '\'];
mkdir([path_root, '\', pathnameSave]);

%% Load head.csv
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

csvfilename = [path_root, '\' inputtype,'\head', '.csv'];
chead = read_mixed_csv(csvfilename, ',');
chead(all(cellfun('isempty',chead),2),:) = [];

head = cell2table(chead(2:size(chead,1), :));
head.Properties.VariableNames = chead(1,:);

%% Get header and body
header = head.Properties.VariableNames;
body = chead(2:size(chead, 1),:);

%% Update Header
if sum(cellfun(cellfind(analtype), header)) == 0,
    header = [header, {analtype}];
end
thisInputCol = find(cellfun(cellfind(inputtype), header));
thisOutputCol = find(cellfun(cellfind(analtype), header));
thisSortCol = 2;

%% Subset body
[salt, ~, saltindex] = uniquetol2(str2double(head.salt), DIV1);
body = [body, strtrim(cellstr(num2str(salt(saltindex))))];
[tau, ~, tauIndex] = uniquetol2(str2double(head.tau), DIV2);
body = [body, strtrim(cellstr(num2str(tau(tauIndex))))];
[rna, ~, rnaIndex] = uniquetol2(str2double(head.rna), DIV3);
body = [body, strtrim(cellstr(num2str(rna(rnaIndex))))];
[glycerol, ~, glycerolIndex] = uniquetol2(str2double(head.glycerol), DIV4);
body = [body, strtrim(cellstr(num2str(glycerol(glycerolIndex))))];

subBodys = groupon(body, [size(body,2)-3, size(body,2)-2, size(body,2)-1]);
sl = length(salt);
tl = length(tau);
rl = length(rna);
gl = length(glycerol);

for ri = 1:rl
    %parameters for figure and panel size
    plotheight=20;
    plotwidth=16;
    subplotsx=tl;
    subplotsy=gl;
    leftedge=1.2;
    rightedge=0.4;
    topedge=1;
    bottomedge=1.5;
    spacex=0.2;
    spacey=0.2;
    fontsize=5;
    sub_pos=subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);
    
    %setting the Matlab figure
    f=figure('visible','off')
    clf(f);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [plotwidth plotheight]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);
    
    %loop to create axes
    for xi=1:subplotsx
        for yi=1:subplotsy
            
            ax=axes('position',sub_pos{xi,yi},'XGrid','off','XMinorGrid','off','FontSize',fontsize,'Box','on','Layer','top');
            
            ti = xi;
            gi = yi;
            
            if yi==subplotsy
                title(['RNA ', num2str(round(rna(ri)*10)/10),' v/v'])
            end
            
            if yi>1
                set(ax,'xticklabel',[])
            end
            
            if xi>1
                set(ax,'yticklabel',[])
            end
            
            if xi==1
                ylabel(['Glycerol ',num2str(round(glycerol(gi)*100)/100),' vv'])
            end
            
            if yi==1
                xlabel(['Tau ',num2str(round(tau(xi)*10)/10),' uM'])
            end
            
            
            
            subbody = body(gi == glycerolIndex & ti == tauIndex & ri == rnaIndex, :);
            if size(subbody, 1) == 0
                continue
            end
            %% sort subbody
            for iii = 1:length(subbody(:,thisSortCol));
                subbodytt(iii) = str2num(subbody{iii, thisSortCol});
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
            hold all;
            for iiii = 1:size(meanDiam,1),
                plot(binDiameters(iiii, :), meanDiam(iiii, :), 'LineWidth', 2.0, 'Color', getColor(iiii));
                
            end
            for iiii = 1:size(meanDiam,1),
                plot(binDiameters(iiii, :), meanDiam(iiii, :) + stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
                plot(binDiameters(iiii, :), meanDiam(iiii, :) - stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
                %                 errorbar(binDiameters(ii, :), meanDiam(ii, :), stdDiam(ii, :),':');
            end
            xlim([0, 15]);
            ylim([0, yLimMax]);
            
            h_legend = legend([num2str(round(100*cellfun(@str2num, subbody(:,thisSortCol)))/100)],...
                'Location', 'NorthEast');
            %             set(h_legend,'FontSize', 5);
 

            
        end
    end
    
    %Saving eps with matlab and then producing pdf and png with system commands
    filenameSample=['RNA ', num2str(round(rna(ri)*100)/100),' ugmL'];
    
    %% F_cking Title
    [ax h] = suplabel(filenameSample  ,'t');
    %%
    display(['saving ', filenameSample]);
    filenameSave = [pathnameSave, filenameSample];
    export_fig([path_root, '\', filenameSave], gcf);
    print(gcf, '-dpdf','-loose',[path_root, '\', filenameSave,'.pdf']);
    display(['saved']);
    
    % system(['epstopdf ',filename,'.eps'])
    % system(['convert -density 300 ',filename,'.eps ',filename,'.png'])
    
    
    close all;
end
