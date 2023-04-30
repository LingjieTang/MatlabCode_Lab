classdef Model < handle
    %Base model, includes DataModel and ParametersModel
    properties
        DataModel;
        ParametersModel;
        OverlaysModel;
        NonCallbackModel;
    end

    methods
        function obj = Model()
            obj.DataModel = DataModel();
            obj.OverlaysModel = OverlaysModel();
            obj.ParametersModel = ParametersModel();
            obj.NonCallbackModel = NonCallbackModel;
        end
    end
end

