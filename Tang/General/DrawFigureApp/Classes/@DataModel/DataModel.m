classdef DataModel < handle
    %DataModel. The fomat in the raw dataset is :
    % For example, I have 3 different data group (control, exp. group1,
    % exp. group2), and I have 6 different data number in each group (DIV3,
    % 4, 5, 7, 9, 11). Then the 'RawDataset' should be a 3x6 cell.
    %
    % And in each grid of the cell is a table that may contain many
    % parameters in different columns(the number of 1st dendrite, the
    % dendritic length...).
    %
    %If you have many parallel repeat (do 1 exp. condition 3 times), just
    %concatenate them into 1 table.
    properties(SetAccess = private)
        RawDataset = load ("ExampleRawDataset.mat").RawDataset;
        FigureType = 'Line';
        OutlierRemove = 'none'; %Method to remove outlier when doing statistics
        LimitedData = false; %Only show limited data groups or numbers (which means the row and column in the RawDataset)
        LimitedRow = 0;
        LimitedColumn = 0;
        PartialAnalyze = 1; %Only analyze partial variables (which means the column in each grid of the cell RawDataset)
        ErrorMode = 'sem';
    end

    properties (Hidden)
        DataParser; %Parse the input
    end

    properties(Hidden, Dependent)
        RawDataExample; %The first none-empty grid of the cell RawDataset
        RawDataRows; %The row number of the Rawdataset, which means the number of data number
        RawDataColumns; %The column number of the Rawdataset, which means the number of data group
        RawDataVariableNames; %The variables (which means the column in each grid of the cell RawDataset) names
        RawDataVariableNum; %The variables (which means the column in each grid of the cell RawDataset) number

        Dataset; %The active dataset, which is determined by LimitedData and PartialAnalyze.
        DataExample; %The first none-empty grid of the cell Dataset
        DataRows; %The row number of the Dataset, which means the number of data number
        DataColumns; %The column number of the Dataset, which means the number of data group
        DataPoints; %table2array(Dataset)
        Mean; %Mean value of the DataPoints
        Error; %Error value of the DataPoints, can be set as sem or std
    end

    events
        DataChanged; %When the properties are changed
    end

    methods
        function obj = DataModel()
            obj.CreateDataParser(); %Create a inputparser
            obj.FillNaN(); %Fill the potential NaN data in the RawDataset
        end
        %% Claim some functions
        %The API to set the properties of DataModel object and notify
        %'DataChanged'
        ChangeData(obj, varargin)
        %Create a input parser
        CreateDataParser(obj)
        FillNaN(obj)
                %% The 'get' methods
        function RawDataExample = get.RawDataExample(obj)
            [r, c] = find(cellfun(@isempty, obj.RawDataset) == false,1);
            RawDataExample = obj.RawDataset{r, c};
        end

        function RawDataRows = get.RawDataRows(obj)
            RawDataRows = size(obj.RawDataset, 1);
        end

        function RawDataColumns = get.RawDataColumns(obj)
            RawDataColumns = size(obj.RawDataset, 2);
        end

        function RawDataVariableNames = get.RawDataVariableNames(obj)
            RawDataVariableNames = obj.RawDataExample.Properties.VariableNames;
        end

        function RawDataVariableNum = get.RawDataVariableNum(obj)
            RawDataVariableNum = length(obj.RawDataVariableNames);
        end

        function Dataset = get.Dataset(obj)
            if(~obj.LimitedData)
                Dataset = cellfun(@(x)  x(:, obj.PartialAnalyze), ...
                    obj.RawDataset, UniformOutput=false);
            else
                Dataset = cellfun(@(x)  x(:, obj.PartialAnalyze), ...
                    obj.RawDataset(obj.LimitedRow, obj.LimitedColumn), UniformOutput=false);
            end

        end

        function DataExample = get.DataExample(obj)
            for Column = 1:obj.DataColumns
                for Row = 1:obj.DataRows
                    if(~isnan(obj.DataPoints{Row, Column}))
                        DataExample = obj.DataPoints{Row, Column};
                        return
                    end
                end
            end   
        end

        function DataRows = get.DataRows(obj)
            DataRows = size(obj.Dataset, 1);
        end

        function DataColumns = get.DataColumns(obj)
            DataColumns = size(obj.Dataset, 2);
        end

        function DataPoints = get.DataPoints(obj)
            DataPoints = cellfun(@table2array, obj.Dataset, UniformOutput=false);
        end

        function Mean = get.Mean(obj)
            Mean = cellfun(@mean, obj.DataPoints, UniformOutput=false);
            %When only use cellfun(@mean), the NaN data will only result in
            %1 NaN output but not NaN array, the following code fix this.
            Mean = obj.NaNarray(Mean);
        end

        function Input = NaNarray(obj, Input)
            NaN_Index = cellfun(@(x) length(x) ~= length(obj.PartialAnalyze), Input);
            NaN_Num = length(find(NaN_Index));
            Input(NaN_Index) = mat2cell(NaN(NaN_Num, length(obj.PartialAnalyze)), ones(NaN_Num, 1));
        end

        function Error = get.Error(obj)
            Error = cellfun(@(x) GetError(x, obj.ErrorMode), obj.DataPoints, UniformOutput=false);
            Error = obj.NaNarray(Error);
        end

    end
end

function Error = GetError(DataPoints, ErrorMode)
switch ErrorMode
    case 'sem'
        Error = std(DataPoints) ./ sqrt(height(DataPoints));
    case 'std'
        Error = std(DataPoints);
end
end