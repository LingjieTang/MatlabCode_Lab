function LineChart2(Dataset)
%% Information
%Aim: A template code to draw linechart.
%
%Prerequisite: Data form is table (.xlsx/.csv .etc).
%
%Author: Tang Lingjie
%
%Version: 2023/03/14
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

%% Initial settings
%Parameters that often need to be changed
Save = false; %Save data (figures and result table) or not
ShowSig = true; %Show significance or not (only show when Datagroup = 2)
XLabel = 'DIV';
XTickLabel = [3, 4, 5, 6, 7, 9, 11]; %The label for the x-axis

% Data loading
DataGroup = 2; %The number of group of data, for example, 2 groups that are "control" and "drug treatment".
GroupNames = {'control', 'cKO'};
DataNumber = 6; %The maxinum number of sub-group in the groups, for exapmle, data are observed on 6 different date in the "control group".


%Parameters that seldom need to be changed
NumberNames = cell(DataNumber, 1); %Specify the names of each sub-group by catenating XLabel and XTickLabel

for nn = 1:DataNumber
    NumberNames{nn} = [XLabel, '_', num2str(XTickLabel(nn))];
end

Colors = {[0.3010 0.7450 0.9330], [0.4660 0.6740 0.1880], [0.4940 0.1840 0.5560], ...
              [0.9290 0.6940 0.1250], [0.8500 0.3250 0.0980], [0 0.4470 0.7410], [0.6350 0.0780 0.1840]}; %The default colors in the Matlab
ColorLen = length(Colors);
FontName = 'Arial';
FontSize = 10;
Resolution = 1200; %Resolution of output figures
%Output a result table to store key information including the mean value,
%the S.E.M, the number of samples, the significance
varNames = {'Type', 'Mean', 'Sem', 'SampleNumber', 'Significance'};
sz = [DataGroup * DataNumber, length(varNames)];
ResultT = table('Size', sz, 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, 'VariableNames', varNames);
OutlierRemove = 'quartiles'; %Removal of outliers. Use 'none' to disable, or 'quartiles' to enable

%% Main program
for ii = 1%[1, 2, 4] %1:size(Dataset{1,1}, 2) %Analyze each column in the table
    Title = string(Dataset{1, 1}.Properties.VariableNames(ii)); %Get the current column title
    figure('Name', Title);
    Mean = zeros(DataGroup, DataNumber);
    Sem = zeros(DataGroup, DataNumber);
    YMax = 0; %Record the max limit for y-axis

    for jj = 1:DataGroup %Analyze each group

        for xx = 1:DataNumber %Analyze each sub-group
            Mean(jj, xx) = mean(Dataset{jj, xx}.(Title));
            Sem(jj, xx) = std(Dataset{jj, xx}.(Title)) / sqrt(length(Dataset{jj, xx}.(Title)));
            %Store Mean and Sem in the ResultTable
            DataPosition = (jj - 1) * DataNumber +xx;
            ResultT.Type(DataPosition) = [GroupNames{jj}, '_', NumberNames{xx}];
            ResultT.Mean(DataPosition) = Mean(jj, xx);
            ResultT.Sem(DataPosition) = Sem(jj, xx);
            ResultT.SampleNumber(DataPosition) = length(Dataset{jj, xx}.(Title));

            if (DataGroup == 2 && jj == 2 && ShowSig) %Calculate signiface when only 2 groups
                p = Independent_Two_Sample_TTest(Dataset{1, xx}.(Title), Dataset{2, xx}.(Title),OutlierRemove);
                ResultT.Significance(DataPosition) = p;
                YMaxNow = Significance_Line(xx, xx, Dataset{1, xx}.(Title), Dataset{2, xx}.(Title), p, 'k', FontName, FontSize, false);
                YMax = max(YMax, YMaxNow);
                hold on
            end

        end

        %Draw errorbar
        e = errorbar(1:DataNumber, Mean(jj, :), Sem(jj, :));
        e.Marker = 'o';
        e.Color = Colors{ColorLen - mod(jj, ColorLen)};
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

    set(gcf, 'position', [FigPosi(FigNumber, 1) FigPosi(FigNumber, 2) 550 400]);

    %Label the x-axis
    set(gca, 'Fontname', FontName, 'FontSize', FontSize);
    set(gca, 'xtick', 1:DataNumber)
    set(gca, 'xticklabel', XTickLabel, 'Fontname', FontName, 'FontSize', FontSize)
    xlabel("DIV", 'Fontname', FontName, 'FontSize', FontSize);

    %Make legend only at the first figure
    if (ii == 1)
        h = findobj(gcf, 'Type', 'errorbar');
        h = h(end:-1:1);
        legend(h, GroupNames);
    end

    set(gca, 'Fontname', FontName, 'FontSize', FontSize);

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

    ylim auto
    LimitY = ylim;
    LimitY(2) = max(LimitY(2), YMax);
    ylim([LimitY(1) - 0.04 * (LimitY(2) - LimitY(1)), LimitY(2) + 0.04 * (LimitY(2) - LimitY(1))])

    %Resize the x-axis
    xlim auto
    LimitX = xlim;
    xlim([LimitX(1) - 0.04 * (LimitX(2) - LimitX(1)), LimitX(2) + 0.04 * (LimitX(2) - LimitX(1))])

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
end