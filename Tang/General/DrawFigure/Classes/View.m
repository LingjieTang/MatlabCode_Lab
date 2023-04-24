classdef View < handle
    properties
        ModelObj;
        hDataListener;
        hParametersListener;
        ControllerObj;
        appObj;
        hUIFig;
        hAxis;
        GridLayout;
        hFigs;
        PartialAnalyze;
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
            obj.hDataListener = obj.ModelObj.DataModel.addlistener('DataChanged', @ obj.UpdateData);
            obj.hParametersListener = obj.ModelObj.ParametersModel.addlistener('ParametersChanged', @obj.UpdateParameters);

            obj.CreateUIFig();

            obj.PartialAnalyze = obj.ModelObj.DataModel.PartialAnalyze;
            obj.hAxis = cell(1, length(obj.PartialAnalyze));
            obj.hFigs = cell(1, length(obj.PartialAnalyze));
            obj.UpdateData();
        end

        function UpdateData(obj, ~, ~)

            MaxFig = 2;

            for ii = obj.PartialAnalyze %For each column, create an axis
                ActivehAxis = find(obj.PartialAnalyze == ii, 1);
                if(~isempty(obj.hAxis{ActivehAxis}))
                    delete(obj.hAxis{ActivehAxis});
                    % close(obj.hUIFig);
                    % obj.CreateUIFig();
                end
                obj.hAxis{ActivehAxis} = uiaxes(obj.GridLayout);
                set(obj.hUIFig, 'CurrentAxes', obj.hAxis{ActivehAxis});
                obj.hAxis{ActivehAxis}.Layout.Row = ceil(ActivehAxis/MaxFig) ;
                obj.hAxis{ActivehAxis}.Layout.Column = mod(ActivehAxis -1 , MaxFig) + 1;



                obj.DrawSpecificFig(ii);

                %Store Mean and Sem in the ResultTable
                % DataPosition = (jj - 1) * DataNumber +xx;
                % ResultT.Type(DataPosition) = [GroupNames{jj}, '_',
                % NumberNames{xx}]; ResultT.Mean(DataPosition) = Mean(jj,
                % xx); ResultT.Sem(DataPosition) = Sem(jj, xx);
                % ResultT.SampleNumber(DataPosition) =
                % length(app.app.Dataset{jj, xx}.(Title));

                % if (DataGroup == 2 && jj == 2 && ShowSig) %Calculate
                % signiface when only 2 groups
                %     p = Independent_Two_Sample_TTest(Dataset{1,
                %     xx}.(Title), Dataset{2, xx}.(Title));%,OutlierRemove
                %     %ResultT.Significance(DataPosition) = p; YMaxNow =
                %     Significance_Line(xx, xx,Dataset{1, xx}.(Title),
                %     Dataset{2, xx}.(Title), p, 'k', 'Arial', 10, false);
                %     YMax = max(YMax, YMaxNow); hold on
                % end


            end

            obj.UpdateParameters();
        end

        function DrawSpecificFig(obj, ii)
            Dataset = obj.ModelObj.DataModel.Dataset;
            DataGroup = size(Dataset, 1);
            DataNumber = size(Dataset, 2);
            FigureType = obj.ModelObj.DataModel.FigureType;

                
                Mean = squeeze(obj.ModelObj.DataModel.Mean(ii, :, :));
                Error = squeeze(obj.ModelObj.DataModel.Error(ii, :, :));

            for jj = 1:DataGroup
                switch FigureType
                    case 'Line'
                        obj.hFigs{jj} = errorbar(1:DataNumber,  Mean(jj, :), Error(jj, :));
                        obj.hFigs{jj}.Marker = 'o';
                        obj.hFigs{jj}.MarkerSize = 0.8 *obj.ModelObj.ParametersModel.FontSize;
                    case 'Bar'
                       obj.hFigs{jj} = bar(1:DataNumber, Mean.', 'grouped');
                    case 'Box'
                       DataPoints = squeeze(obj.ModelObj.DataModel.DataPoints(ii, :, :));
                       yData = cell2mat(DataPoints(:));
                       
                      DataSize = cellfun(@(x) size(x,1), DataPoints);
                      %DataSizeExpand =  DataSize(:);
                      xGroupNum = sum(DataSize);
                      xGroup = ones(sum(xGroupNum), 1);
                      xOrder = [1, cumsum(xGroupNum)];

                      Category = cell(DataGroup, DataNumber);
                      for xx = 1:DataGroup
                          for zz = 1:DataNumber
                                   if(DataSize(xx,zz)~=0)
                                       Category{xx,zz} = repmat(xx,DataSize(xx,zz), 1);
                                   end
                          end
                      end
                      Category = categorical(cell2mat(Category(:)));


                      for xx = 1:DataNumber
                          xGroup(xOrder(xx): xOrder(xx+1)) = xx;
                      end

                       obj.hFigs{jj} = boxchart(xGroup , yData, 'GroupByColor', Category);
                end
                hold on

            end
        end

        function UpdateParameters(obj, src, event)
            Parameters = obj.ModelObj.ParametersModel;
            Dataset = obj.ModelObj.DataModel.Dataset;

            for ii = 1:length(obj.PartialAnalyze)
                ActivehAxis = ii;

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

        function MyCloseRequest(obj, src)
            delete(src);
            delete(obj.hDataListener);
            delete(obj.hParametersListener);
        end


        function CreateUIFig(obj)

            obj.hUIFig = uifigure('Name', "Drawn Figure", ...
                'HandleVisibility','on','Icon','Figures.jpg','AutoResizeChildren','off');

            %set GridLayout to align the axes
            obj.GridLayout = obj.CreateGridLayout();
            obj.hUIFig.SizeChangedFcn = @(src,event) obj.UpdateGridLayout;
            obj.hUIFig.CloseRequestFcn = @(src,event) obj.MyCloseRequest(src);

        end
    end
end

function xPosition = CalxPosition(Mean)
xPosition = Mean;
DataGroup = size(Mean, 1);
DataNumber = size(Mean, 2);
Cali = 0.8 / DataGroup; %Calibration of the x-coordinate value of data points
for Row = 1:DataGroup
    for Column = 1:DataNumber
        if(isnan(xPosition(Row, Column)))
        else
            FirstTerm = Column - Cali * (DataGroup - 1) / 2;
            xPosition(Row, Column) = FirstTerm + Cali * (Row - 1); %Arithmetic series formula
        end
    end
end
end


