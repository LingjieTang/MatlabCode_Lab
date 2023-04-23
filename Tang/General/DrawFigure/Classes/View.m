classdef View < handle
    properties
        ModelObj;
        ControllerObj;
        appObj;
        hUIFig;
        hAxis;
        GridLayout;
        hFigs;
    end

    %Only 1 View object can be created by the static method GetView
    methods(Static)
        function obj = GetView(app)
            persistent LocalViewObj;
            if isempty(LocalViewObj)||~isvalid(LocalViewObj)||isempty(LocalViewObj.hUIFig)
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
            obj.ModelObj.DataModel.addlistener('DataChanged', @obj.UpdateData);
            obj.ModelObj.ParametersModel.addlistener('ParametersChanged', @obj.UpdateParameters);

            obj.hUIFig = uifigure('Name', "Drawn Figure", ...
                'HandleVisibility','on','Icon','Figures.jpg','AutoResizeChildren','off');
            % obj.hUIFig.CloseRequestFcn = @(src,event) obj.ClearViewObj();


            %set GridLayout to align the axes
            obj.GridLayout = obj.CreateGridLayout();
            obj.hUIFig.SizeChangedFcn = @(src,event) obj.UpdateGridLayout;
            obj.UpdateData();
            obj.UpdateParameters();
        end

        function UpdateData(obj)
            PartialAnalyze = obj.ModelObj.DataModel.PartialAnalyze;
            obj.hAxis = cell(1, length(PartialAnalyze));
            obj.hFigs = cell(1, length(PartialAnalyze));
            Dataset = obj.ModelObj.DataModel.Dataset;
            DataGroup = size(Dataset, 1);
            DataNumber = size(Dataset, 2);
            MaxFig = 2;

            for ii = PartialAnalyze
                ActivehAxis = find(PartialAnalyze == ii, 1);
                obj.hAxis{ActivehAxis} = uiaxes(obj.GridLayout);
                set(obj.hUIFig, 'CurrentAxes', obj.hAxis{ActivehAxis});
                obj.hAxis{ActivehAxis}.Layout.Row = ceil(ActivehAxis/MaxFig) ;
                obj.hAxis{ActivehAxis}.Layout.Column = mod(ActivehAxis -1 , MaxFig) + 1;
                Mean = zeros(DataGroup, DataNumber);
                Error = zeros(DataGroup, DataNumber);

                for jj = 1:DataGroup %Analyze each group

                    for xx = 1:DataNumber %Analyze each sub-group
                        if(~isempty(Dataset{jj, xx}))
                            Title = string(Dataset{1,1}.Properties.VariableNames(ii)); %Get the current column title
                            Mean(jj, xx) = mean(Dataset{jj, xx}.(Title));
                            Error(jj, xx) = std(Dataset{jj, xx}.(Title)) / sqrt(length(Dataset{jj, xx}.(Title)));
                            %Store Mean and Sem in the ResultTable
                            % DataPosition = (jj - 1) * DataNumber +xx;
                            % ResultT.Type(DataPosition) = [GroupNames{jj},
                            % '_', NumberNames{xx}];
                            % ResultT.Mean(DataPosition) = Mean(jj, xx);
                            % ResultT.Sem(DataPosition) = Sem(jj, xx);
                            % ResultT.SampleNumber(DataPosition) =
                            % length(app.app.Dataset{jj, xx}.(Title));

                            if (DataGroup == 2 && jj == 2 && ShowSig) %Calculate signiface when only 2 groups
                                p = Independent_Two_Sample_TTest(Dataset{1, xx}.(Title), Dataset{2, xx}.(Title));%,OutlierRemove
                                %ResultT.Significance(DataPosition) = p;
                                YMaxNow = Significance_Line(xx, xx,Dataset{1, xx}.(Title), Dataset{2, xx}.(Title), p, 'k', 'Arial', 10, false);
                                YMax = max(YMax, YMaxNow);
                                hold on
                            end
                        end

                    end

                    %Draw errorbar
                    e = errorbar(1:DataNumber, Mean(jj, :), Error(jj, :));
                    e.Marker = 'o';
                    e.MarkerSize = 8;%0.8 * FontSize;
                    hold on
                end
            end

            obj.UpdateParameters();
        end

        function UpdateParameters(obj, ~, ~)
            PartialAnalyze = obj.ModelObj.DataModel.PartialAnalyze;
            Parameters = obj.ModelObj.ParametersModel;
            Dataset = obj.ModelObj.DataModel.Dataset;

            for ii = 1:length(PartialAnalyze)
                ActivehAxis = ii;
                obj.hFigs{ActivehAxis}.Color = rand(1, 3);

                ax = obj.hAxis{ActivehAxis};
                XTickLabel = string(Parameters.XTickLabel);
                XLabel = string(Parameters.XLabel);
                FontName = string(Parameters.FontName);
                FontSize = Parameters.FontSize;
                Title = string(Dataset{1,1}.Properties.VariableNames(ii)); %Get the current column title

                set(ax,'xticklabel', XTickLabel, 'Fontname', FontName, 'FontSize', FontSize);
                xlabel(ax, XLabel, 'Fontname', FontName, 'FontSize', FontSize);
                ylabel(ax, Title, 'Fontname', FontName, 'FontSize', FontSize, 'Interpreter', 'none');
            end

        end

        function GridLayout = CreateGridLayout(obj)
            GridLayout = uigridlayout('Parent', obj.hUIFig);
            % GridLayout.ColumnWidth = {'1x'};
            % GridLayout.RowHeight = {'1x'};
            % GridLayout.ColumnSpacing = 0;
            % GridLayout.RowSpacing = 0;
            % GridLayout.Padding = [0 0 0 0];
            % GridLayout.Scrollable = 'on';
        end

        % Changes arrangement of the app based on UIFigure width
        function UpdateGridLayout(obj, event)
            MiniWidth = 576;
            currentFigureWidth = obj.hUIFig.Position(3);
            if(currentFigureWidth <= MiniWidth)
                % Change to a 3x1 grid
                obj.GridLayout.RowHeight = {MiniWidth};
                obj.GridLayout.ColumnWidth = {MiniWidth};
            else
                % Change to a 2x2 grid
                obj.GridLayout.RowHeight = {'1x'};
                obj.GridLayout.ColumnWidth = {'1x'};
   
            end
        end

    end
end




