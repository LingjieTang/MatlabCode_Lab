classdef DataModel < handle
    %DataModel that contains: Dataset: The data FigureType: The type of the
    %figure to present the data

    properties
        Dataset = load ("Dataset.mat").Dataset;
        FigureType = 'Bar';
        OutlierRemove = 'none';
        Error = false;
        Significance = false;
        LimitedData = false;
        PartialAnalyze = [1,2,4];
    end

    properties(Hidden)
        DataParser;
    end

    events
        DataChanged;
    end

    methods
        function obj = DataModel()
            obj.CreateDataParser();
        end

        function ChangeData(obj, varargin)
            p = obj.DataParser;
            p.parse(varargin{:});
            Fields = fields(p.Results);
            for ii = 1:length(Fields)
                obj.(Fields{ii}) = p.Results.(Fields{ii});
            end
            obj.notify('DataChanged');
        end

        function CreateDataParser(obj)
            obj.DataParser = inputParser();
            DataPropertiesName = properties(obj);
            for ii = 1:length(DataPropertiesName)
                DataPropertiesDefault = obj.(DataPropertiesName{ii});
                obj.DataParser.addParameter(DataPropertiesName{ii}, DataPropertiesDefault);
            end
        end
    end

end

