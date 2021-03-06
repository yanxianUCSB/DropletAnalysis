function compareDimThis(path_root, DivCell, Instruction, Axis, Selection, headfilename)
% Ver 4.0
% comparision = [dim1 dim2 dim3 dim4] showing the way to present data


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
    header = [header, {analtype}];
end
thisInputCol = find(cellfun(cellfind(inputtype), header));
thisOutputCol = find(cellfun(cellfind(analtype), header));

%% Subset body
for divi = 1:length(DivCell)
    tc = table2cell(head(:, Instruction.col(divi)));
    DIV1 = DivCell{divi};
    [thisdiv, ~, thisdivIndex] = uniquetol2(str2double(tc), DIV1);
    body = [body, strtrim(cellstr(num2str(thisdiv(thisdivIndex))))];
    divIndexCell{divi} = thisdivIndex;
end

% [salt, ~, saltindex] = uniquetol2(str2double(head.salt), DIV1);
% body = [body, strtrim(cellstr(num2str(salt(saltindex))))];
% [tau, ~, tauIndex] = uniquetol2(str2double(head.tau), DIV2);
% body = [body, strtrim(cellstr(num2str(tau(tauIndex))))];
% [rna, ~, rnaIndex] = uniquetol2(str2double(head.rna), DIV3);
% body = [body, strtrim(cellstr(num2str(rna(rnaIndex))))];
% [glycerol, ~, glycerolIndex] = uniquetol2(str2double(head.glycerol), DIV4);
% body = [body, strtrim(cellstr(num2str(glycerol(glycerolIndex))))];

% ed = size(body,2) - length(Instruction.comparision);
% subBodys = groupon(body, ed+Instruction.comparision(2:4));
% subBodys = groupon(body, size(body,2)-2:size(body,2));
% sl = length(DivCell{1});
subplotsx = length(DivCell{2});
subplotsy = length(DivCell{3});
subplotsz = length(DivCell{4});
dimi = Instruction.comparision(1);
dimx = Instruction.comparision(2);
dimy = Instruction.comparision(3);
dimz = Instruction.comparision(4);

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
%         plotheight=20;
%         plotwidth=16;
        %     subplotsx=subplotsx;
        %     subplotsy=subplotsy;
%         leftedge=1.2;
%         rightedge=0.4;
%         topedge=1;
%         bottomedge=1.5;
%         spacex=0.2;
%         spacey=0.2;
%         fontsize=5;
%         sub_pos={[0.0750    0.0750    0.2156    0.2112]};
        
        %setting the Matlab figure
        f=figure('visible','off');
        clf(f);
%         set(gcf, 'PaperUnits', 'centimeters');
%         set(gcf, 'PaperSize', [plotwidth plotheight]);
%         set(gcf, 'PaperPositionMode', 'manual');
%         set(gcf, 'PaperPosition', [0 0 plotwidth plotheight]);
    
    %% loop to create axes
    for xi=1:subplotsx
        for yi=1:subplotsy
            
            ax=axes('XGrid','off','XMinorGrid','off','Box','on','Layer','top');
                        
             if yi==subplotsy
                dc = DivCell{dimz};
                titlestr = [Instruction.names{dimz},' ', ...
                    num2str(round(dc(zi)*100)/100),' ', Axis.Units{dimz}, ' '];
                dc = DivCell{dimy};
                titlestr = [titlestr, Instruction.names{dimy},' ', ...
                    num2str(round(dc(yi)*100)/100),' ', Axis.Units{dimy}, ' '];
                dc = DivCell{dimx};
                titlestr = ([titlestr, Instruction.names{dimx},' ', ...
                    num2str(round(dc(xi)*100)/100),' ', Axis.Units{dimx}, ' ']);
                title(titlestr);
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
                ylabel('Count #');
%                 ylabel([Instruction.names{dimy},' ', ...
%                     num2str(round(dc(yi)*100)/100),' ', Axis.Units{dimy}])
%                 ylabel(['RNA ',num2str(round(rna(yi)*10)/10),' ug/mL'])
            end
            
            if yi==1
%                 dimi = Instruction.comparision(3);
                dc = DivCell{dimx};
                xlabel('Size / um');
%                 xlabel([Instruction.names{dimx},' ', ...
%                     num2str(round(dc(xi)*100)/100),' ', Axis.Units{dimx}])
%                 xlabel(['Tau ',num2str(round(tau(xi)*10)/10),' uM'])
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
                
                lineProps.width = 1.5;
                lineProps.col = {getColor(iiii)};
                transparent = 1;
                mseb(binDiameters(iiii, :), meanDiam(iiii, :), stdDiam(iiii, :),...
                    lineProps, transparent);
%                 plot(binDiameters(iiii, :), meanDiam(iiii, :), 'LineWidth', 1.5, 'Color', getColor(iiii));
                
            end
%             for iiii = 1:size(meanDiam,1),
%                 plot(binDiameters(iiii, :), meanDiam(iiii, :) + stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
%                 plot(binDiameters(iiii, :), meanDiam(iiii, :) - stdDiam(iiii, :),'-.', 'Color', getColor(iiii));
%                 %                 errorbar(binDiameters(ii, :), meanDiam(ii, :), stdDiam(ii, :),':');
%             end
            xlim(Axis.xLim);
            ylim(Axis.yLim);
            
            
            thislegendi = Instruction.col(Instruction.comparision(1));
            salts = round(100*cellfun(@str2num, subbody(:,thislegendi))) / 100;
            for kim = 1:size(subbody(:,thislegendi), 1)
                LG{kim} = strjoin([{Instruction.names{dimi}},...
                    {' = '}, {num2str(salts(kim))}, {' '}, ...
                    {Axis.Units{dimi}}]);
            end
            h_legend = legend([LG],...
                'Location', 'NorthEast');
            
%             h_legend = legend([num2str(round(100*cellfun(@str2num, subbody(:, thislegendi)))/100)],...
%                 'Location', 'NorthEast');
            %             set(h_legend,'FontSize', 5);

            
        end
    end
    
    %Saving eps with matlab and then producing pdf and png with system commands
%     dimi = Instruction.comparision(1);
    dc = DivCell{dimz};
    filenameSample = ([Instruction.names{Instruction.comparision(1)}, ...
        ' ', num2str(Selection), ' ']);
    
%     %% F_cking Title
%     [ax h] = suplabel(['Size Distribution of ', Instruction.names{dimi}, ' at ', ...
%         filenameSample],'t');
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
