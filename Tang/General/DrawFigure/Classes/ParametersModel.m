classdef ParametersModel < handle

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

    properties(Hidden)
        ParametersParser;
    end

    events
        ParametersChanged;
    end

    methods
        function obj = ParametersModel()
            obj.CreateParametersParser();
        end

        function ChangeParameters(obj, varargin)
            p = obj.ParametersParser;
            p.parse(varargin{:});
            Fields = fields(p.Results);
            for ii = 1:length(Fields)
                obj.(Fields{ii}) = p.Results.(Fields{ii});
            end
            obj.notify('ParametersChanged');
        end

        function CreateParametersParser(obj)
            obj.ParametersParser = inputParser();
            ParametersPropertiesName = properties(obj);
            for ii = 1:length(ParametersPropertiesName)
                DataPropertiesDefault = obj.(ParametersPropertiesName{ii});
                obj.ParametersParser.addParameter(ParametersPropertiesName{ii}, DataPropertiesDefault);
            end
        end
    end

end

