function tifData = getTifData(filename)
% 
    imageInfo=imfinfo(filename);
    imageWidth=imageInfo(1).Width;
    imageHeight=imageInfo(1).Height;
    
    vBin=96/imageInfo(1).YResolution;
    hBin=96/imageInfo(1).XResolution;
    
    numFrames=length(imageInfo);
    imageData=zeros(imageHeight,imageWidth,numFrames,'uint16');
    
%     warning('off','MATLAB:imagesci:Tiff:libraryWarning');
%     warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
    imageData = imread(filename);
%     warning('on','MATLAB:imagesci:Tiff:libraryWarning');
%     warning('on','MATLAB:imagesci:tiffmexutils:libtiffWarning');
        
    tifData =  struct(...
        'numFrames',{numFrames}',...
        'imageData',{imageData},...
        'verticalBinning',{vBin},...
        'horizontalBinning',{hBin});

end