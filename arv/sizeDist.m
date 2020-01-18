function sizeDist(path_root, ifgroupon, thrd_adjust, ...
    bwlabelpara,...
    Eccentricity, ...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam, headfilename)
% Ver 2.0

analtype = 'diameterDist';
inputtype = 'raw';
if ~exist('path_root', 'var'),
    path_root = uigetdir('C:/', analtype);    %Choose directory containing TIFF files.
    %     path_root = 'D:\Desktop\Yanxian-to-backup\Yanxian-to-backup';  % Test
end

%% Load head.csv
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
if ~exist('headfilename', 'var'),
    headfilename = 'head';
end
csvfilename = [path_root, '\' inputtype,'\', headfilename, '.csv'];
head = read_mixed_csv(csvfilename, ',');
head(all(cellfun('isempty',head),2),:) = [];
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
if ifgroupon,
    subBodys = groupon(body, [2:6, 8:10]);
else
    subBodys = groupon(body, [1]);
end

for subbodyi = 1:length(subBodys)
    subbody = subBodys{subbodyi};
    
    %% filenames
    filenames = subbody(:, 1);
    
    
    %% Load tifData
    kk = 1;
    diamDistribution = [];
    for ii = 1:length(filenames)
        [filenamePath, filenameSample] = fileparts(filenames{ii});
        load([path_root, '\', filenamePath, '\',...
            inputtype, '\', filenameSample, '.mat'], 'tifData');
        S = tifData;
        
        %% thresholding images based on Ridler Calvard
        %         Reference: [1]. T. W. Ridler, S. Calvard, Picture thresholding using an iterative selection method, 
%            IEEE Trans. System, Man and Cybernetics, SMC-8, pp. 630-632, 1978.
        Im = S.imageData;
        [threshold, ~] = isodata(Im);
 
        IBW = ones(size(Im));
        IBW(threshold + thrd_adjust <= Im) = 0;
        
        %% BW fill
        binaryImage = imfill(IBW);
        %% Regionprops
        % Filter out extremely small or large or eccentric regions
%         cc = bwconncomp(binaryImage); 
%         measurements = regionprops(cc, 'EquivDiameter','Eccentricity');
%         idx = find([measurements.EquivDiameter] > minDiam & ...
%             [measurements.EquivDiameter] < maxDiam & ... 
%             [measurements.Eccentricity] < Eccentricity);
%         binaryImage = ismember(labelmatrix(cc), idx);

        labeledImage = bwlabel(binaryImage); 
        measurements = regionprops(labeledImage, 'EquivDiameter','Eccentricity');
        idx = find([measurements.EquivDiameter] > minDiam & ...
            [measurements.EquivDiameter] < maxDiam & ... 
            [measurements.Eccentricity] < Eccentricity);
        binaryImage = ismember(labeledImage, idx);
        
%         %% Regionprops
%         labeledImage = bwlabel(binaryImage, bwlabelpara);
%         measurements = regionprops(labeledImage, 'EquivDiameter', 'Eccentricity');
%         allDiameters =  [measurements.EquivDiameter];
% 
%         %% Filter out extremely small or large or eccentric points
%         idx = find([measurements.EquivDiameter] > minDiam & ...
%             [measurements.EquivDiameter] < maxDiam & ... 
%             [measurements.Eccentricity] < Eccentricity);
                
        allDiameters = [measurements.EquivDiameter];
        allDiameters = allDiameters(idx);
        
        %% scale diameters in unit of micrometer
        allDiameters2 = SCALE * allDiameters;  % 20X IX-70 microscope, 0.322 um/pixel
        minDiam2 = SCALE * minDiam;
        maxDiam2 = SCALE * maxDiam;
%         allDiameters = allDiameters(( minDiam <= allDiameters) & (allDiameters <= maxDiam));
        
        interval = abs(maxDiam2-minDiam2)/numberOfBins;
        [counts, binDiameters] = hist(allDiameters2, minDiam2:interval:maxDiam2);
        
        diamDistribution(ii, :) = [counts];
        
    end
    
    %% Average and Std
    meanDiam = mean(diamDistribution, 1);
    stdDiam = std(diamDistribution, 1);
    if size(diamDistribution, 1) == 1,
        stdDiam = zeros(1, size(diamDistribution, 2));
    end
    
    
    %% Plot size dist
    
    figDist = figure;
    hold on;
    
    plotTitle = [inputtype, ' ',filenameSample, ' Droplet Size Dist'];
    
    bar(binDiameters, meanDiam);
    errorbar(binDiameters, meanDiam, stdDiam,'.');
    
    xlim([minDiam2, maxDiam2]);
    ylim([0, 100]);
    xlabel('diameter/[\mum]');
    ylabel('#');
    title(plotTitle);
    
    %% #% dist
    figDist2 = figure;
    hold on;
    
    plotTitle2 = [inputtype, ' ', filenameSample, ' Droplet Size Dist'];
    
    normDist = 100*normr2(diamDistribution);
    normDistMean = mean(normDist, 1);
    normDistStd = std(normDist, 1);
    if size(normDist, 1) == 1,
        normDistStd = zeros(1, size(normDist, 2));
    end
    
    bar(binDiameters, normDistMean, 'BarWidth', 1.0);
    errorbar(binDiameters, normDistMean, normDistStd,'.');
    
    xlim([minDiam2, maxDiam2]);
    ylim([0, 30]);
    xlabel('diameter/[\mum]');
    ylabel('%');
    title(plotTitle2);
    
    %% Save size distribution figures
    display(['saving ', filenameSample]);
    filenameSave = [pathnameSave, filenameSample];
    export_fig([path_root, '\', filenameSave], figDist);
    export_fig([path_root, '\', filenameSave, '_prc'], figDist2);
    
    %% Save size recognition images
    fig3 = figure;
    I = uint16(zeros([size(binaryImage) 3]));
    I(:, :, 2) = reshape(2^4*double(tifData.imageData), ...
        size(binaryImage, 1), size(binaryImage, 2));
    I(:, :, 3) = I(:, :, 2);
    I(:, :, 1) = I(:, :, 2) + im2uint16(binaryImage);
    image(I);
%     imagesc(255*binaryImage);
    export_fig([path_root, '\', filenameSave, '_bw'], fig3);
    
    
    S.meanDiam = meanDiam;
    S.stdDiam = stdDiam;
    S.binDiameters = binDiameters;
    save([path_root, '\', filenameSave, '.mat'], 'S');
    try
        csvwrite([path_root, '\', filenameSave, '.csv'], [binDiameters', meanDiam', stdDiam']);
    catch
    end
    display('saved');
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
newcsvfilename = [path_root, '\', pathnameSave, headfilename, '.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',')


