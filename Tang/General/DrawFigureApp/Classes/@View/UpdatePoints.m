function UpdatePoints(obj)
DataModel = obj.ModelObj.DataModel;


%Analyze each variable
for VariableNow = obj.PartialAnalyze
    %Find the relative position in the PartialAnalyze
    ActivehAxis = find(obj.PartialAnalyze == VariableNow, 1);
    nexttile(ActivehAxis)

    DataPoints = cellfun(@(x) x(:, ActivehAxis), obj.ModelObj.DataModel.DataPoints, 'UniformOutput', false);
    % DataSize = cellfun(@(x) size(x,1), DataPoints);
    Ydata = cell(DataModel.DataRows, DataModel.DataColumns);
    Xdata = cell(DataModel.DataRows, DataModel.DataColumns);
    Cdata = cell(DataModel.DataRows, DataModel.DataColumns);

    switch DataModel.FigureType
        case 'Bar'
            hImages = findobj('Type', 'bar');
            hImages = hImages((ActivehAxis-1)*DataModel.DataColumns + 1 : ActivehAxis*DataModel.DataColumns);
            Xposition = [hImages(end:-1:1).XEndPoints];
            XJitterWidth = 0.5*hImages(1).BarWidth/DataModel.DataColumns;
            for ii = 1:length(Xposition)
                Ydata{ii} = DataPoints{ii};
                Xdata{ii} = Xposition(ii)*ones(length(Ydata{ii}),1);
                Cdata{ii} = repmat(obj.Colororder(ceil(ii/DataModel.DataRows), :), length(Ydata{ii}), 1);
            end


        case 'Box'
            hImages = findobj('Type', 'box');
            hImages = hImages((ActivehAxis-1)*DataModel.DataColumns + 1 : ActivehAxis*DataModel.DataColumns);
            Cali = 1 / DataModel.DataColumns;
            Xposition = zeros(DataModel.DataRows, DataModel.DataColumns);
            for Row = 1:DataModel.DataRows
                for Column = 1:DataModel.DataColumns
                    %x-coordinate value of data points are arithmetic
                    %progression. The first term is xx-Cali*(DataGroup-1)/2
                    %and the tolerance is Cali.
                    FirstTerm = Row - Cali * (DataModel.DataColumns - 1) / 2;
                    Xposition(Row, Column) = FirstTerm + Cali * (Column - 1); %Arithmetic series formula
                end
            end
            XJitterWidth = hImages(1).BoxWidth/(DataModel.DataColumns+0.8*(DataModel.DataColumns - 1));
            for ii = 1:length(Xposition(:))
                Ydata{ii} = DataPoints{ii}(~isoutlier(DataPoints{ii}, 'quartiles'));
                Xdata{ii} = Xposition(ii)*ones(length(Ydata{ii}),1);
                Cdata{ii} = repmat(obj.Colororder(ceil(ii/DataModel.DataRows), :), length(Ydata{ii}), 1);
            end

        case 'Violin'
            hImages = findobj('Type', 'patch');
            hImages = hImages((ActivehAxis-1)*DataModel.DataRows*DataModel.DataColumns + 1 : ActivehAxis*DataModel.DataRows*DataModel.DataColumns);
            hImages = hImages(end:-1:1);
            XJitterWidth = max(hImages(1).XData) - min(hImages(1).XData);
            Xposition = zeros(DataModel.DataRows, DataModel.DataColumns);
            for ii = 1:length(hImages)
                Xposition(ceil(ii/DataModel.DataColumns), mod(ii-1,DataModel.DataColumns)+1) = hImages(ii).XData(1);
            end
            for ii = 1:length(hImages)
                Ydata{ii} = DataPoints{ii};  
                Xdata{ii} = Xposition(ii)*ones(length(Ydata{ii}),1);
                Cdata{ii} = repmat(obj.Colororder(ceil(ii/DataModel.DataRows), :), length(Ydata{ii}), 1);
            end
    end

    SwarmSize = 5;
    hold on
    swarmchart(cell2mat(Xdata(:)), cell2mat(Ydata(:)), SwarmSize,...
        cell2mat(Cdata(:)), 'filled', 'XJitter', 'density', 'XJitterWidth', XJitterWidth)

    obj.ResizeAxis();
end

end