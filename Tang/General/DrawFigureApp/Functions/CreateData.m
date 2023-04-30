function CreateData()
%Please modify here, row means how many points on the x-axis, column means
%how many groups at each points
% For example, I have 3 different data group (control, exp. group1, exp.
% group2), and I have 6 different data points(DIV3, 4, 5, 7,
% 9, 11).
%
% And in each grid of the cell is a table that may contain many parameters
% in different columns(the number of 1st dendrite, the dendritic
% length...).
%
%If you have many parallel repeat (do 1 exp. condition 3 times), just
%concatenate them into 1 table.
Row = 6;
Column = 3;
RawDataset = cell(Row,Column);

RawDataset{1, 1} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV3\trace\Data_by_Matlab.xlsx'); ...
    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV3\trace\Data_by_Matlab.xlsx')];
RawDataset{2, 1} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV4\trace\Data_by_Matlab.xlsx'); ...
    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV4\trace\Data_by_Matlab.xlsx')];
RawDataset{3, 1} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV5\trace\Data_by_Matlab.xlsx'); ...
    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV5\trace\Data_by_Matlab.xlsx')];
RawDataset{4, 1} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV7\trace\Data_by_Matlab.xlsx'); ...
    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV7\trace\Data_by_Matlab.xlsx')];
RawDataset{5, 1} = [readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV9\trace\Data_by_Matlab.xlsx'); ...
    readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV9\trace\Data_by_Matlab.xlsx')];
RawDataset{6, 1} = readtable('G:\Imaging\29. 221208_FV1000_GCs_ICR_BasalCurve\DIV11\trace\Data_by_Matlab.xlsx');

RawDataset{2, 2} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV4_TTXAPV\trace\Data_by_Matlab.xlsx');
RawDataset{3, 2} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV5_TTXAPV\trace\Data_by_Matlab.xlsx');
RawDataset{4, 2} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV7_TTXAPV\trace\Data_by_Matlab.xlsx');
RawDataset{5, 2} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV9_TTXAPV\trace\Data_by_Matlab.xlsx');
RawDataset{6, 2} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV11_TTXAPV\trace\Data_by_Matlab.xlsx');


RawDataset{2,3} =  readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV4_15mMK+\trace\Data_by_Matlab.xlsx');
RawDataset{3,3} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV5_15mMK+\trace\Data_by_Matlab.xlsx');
RawDataset{4,3} = readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV7_15mMK+\trace\Data_by_Matlab.xlsx');
RawDataset{5,3} =  readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV9_15mMK+\trace\Data_by_Matlab.xlsx');
RawDataset{6,3} =  readtable('G:\Imaging\31. 221216_FV1000_GCs_ICR_ActivityOnDendrite_40x\DIV11_15mMK+\trace\Data_by_Matlab.xlsx');

save('\Exported\RawDataset.mat', "RawDataset");
end

