classdef DataModel < handle
    %DataModel that contains: Dataset: The data FigureType: The type of the
    %figure to present the data

    properties
        RawDataset = load ("Dataset.mat").Dataset;
        FigureType = 'Line';
        OutlierRemove = 'none';
        ShowError = false;
        Significance = false;
        LimitedData = false;
        PartialAnalyze = 1;
    end

    properties(Hidden)
        DataParser;
    end

    properties(Hidden, Dependent)
        DataExample;
        DataColumns;
        Dataset;
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

            ChangedResult = rmfield(p.Results, p.UsingDefaults);
            ChangedField = fields(ChangedResult);
            obj.(ChangedField{:}) = ChangedResult.(ChangedField{:});
            if(obj.PartialAnalyze == 0)
                obj.PartialAnalyze = obj.DataColumns;
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

        function Dataset = get.Dataset(obj)
            Dataset = cellfun(@(x) obj.TakePartialData(x), obj.RawDataset, UniformOutput=false);
        end

        function DataColumns = get.DataColumns(obj)
            DataColumns = size(obj.DataExample, 2);
        end

        function DataExample = get.DataExample(obj)
            [r, c] = find(cellfun(@isempty, obj.RawDataset) == 0,1);
            DataExample = obj.RawDataset{r, c};
        end

        function PartialData = TakePartialData(obj, TotalData)
            if(isempty(TotalData))
                PartialData = [];
            else
                PartialData = TotalData(:, obj.PartialAnalyze);
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
            
            RawDataGroup = size(obj.RawDataset, 1);
            RawDataNumber = size(obj.RawDataset, 2);
            Empty = cellfun(@isempty, obj.RawDataset);
            % [r, c] = find(Empty == false, 1);
            % obj.DataExample = obj.RawDataset{r, c};
            Result = NaN(obj.DataColumns, RawDataGroup, RawDataNumber);
            if(strcmp(Type, 'MyDataPoints'))
                Result = cell(obj.DataColumns, RawDataGroup, RawDataNumber);
            end

            for ii = 1:obj.DataColumns
                Title = string(obj.DataExample.Properties.VariableNames(ii)); %Get the current column title
                for jj = 1:RawDataGroup
                    for xx = 1:RawDataNumber
                        if(Empty(jj, xx) == false)
                            DataAnalyzing = obj.RawDataset{jj, xx}.(Title);
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
