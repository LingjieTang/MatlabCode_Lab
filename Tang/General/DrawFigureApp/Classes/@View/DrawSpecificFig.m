function DrawSpecificFig(obj, ActivehAxis)
DataModel = obj.ModelObj.DataModel;
Mean = cellfun(@(x) x(ActivehAxis), DataModel.Mean);

DataPoints = cellfun(@(x) x(:, ActivehAxis), DataModel.DataPoints, 'UniformOutput', false);
DataSize = cellfun(@(x) size(x,1), DataPoints);

%For each variable, create a new tile
nexttile();

%Draw specific type of figure
switch DataModel.FigureType
    case 'Line'
        plot(Mean,'Marker','o');
    case 'Bar'
        bar(Mean, 1,'FaceAlpha', 0.5);
        hImages = findobj([gcf,gca],'Type', 'bar');
        hImages = hImages(DataModel.DataColumns:-1:1);
        for ii = 1:length(hImages)
            set(hImages(ii), 'EdgeColor', obj.Colororder(ii,:));
        end
    case 'Box'
        xGroupData = cell(DataModel.DataRows, DataModel.DataColumns);
        yData = cell2mat(DataPoints(:));
        cGroupData = cell(DataModel.DataRows, DataModel.DataColumns);
        for Row = 1:DataModel.DataRows
            for Column = 1: DataModel.DataColumns
                xGroupData{Row, Column} = Row*ones(DataSize(Row, Column), 1);
                cGroupData{Row, Column} = Column*ones(DataSize(Row, Column), 1);
            end
        end
        xGroupData = cell2mat(xGroupData(:));
        cGroupData = categorical(cell2mat(cGroupData(:)));
        boxchart(xGroupData, yData, 'GroupByColor', cGroupData, 'MarkerSize', 5, 'MarkerStyle','+');

    case 'Violin'
        Cali = 0.8 / DataModel.DataColumns;
        Density = cell(DataModel.DataRows, DataModel.DataColumns);
        Value = cell(DataModel.DataRows, DataModel.DataColumns);

        for Row = 1:DataModel.DataRows %jj = 1:DataGroup %Analyze each group
            for Column = 1:DataModel.DataColumns %xx = 1:DataNumber %Analyze each sub-group
                %x-coordinate value of data points are arithmetic
                %progression. The first term is xx-Cali*(DataGroup-1)/2 and
                %the tolerance is Cali.
                FirstTerm = Row - Cali * (DataModel.DataColumns - 1) / 2;
                Xposition = FirstTerm + Cali * (Column - 1); %Arithmetic series formula

                %Draw violin based on ksdenstiy with limited border
                if(any(isnan(DataPoints{Row, Column})))
                    Density{Row, Column} = 0;
                    Value{Row, Column} = NaN;
                else
                    [Density{Row, Column}, Value{Row, Column}] = ksdensity(DataPoints{Row, Column}, 'Support', ...
                        [min(DataPoints{Row, Column}) - 1E-5, max(DataPoints{Row, Column} + 1E-5)], 'BoundaryCorrection', 'reflection');

                    Value{Row, Column} = [Value{Row, Column}(1), Value{Row, Column}(1:end), Value{Row, Column}(end)]; %Smooth the border
                    Magnification = 0.4 * Cali / max(Density{Row, Column}); %Normalized the maximum of the density to the same width
                    Density{Row, Column} = [Density{Row, Column}(1), Density{Row, Column}(2) + 1E-5,...
                        Density{Row, Column}(2:end - 1), Density{Row, Column}(end - 1) - 1E-5, Density{Row, Column}(end)] * Magnification;
                end
                Colororder = colororder();
                patch([Xposition - Density{Row, Column}, Xposition + Density{Row, Column}(end:-1:1)], [Value{Row, Column}, Value{Row, Column}(end:-1:1)], Colororder(Column,:), 'FaceAlpha', .3);
                hold on
            end
        end
end

end

