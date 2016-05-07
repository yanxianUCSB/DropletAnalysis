function compareDim(path_root, DivCell, Instruction, Axis, headfilename)
% Ver 4.0
% comparision = [dim1 dim2 dim3 dim4] showing the way to present data
Selection = [];

analtype = 'compareDim';
inputtype = 'diameterDist';
if ~exist('path_root', 'var'),
    path_root = uigetdir('C:/', analtype);    %Choose directory containing TIFF files.
end
if ~exist('headfilename', 'var'),
    headfilename = 'head';
end
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
for divi = 1:length(DivCell)
    tc = table2cell(head(:, Instruction.col(divi)));
    DIV1 = DivCell{divi};
    [thisdiv, ~, thisdivIndex] = uniquetol2(str2double(tc), DIV1);
    body = [body, strtrim(cellstr(num2str(thisdiv(thisdivIndex))))];
    header = [header, {['DivIndex', num2str(divi)]}];
    divIndexCell{divi} = thisdivIndex;
end
newHead = [header; body];

%%
dimi = Instruction.comparision(1);
dimx = Instruction.comparision(2);
dimy = Instruction.comparision(3);
dimz = Instruction.comparision(4);
subplotsx = length(DivCell{dimx});
subplotsy = length(DivCell{dimy});
subplotsz = length(DivCell{dimz});


if ~isempty(Selection)
    
    figurePublish();

    theseRows = ismember(divIndexCell{dimx}, Selection(1)) & ...
        ismember(divIndexCell{dimy}, Selection(2));
    
    body = body(theseRows, :);
    for divi = 1:length(DivCell)
        thisdivIndex = divIndexCell{divi};
        divIndexCell{divi} = thisdivIndex(theseRows);
    end
    
    subplotsx = 1;
    subplotsy = 1;
    tmp = DivCell{dimx};
    DivCell{dimx} = tmp(Selection(1));
    tmp = DivCell{dimy};
    DivCell{dimy} = tmp(Selection(2));
end

for zi = 1:subplotsz
        %% parameters for figure and panel size
        plotheight=20;
        plotwidth=16;
        %     subplotsx=subplotsx;
        %     subplotsy=subplotsy;
        leftedge=1.2;
        rightedge=0.4;
        topedge=1;
        bottomedge=1.5;
        spacex=0.2;
        spacey=0.2;
        fontsize=5;
        sub_pos=subplot_pos(plotwidth,plotheight,leftedge,rightedge,bottomedge,topedge,subplotsx,subplotsy,spacex,spacey);
        
        %setting the Matlab figure
        f=figure('visible','off');
        clf(f);
        set(gcf, 'PaperUnits', 'centimeters');
        set(gcf, 'PaperSize', [plotwidth plotheight]);
        set(gcf, 'PaperPositionMode', 'manual');
        set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);
    
    %% loop to create axes
    for xi=1:subplotsx
        for yi=1:subplotsy
            
            ax=axes('position',sub_pos{xi,yi},'XGrid','off','XMinorGrid','off','FontSize',fontsize,'Box','on','Layer','top');
                        
 
            if yi==subplotsy
                dc = DivCell{dimz};
                title([Instruction.names{dimz},' ', ...
                    num2str(round(dc(zi)*100)/100),' ', Axis.Units{dimz}])
            end
            
            if yi>1
                set(ax,'xticklabel',[])
            end
            
            if xi>1
                set(ax,'yticklabel',[])
            end
            
            if xi==1
                %                 dimi = Instruction.comparision(2);
                dc = DivCell{dimy};
                ylabel([Instruction.names{dimy},' ', ...
                    num2str(round(dc(yi)*100)/100),' ', Axis.Units{dimy}])
                %                 ylabel(['RNA ',num2str(round(rna(yi)*10)/10),' ug/mL'])
                set(ax,'yLim',Axis.yLim);
            end
            

            
            if yi==1
                %                 dimi = Instruction.comparision(3);
                dc = DivCell{dimx};
                xlabel([Instruction.names{dimx},' ', ...
                    num2str(round(dc(xi)*100)/100),' ', Axis.Units{dimx}])
                %                 xlabel(['Tau ',num2str(round(tau(xi)*10)/10),' uM'])
                set(ax,'xLim',Axis.xLim);
            end
            
            
            subbody = body(xi == divIndexCell{dimx} & ...
                yi == divIndexCell{dimy} &...
                zi == divIndexCell{dimz}, :);
            if ~isempty(Selection)
                subbody = body;
            end
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
                plot(binDiameters(iiii, :), meanDiam(iiii, :), 'LineWidth', 1.0, 'Color', getColor(iiii));
                
            end
            for iiii = 1:size(meanDiam,1),
                plot(binDiameters(iiii, :), meanDiam(iiii, :) + stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
                plot(binDiameters(iiii, :), meanDiam(iiii, :) - stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
                %                 errorbar(binDiameters(ii, :), meanDiam(ii, :), stdDiam(ii, :),':');
            end
            xlim(Axis.xLim);
            ylim(Axis.yLim);
            
            thislegendi = Instruction.col(Instruction.comparision(1));
            h_legend = legend([num2str(round(100*cellfun(@str2num, subbody(:, thislegendi)))/100)],...
                'Location', 'NorthEast');
            %             set(h_legend,'FontSize', 5);

            
        end
    end
    
    %Saving eps with matlab and then producing pdf and png with system commands
%     dimi = Instruction.comparision(1);
    dc = DivCell{dimz};
    filenameSample = ([Instruction.names{Instruction.comparision(4)}, num2str(dc(zi))]);
%     filenameSample = ([Instruction.names{dimz}, ' ', num2str(Selection), ' ', ...
%         num2str(round(dc(zi)*100)/100),' ', Axis.Units{dimz}]);
    
    %% F_cking Title
    [ax h] = suplabel(['Size Distribution of ', Instruction.names{dimz}, ' at ', ...
        filenameSample],'t');
    %% Save pdf
    display(['saving ', filenameSample]);
    filenameSave = [pathnameSave, filenameSample];
    export_fig([path_root, '\', filenameSave], gcf);
    print(gcf, '-dpdf','-loose',[path_root, '\', filenameSave,'.pdf']);
    display(['saved']);
    
    close all;
end

%% Save newHead
newds = cell2dataset([header; body]);
newcsvfilename = [path_root, '\', pathnameSave, headfilename, '.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',');
