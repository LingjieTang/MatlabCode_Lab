%To draw figures after "DrawButton" is pushed.
function DrawData(app)
%% Create a new uifigure

%set HandleVisibility on to let it become the current figure
Fig = uifigure('Name', "Drawn Figure",'HandleVisibility','on');

%set GridLayout to align the axes
GridLayout = CreateGridLayout(Fig);

%% Data loading

%Find the first non-empty data in app.Dataset
[r, c] = find(cellfun(@isempty, app.Dataset) == 0, 1);
DataGroup = size(app.Dataset, 1);

GroupNames = {'control', 'cKO'};
DataNumber = size(app.Dataset, 2);


%Parameters that seldom need to be changed
NumberNames = cell(DataNumber, 1); %Specify the names of each sub-group by catenating XLabel and XTickLabel

for nn = 1:DataNumber
    NumberNames{nn} = [XLabel, '_', num2str(XTickLabel(nn))];
end

%Output a result table to store key information including the mean value,
%the S.E.M, the number of samples, the significance
varNames = {'Type', 'Mean', 'Sem', 'SampleNumber', 'Significance'};
sz = [DataGroup * DataNumber, length(varNames)];
ResultT = table('Size', sz, 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, 'VariableNames', varNames);
OutlierRemove = 'quartiles'; %Removal of outliers. Use 'none' to disable, or 'quartiles' to enable
DataAnalyze = 1:2;
%% Main program
for ii = DataAnalyze %1:size(app.app.Dataset{1,1}, 2) %Analyze each column in the table
    AxisHandle = cell(1, length(DataAnalyze));
    ActiveAxisHandle = find(DataAnalyze == ii, 1);
    AxisHandle{ActiveAxisHandle} = uiaxes(GridLayout);
    set(Fig, 'CurrentAxes', AxisHandle{ActiveAxisHandle});
    AxisHandle{ActiveAxisHandle}.Layout.Row = ceil(ActiveAxisHandle/3) ;
    AxisHandle{ActiveAxisHandle}.Layout.Column = mod(ActiveAxisHandle -1 , 3) + 1;

    Title = string(app.app.Dataset{1, 1}.Properties.VariableNames(ii)); %Get the current column title
    %figure('Name', Title);
    Mean = zeros(DataGroup, DataNumber);
    Sem = zeros(DataGroup, DataNumber);
    YMax = 0; %Record the max limit for y-axis

    for jj = 1:DataGroup %Analyze each group

        for xx = 1:DataNumber %Analyze each sub-group
            if(~isempty(app.app.Dataset{jj, xx}))
                Mean(jj, xx) = mean(app.app.Dataset{jj, xx}.(Title));
                Sem(jj, xx) = std(app.app.Dataset{jj, xx}.(Title)) / sqrt(length(app.app.Dataset{jj, xx}.(Title)));
                %Store Mean and Sem in the ResultTable
                DataPosition = (jj - 1) * DataNumber +xx;
                % ResultT.Type(DataPosition) = [GroupNames{jj}, '_',
                % NumberNames{xx}]; ResultT.Mean(DataPosition) = Mean(jj,
                % xx); ResultT.Sem(DataPosition) = Sem(jj, xx);
                % ResultT.SampleNumber(DataPosition) =
                % length(app.app.Dataset{jj, xx}.(Title));

                if (DataGroup == 2 && jj == 2 && ShowSig) %Calculate signiface when only 2 groups
                    p = Independent_Two_Sample_TTest(app.app.Dataset{1, xx}.(Title), app.app.Dataset{2, xx}.(Title),OutlierRemove);
                    ResultT.Significance(DataPosition) = p;
                    YMaxNow = Significance_Line(xx, xx, app.app.Dataset{1, xx}.(Title), app.app.Dataset{2, xx}.(Title), p, 'k', FontName, FontSize, false);
                    YMax = max(YMax, YMaxNow);
                    hold on
                end
            end

        end

        %Draw errorbar
        e = errorbar(1:DataNumber, Mean(jj, :), Sem(jj, :));
        e.Marker = 'o';
        e.MarkerSize = 0.8 * FontSize;
        hold on
    end

    %% Setting of the figure

    %Set the position of figure
    FigPosi = [100 550; 700 550; 1300 550; 100 50; 700 50; 1300 50];
    FigNumber = mod(ii, DataNumber);

    if (FigNumber == 0)
        FigNumber = DataNumber;
    end

    %set(app.DrawFigureUIFigure, 'position', [FigPosi(FigNumber, 1)
    %FigPosi(FigNumber, 2) 550 400]);

    %Label the x-axis
    set(gca,'Fontname', FontName, 'FontSize', FontSize);
    set(gca,'xtick', 1:DataNumber)
    set(gca,'xticklabel', XTickLabel, 'Fontname', FontName, 'FontSize', FontSize)
    xlabel(gca,"DIV", 'Fontname', FontName, 'FontSize', FontSize);

    %Make legend only at the first figure
    if (ii == 1)
        h = findobj(Fig, 'Type', 'errorbar');
        h = h(end:-1:1);
        legend(h, GroupNames);
    end

    set(gca,'Fontname', FontName, 'FontSize', FontSize);

    %Modify the label for y-axis
    if (contains(Title, 'length'))
        NewTitle = "Total dendritic length/μm";
    else

        if (contains(Title, 'points'))
            NewTitle = "Total branch points/100 μm primary dendrites";
        else

            if (contains(Title, 'tips'))
                NewTitle = "No. of total dendrites";
            else
                NewTitle = strrep(Title, '_', ' ');
                NewTitle = strrep(NewTitle, 'No', 'No.');
            end

        end

    end

    ylabel(NewTitle, 'Fontname', FontName, 'FontSize', FontSize);

    %Resize the y-axis

    ylim auto;
    LimitY = ylim;
    LimitY(2) = max(LimitY(2), YMax);
    ylim([LimitY(1) - 0.04 * (LimitY(2) - LimitY(1)), LimitY(2) + 0.04 * (LimitY(2) - LimitY(1))])

    %Resize the x-axis
    xlim auto;
    LimitX = xlim;
    xlim([LimitX(1) - 0.04 * (LimitX(2) - LimitX(1)), LimitX(2) + 0.04 * (LimitX(2) - LimitX(1))])
end

%% Save the figures and table
if (Save)
    mkdir Analysis %Make new folder
    FigPath = strcat('Analysis/', string(ii), '. ', Title, '.tiff'); %Save as tiff
    exportgraphics(gcf, FigPath, 'Resolution', Resolution)
    FigPath2 = strcat('Analysis/', string(ii), '. ', Title, '.eps'); %Save as eps
    exportgraphics(gcf, FigPath2, 'Resolution', Resolution)
    TabPath = strcat('Analysis/', string(ii), '. ', Title, '_Mean_and_Sem.xlsx');
    writetable(ResultT, TabPath);
end

end

function GridLayout = CreateGridLayout(Fig)
    GridLayout = uigridlayout('Parent', Fig);
    GridLayout.ColumnWidth = {'1x'};
    GridLayout.RowHeight = {'1x'};
    GridLayout.ColumnSpacing = 0;
    GridLayout.RowSpacing = 0;
    GridLayout.Padding = [0 0 0 0];
    GridLayout.Scrollable = 'on';
end