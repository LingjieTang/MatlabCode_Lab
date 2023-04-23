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
        LimitedDataValue;
    end

    methods


    end
end

