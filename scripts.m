% Specify file to be processed
[filename, pathname, filterindex] = uigetfile();
%%
[~, name, ext] = fileparts(filename);
% Specify range of particle radii
radiusRange = [1, 5; 5, 10; 10, 20; 20, 40; 40, 80;];
% Specify edge detection threshold (in case of blurry images)
EdgeThreshold = 0.01;
% Specify polarity
ObjectPolarity = 'dark';
% Specify Sensitivity
Sensitivity = 0.90;
% Note: When tweaking the detection parameters above, keep in mind that
% this program disregards one of two circles that overlap with more than 10
% pixels. To change this, edit line 14 of findcircles.m - more information
% about this behaviour can be found in RemoveOverLap.m.
% Initialise variables
centers = [];
radii = [];
% Open image to be processed
thrd_adjust = 0;
image = 2^4*imread([pathname, filename]);
[threshold, ~] = isodata(image);
IBW = ones(size(image));
IBW(threshold + thrd_adjust <= image) = 0;
% BW fill
binaryImage = 1-imfill(IBW);

% Call findcircles.m function
[centers,radii] = findcircles(radiusRange,binaryImage,EdgeThreshold,ObjectPolarity,Sensitivity);
% Draw the Circles on the Image
imshow(image);
%
h = viscircles(centers,radii);
%%
% Save analysis results
save([pathname, name, '.mat'],'centers','EdgeThreshold','radii','radiusRange');
%%

%%
hist(radii)
