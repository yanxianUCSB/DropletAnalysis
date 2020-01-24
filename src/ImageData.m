classdef ImageData
% Object for image manipulation.

    properties
        filepath = '';
        A, map, transparency;   % returned by imread
        measurements;           % returned by regionprops
    end
    properties (Hidden)
        islabeled = false;      % binary. process flag.
        ismeasured = false;
        isgradient = false;
        isinverted = false;
    end
    properties (Dependent)
        width, height;          % int. unit: pixel
        isbinary, isuint16;     % binary. Image types.
    end
    % getters and setters
    methods
        function width = get.width(obj)
            width = size(obj.A, 2);
        end
        function height = get.height(obj)
            height = size(obj.A, 1);
        end
        function isbinary = get.isbinary(obj)
            isbinary = isa(obj.A, 'logical');
        end
        function isuint16 = get.isuint16(obj)
            isuint16 = isa(obj.A, 'uint16');
        end
    end
    methods
        function obj = ImageData(filepath)
            if nargin == 0
                return
            end
            if isstruct(filepath)
                filepath = fullfile(filepath.folder, filepath.name);
            elseif ischar(filepath) && strcmp(filepath, 'demo')
                % TODO: move this line to ImageDataTest. 
                filepath = 'testin/2N4R-1/Pos0/img_000000000_Brightfield_000.tif';
            end
            assert(ischar(filepath));
            obj.filepath = filepath;
            [obj.A, obj.map, obj.transparency] = imread(obj.filepath);
        end
        function b = issameimage(obj, imagedata)
            assert(isa(imagedata, 'ImageData'));
            b = strcmp(obj.filepath, imagedata.filepath);
        end
        function obj = imXOR(obj, imagedata)
            % merge two imagedata using logical XOR
            assert(obj.issameimage(imagedata));
            % assume two imagedatas have no overlapping regions
            % TODO: using point sorting to exclude overlapping regions.
            if obj.ismeasured && imagedata.ismeasured
                obj.A = xor(obj.A, imagedata.A);
                obj = obj.labelimage();
                obj = obj.regionprops();
                return
            else
                throw(MException('ImageData:imxor:NotLabeledGrayscale', ...
                    'A.imxor(B), either A or B is NotLabeledGrayscale imagedata'));
            end
        end
        function obj = invert(obj)
            % obj should be either binary or uint16
            if obj.isbinary
                obj.A = ~obj.A;
            elseif obj.isuint16
                obj.A = 2^16 - obj.A;
            else
                throw(MException('ImageData:invert:NotUint16orBinary', ''));
            end
            obj.isinverted = ~obj.isinverted;
        end
        function obj = stretchlim(obj)
            % lowhigh = stretchlim(I) computes the lower and upper limits 
            % that can be used for contrast stretching grayscale or RGB 
            % image I. The limits are returned in lowhigh. By default, the
            % limits specify the bottom 1% and the top 1% of all pixel values.
            if obj.isbinary
                obj.A = uint16(obj.A)*2^16;
            else
                obj.A = imadjust(obj.A, stretchlim(obj.A), []);
            end
        end
        function obj = imbinarize(obj, sensitivity)
            % Binarize grayscale image by adaptive thresholding.
            if ~obj.isbinary
                obj.A = imbinarize(obj.A, 'adaptive','Sensitivity',sensitivity);
            end
        end
        function obj = imgradient(obj)
            % Convert grayscale image to magnitude of gradient.
            if ~obj.isgradient
                obj.A = imgradient(obj.A);
                obj.isgradient = true;
            end
        end
        function obj = labelimage(obj)
            % Label binarized images
            assert(obj.isbinary);
            obj.A = bwlabel(obj.A); 
            obj.islabeled = true;
        end
        function obj = imfill(obj)
            % Filled binary image
            assert(obj.isbinary);
            obj.A = imfill(obj.A, 'holes');
        end
        function obj = regionprops(obj)
            % Measure regional properties.
            % Circularity is MATLAB 2019b only
            % Circularity that specifies the roundness of objects, returned
            % as a struct with field Circularity. The struct contains the
            % circularity value for each object in the input image. The
            % circularity value is computed as (4*Area*pi)/(Perimeter2).
            % For a perfect circle, the circularity value is 1. The input
            % must be a label matrix or binary image with contiguous
            % regions. If the image contains discontiguous regions,
            % regionprops returns unexpected results. Circularity is not
            % recommended for very small objects such as a 3*3 square. For
            % such cases the results might exceed the circularity value for
            % a perfect circle which is 1.
            %
            %Eccentricity of the ellipse that has the same second-moments
            %as the region, returned as a scalar. The eccentricity is the
            %ratio of the distance between the foci of the ellipse and its
            %major axis length. The value is between 0 and 1. (0 and 1 are
            %degenerate cases. An ellipse whose eccentricity is 0 is
            %actually a circle, while an ellipse whose eccentricity is 1 is
            %a line segment.)
            %
            % 'EquivDiameter'	Diameter of a circle with the same area as
            % the region, returned as a scalar. Computed as
            % sqrt(4*Area/pi).
            assert(obj.islabeled);
            obj.measurements = regionprops(obj.A, 'EquivDiameter','Eccentricity','Area','Perimeter');
            obj.ismeasured = true;
        end
        function obj = subsetregion(obj, minDiam, maxDiam, ecc, cir)
            % Subset regions based on diameter range, max eccentricity and
            % min circularity. See regionprops for definitions.
            assert(obj.ismeasured);
            % compatible with MATLAB 2018b
            circ = [obj.measurements.Area].*pi*4 ./ [obj.measurements.Perimeter] .^2;
            idx = find([obj.measurements.EquivDiameter] > minDiam & ...
                [obj.measurements.EquivDiameter] < maxDiam & ... 
                circ > cir & ...
                [obj.measurements.Eccentricity] < ecc);
            obj.A = ismember(obj.A, idx);
            obj.ismeasured = false;
        end
        function obj = finddroplet(obj, params)
            % Detect and labeled droplets.
            %' obj should be binary or uint16
            assert(obj.isbinary || obj.isuint16);
            %setup params
            if nargin == 1; params = DropletParams(); end
            assert(isa(params, 'DropletParams'));
            [sensitivity, minDiam, maxDiam, ecc, cir] = params.print();
            %find obj and its invert
            function obj = find_(obj)
                if ~obj.isbinary
                    obj = obj.stretchlim();
                    obj = obj.imbinarize(sensitivity);
                end
                obj = obj.imfill();
                obj = obj.labelimage();
                obj = obj.regionprops();
                obj = obj.subsetregion(minDiam, maxDiam, ecc, cir);
                obj = obj.regionprops();
            end
            id1 = find_(obj);
            id2 = find_(obj.invert());
            obj = id1.imXOR(id2);
        end
        function percent = getpc(obj)
            % get percentage of droplet coverage
            if ~obj.isbinary; obj.A = imbinarize(obj.A, 1e-16); end
            percent = mean(obj.A, 'all');
            return
        end
        function diamhist = diamhist(obj)
            % return a Histogram object of equivDiameter
            assert(obj.ismeasured)
            diamhist = histogram([obj.measurements.EquivDiameter]);
        end
        function show(obj)
            image(obj.A, 'CDataMapping', 'scaled');
        end
        function histogram(obj)
            histogram(obj.A)
        end
        function filename = imwrite(obj, filename)
            if nargin == 0
                filename = strcat(tempname, '.png');
            end
            if obj.isbinary
                A = uint16(obj.A)*2^16;
            else
                A = obj.A;
            end
            imwrite(A, filename);
        end
    end
    methods (Static)
        function C = imfuse(id0, id)
            % fuse two ImageData.
            C = ImageData();
            A = id0.A; B = id.A;
            C.A = imfuse(A,B,'falsecolor','Scaling','joint','ColorChannels',[1 2 0]);
        end
        function imshowpair(id0, id1)
            imshowpair(id0.stretchlim().A, id1.stretchlim().A, 'montage');
        end
    end
end