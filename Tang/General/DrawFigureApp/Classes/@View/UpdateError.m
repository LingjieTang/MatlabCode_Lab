function UpdateError(obj)
DataModel = obj.ModelObj.DataModel;

%Analyze each variable
for VariableNow = obj.PartialAnalyze
    %Find the relative position in the PartialAnalyze
    ActivehAxis = find(obj.PartialAnalyze == VariableNow, 1);
    nexttile(ActivehAxis)
    Mean = cellfun(@(x) x(ActivehAxis), DataModel.Mean);
    Error = cellfun(@(x) x(ActivehAxis), DataModel.Error);
    hold on

    switch DataModel.FigureType
        case 'Bar'
            hImages = findobj('Type', 'bar');
            hImages = hImages((ActivehAxis-1)*DataModel.DataColumns + 1 : ActivehAxis*DataModel.DataColumns);
            Xposition = [hImages(end:-1:1).XEndPoints];
            
            for ii = 1:DataModel.DataColumns
                errorbar(Xposition((ii-1)*DataModel.DataRows + 1 : ii*DataModel.DataRows), ...
                    Mean(:,ii), Error(:,ii), 'Marker','o','LineStyle','none', 'Color', ...
                    obj.Colororder(mod(ii-1, length(obj.Colororder))+1,:));
            end

        case 'Line'
            e = errorbar(Mean, Error, 'Marker','o','LineStyle','none');
            for ii = 1:length(e)
                e(ii).Color = obj.Colororder(mod(ii-1, length(obj.Colororder))+1,:);
            end
    end

    hold off
    obj.ResizeAxis();
end

end