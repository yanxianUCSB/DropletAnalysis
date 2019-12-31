%%
da = DropletAnalyzer();
id = ImageData('demo');
id = id.stretchlim();
level = da.getlevel(id);
%%
id = ImageData('demo');
I = id.A;
T = adaptthresh(I, 0.5);
BW = imbinarize(I, 'adaptive','Sensitivity',0.55);
BW = imfill(BW);
imshowpair(I,BW,'montage');
%%
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

%%
obj.imagedata = obj.imagedata.tobinary(level);
obj.imagedata.show();

%% get best min, max Diam, sensitive for the demo image
id0 = ImageData('demo');
minDiams = 1:20;
f = figure('visible','off');
for ii = 1:20
    minDiam = minDiams(ii)
    maxDiam = 100
    ecc = 1
    cir = 0.5
    sensitivity = 0.55
    id0 = id0.stretchlim();
    id = id0.imbinarize(sensitivity);
    id = id.labelimage();
    id = id.regionprops();
    id = id.subsetregion(minDiam, maxDiam, ecc, cir);
    A = id0.A; B = id.A;
    C = imfuse(A,B,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
    imshow(C);
    imshowpair(A, B,'montage');
    title(num2str(ii))
    saveas(f, strcat('testin/', num2str(ii), '.png'));
end