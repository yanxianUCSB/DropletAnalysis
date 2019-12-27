function files = filesInPath(pathname, type)
    % Return a struct array of files in a given path
    
    if ~exist('type', 'var')
        type = 'tif';
    end
    
    if ~exist('pathname', 'var')
        pathname = uigetdir('C:/', 'Choose directory containing TIF files:');    %Choose directory containing TIFF files.
    end

    files = dir(strcat([pathname,'/*.', type]));
end