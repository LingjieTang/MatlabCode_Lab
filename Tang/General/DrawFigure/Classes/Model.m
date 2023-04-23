classdef Model < handle
    %Model that contains DataModel and ParameterModel
    properties
        DataModel;
        ParametersModel;
    end

    events
        DataChanged;
        ParametersChanged;
    end

    methods
        function obj = Model()
            obj.DataModel = DataModel();
            obj.ParametersModel = ParameterModel();
            obj.DataModel.CreateDataParser();
            obj.ParametersModel.CreateParametersParser();
        end

        function ChangeData(obj, varargin)
            obj.DataParser.parse(varargin{:});
            Fields = fields(obj.DataParser.Results);
            for ii = 1:length(Fields)
                obj.DataModel.(Fields{ii}) = obj.DataParser.Results.(Fields{ii});
            end
            obj.notify('DataChanged');
        end

        function ChangeParameters(obj, varargin)
            obj.ParametersParser.parse(varargin{:});
            Fields = fields(obj.ParametersParser.Results);
            for ii = 1:length(Fields)
                obj.ParametersModel.(Fields{ii}) = obj.ParametersParser.Results.(Fields{ii});
            end
            obj.notify('ParametersChanged');
        end

        function CreateDataParser(obj)
            obj.DataParser = inputParser();
            DataPropertiesName = properties(obj.DataModel);
            for ii = 1:length(DataPropertiesName)
                DataPropertiesDefault = obj.DataModel.(DataPropertiesName{ii});
                obj.DataParser.addParameter(DataPropertiesName{ii}, DataPropertiesDefault);
            end
        end

        function CreateParametersParser(obj)
            obj.ParametersParser = inputParser();
            ParametersPropertiesName = properties(obj.ParametersModel);
            for ii = 1:length(ParametersPropertiesName)
                ParametersPropertiesDefault = obj.ParametersModel.(ParametersPropertiesName{ii});
                obj.ParametersParser.addParameter(ParametersPropertiesName{ii}, ParametersPropertiesDefault);
            end
        end

    end
end

