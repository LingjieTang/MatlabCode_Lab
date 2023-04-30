function UpdateSignificance(obj)
DataModel = obj.ModelObj.DataModel;
ParametersModel = obj.ModelObj.ParametersModel;
OverlaysModel = obj.ModelObj.OverlaysModel;
ShowpValue = OverlaysModel.ShowpValue;


%Analyze each variable
for VariableNow = obj.PartialAnalyze
    %Find the relative position in the PartialAnalyze
    ActivehAxis = find(obj.PartialAnalyze == VariableNow, 1);
    nexttile(ActivehAxis)
    DataPoints = cellfun(@(x) x(:, ActivehAxis), DataModel.DataPoints, 'UniformOutput', false);
    DataExample = DataModel.DataExample;

    hold on

    switch DataModel.FigureType
        case 'Bar'
            hImages = findobj('Type', 'bar');
            hImages = hImages((ActivehAxis-1)*DataModel.DataColumns + 1 :ActivehAxis*DataModel.DataColumns);
            Xposition = [hImages(end:-1:1).XEndPoints];
            for Row = 1:DataModel.DataRows
                if(DataModel.DataColumns == 1)
                    Column = 1;
                    if(any(~isnan(DataPoints{Row, Column})))
                        p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataExample, ...
                            OverlaysModel.OutlierRemove);
                        Significance_Line(Row, Row, DataPoints{Row, Column}, DataPoints{Row, Column}, p,...
                            obj.Colororder(1,:), ...
                            ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                    end
                else
                    for Column = 2:DataModel.DataColumns
                        if(any(~isnan(DataPoints{Row, Column})) && any(~isnan(DataPoints{Row, 1})))
                            p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataPoints{Row, 1}, ...
                                OverlaysModel.OutlierRemove);
                            Significance_Line(Xposition(Row), Xposition((Column-1)*DataModel.DataRows + Row), ...
                                DataPoints{Row, Column}, DataPoints{Row, 1}, p,...
                                obj.Colororder(mod(Column-1, length(obj.Colororder))+1,:), ...
                                ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                        end
                    end
                end
            end

        case 'Line'
            for Row = 1:DataModel.DataRows
                if(DataModel.DataColumns == 1)
                    Column = 1;
                    if(any(~isnan(DataPoints{Row, Column})))
                        p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataExample, ...
                            OverlaysModel.OutlierRemove);
                        Significance_Line(Row, Row, DataPoints{Row, Column}, DataPoints{Row, Column}, p,...
                            obj.Colororder(1,:), ...
                            ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                    end
                else
                    for Column = 2:DataModel.DataColumns
                        if(any(~isnan(DataPoints{Row, Column})) && any(~isnan(DataPoints{Row, 1})))
                            p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataPoints{Row, 1}, ...
                                OverlaysModel.OutlierRemove);
                            Significance_Line(Row, Row, DataPoints{Row, Column}, DataPoints{Row, 1}, p,...
                                obj.Colororder(mod(Column-1, length(obj.Colororder))+1,:), ...
                                ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                        end
                    end
                end
            end

        case 'Box'
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
            for Row = 1:DataModel.DataRows
                if(DataModel.DataColumns == 1)
                    Column = 1;
                    if(any(~isnan(DataPoints{Row, Column})))
                        p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataExample, ...
                            OverlaysModel.OutlierRemove);
                        Significance_Line(Row, Row, DataPoints{Row, Column}, DataPoints{Row, Column}, p,...
                            obj.Colororder(1,:), ...
                            ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                    end
                else
                    for Column = 2:DataModel.DataColumns
                        if(any(~isnan(DataPoints{Row, Column})) && any(~isnan(DataPoints{Row, 1})))
                            p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataPoints{Row, 1}, ...
                                OverlaysModel.OutlierRemove);
                            Significance_Line(Xposition(Row, Column), Xposition(Row, 1), ...
                                DataPoints{Row, Column}, DataPoints{Row, 1}, p,...
                                obj.Colororder(mod(Column-1, length(obj.Colororder))+1,:), ...
                                ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                        end
                    end
                end
            end

        case 'Violin'
            hImages = findobj('Type', 'patch');
            hImages = hImages((ActivehAxis-1)*DataModel.DataRows*DataModel.DataColumns + 1 : ActivehAxis*DataModel.DataRows*DataModel.DataColumns);
            hImages = hImages(end:-1:1);
            Xposition = zeros(DataModel.DataRows, DataModel.DataColumns);
            for ii = 1:length(hImages)
                Xposition(ceil(ii/DataModel.DataColumns), mod(ii-1,DataModel.DataColumns)+1) = hImages(ii).XData(1);
            end
            for Row = 1:DataModel.DataRows
                if(DataModel.DataColumns == 1)
                    Column = 1;
                    if(any(~isnan(DataPoints{Row, Column})))
                        p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataExample, ...
                            OverlaysModel.OutlierRemove);
                        Significance_Line(Row, Row, DataPoints{Row, Column}, DataPoints{Row, Column}, p,...
                            obj.Colororder(1,:), ...
                            ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                    end
                else
                    for Column = 2:DataModel.DataColumns
                        if(any(~isnan(DataPoints{Row, Column})) && any(~isnan(DataPoints{Row, 1})))
                            p = Independent_Two_Sample_TTest(DataPoints{Row, Column}, DataPoints{Row, 1}, ...
                                OverlaysModel.OutlierRemove);
                            Significance_Line(Xposition(Row, Column), ...
                                Xposition(Row, 1), ...
                                DataPoints{Row, Column}, DataPoints{Row, 1}, p,...
                                obj.Colororder(mod(Column-1, length(obj.Colororder))+1,:), ...
                                ParametersModel.FontName, ParametersModel.FontSize, false,ShowpValue);
                        end
                    end
                end
            end
    end

    hold off
    obj.ResizeAxis();
end

end