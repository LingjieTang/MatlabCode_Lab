function UpdateOverlays(obj, ~, ~)
DataModel = obj.ModelObj.DataModel;
OverlaysModel = obj.ModelObj.OverlaysModel;

if(OverlaysModel.ShowPoints)
    %Line type will not display datapoints
    if(~strcmp(DataModel.FigureType, 'Line'))
        obj.UpdatePoints();
    end
else
    try
        SwarmChart = findobj('Type','scatter');
        delete(SwarmChart(:))
        obj.ResizeAxis();
    catch
    end
end

if(OverlaysModel.ShowError)
    %Only show errorbar in bar and line
    if(strcmp(DataModel.FigureType, 'Bar')||strcmp(DataModel.FigureType, 'Line'))
        obj.UpdateError();
    end
else
    try
        Errorbar = findobj('Type','errorbar');
        delete(Errorbar(:))
        obj.ResizeAxis();
    catch
    end
end

try
    Significance = findobj('Type','text');
    if(~strcmp(DataModel.FigureType, 'Line'))
        Significance = [Significance; findobj('Type','line')];
    end
    delete(Significance(:))
    obj.ResizeAxis();
catch
end
if(OverlaysModel.ShowSignificance)
    obj.UpdateSignificance();
else
    try
        Significance = findobj('Type','text');
        if(~strcmp(DataModel.FigureType, 'Line'))
            Significance = [Significance; findobj('Type','line')];
        end
        delete(Significance(:))
        obj.ResizeAxis();
    catch
    end
end

try
    Legend = findobj('Type','legend');
    delete(Legend(:))
catch
end
if(OverlaysModel.ShowLegend)
    %Analyze each variable
    for VariableNow = obj.PartialAnalyze
        if(any(ismember(VariableNow, OverlaysModel.PartialLegend)))
            %Find the relative position in the PartialAnalyze
            ActivehAxis = find(obj.PartialAnalyze == VariableNow, 1);
            nexttile(ActivehAxis)
            Legend = textscan(OverlaysModel.Legend,'%s','Delimiter',',');
            Legend = Legend{:};
            legend(Legend);
        end
    end
end

end