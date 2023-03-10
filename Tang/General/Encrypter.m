%% Information
%Aim: To randomize and encrypt the name of sub-folders you are going to deal with, 
%in order to analyze the data in a blind manner. If the names have been encrypted,
%this code can also decrypt using a record table.
%
%Prerequisite: The sub-folders are supposed to have a common word for
%recognition (in my case "DIV"), in order not to encrypt the names for 2
%times and thus makes it unable to be decrypted
%
%Output: This code will encrypt the sub-folder names and make a record
%of the former and later name for decryption.
%
%Author: Tang Lingjie
%
%Version: 2023/03/10
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com

clc
clear

%% Parts that have variables
LoadPath = 'G:\Imaging\40. 230309_FV1000_CGC_B6cKOBasalCurve';
CommonWord = "DIV";

%% Functions
%Read  folder names
File = dir(fullfile(LoadPath));
File = File(3:end);

%Only select the sub-folders
jj = 1;
for  ii = 1:length(File)
    if(File(ii).isdir)
        File2(jj) = File(ii);
        jj = jj+1;
    end
end
File = File2;

%Randomize and encrypt the name of sub-folders by concatenation of 2 random numbers varies from 0~1000
if(contains(File(2).name, CommonWord))
    %To record the transformation of folder names
    Record = cell(length(File),2);
    rng('shuffle')
    for ii = 1:length(File)
        OldName = File(ii).name;
        OldPath =  fullfile([LoadPath, '\', OldName]);
        
        NewDigit1 = round(1000*(rand));
        NewDigit2 = round(1000*(rand));
        NewName = strcat(num2str(NewDigit1), num2str(NewDigit2));
        NewPath =  fullfile([LoadPath, '\', NewName]);
        
        %Rename and record
        movefile (OldPath, NewPath)
        Record{ii,1} = OldName;
        Record{ii,2} = NewName;
    end
    writecell(Record, fullfile([LoadPath, '\Record.xlsx']))
else
    %Decrypt
    Record = readcell(fullfile([LoadPath, '\Record.xlsx']));
    for ii = 1:length(File)
        movefile (fullfile([LoadPath, '\', Record{ii,2}]), fullfile([LoadPath, '\', Record{ii,1}]))
    end
end