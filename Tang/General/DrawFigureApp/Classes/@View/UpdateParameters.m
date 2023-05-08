function UpdateParameters(obj, ~, ~)
DataModel = obj.ModelObj.DataModel;
ParametersModel = obj.ModelObj.ParametersModel;

%Adjust the parameters in each tile
for ii = 1:length(obj.PartialAnalyze)
    nexttile(ii)

    %Set the font name and size
    fontname(string(ParametersModel.FontName))
    fontsize(ParametersModel.FontSize, 'pixels')

    %Set parameters for x-axis
    xlabel(string(ParametersModel.XLabel))

    XTickLabel = ParametersModel.XTickLabel;
    if(isempty(XTickLabel))
    else
        XTickLabel = textscan(ParametersModel.XTickLabel,'%s','Delimiter',' ');
        XTickLabel = XTickLabel{:};
    end  
    xticklabels(XTickLabel)
    %Use length(string(ParametersModel.XTickLabel)) rather than
    %length(DataModel.Rows) in case some ticks are not required to be
    %displayed
    xticks(1:length(XTickLabel));

    %Set parameters for y-axis

    if(isempty(ParametersModel.YLabel))
        if(isempty(DataModel.RawDataExample.Properties.VariableDescriptions)) %If the head of table is legal
            YLabel = string(DataModel.RawDataVariableNames(obj.PartialAnalyze(ii)));
        else
            YLabel = string(DataModel.RawDataExample.Properties.VariableDescriptions(obj.PartialAnalyze(ii)));
        end        
    else
        YLabel = textscan(ParametersModel.YLabel{:},'%s','Delimiter',',');
        YLabel = YLabel{:};
        YLabel = YLabel{ii};
    end
    ylabel(YLabel, 'Interpreter', 'none');

    %Show axis box or not
    if(ParametersModel.ShowAxisBox)
        set(gca, 'Box', 'on')
    else
        set(gca, 'Box', 'off')
    end

    %Resize x and y axis
    obj.ResizeAxis();


end

end