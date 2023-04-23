classdef Model < handle
    %Model that contains DataModel and ParameterModel
    properties
        DataModel;
        ParametersModel;
    end

    methods
        function obj = Model()
            obj.DataModel = DataModel();
            obj.ParametersModel = ParametersModel();
        end
    end
end

