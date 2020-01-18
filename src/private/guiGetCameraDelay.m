function cameraDelay = guiGetCameraDelay()
%Enter the camera delay in seconds.  This is the delay between the start
%time of the experiment (e.g. injection start time) and the time that the
%camera turns on.

answer = inputdlg('Enter camera delay time in seconds: ',...
    'Camera Delay', 1, {'0'});
cameraDelay = str2num(answer{1});

end