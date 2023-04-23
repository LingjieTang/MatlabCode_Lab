classdef Controller < handle
    %Controller in the MVC pattern
    properties
        ModelObj;
        ViewObj;
    end

    methods
        function obj = Controller(app)
            obj.ModelObj = app.ModelObj;
        end

        function DataChangedCallback(obj, varargin)
            obj.ModelObj.DataModel.ChangeData(varargin{:});
        end

        function ParametersChangedCallback(obj, varargin)
            obj.ModelObj.ParametersModel.ChangeParameters(varargin{:});
        end

        function DrawButtonPushedCallback(obj)
            obj.DataChangedCallback();
        end

    end

end

