%% Information
%Aim: A template code to draw barplot.
%
%Prerequisite: Data form is table (.xlsx/.csv .etc).
%
%Author: Tang Lingjie
%
%Version: 2023/03/27
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

%% Initial settings
%Parameters that often need to be changed
Save = false; %Save data (figures and result table) or not
ShowErrorbar = true; %Show mean and errorbar or not
ShowSig = true; %Show significance or not (only show when Datagroup = 2)
XLabel = 'Transfection';
XTickLabel =  ["HA Elyra7","mCherry Elyra7", "HA FV1000"]; %The label for the x-axis

% Data loading
DataGroup = 2; %The number of group of data, for example, 2 groups that are "control" and "drug treatment".
GroupNames = {'none treatment', 'treatment'};
DataNumber = 3; %The maxinum number of sub-group in the groups, for exapmle, data are observed on 6 different date in the "control group".
Dataset = cell(DataGroup, DataNumber);
DataPoints = cell(DataGroup, DataNumber);
Dataset{1, 1} = readtable('G:\Imaging\34. 230124_Elyra7_ GCsandN2a_Btbd3Translocation_63x\CGC Btbd3HA ms\no treatment\Integrated_by_Matlab.csv');
Dataset{2, 1} = readtable('G:\Imaging\34. 230124_Elyra7_ GCsandN2a_Btbd3Translocation_63x\CGC Btbd3HA ms\TTX+1 h K+\Integrated_by_Matlab.csv');
Dataset{1, 2} = readtable('G:\Imaging\34. 230124_Elyra7_ GCsandN2a_Btbd3Translocation_63x\CGC Btbd3mc GFP\no treatment\Integrated_by_Matlab.csv');
Dataset{2, 2} = readtable('G:\Imaging\34. 230124_Elyra7_ GCsandN2a_Btbd3Translocation_63x\CGC Btbd3mc GFP\1 h 100uM glutamate\Integrated_by_Matlab.csv');
Dataset{1, 3} = readtable('G:\Imaging\39. 230301_FV1000_CGC_Translocation_preTTXorAPV\TestImaging\preTTXAPV\1hAMPA\Integrated_by_Matlab.csv');
Dataset{2, 3} = readtable('G:\Imaging\39. 230301_FV1000_CGC_Translocation_preTTXorAPV\TestImaging\preTTXAPV\1hNMDA\Integrated_by_Matlab.csv');

%Parameters that seldom need to be changed
NumberNames = cell(DataNumber, 1); %Specify the names of each sub-group by catenating XLabel and XTickLabel

for nn = 1:DataNumber
    NumberNames{nn} = [XTickLabel(nn)]; %In this case, there is no need for NumberNames, but if you want to specify the names that are different from XTickLabel, use this code
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
for ii = 3:3%1:size(Dataset{1, 1}, 2) %Analyze each column in the table
    Title = string(Dataset{1, 1}.Properties.VariableNames(ii)); %Get the current column title
    figure('Name', Title);

    for jj = 1:DataGroup %Analyze each group

        for xx = 1:DataNumber %Analyze each sub-group
            %x-coordinate value of data points are arithmetic progression.
            %The first term is xx-Cali*(DataGroup-1)/2 and the tolerance is
            %Cali.
            FirstTerm = xx - Cali * (DataGroup - 1) / 2;
            Xposition = FirstTerm + Cali * (jj - 1); %Arithmetic series formula
            DataPoints{jj,xx} = Dataset{jj, xx}.(Title)(2:2:end)./Dataset{jj, xx}.(Title)(1:2:end-1); %Process the data
            Mean = mean(DataPoints{jj,xx});
            Sem = std(DataPoints{jj,xx}) / sqrt(length(DataPoints{jj,xx}));

            %Decide the color of bars
            if(~mod(jj, DataNumber))
                Color = Colors{jj};
            else
                Color = Colors{mod(jj, DataNumber)};
            end
            %Draw the barplot
            bar(Xposition, Mean, 0.8 * Cali, 'FaceColor', Color ,'EdgeColor', Color, 'FaceAlpha', 0.5); %Draw the barplot

            %Store Mean and Sem in the ResultTable
            DataPosition = (jj - 1) * DataNumber +xx;
            ResultT.Type(DataPosition) = strcat(GroupNames{jj}, '_', NumberNames{xx});
            ResultT.Mean(DataPosition) = Mean;
            ResultT.Sem(DataPosition) = Sem;
            ResultT.SampleNumber(DataPosition) = length(DataPoints{jj,xx});
            hold on
            if (DataGroup == 2 && jj == 2 && ShowSig) %Calculate signiface when only 2 groups
                p = Independent_Two_Sample_TTest(DataPoints{1,xx}, DataPoints{2,xx}, OutlierRemove);
                ResultT.Significance(DataPosition) = p;
                Significance_Line(FirstTerm, FirstTerm + Cali,  DataPoints{1,xx}, DataPoints{2,xx}, p, 'k', FontName, FontSize, false);
            end

            hold on
            %Draw errorbar
            if (ShowErrorbar)
                e = errorbar(Xposition, Mean, Sem, 'o', 'MarkerSize', 5);
                e.Color = 'k';
            end

            %Use swarmchart to plot the data point that are not outliers
            s = swarmchart(Xposition * ones(length(DataPoints{jj,xx}), 1), DataPoints{jj,xx}, 5, Color, 'filled');
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
    xlabel(XLabel, 'Fontname', FontName, 'FontSize', FontSize);

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

    NewTitle = "Intensity Cyto/Nucleus";
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
