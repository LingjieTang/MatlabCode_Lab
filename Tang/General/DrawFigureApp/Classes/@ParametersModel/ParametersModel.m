classdef ParametersModel < handle
    properties
        XLabel = 'DIV';
        XTickLabel = '3 4 5 7 9 11';
        FontName = 'Arial';
        FontSize = 10;
        Title = 'Num of 1st dendrites';
        ShowAxisBox = true;
        YLabel = '';
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
          
            ChangedResult = rmfield(p.Results, p.UsingDefaults);
            ChangedField = fields(ChangedResult);
            obj.(ChangedField{:}) = ChangedResult.(ChangedField{:});
            if(ChangedField{:} == "XTickLabel")
                obj.XTickLabel = obj.XTickLabel{:};
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

