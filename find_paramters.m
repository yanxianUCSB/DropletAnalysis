%% isodata
ida = DropletAnalyzer();
id = ImageData('demo');
id = id.stretchlim();
level = ida.getlevel(id)
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
minDiams = 3:5;
sensies = linspace(0.55, 0.65, 5);
idArray = ImageData.empty(length(minDiams),0);
params = DropletParams();

id0 = id0.stretchlim();
for ii = 1:length(minDiams)
    for jj = 1:length(sensies)
        %%
        params.minDiam = minDiams(ii);
        params.maxDiam = 100;
        params.ecc = 1;
        params.cir = 0.5;
        params.sensitivity = sensies(jj);
        idArray(ii, jj) = id0.finddroplet(params);
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


%% find all brightfield images in a folder and its subfolders
clear all;
% doc filefinder
ida0 = ImageDataArray('demo');
dp = DropletParams();
for sensitivity = linspace(0.6, 0.6, 1)
    dp.sensitivity = sensitivity;
    ida1 = ida0.finddroplet(dp);
    %%
    him0 = ida0.strechlim().toHugeImage();
    him1 = ida1.toHugeImage();
    imwrite([him0, 2^16*him1], strcat('tmp', num2str(sensitivity),'.png'));
end
%%
him0 = ida0.strechlim().toHugeImage();
him1 = ida1.toHugeImage();
imwrite([him0, 2^16*him1], 'tmp.png')
%% calculate percentage
percents = ida1.analyze();
cell2csv('results.csv', percents)

%% Work on real data
clear all;
datain = '/Users/yanxlin/Box/data/LightMicroscope/191122 NaCl SC';
ida0 = ImageDataArray(datain);
para = DropletParams();
ida1 = ida0.finddroplet(para);
%
for ii = 1:numel(ida1.idArray)
    id0A = ida0.idArray(ii).stretchlim().A;
    id1A = ida1.idArray(ii).A;
    imwrite(id0A, strcat('testout/', num2str(ii), 'o.png'));
    imwrite(uint16(id1A * 2^16), strcat('testout/', num2str(ii), '.png'));
end
%
percents = ida1.analyze();
cell2csv('results.csv', percents)

%% Result - 1
%' Result misses connected droplets that has large area but low circularity.
%Try including such regions
datain = '/Users/yanxlin/Box/data/LightMicroscope/191122 NaCl SC/2N4R-1-3/Pos0/img_000000000_Brightfield_002.tif';
id0 = ImageData(datain);
id1 = id0.finddroplet(DropletParams());
ImageData.imshowpair(id0, id1)
% results showed too much large irregular droplets identified. End Try.
%% Result - 2 
% z-stack images show that at some focus droplet appears brighter than
% background while at other focus droplet appears darker. Ideally, an alg
% should segment droplets based on its constrast with nearby surrounding.
% Current alg assumes droplets are brigher. Therefore experimentally we
% should do a z stack and select the one with maximum coverage.
%% 191122 NaCl SC/
clear all
datain = '/Users/yanxlin/Box/data/LightMicroscope/191122 NaCl SC/';
dataout= 'testout/';
ZeissCoverage(datain, dataout);
%% rebuttal repeat
datain = fullfile(getuserdir(),'../Box/data/LightMicroscope/190923-rebuttal-repeat/');
dataout= 'testout/1/';
ZeissCoverage(datain, dataout);

%%
% %% Try gradient
% clear all;
% minDiams = 3;
% sensies = linspace(0.6, 0.7, 1);
% idArray = ImageData.empty(length(minDiams),0);
% minDiam = 3;
% maxDiam = 100;
% ecc = 1;
% cir = 0.5;
% sensitivity = 0.6;
% 
% id0 = ImageData('demo');
% id1 = id0.imgradient();
% range(id1.A, 'all')
% id2 = id0.stretchlim();
% id2 = id2.imgradient();
% range(id2.A, 'all')
% %%
% id1.show()
% %%
% id2.show()
% %%
% imshowpair(originalI,dilatedI,'montage')
% 



