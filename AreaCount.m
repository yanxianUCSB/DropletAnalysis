function AreaCount(path_root, ifgroupon, thrd_adjust, ...
    xxx, ...
    Eccentricity, ...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam, headfilename)

analtype = 'AreaCount';
inputtype = 'raw';
if ~exist('path_root', 'var'),
    path_root = uigetdir('C:/', analtype);    %Choose directory containing TIFF files.
end

    % Output
    pathnameSave = [ analtype, '\'];
    mkdir([path_root, '\', pathnameSave]);

% Load head.csv
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
if ~exist('headfilename', 'var'),
    headfilename = 'head';
end
csvfilename = [path_root, '\' inputtype,'\', headfilename, '.csv'];
head = read_mixed_csv(csvfilename, ',');
head(all(cellfun('isempty',head),2),:) = [];

% Get header and body
header = head(1,:);
body = head(2:size(head,1),:);
[om1, om2] = size(head);

% Update Header
if sum(cellfun(cellfind(analtype), header)) == 0,
    header(om2+1) = {analtype};
end
thisInputCol = find(cellfun(cellfind(inputtype), header));
thisOutputCol = find(cellfun(cellfind(analtype), header));

% Subset body
if ifgroupon,
    subBodys = groupon(body, [2:6, 8:10]);
else
    subBodys = groupon(body, [thisInputCol]);
end

for subbodyi = 1:length(subBodys)
    subbody = subBodys{subbodyi};
    
    % filenames
    filenames = subbody(:, 1);
    
    % Load tifData
%     kk = 1;
    diamDistribution = [];
    Areas = [];
    for ii = 1:length(filenames)
        [filenamePath, filenameSample] = fileparts(filenames{ii});
        load([path_root, '\', filenamePath, '\',...
            inputtype, '\', filenameSample, '.mat'], 'tifData');
        fileData = tifData;
        
        %% thresholding images based on Ridler Calvard
        threshold = mean(mean(fileData.imageData));
        binaryImage = imThreshold(fileData.imageData, threshold + thrd_adjust);
        
        %% Regionprops
        labeledImage = bwlabel(binaryImage); 
        stats = regionprops('table',labeledImage, 'EquivDiameter','Eccentricity',...
            'Centroid', 'MajorAxisLength','MinorAxisLength');
        
        idx = find([stats.EquivDiameter] > minDiam & ...
            [stats.EquivDiameter] < maxDiam & ... 
            [stats.Eccentricity] < Eccentricity);
        binaryImage = ismember(labeledImage, idx);
%         allDiameters = stats.EquivDiameter(idx);
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        radii = diameters(idx)/2;
        centers = stats.Centroid(idx,:);

        % Areas
        Areas(ii) = sum(pi*radii.^2)/(size(binaryImage,1)*size(binaryImage,2));
        Areas(ii) = sum(sum(binaryImage ==1))/(size(binaryImage,1)*size(binaryImage,2));
    end
    
    %% Average and Std
    meanArea  = mean(Areas);
    stdArea  = std(Areas);
    if size(diamDistribution, 1) == 1,
        stdArea = 0;
    end

    %% Ratio and Salt
    Salt = str2num(subbody{1, 2});
    Ratio = str2num(subbody{1, 3})*22./str2num(subbody{1,4});
    
    
    %% Save size recognition images
    fig3 = figure;
    I = uint16(zeros([size(binaryImage) 3]));
    I(:, :, 2) = reshape(2^4*double(tifData.imageData), ...
        size(binaryImage, 1), size(binaryImage, 2));
    I(:, :, 3) = I(:, :, 2);
    I(:, :, 1) = I(:, :, 2) + im2uint16(binaryImage);
    imshow(I);
    
    viscircles(centers, radii, 'Color', 'b');
    

    filenameSave = [pathnameSave, filenameSample];
    
    display(['saving ', filenameSample]);
%     export_fig([path_root, '\', filenameSave, '_bw'], fig3);
    
    
    %% update
    % update head.csv
    newsubbody(1, :) = subbody(1, :);
    newsubbody(1, thisOutputCol) = {filenameSave};
    newsubbody(1, thisOutputCol+1) = {meanArea};
    newsubbody(1, thisOutputCol+2) = {stdArea};
    newsubbody(1, thisOutputCol+3) = {Salt};
    newsubbody(1, thisOutputCol+4) = {Ratio};


    %% Combine new subbody
    if ~exist('newBody', 'var')
        newBody = {};
    end
    newBody = [newBody; newsubbody];
    clear newsubbody;
    
end

%% Save area

header(end+1) = {'MeanArea'};
header(end+1) = {'StdArea'};
header(end+1) = {'Salt'};
header(end+1) = {'Ratio'};

newds = cell2dataset([header; newBody]);
newcsvfilename = [path_root, '\', pathnameSave, headfilename, '.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',')

%% Save Salt and Ratio figures
Axis.title = [];
Axis.legend = [];
Axis.xLabel = 'NaCl [mM]';
Axis.yLabel = 'Coverage [%]';
[X, I]= sort(cell2mat(newBody(:, thisOutputCol+3)));
newBody = newBody(I,:);
Y = 100*cell2mat(newBody(:, thisOutputCol+1));
ErrX = X;
ErrY = Y;
Err = 100*cell2mat(newBody(:, thisOutputCol+2));
fig4 = createfigureScatter(X, Y, ErrX, ErrY, Err, Axis);
export_fig([path_root, '\', pathnameSave, '\Salt'], fig4);

Axis.title = [];
Axis.legend = [];
Axis.xLabel = '\Deltatau187 : RNA mass ratio';
Axis.yLabel = 'Coverage [%]';
[X, I]= sort(cell2mat(newBody(:, thisOutputCol+4)));
newBody = newBody(I,:);
Y = 100*cell2mat(newBody(:, thisOutputCol+1));
ErrX = X;
ErrY = Y;
Err = 100*cell2mat(newBody(:, thisOutputCol+2));
fig5 = createfigureScatter(X, Y, ErrX, ErrY, Err, Axis);
export_fig([path_root, '\', pathnameSave, '\Ratio'], fig5);
