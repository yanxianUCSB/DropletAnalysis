function processTifs(pathname)
% Ver 1.1
% Load tif files from Andor into Matlab with relevant metadata and save as a
% matlab .mat file for later use.

files = filesInPath(pathname);

%Enter the camera delay in seconds.  This is the delay between the start
%time of the experiment (e.g. injection start time) and the time that the
%camera turns on.
cameraDelay = guiGetCameraDelay();


for i = 1:size(files,1)
    
    file = files(1);
    filename = strcat([file.folder, filesep, file.name]);
    
    display(['Processing file ', num2str(i), ' of ', num2str(size(files,1))]);
    
    tifData = getTifData(filename);
    
    tifData.cameraDelay = {cameraDelay};
    
    save(strcat([filename(1:end-4),'.mat']),'tifData');
    
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



end


