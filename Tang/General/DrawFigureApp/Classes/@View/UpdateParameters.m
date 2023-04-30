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

    XTickLabel = textscan(ParametersModel.XTickLabel,'%s','Delimiter',' ');
    XTickLabel = XTickLabel{:};
    xticklabels(XTickLabel)
    %Use length(string(ParametersModel.XTickLabel)) rather than
    %length(DataModel.Rows) in case some ticks are not required to be
    %displayed
    temp = textscan(ParametersModel.XTickLabel,'%s','Delimiter',' ');
    temp = temp{:};
    xticks(1:length(temp));

    %Set parameters for y-axis
    YLabel = string(DataModel.RawDataVariableNames(obj.PartialAnalyze(ii)));
    ylabel(YLabel, 'Interpreter', 'none');

    %Resize x and y axis
    obj.ResizeAxis();

    %Show axis box or not
    if(ParametersModel.ShowAxisBox)
        set(gca, 'Box', 'on')
    else
        set(gca, 'Box', 'off')
    end
end

end