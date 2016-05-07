function plotThis(path_root, Group, Intruct, Axis, selectedCol, headfilename)
% Ver 4.0
% comparision = [dim1 dim2 dim3 dim4] showing the way to present data

analtype = 'compareDim';
inputtype = 'diameterDist';

% Make Output Dir
pathnameSave = [ analtype, '\'];
mkdir([path_root, '\', pathnameSave]);

% Load head.csv
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

csvfilename = [path_root, '\' inputtype,'\', headfilename, '.csv'];
chead = read_mixed_csv(csvfilename, ',');
chead(all(cellfun('isempty',chead),2),:) = [];

head = cell2table(chead(2:size(chead,1), :));
head.Properties.VariableNames = chead(1,:);

% Get header and body
header = head.Properties.VariableNames;
body = chead(2:size(chead, 1),:);


thisInputCol = find(cellfun(cellfind(inputtype), header));
thisOutputCol = find(cellfun(cellfind(analtype), header));

% Subset body
for divi = 1:length(Group)
    tc = table2cell(head(:, Intruct.col(divi)));
    DIV1 = Group{divi};
    [thisdiv, ~, thisdivIndex] = uniquetol2(str2double(tc), DIV1);
    body = [body, strtrim(cellstr(num2str(thisdiv(thisdivIndex))))];
    header = [header, {['DivIndex', num2str(divi)]}];
    divIndexCell{divi} = thisdivIndex;
end
newHead = [header; body];

% %% Update Header
% if sum(cellfun(cellfind(analtype), header)) == 0,
%     %     header = [header, {analtype}];
% end

%
dimi = Intruct.comparision(1);
dimx = Intruct.comparision(2);
dimy = Intruct.comparision(3);
dimz = Intruct.comparision(4);

xi=selectedCol(1);
yi=selectedCol(2);
zi =  selectedCol(3);

subbody = body((xi == divIndexCell{dimx}) & ...
    (yi == divIndexCell{dimy}) &...
    (zi == divIndexCell{dimz}), :);

if size(subbody, 1) == 0
    return
end

% sort subbody
for iii = 1:length(subbody(:,dimi));
    subbodytt(iii) = str2num(subbody{iii, dimi});
end
[~, kkk] = sort(subbodytt);
subbody = subbody(kkk, :);
clear iii kkk subbodytt;

% Load filenames
filenames = subbody(:, thisInputCol);

% Load Data
meanDiam = [];
stdDiam = [];
binDiameters = [];
for iiii = 1:length(filenames)
    [filenamePath, filenameSample] = fileparts(filenames{iiii});
    load([path_root, '\', filenamePath, '\', filenameSample, '.mat'], 'S');
    % read S
    meanDiam = [meanDiam; S.meanDiam];
    stdDiam = [stdDiam; S.stdDiam];
    binDiameters = [binDiameters; S.binDiameters];
end

% Create legends
thislegendi = Intruct.col(Intruct.comparision(1));
values = round(100*cellfun(@str2num, subbody(:,thislegendi))) / 100;
for kim = 1:length(values)
    LG{kim} = [sprintf('%05s %03s ', Intruct.names{dimi},...
        num2str(values(kim))), ...
        Axis.Units{dimi}];
end
Axis.legend = LG;
Axis.title = [];

% Create figure
createfigure(binDiameters(1,:)', meanDiam',...
    binDiameters', meanDiam', stdDiam', Axis);

%% Save
% Saving eps with matlab and then pdf and png 
dc = Group{dimz};
filenameSample = ([Intruct.names{Intruct.comparision(4)}, num2str(dc(zi))]);
filenameSave = [pathnameSave, filenameSample];

display(['saving figures: ', filenameSample]);
export_fig([path_root, '\', filenameSave], gcf, '-png');
print(gcf, '-dpdf','-loose',[path_root, '\', filenameSave,'.pdf']);
print(gcf, '-depsc',[path_root, '\', filenameSave,'.eps']);
display(['saved']);


%% Save newHead
display(['saving meta: ', filenameSample]);
newds = cell2dataset([header; body]);
newcsvfilename = [path_root, '\', pathnameSave, headfilename, '.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',');
display(['saved']);

