classdef ImageDataArray < ObjectArray
    properties
        folder = '';
        idArray
        isdroplet = false
    end
    methods
        function obj = ImageDataArray(argin)
            obj.idArray = ImageData().empty();
            if nargin == 0
                return
            end
            if ischar(argin)
                if strcmp(argin, 'demo')
                    argin = 'testin';
                end
                obj.folder = argin;
                fileList = dir(fullfile(obj.folder, '**', '*Brightfield*.tif'));
                obj.idArray = obj.imarrayread(fileList);
            elseif isa(argin, 'ImageData')
                obj.idArray = argin;
            end
        end
        function obj = finddroplet(obj, params)
            assert(~isempty(obj.idArray))
            for ii = 1:numel(obj.idArray)
                obj.idArray(ii) = obj.idArray(ii).finddroplet(params);
            end
            obj.isdroplet = true;
        end
        function pcnt = getpc(obj)
            assert(obj.isdroplet)
            pcnt = zeros(1, obj.size);
            for ii = 1:obj.size
                pcnt(ii) = obj.idArray(ii).getpc();
            end
        end
        function res = analyze(obj)
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
    methods % getters and setters
        function idArray = get.idArray(obj)
            idArray = obj.data;
        end
        function obj = set.idArray(obj, idArray)
            obj.data = idArray;
        end
    end
    methods (Static)
        function idArray = imarrayread(fileList)
            assert(isstruct(fileList));
            idArray = ImageData().empty();
            for ii = 1:numel(fileList)
                idArray(ii) = ImageData(fileList(ii));
            end
        end
    end
    %1. convert image file path to ImageData
    %2. convert ImageData to size freq
    %3. read all subfolder and output a table of size freq
end

