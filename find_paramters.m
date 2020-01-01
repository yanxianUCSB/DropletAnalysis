%% isodata
da = DropletAnalyzer();
id = ImageData('demo');
id = id.stretchlim();
level = da.getlevel(id)
%% sensitivity
id = ImageData('demo');
I = id.A;
T = adaptthresh(I, 0.5);
BW = imbinarize(I, 'adaptive','Sensitivity',0.6);
% BW = imfill(BW);
imshowpair(I,BW,'montage');
%% minDiam, ecc filter
minDiam = 6;
maxDiam = 100;
Eccentricity = 1;
labeledImage = bwlabel(BW); 
measurements = regionprops(labeledImage, 'EquivDiameter','Eccentricity');
idx = find([measurements.EquivDiameter] > minDiam & ...
    [measurements.EquivDiameter] < maxDiam & ... 
    [measurements.Eccentricity] < Eccentricity);
binaryImage = ismember(labeledImage, idx);
imshowpair(I,binaryImage,'montage');

%% get best min, max Diam, sensitive for the demo image
id0 = ImageData('demo');
minDiams = 3:7;
sensies = linspace(0.6, 0.7, 5);
idArray = ImageData.empty(length(minDiams),0);
for ii = 1:length(minDiams)
    for jj = 1:length(sensies)
        minDiam = minDiams(ii);
        maxDiam = 100;
        ecc = 1;
        cir = 0.5;
        sensitivity = sensies(jj);
        id0 = id0.stretchlim();
        id = id0.imbinarize(sensitivity);
        id = id.labelimage();
        id = id.regionprops();
        id = id.subsetregion(minDiam, maxDiam, ecc, cir);
        idArray(ii, jj) = id;
    end
end
tmpName = tempname;
save(tmpName, 'id0','idArray')
% %%
% clearvars -except tmpName id0 idArray
% %%
% load(tmpName, 'id0', 'idArray')
%% examine by eyes
hugeImage = uint16(zeros(id0.height*length(minDiams), id0.width*2));
for ii = 1:length(minDiams)
    for jj = 1:length(sensies)
        hugeImage((id0.height*(ii-1)+1):(id0.height*ii), ...
        (2*id0.width*(jj-1)+1):(2*id0.width*jj)) = ...
            [id0.A, 2^16*idArray(ii, jj).A];
    end
end
% imwrite
imwrite(hugeImage, 'tmp.png');
% seems 0.6 and 3 is better
%% plot
