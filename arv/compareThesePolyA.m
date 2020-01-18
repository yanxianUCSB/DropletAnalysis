function compareThesePolyA(path_root, DIV1, DIV2, DIV3, DIV4, Pick, xLim, yLim)
% Ver 2.0

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
thisSolCol = 4;

%% Subset body
[salt, ~, saltindex] = uniquetol2(str2double(head.salt), DIV1);
body = [body, strtrim(cellstr(num2str(salt(saltindex))))];
[tau, ~, tauIndex] = uniquetol2(str2double(head.tau), DIV2);
body = [body, strtrim(cellstr(num2str(tau(tauIndex))))];
[glycerol, ~, glycerolIndex] = uniquetol2(str2double(head.glycerol), DIV4);
body = [body, strtrim(cellstr(num2str(glycerol(glycerolIndex))))];

% Ver04151601
theseRows = salt(saltindex) == Pick(1) & ...
    tau(tauIndex) == Pick(2) &...
    glycerol(glycerolIndex) == Pick(4);
body = body(theseRows, :);
saltindex = saltindex(theseRows);
tauIndex = tauIndex(theseRows);
glycerolIndex = glycerolIndex(theseRows);
% 
salt = Pick(1);
tau = Pick(2);
rna = Pick(3);
glycerol = Pick(4);


subBodys = groupon(body, size(body,2)-2:size(body,2));

sl = length(salt);
tl = length(tau);
gl = length(glycerol);


for si = 1:sl
    
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
    f=figure('visible','off');
    clf(f);
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperSize', [plotwidth plotheight]);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);
    

    
    %loop to create axes
    for i=1:subplotsx
        for ii=1:subplotsy
            
            ax=axes('position',sub_pos{i,ii},'XGrid','off','XMinorGrid','off','FontSize',fontsize,'Box','on','Layer','top');
            
            ti = i;
            gi = ii;
            
            if ii==subplotsy
                title(['NaCl ', num2str(round(salt(si)*10)/10),' mM ',...
                    ['Glycerol ',num2str(round(glycerol(ii)*100)/100),' v/v'],...
                    ['Tau ',num2str(round(tau(ti)*10)/10),' uM']])
                
            end
            
            if ii>1
                set(ax,'xticklabel',[])
            end
            
            if i>1
                set(ax,'yticklabel',[])
            end
            
            if i==1
                ylabel('Particle Number')
            end
            
            if ii==1
                xlabel(['Particle Size / um']);
            end

            
            subbody = body;
            if size(subbody, 1) == 0
                continue
            end
            %% sort subbody
            for iii = 1:length(subbody(:,4));
                subbodytt(iii) = str2num(subbody{iii, 4});
            end
            [~, kkk] = sort(subbodytt);
            subbody = subbody(kkk, :);
            clear iii kkk subbodytt;
            %% filenames
            filenames = subbody(:, thisInputCol);
            Salts = subbody(:, end-2);
            polyA = subbody(:, 4);
            %% Load Data
            kk = 1;
            meanDiam = [];
            stdDiam = [];
            binDiameters = [];
            for iiii = 1:length(filenames)
                [filenamePath, filenameSample] = fileparts(filenames{iiii});
                load([path_root, '\', filenamePath, '\', filenameSample, '.mat'], 'S');
                S = S;
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
            
            for kim = 1:size(polyA, 1)
                polyA{kim} = strjoin([{'RNA = '}, polyA(kim), {' ug/mL'}]);
            end
            h_legend = legend([polyA]);
            %             set(h_legend,'FontSize', 5);
            
            
        end
    end
    
    
    %Saving eps with matlab and then producing pdf and png with system commands
    filenameSample=['RNA_NaCl ', num2str(round(salt(si)*10)/10),' mM'];
    
    %% F_cking Title
%     [ax h] = suplabel(filenameSample  ,'t');
    %%
    display(['saving ', filenameSample]);
    filenameSave = [pathnameSave, filenameSample];
    export_fig([path_root, '\', filenameSave, '.png'], gcf);
    print(gcf, '-dpdf','-loose',[path_root, '\', filenameSave,'.pdf'], '-r300');
    display(['saved']);
    
    % system(['epstopdf ',filename,'.eps'])
    % system(['convert -density 300 ',filename,'.eps ',filename,'.png'])
    
    
    close all;
end
