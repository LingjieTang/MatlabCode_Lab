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
            if(any(cellfun(@(x) strcmp('PartialAnalyze', x), varargin)))
                if(~isempty(obj.ViewObj))%In case customer change value before DrawButton pushed
                    obj.ViewObj.ClearAllAxes();
                end
            end
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

