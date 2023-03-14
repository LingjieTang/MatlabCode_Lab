%% Information
%Aim: A template code to draw electrophysiological figures.
%
%Prerequisite: Data form is table.(.xlsx/.csv .etc).
%
%YMethod: Represents the meaning of y-axis. 2 types. 'Relative': means the
%relative pixel values, the formulation is (x-u)/u, where x is data and u
%is mean 'Difference': menas the difference oof pixel values, the
%formulation is  (x-x0)/x0, where x is data and x0 is the first data point
%
%Author: Tang Lingjie
%
%Version: 2023/03/14
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

%% Folder Path
%Parameters that often need to be changed
Save = false; %Save data (figures and result table) or not
YMethod = 'Relative';
AxisVisiblity = true; %Draw the axis or not

%Parameters that seldom need to be changed
FontName = 'Arial';
FontSize = 10;
Resolution = 1200; %Resolution of output figures

% Data loading
DataGroup = 2; %The number of group of data, for example, 2 groups that are "control" and "drug treatment".
GroupNames = {'control', 'K+'};
DataNumber = 9; %Cell number
Dataset = cell(DataGroup, DataNumber);

Dataset{1, 1} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_02.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_02.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_02.csv')];
Dataset{1, 2} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_04.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_04.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_04.csv')];
Dataset{1, 3} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_05.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_05.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_05.csv')];
Dataset{1, 4} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_06.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_06.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_06.csv')];
Dataset{1, 5} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_07.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_07.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_07.csv')];
Dataset{1, 6} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_08.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_08.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_08.csv')];
Dataset{1, 7} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_09.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_09.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_09.csv')];
Dataset{1, 8} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_10.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_10.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_10.csv')];
Dataset{1, 9} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\control\Values_11.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\control\Values_11.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\control\Values_11.csv')];

Dataset{2, 1} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\K+\Values_01.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\K+\Values_01.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\K+\Values_01.csv')];
Dataset{2, 2} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\K+\Values_02.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\K+\Values_02.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\K+\Values_02.csv')];
Dataset{2, 3} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\K+\Values_06.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\K+\Values_06.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\K+\Values_06.csv')];
Dataset{2, 4} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\K+\Values_07.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\K+\Values_07.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\K+\Values_07.csv')];
Dataset{2, 5} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\K+\Values_10.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\K+\Values_10.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\K+\Values_10.csv')];
Dataset{2, 6} = [readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV4\K+\Values_13.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV5\K+\Values_13.csv'); ...
                     readtable('G:\Imaging\32. 230103_CV1000_GCs_GCaMP6s_DIV3_6\DIV6\K+\Values_13.csv')];

%% Main program
x = [linspace(0, 3, 100), linspace(3.5, 6.5, 100), linspace(7, 10, 100)];
Cali = 0;

for ii = 1:DataGroup
    figure('Name', GroupNames{ii})

    for jj = 1:DataNumber

        if (~isempty(Dataset{ii, jj}))
            T = Dataset{ii, jj};
        else
            break
        end

        if (strcmp(YMethod, 'Difference'))
            y = table2array(T(:, 2)) / table2array(T(1, 2)) - 1 - Cali;
        else

            if (strcmp(YMethod, 'Relative'))
                y = table2array(T(:, 2)) / mean(table2array(T(:, 2))) - 1 - Cali;
            end

        end

        p = plot(x(1:100), y(1:100));
        Color = p.Color;
        hold on
        plot(x(101:200), y(101:200), 'Color', Color);
        plot(x(201:300), y(201:300), 'Color', Color);
        txt = sprintf("cell %d", jj);
        t = text(-0.2, -Cali, txt, 'HorizontalAlignment', 'right');
        t.Color = Color;
        t.FontSize = FontSize;
        t.FontName = FontName;
        Cali = Cali + 1;
    end

    if (~AxisVisiblity)
        axis off
    end

end

%Resize the x-axis
xlim auto
LimitX = xlim;
xlim([LimitX(1) - 0.04 * (LimitX(2) - LimitX(1)), LimitX(2) + 0.04 * (LimitX(2) - LimitX(1))])

% Save the figures and table mkdir Analysis
if (Save)
    %Make new folder
    FigPath = strcat('Analysis/', YMethod, '.tiff');
    FigPath2 = strcat('Analysis/', YMethod, '.eps');

    exportgraphics(gcf, FigPath, 'Resolution', Resolution)
    exportgraphics(gcf, FigPath2, 'Resolution', Resolution)
end
