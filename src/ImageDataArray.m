classdef ImageDataArray < ObjectArray
    % Array of ImageData 
    properties
        folder = '';            % char: a path containing all images.
        idArray                 % ImageData Array
        isdroplet = false;      % binary: process flag.
    end
    methods
        function obj = ImageDataArray(argin)
            obj.idArray = ImageData().empty();
            if nargin == 0
                return
            end
            if ischar(argin)
                if strcmp(argin, 'demo')
                    % TODO: Define Demo in TestCase.
                    argin = 'testin';
                end
                obj.folder = argin;
                % TODO: print out patterns used for tif filenames.
%                 fileList = dir(fullfile(obj.folder, '**', '*Brightfield*.tif'));
                fileList = dir(fullfile(obj.folder, '**', '*.tif'));
                obj.idArray = obj.imarrayread(fileList);
            elseif isa(argin, 'ImageData')
                obj.idArray = argin;
            end
        end
        function obj = finddroplet(obj, params)
            % Finddroplets for each elem in idArray
            assert(~isempty(obj.idArray))
            for ii = 1:numel(obj.idArray)
                obj.idArray(ii) = obj.idArray(ii).finddroplet(params);
            end
            obj.isdroplet = true;
        end
        function pcnt = getpc(obj)
            % Return an array of percentage of idArray
            assert(obj.isdroplet)
            pcnt = zeros(1, obj.size);
            for ii = 1:obj.size
                pcnt(ii) = obj.idArray(ii).getpc();
            end
        end
        function res = analyze(obj)
            % Return a cell of two columns: FilePath and Percentage
            assert(obj.isdroplet)
            res = {'FilePath', 'Percentage'};
            for ii = 1:obj.size
                id = obj.idArray(ii);
                [filepath, ~, ~] = fileparts(id.filepath);
                res{ii+1,1} = filepath;
                res{ii+1,2} = id.getpc();
            end
        end
        function hugeImage = toHugeImage(obj)
            % Tile all images in idArray rowwise
            assert(~isempty(obj.idArray))
            ht = obj.idArray(1).height;
            wd = obj.idArray(1).width;
            hugeImage = uint16(zeros(ht * numel(obj.idArray), wd));
            for ii = 1:numel(obj.idArray)
                hugeImage(ht*(ii-1) + 1 : ht*ii, :) = obj.idArray(ii).A;
            end
        end 
        function obj = strechlim(obj)
            assert(~obj.isempty())
            for ii = 1:numel(obj.idArray)
                obj.idArray(ii) = obj.idArray(ii).stretchlim();
            end
        end
    end
    % getters and setters
    methods 
        function idArray = get.idArray(obj)
            idArray = obj.data;
        end
        function obj = set.idArray(obj, idArray)
            obj.data = idArray;
        end
    end
    methods (Static)
        function idArray = imarrayread(fileList)
            % Returns an Array of ImageData using a fileList struct
            assert(isstruct(fileList));
            idArray = ImageData().empty();
            for ii = 1:numel(fileList)
                idArray(ii) = ImageData(fileList(ii));
            end
        end
    end
end

