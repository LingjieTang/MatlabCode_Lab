classdef DataModel < handle
    %DataModel that contains: Dataset: The data FigureType: The type of the
    %figure to present the data

    properties
        Dataset = load ("Dataset.mat").Dataset;
        FigureType = 'Line';
        OutlierRemove = 'none';
        ShowError = false;
        Significance = false;
        LimitedData = false;
        PartialAnalyze = 1;%[1,2,4];
    end

    properties(Hidden)
        DataParser;
    end

    properties(Hidden, Dependent)
        DataPoints;
        Mean;
        Error;
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

        function DataPoints = get.DataPoints(obj)
            DataPoints = obj.GetMeanOrErrorOrDataPoints('MyDataPoints');
        end

        function Mean = get.Mean(obj)
            Mean = obj.GetMeanOrErrorOrDataPoints('mean');
        end

        function Error = get.Error(obj)
            Error = obj.GetMeanOrErrorOrDataPoints('MySem');
        end

        function Result = GetMeanOrErrorOrDataPoints (obj, Type)
            Empty = cellfun(@isempty, obj.Dataset);
            DataGroup = size(obj.Dataset, 1);
            DataNumber = size(obj.Dataset, 2);

            [r, c] = find(Empty == false, 1);
            DataExample = obj.Dataset{r, c};
            ColumnNum = size(DataExample, 2);
            Result = NaN(ColumnNum, DataGroup, DataNumber);
            if(strcmp(Type, 'MyDataPoints'))
                Result = cell(ColumnNum, DataGroup, DataNumber);
            end

            for ii = 1:ColumnNum
                Title = string(DataExample.Properties.VariableNames(ii)); %Get the current column title
                for jj = 1:DataGroup
                    for xx = 1:DataNumber
                        if(Empty(jj, xx) == false)
                            DataAnalyzing = obj.Dataset{jj, xx}.(Title);
                            Result(ii, jj, xx) = feval(Type, DataAnalyzing);
                        elseif(strcmp(Type, 'MyDataPoints'))
                            Result{ii, jj, xx} = [];
                        end
                    end
                end
            end
        end

    end
end

function Result = MySem(DataAnalyzing)
    Result = std(DataAnalyzing) / sqrt(length(DataAnalyzing));
end

function Result = MyDataPoints(DataAnalyzing)
    Result = num2cell(DataAnalyzing, 1);
end
