

function processTifs(pathname)
% Ver 1.1
% Load tif files from Andor into Matlab with relevant metadata and save as a
% matlab .mat file for later use.


if ~exist('pathname', 'var')
    pathname = uigetdir('C:/', 'Choose directory containing TIF files:');    %Choose directory containing TIFF files.
end
files = dir(strcat([pathname,'/*.tif']));

%Enter the camera delay in seconds.  This is the delay between the start
%time of the experiment (e.g. injection start time) and the time that the
%camera turns on.

answer = inputdlg('Enter camera delay time in seconds: ',...
    'Camera Delay', 1, {'0'});
cameraDelay = str2num(answer{1});

for i = 1:size(files,1)
    
    display(['Processing file ', num2str(i), ' of ', num2str(size(files,1))]);
    
    
    filename=files(i).name;
    filePath = strcat([pathname,'/',filename]);
    imageInfo=imfinfo(filePath);
    imageWidth=imageInfo(1).Width;
    imageHeight=imageInfo(1).Height;
    
    vBin=96/imageInfo(1).YResolution;
    hBin=96/imageInfo(1).XResolution;
    
    numFrames=length(imageInfo);
    imageData=zeros(imageHeight,imageWidth,numFrames,'uint16');
    %         exposureTime = imageInfo(1).UnknownTags(13).Value;
    %         cycleTime = imageInfo(1).UnknownTags(15).Value;
    %         frameRate = 1.0/cycleTime;
    %         sensorTemp = imageInfo(1).UnknownTags(6).Value;
    
    
    
    warning('off','MATLAB:imagesci:Tiff:libraryWarning');
    warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
    imageData = imread(filePath);
    
    varname = genvarname(files(i).name);
    
    tifData =  struct(...
        'numFrames',{numFrames}',...
        'imageData',{imageData},...
        'cameraDelay',{cameraDelay},...
        'verticalBinning',{vBin},...
        'horizontalBinning',{hBin});
    
    %     tifData =  struct(...
    %         'numFrames',{numFrames}',...
    %             'exposureTime',{exposureTime},...
    %             'cycleTime',{cycleTime},...
    %             'frameRate',{frameRate},...
    %             'sensorTemp',{sensorTemp},...
    %     'imageData',{imageData},...
    %         'cameraDelay',{cameraDelay},...
    %         'verticalBinning',{vBin},...
    %         'horizontalBinning',{hBin});
    
    save(strcat([pathname,'/',filename(1:end-4),'.mat']),'tifData');
    
    %     %% Video record
    %     TiffName = filePath;
    %     in = imfinfo(TiffName);
    %     for k = 1 : numel(in)
    %         imshow(imread(TiffName, k));
    %         mov(k) = getframe; %// Change here
    %     end
    %     movie2avi(mov, strcat([pathname,'/',filename(1:end-4),'.avi']));
    %
end

warning('on','MATLAB:imagesci:Tiff:libraryWarning');
warning('on','MATLAB:imagesci:tiffmexutils:libtiffWarning');




