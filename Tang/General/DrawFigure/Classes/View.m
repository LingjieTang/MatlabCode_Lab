classdef View < handle
    properties
        ModelObj;
        ControllerObj;
        hUIFig;
        hAxis;
        GridLayout;
        hFigs;
    end

    %Only 1 View object can be created by the static method GetView
    methods(Static) 
        function obj = GetView(app)
            persistent LocalViewObj;
            if isempty(LocalViewObj)||~isvalid(LocalViewObj)
                LocalViewObj = View(app);
            end
            obj = LocalViewObj;
        end
    end

    methods(Access = private)
        function obj = View(app)
            obj.ModelObj = app.ModelObj;
            obj.ModelObj.addlistener('DataChanged', @obj.UpdateData);
            obj.ModelObj.addlistener('ParametersChanged', @obj.UpdateParameters);

            obj.ControllerObj = app.ControllerObj;
            obj.ControllerObj.ViewObj = obj;

            obj.hUIFig = uifigure('Name', "Drawn Figure",'HandleVisibility','on');
            %set GridLayout to align the axes
            obj.GridLayout = obj.CreateGridLayout();
            obj.UpdateData();
            obj.UpdateParameters();
        end

        function UpdateData(obj, ~, ~)
            %Temp
            DataAnalyze = 1:3;
            obj.hAxis = cell(1, length(DataAnalyze));
            obj.hFigs = cell(1, length(DataAnalyze));

            for ii = DataAnalyze
                Dataset = obj.ModelObj.DataModel.Dataset;
                ActivehAxis = find(DataAnalyze == ii, 1);
                obj.hAxis{ActivehAxis} = uiaxes(obj.GridLayout);
                set(obj.hUIFig, 'CurrentAxes', obj.hAxis{ActivehAxis});
                obj.hAxis{ActivehAxis}.Layout.Row = ceil(ActivehAxis/3) ;
                obj.hAxis{ActivehAxis}.Layout.Column = mod(ActivehAxis -1 , 3) + 1;

                obj.hFigs{ActivehAxis} = plot(obj.hAxis{ActivehAxis}, Dataset{1, 1}{:,ii});
                %Title = string(Dataset{1,
                %1}.Properties.VariableNames(ii)); %Get the current column
                %title
            end

            obj.UpdateParameters();
        end

        function UpdateParameters(obj, ~, ~)
            %Temp
            DataAnalyze = 1:3;
            Parameters = obj.ModelObj.ParametersModel;

            for ii = 1:length(DataAnalyze)
                %Temp
                ActivehAxis = ii;
                obj.hFigs{ActivehAxis}.Color = rand(1, 3);

                ax = obj.hAxis{ActivehAxis};
                XTickLabel = string(Parameters.XTickLabel);
                XLabel = string(Parameters.XLabel);
                FontName = string(Parameters.FontName);
                FontSize = Parameters.FontSize;
                Title = string(Parameters.Title);

                set(ax,'xticklabel', XTickLabel, 'Fontname', FontName, 'FontSize', FontSize);
                xlabel(ax, XLabel, 'Fontname', FontName, 'FontSize', FontSize);
                ylabel(ax, Title, 'Fontname', FontName, 'FontSize', FontSize);
            end

        end

        function GridLayout = CreateGridLayout(obj)
            GridLayout = uigridlayout('Parent', obj.hUIFig);
            GridLayout.ColumnWidth = {'1x'};
            GridLayout.RowHeight = {'1x'};
            GridLayout.ColumnSpacing = 0;
            GridLayout.RowSpacing = 0;
            GridLayout.Padding = [0 0 0 0];
            GridLayout.Scrollable = 'on';
        end

    end
end




