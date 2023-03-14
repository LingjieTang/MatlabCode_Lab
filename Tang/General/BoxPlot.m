%% Information
%Aim: A template code to draw boxplot.
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
ShowErrorbar = false; %Show mean and errorbar or not
ShowSig = true; %Show significance or not (only show when Datagroup = 2)
XLabel = 'DIV';
XTickLabel = [3, 4, 5, 7, 9, 11]; %The label for the x-axis

% Data loading
DataGroup = 2; %The number of group of data, for example, 2 groups that are "control" and "drug treatment".
GroupNames = {'control', 'TTX + APV', 'K+'};
DataNumber = 6; %The maxinum number of sub-group in the groups, for exapmle, data are observed on 6 different date in the "control group".
Dataset = cell(DataGroup, DataNumber);
Dataset{1, 1} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV3\trace\Data_by_Matlab.xlsx'); ...
                     readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV3\trace\Data_by_Matlab.xlsx')];
Dataset{1, 2} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV4\trace\Data_by_Matlab.xlsx'); ...
                     readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV4\trace\Data_by_Matlab.xlsx')];
Dataset{1, 3} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV5\trace\Data_by_Matlab.xlsx'); ...
                    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV5\trace\Data_by_Matlab.xlsx')];
Dataset{1, 4} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV7\trace\Data_by_Matlab.xlsx'); ...
                    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV7\trace\Data_by_Matlab.xlsx')];
Dataset{1, 5} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV9\trace\Data_by_Matlab.xlsx'); ...
                    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV9\trace\Data_by_Matlab.xlsx')];
Dataset{1, 6} = readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV11\trace\Data_by_Matlab.xlsx');

Dataset{2, 1} = Dataset{1, 1};
Dataset{2, 2} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV4_TTXAPV\trace\Data_by_Matlab.xlsx');
Dataset{2, 3} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV5_TTXAPV\trace\Data_by_Matlab.xlsx');
Dataset{2, 4} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV7_TTXAPV\trace\Data_by_Matlab.xlsx');
Dataset{2, 5} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV9_TTXAPV\trace\Data_by_Matlab.xlsx');
Dataset{2, 6} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV11_TTXAPV\trace\Data_by_Matlab.xlsx');

% Dataset{3,1} = Dataset{1,1};
% Dataset{3,2} =  readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV4_15mMK+\trace\Data_by_Matlab.xlsx');
% Dataset{3,3} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV5_15mMK+\trace\Data_by_Matlab.xlsx');
% Dataset{3,4} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV7_15mMK+\trace\Data_by_Matlab.xlsx');
% Dataset{3,5} =  readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV9_15mMK+\trace\Data_by_Matlab.xlsx');
% Dataset{3,6} =  readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV11_15mMK+\trace\Data_by_Matlab.xlsx');

%Parameters that seldom need to be changed
NumberNames = cell(DataNumber, 1); %Specify the names of each sub-group by catenating XLabel and XTickLabel

for nn = 1:DataNumber
    NumberNames{nn} = [XLabel, '_', num2str(XTickLabel(nn))];
end

Cali = 0.8 / DataGroup; %Calibration of the x-coordinate value of data points
JitterWidth = 0.8 * Cali; %The JitterWidth in the swarmchart
Colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250], ...
             [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]}; %The default colors in the Matlab
FontName = 'Arial';
FontSize = 10;
Resolution = 1200; %Resolution of output figures
%Output a result table to store key information including the mean value,
%the S.E.M, the number of samples, the significance
varNames = {'Type', 'Mean', 'Sem', 'SampleNumber', 'Significance'};
sz = [DataGroup * DataNumber, length(varNames)];
ResultT = table('Size', sz, 'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, 'VariableNames', varNames);
OutlierRemove = 'quartiles';

%% Main program
for ii = 1:size(Dataset{1, 1}, 2) %Analyze each column in the table
    Title = string(Dataset{1, 1}.Properties.VariableNames(ii)); %Get the current column title
    figure('Name', Title);

    for jj = 1:DataGroup %Analyze each group

        for xx = 1:DataNumber %Analyze each sub-group
            %x-coordinate value of data points are arithmetic progression.
            %The first term is xx-Cali*(DataGroup-1)/2 and the tolerance is
            %Cali.
            FirstTerm = xx - Cali * (DataGroup - 1) / 2;
            Xposition = FirstTerm + Cali * (jj - 1); %Arithmetic series formula
            Xpositions = Xposition * ones(length(Dataset{jj, xx}.(Title)), 1);
            boxplot(Dataset{jj, xx}.(Title), 'positions', Xpositions, 'Widths', 0.8 * Cali, 'Colors', Colors{mod(jj, DataNumber)}); %Draw the boxplot
            %Change the color of outliers
            if (xx == DataNumber)
                Outliers = findobj(gcf, 'tag', 'Outliers');
                set(Outliers(1:DataNumber), 'MarkerEdgeColor', Colors{mod(jj, DataNumber)})
            end

            % Plot data points, mean value and outliers
            TrueData = Dataset{jj, xx}.(Title)(~isoutlier(Dataset{jj, xx}.(Title), 'quartiles')); %TrueData represents the data point that are not outliers
            %Store Mean and Sem in the ResultTable
            DataPosition = (jj - 1) * DataNumber +xx;
            ResultT.Type(DataPosition) = [GroupNames{jj}, '_', NumberNames{xx}];
            ResultT.Mean(DataPosition) = mean(TrueData);
            ResultT.Sem(DataPosition) = std(TrueData) / sqrt(length(TrueData));
            ResultT.SampleNumber(DataPosition) = length(Dataset{jj, xx}.(Title));

            if (DataGroup == 2 && jj == 2 && ShowSig) %Calculate signiface when only 2 groups
                p = Independent_Two_Sample_TTest(Dataset{1, xx}.(Title), Dataset{2, xx}.(Title), OutlierRemove);
                ResultT.Significance(DataPosition) = p;
                Significance_Line(FirstTerm, FirstTerm + Cali, Dataset{1, xx}.(Title), Dataset{2, xx}.(Title), p, 'k', FontName, FontSize, false);
            end

            hold on
            %Draw errorbar
            if (ShowErrorbar)
                e = errorbar(Xposition, ResultT.Mean(DataPosition), ResultT.Sem(DataPosition), 'o', 'MarkerSize', 5);
                e.Color = 'k';
            end

            %Use swarmchart to plot the data point that are not outliers
            s = swarmchart(Xposition * ones(length(TrueData), 1), TrueData, 5, Colors{mod(jj, DataNumber)}, 'filled');
            s.XJitter = 'density';
            s.XJitterWidth = JitterWidth;
        end

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

    %Label the boxplot with designated colors
    h = findobj(gca, 'Tag', 'Box');

    for j = 1:length(h)
        Realj = length(h) + 1 - j; %Because the found boxes are in reverse order
        patch(get(h(Realj), 'XData'), get(h(Realj), 'YData'), Colors{ceil(j / DataNumber)}, 'EdgeColor', Colors{ceil(j / DataNumber)}, 'FaceAlpha', .3);
    end

    %Make legend only at the first figure
    if (ii == 1)
        c = get(gca, 'Children');

        if (ShowErrorbar)
            Legend = [GroupNames, 'mean ± SEM'];
            LegendRange = [c(DataGroup * DataNumber:-DataNumber:DataNumber); c(DataGroup * DataNumber + DataGroup)];
        else
            Legend = GroupNames;
            LegendRange = c(DataGroup * DataNumber:-DataNumber:DataNumber);
        end

        legend(LegendRange, Legend);
    end

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
    ylim([LimitY(1), LimitY(2) + 0.04 * (LimitY(2) - LimitY(1))])

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
