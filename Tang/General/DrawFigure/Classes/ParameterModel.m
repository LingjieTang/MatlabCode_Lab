classdef ParameterModel < handle

    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明

    properties
        XLabel = 'DIV';
        XTickLabel = {3,4,5,6,7,9,11};
        FontName = 'Arial';
        FontSize = 10;
        Title = 'Num of 1st dendrites';
        AutoSave = false;
        Legend = false;
        Resolution = 1200;
        SaveFormat = 'tif';
    end

    methods
        function obj = ParameterModel()
            obj.XLabel = load ("Parameters.mat").Parameters;
        end

    end
end

