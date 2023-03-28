%% Information

%Aim: To integrate all the csv file in the folder (into a new csv)
%
%Prerequisite: csv format data output in the same folder
%
%Output: An integrated csv data named 'Integrated_by_Matlab.csv'
%
%Author: Tang Lingjie
%
%Version: 2023/03/27
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

%%
clc
clear

LoadPath = 'G:\Imaging\39. 230301_FV1000_CGC_Translocation_preTTXorAPV\TestImaging\preTTXAPV\1hAMPA';
SavePath = [LoadPath, '\Integrated_by_Matlab.csv'];

%Read  folder names
File = dir(fullfile(LoadPath));
File = File(3:end);

%Only select the csv files in the loadpath
jj = 1;
for ii = 1:length(File)
    if (contains(File(ii).name, '.csv') && (~contains(File(ii).name, 'Matlab'))) %Exclude the possible pre-existed Integrated_by_Matlab.csv
        File2(jj, :) = File(ii);
        jj = jj + 1;
    end
end
File = File2;

varNames = {'Location','Area', 'Mean'};
varTypes = {'string','double', 'double'};
sz = [100, length(varNames)];
TotalTable = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);

%Read .csv file of each GCs
jj = 1;
for ii = 1:length(File)
    Folder = fullfile(LoadPath, File(ii).name);
    tbl = readtable(fullfile(LoadPath, File(ii).name));
    %The '.csv' table contains 3 columns: ROI order, Area, Mean
   TotalTable.Area(jj:jj+height(tbl)-1) =  tbl.Area;
   TotalTable.Mean(jj:jj+height(tbl)-1)  =  tbl.Mean;
   jj = jj+height(tbl);
end

TotalTable = TotalTable(table2array(TotalTable(:, 2)) ~= 0, :);
TotalTable.Location(1:2:end-1) = 'Nucleus';
TotalTable.Location(2:2:end) = 'Cyto';
writetable(TotalTable, SavePath)
