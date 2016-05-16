classdef Head
    properties
        path_root
        headfilename
        csvfilename
        inputtype
        inputCol
        outputtype
        outputCol
        head
        header
        body
        aggCol % Aggregated column Number
        subBodys
        pathnameSave
    end
    methods
        % Set
        function obj = set.path_root(obj, path_root)
            obj.path_root = path_root;
        end
        function obj = set.inputtype(obj, inputtype)
            obj.inputtype = inputtype;
        end
        function obj = set.outputtype(obj, outputtype)
            obj.outputtype = outputtype;
        end
        function obj = set.headfilename(obj, headfilename)
            obj.headfilename = headfilename;
        end
        % Initilization
        function obj = init(obj)
            obj = obj.loadhead();
            obj.header = obj.head(1,:);
            obj.body = obj.head(2:size(obj.head,1),:);
            obj.pathnameSave = [ obj.outputtype, '\'];
            obj = obj.updateIOCol();
        end

        % Update
        function obj = updateHeader(obj)
            if sum(strcmp(obj.outputtype, obj.header)) == 0,
                obj.header(end+1) = {obj.outputtype};
                obj = obj.updateIOCol();
            end
        end
        function obj = updateIOCol(obj)
            obj.inputCol = strcmp(obj.inputtype, obj.header);
            obj.outputCol = strcmp(obj.outputtype, obj.header);
        end
        % I/O
        function obj = loadhead(obj)
            obj.csvfilename = [obj.path_root, '\' obj.inputtype,'\', obj.headfilename, '.csv'];
            obj.head = read_mixed_csv(obj.csvfilename, ',');
        end
        function makedir(obj)
            if ~isdir([obj.path_root, '\', obj.pathnameSave])
                mkdir([obj.path_root, '\', obj.pathnameSave]);
            end
        end
        %
        function obj = group(obj, aggCol)
            obj.aggCol = aggCol;
            obj.subBodys = groupon(obj.body, aggCol);
        end
%         function obj = do(obj, fun)
%             for subbodyi = 1:length(obj.subBodys)
%                 subbody = obj.subBodys{subbodyi};
%                 % filenames
%                 filenames = subbody(:, 1);
%                 % Load Data
%                 results_theseFiles = [];
%                 for ii = 1:length(filenames)
%                     [filenamePath, filenameSample] = fileparts(filenames{ii});
%                     load([obj.path_root, '\', filenamePath, '\',...
%                         obj.inputtype, '\', filenameSample, '.mat'], 'Data');
%                     results_theseFiles = ...
%                         [results_theseFiles;...
%                         fun(Data)];
%                 end
%             end
% 
%         end
    end
end
