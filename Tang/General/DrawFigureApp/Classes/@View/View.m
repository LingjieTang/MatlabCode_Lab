classdef View < handle
    properties
        ModelObj;
        hDataListener;
        hOverlaysListener;
        hParametersListener;
        ControllerObj;
        appObj;
        hFig;
        hTiledLayout;
        hSwarmChart;
        Colororder = colororder;
    end

    properties(Dependent)
        PartialAnalyze;
    end
    %% Singleton pattern, the API for getting instance is 'GetView' function
    methods(Static)
        function obj = GetView(app)
            persistent LocalViewObj;
            if isempty(LocalViewObj)||~isvalid(LocalViewObj)||isempty(LocalViewObj.hFig)
                LocalViewObj = View(app);
            end
            obj = LocalViewObj;
        end
    end

    methods(Access = private)
        function obj = View(app)
            obj.appObj = app;
            obj.ModelObj = app.ModelObj;
            obj.ControllerObj = app.ControllerObj;
            obj.ControllerObj.ViewObj = obj;

            %Add listener to the Models
            obj.hDataListener = obj.ModelObj.DataModel.addlistener('DataChanged', @ obj.UpdateData);
            obj.hOverlaysListener = obj.ModelObj.OverlaysModel.addlistener('OverlaysChanged', @ obj.UpdateOverlays);
            obj.hParametersListener = obj.ModelObj.ParametersModel.addlistener('ParametersChanged', @obj.UpdateParameters);


            obj.CreateFig(); %Create a main frame
            obj.UpdateData(); %Draw data
        end
    end

    methods
        %Claim some functions
        CreateFig(obj);
        MyCloseRequest(obj, src);
        UpdateData(obj, ~, ~);
        DrawSpecificFig(obj, ActivehAxis)
        UpdateParameters(obj, ~, ~)
        UpdatePoints(obj);
        UpdateOverlays(obj, ~, ~);
        UpdateError(obj);
        UpdateSignificance(obj)

        %Get methods for dependent properties
        function PartialAnalzye = get.PartialAnalyze(obj)
            PartialAnalzye = obj.ModelObj.DataModel.PartialAnalyze;
        end
    end

    methods
        function ResizeAxis(obj)
            for ii = 1:length(obj.PartialAnalyze)
                nexttile(ii)
                %Resize the y-axis
                ylim auto
                LimitY = ylim;
                try
                    PotentialText = findobj(gca, 'Type','text');
                    PotentialTextXYZ = [PotentialText.Position];
                    PotentialTextY = PotentialTextXYZ(2:obj.ModelObj.DataModel.DataColumns:end-1);
                    LimitY(2) = max(LimitY(2), max(PotentialTextY));
                catch
                end
                %not reset, for keeping the view for possible non-negative
                %data
                ylim([LimitY(1), LimitY(2) + 0.04 * (LimitY(2) - LimitY(1))])

                %Resize the x-axis
                xlim auto
                LimitX = xlim;
                xlim([LimitX(1) - 0.04 * (LimitX(2) - LimitX(1)), LimitX(2) + 0.04 * (LimitX(2) - LimitX(1))])
            end
        end
    end
end