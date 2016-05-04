function sizeDist(path_root, ifgroupon, thrd_offset, ...
    bwlabelpara,...
    Eccentricity, ...
    numberOfBins,...
    SCALE, ...
    minDiam, maxDiam, headfilename)
% Ver 3.0
% Input and Output
outputName = 'diameterDist';
inputName = 'raw';

% Function Definition
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));

% Load head.csv and get rid of empty rows
head = read_mixed_csv([path_root, '\' inputName,'\', headfilename, '.csv'], ',');
head(all(cellfun('isempty',head),2),:) = [];

% Get header and body
header = head(1,:);
body = head(2:size(head,1),:);

% Update Header
if sum(cellfun(cellfind(outputName), header)) == 0,
    header(size(header,2)+1) = {outputName};
end
inputCol = find(cellfun(cellfind(inputName), header));
outputCol = find(cellfun(cellfind(outputName), header));

% Create output directory
outputPath = [ outputName, '\'];
mkdir([path_root, '\', outputPath]);

% Subset body into subbodys containing groups of parallel trials
if ifgroupon,
    subBodys = groupon(body, [2:6, 8:10]);
else
    subBodys = groupon(body, [inputCol]);
end

for subbodyi = 1:length(subBodys)
    subbody = subBodys{subbodyi};
    
    % get filenames from each subbody
    filenames = subbody(:, inputCol);
    
    % Load tifData from filenames
%     kk = 1;
    diamCounts = [];
    for ii = 1:length(filenames)
        [~, thisFileName, ~] = fileparts(filenames{ii});
        load([path_root, '\', inputName, '\', thisFileName, '.mat'], 'tifData');
        S = tifData;
        
        %% thresholding images based on Ridler Calvard
        %         Reference: [1]. T. W. Ridler, S. Calvard, Picture thresholding using an iterative selection method,
        %            IEEE Trans. System, Man and Cybernetics, SMC-8, pp. 630-632, 1978.
        Im = S.imageData;
        [threshold, ~] = isodata(Im);
        IBW = ones(size(Im));
        % Set threshold plus offset and convert biterate image to binary image.
        IBW(threshold + thrd_offset <= Im) = 0;
        
        % Fill hollow structure in binary image to simply connected region.
        binaryImage = imfill(IBW);
        
        %% find size distribution based on imfindcircles.m
        % Specify range of particle radii
        radiusRange = [5, 10; 10, 20; 20, 40; 40, 60; 60, 80; 80, 100;];
        % Specify edge detection threshold (in case of blurry images)
        EdgeThreshold = 0.01;
        % Specify polarity
        ObjectPolarity = 'bright';
        % Specify Sensitivity
        Sensitivity = 0.90;
        % Call findcircles.m function
        [centers,radii] = findcircles(radiusRange,binaryImage,EdgeThreshold,ObjectPolarity,Sensitivity);
        allDiameters = radii;
        %% Regionprops
        % Filter out extremely small or large or eccentric regions
%         cc = bwconncomp(binaryImage); 
%         measurements = regionprops(cc, 'EquivDiameter','Eccentricity');
%         idx = find([measurements.EquivDiameter] > minDiam & ...
%             [measurements.EquivDiameter] < maxDiam & ... 
%             [measurements.Eccentricity] < Eccentricity);
%         binaryImage = ismember(labelmatrix(cc), idx);

%         labeledImage = bwlabel(binaryImage); 
%         measurements = regionprops(labeledImage, 'EquivDiameter','Eccentricity');
%         idx = find([measurements.EquivDiameter] > minDiam & ...
%             [measurements.EquivDiameter] < maxDiam & ... 
%             [measurements.Eccentricity] < Eccentricity);
%         binaryImage = ismember(labeledImage, idx);
        
%         %% Regionprops
%         labeledImage = bwlabel(binaryImage, bwlabelpara);
%         measurements = regionprops(labeledImage, 'EquivDiameter', 'Eccentricity');
%         allDiameters =  [measurements.EquivDiameter];
% 
%         %% Filter out extremely small or large or eccentric points
%         idx = find([measurements.EquivDiameter] > minDiam & ...
%             [measurements.EquivDiameter] < maxDiam & ... 
%             [measurements.Eccentricity] < Eccentricity);
                
%         allDiameters = [measurements.EquivDiameter];
%         allDiameters = allDiameters(idx);
        
        %% scale diameters in unit of micrometer
        allDiameters2 = SCALE * allDiameters;  % 20X IX-70 microscope, 0.322 um/pixel
        minDiam2 = SCALE * minDiam;
        maxDiam2 = SCALE * maxDiam;
        %         allDiameters = allDiameters(( minDiam <= allDiameters) & (allDiameters <= maxDiam));
        
        interval = abs(maxDiam2-minDiam2)/numberOfBins;
        [counts, binDiameters] = hist(allDiameters2, minDiam2:interval:maxDiam2);
        
        % Truncate the diameter below the limit
        counts = counts(2:end);
        binDiameters = binDiameters(2:end);
        
        diamCounts(ii, :) = [counts];
    end
    
    %% Average and Std
    meanDiam = mean(diamCounts, 1);
    stdDiam = std(diamCounts, 1);
    if size(diamCounts, 1) == 1,
        stdDiam = zeros(1, size(diamCounts, 2));
    end
    
    
    %% Plot size dist
    
    figDist = figure;
    hold on;
    
    plotTitle = [inputName, ' ',thisFileName, ' Droplet Size Dist'];
    
    bar(binDiameters, meanDiam);
    errorbar(binDiameters, meanDiam, stdDiam,'.');
    
    xlim([minDiam2, maxDiam2]);
    ylim([0, 100]);
    xlabel('diameter/[\mum]');
    ylabel('#');
    title(plotTitle);
    
    %% percentage of dist
    figDist2 = figure;
    hold on;
    
    plotTitle2 = [inputName, ' ', thisFileName, ' Droplet Size Dist'];
    
    normDist = 100*normr2(diamCounts);
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
    display(['saving ', thisFileName]);
    filenameSave = [outputPath, thisFileName];
    export_fig([path_root, '\', filenameSave], figDist);
    export_fig([path_root, '\', filenameSave, '_prc'], figDist2);
    
    %% Save size recognition images
    fig3 = figure;
%     I = uint16(zeros([size(binaryImage) 3]));
%     I(:, :, 2) = reshape(2^8*double(tifData.imageData), ...
%         size(binaryImage, 1), size(binaryImage, 2));
%     I(:, :, 3) = I(:, :, 2);
%     I(:, :, 1) = I(:, :, 2) + im2uint16(binaryImage);
%     image(I);
%     imagesc(255*binaryImage);
imshow(2^4*tifData.imageData);
h = viscircles(centers, radii, 'EdgeColor', 'b');
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
    newsubbody(1, outputCol) = {filenameSave};
    %% Combine new subbody
    if ~exist('newBody', 'var')
        newBody = {};
    end
    newBody = [newBody; newsubbody];
    clear newsubbody;
    
end

newds = cell2dataset([header; newBody]);
newcsvfilename = [path_root, '\', outputPath, headfilename, '.csv'];
export(newds,'file',[newcsvfilename],'delimiter',',')


