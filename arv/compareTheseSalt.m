function compareTheseSalt(path_root, DIV1, DIV2, DIV3, DIV4, Pick, xLim, yLim)
% Ver 4.0


analtype = 'publish';
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

%% Subset body
[salt, ~, saltindex] = uniquetol2(str2double(head.salt), DIV1);
body = [body, strtrim(cellstr(num2str(salt(saltindex))))];
[tau, ~, tauIndex] = uniquetol2(str2double(head.tau), DIV2);
body = [body, strtrim(cellstr(num2str(tau(tauIndex))))];
[rna, ~, rnaIndex] = uniquetol2(str2double(head.rna), DIV3);
body = [body, strtrim(cellstr(num2str(rna(rnaIndex))))];
[glycerol, ~, glycerolIndex] = uniquetol2(str2double(head.glycerol), DIV4);
body = [body, strtrim(cellstr(num2str(glycerol(glycerolIndex))))];

% Ver04151601
theseRows = rna(rnaIndex) == Pick(3) & ...
    tau(tauIndex) == Pick(2) &...
    glycerol(glycerolIndex) == Pick(4);
body = body(theseRows, :);
saltindex = saltindex(theseRows);
rnaIndex = rnaIndex(theseRows);
tauIndex = tauIndex(theseRows);
glycerolIndex = glycerolIndex(theseRows);
salt = Pick(1);
tau = Pick(2);
rna = Pick(3);
glycerol = Pick(4);
% 

subBodys = groupon(body, size(body,2)-2:size(body,2));
sl = length(salt);
tl = length(tau);
rl = length(rna);
gl = length(glycerol);

for gi = 1:gl
    %parameters for figure and panel size
    plotheight=20;
    plotwidth=16;
    subplotsx=tl;
    subplotsy=gl;
    leftedge=2;
    rightedge=0.8;
    topedge=1.5;
    bottomedge=3;
    spacex=2;
    spacey=2;
    fontsize=get(0, 'DefaultAxesFontSize');
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
            pi = yi;
            
 
            if yi==subplotsy
                title(['Glycerol ', num2str(round(glycerol(gi)*10)/10),' v/v', ...
                    ['RNA ',num2str(round(rna(yi)*10)/10),' ug/mL'],...
                    ['Tau ',num2str(round(tau(ti)*10)/10),' uM']]);
            end
            
            if yi>1
                set(ax,'xticklabel',[])
            end
            
            if xi>1
                set(ax,'yticklabel',[])
            end
            
            if xi==1
                ylabel(['Particle Number'])
            end
            
            if yi==1
                xlabel(['Particle Size / um']);
            end
            
            subbody = body;
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
            hold all;
            for iiii = 1:size(meanDiam,1),
                plot(binDiameters(iiii, :), meanDiam(iiii, :), 'LineWidth', 1.5, 'Color', getColor(iiii));
                
            end
            for iiii = 1:size(meanDiam,1),
                plot(binDiameters(iiii, :), meanDiam(iiii, :) + stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
                plot(binDiameters(iiii, :), meanDiam(iiii, :) - stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
                %                 errorbar(binDiameters(ii, :), meanDiam(ii, :), stdDiam(ii, :),':');
            end
            xlim(xLim);
            ylim(yLim);
            
            salts = round(10*cellfun(@str2num, subbody(:,2)))/10;
            for kim = 1:size(subbody(:,2), 1)
                LG{kim} = strjoin([{'NaCl = '}, {num2str(salts(kim))}, {' mM'}]);
            end
            h_legend = legend([LG],...
                'Location', 'NorthEast');
            %             set(h_legend,'FontSize', 5);

            
        end
    end
    
    %Saving eps with matlab and then producing pdf and png with system commands
    filenameSample=['Salt_Glycerol ', num2str(round(glycerol(gi)*100)/100),' vv'];
    
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
