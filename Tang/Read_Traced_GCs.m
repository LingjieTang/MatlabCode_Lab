%% Information

%Aim: To pool the morphological data(csv format,output by Fiji SNT tracing)
%of each GCs together,and analyze the desire parameters in this order:
%{'No_of_primary_dendrite', 'No_of_secondary_dendrite', 'No_of_tips',
%'Total_length','Primary_dendrite_with_branches','Total_branch_points'}
%
%Prerequisite:csv format data output ('SNT Measurements.csv') by Fiji SNT tracing plugin,
%in the LoadPath, use 01,02.. rather than 1,2.. to avoid different arrangement in Matlab
%
%Important(Already fixed by additional code): Sometimes SNT don't save table by the order of path but by the
%order of path order(namely the primary or secondary dendrite), remember to correct it if so.
%
%Author: Tang Lingjie
%
%Version: 2023/03/14
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

%%
clc
clear

LoadPath = 'H:\ToMeiran\Data\cont_DIV3\trace Ding';
SavePath = [LoadPath, '\Data_by_Matlab.xlsx'];
LengthThre = 5; %The length threshold that a process is thought as a dendrite

%Read  folder names
File = dir(fullfile(LoadPath));
File = File(3:end);

%Only select the sub-folders in the loadpath
jj = 1;

for ii = 1:length(File)

    if (File(ii).isdir)
        File2(jj, :) = File(ii);
        jj = jj + 1;
    end

end

File = File2;

sz = [100, 6];
varNames = {'No_of_primary_dendrite', 'No_of_secondary_dendrite', 'No_of_tips', ...
                'Total_length', 'Primary_dendrite_with_branches', 'Total_branch_points'};
varTypes = {'double', 'double', 'double', 'double', 'double', 'double'};
TotalTable = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);

%Read .csv file of each GCs
for ii = 1:length(File)
    Folder = fullfile(LoadPath, File(ii).name);
    tbl = readtable(fullfile(LoadPath, File(ii).name, 'SNT Measurements.csv'));
    %The 'SNT Measurements.csv' table contains 4 columns: path number, SWCtype,
    %PathLength and PathOrder
    PathNum = table2cell(tbl(:, 1));
    tbl = tbl(contains(PathNum, "Path"), :); %Note whether the 1st column is the order of path
    tbl = tbl(table2array(tbl(:, 3)) >= LengthThre, :);

    %% Belows is the code for solving the possibile bug caused by that SNT didn't save the first column(No. of path) in order
    %In that case, parameters such as the number of primary dendrites will be correct, but parameters such as dendrites with
    %branches will be false
    PathNum = table2cell(tbl(:, 1));
    PathNumTable = zeros(length(PathNum), 1);

    for jj = 1:length(PathNum)
        StrPathNum = char(PathNum(jj));
        Front = strfind(StrPathNum, '(');
        Behind = strfind(StrPathNum, ')');
        %Find the No. of path
        PathNumTable(jj) = str2double(StrPathNum(Front + 1:Behind - 1));
    end

    %Resort the table due to the No. of path
    [~, index] = sort(PathNumTable);
    tbl = tbl(index, :);

    %%Calculate the parameters
    TotalTable.No_of_primary_dendrite(ii) = length(find(tbl.PathOrder == 1));

    Secondary = find(tbl.PathOrder == 2);
    TotalTable.No_of_secondary_dendrite(ii) = length(Secondary);
    TotalTable.No_of_tips(ii) = length(tbl.PathOrder);
    TotalTable.Total_length(ii) = sum(table2array(tbl(:, 3))); %Note whether the 3rd column is length
    TotalTable.Primary_dendrite_with_branches(ii) = ...
        length(Secondary(tbl.PathOrder(Secondary - 1) == 1)) / TotalTable.No_of_primary_dendrite(ii);

    tbl2 = tbl(tbl.PathOrder == 1, :);
    TotalTable.Total_branch_points(ii) = 100 * TotalTable.No_of_secondary_dendrite(ii) / sum(table2array(tbl2(:, 3)));
    %Note whether the 3rd column is length
end

TotalTable = TotalTable(table2array(TotalTable(:, 1)) ~= 0, :);
writetable(TotalTable, SavePath)
