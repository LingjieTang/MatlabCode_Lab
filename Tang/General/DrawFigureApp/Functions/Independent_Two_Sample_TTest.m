%% Information
%Aim: Difference Analysis by indenpendent two sample ttest(Welch t-test or Student t-test)
%Enables removal of outlier by quartiles (varargin = 'quartiles') or other methods. 
%(For no removal: 'none')
%
%Prerequisite: Two groups of data
%
%Output: p value
%
%Author: Tang Lingjie
%
%Version: 2023/03/14
%
%Email: tanglj0222@gmail.com; wasdiojk@126.com
%%

function [p] = Independent_Two_Sample_TTest(AGroup, BGroup, varargin)

    if (strcmp(varargin{1},'none')~=1)
        OutlierRemove = varargin{1};
        AGroup = AGroup(~isoutlier(AGroup, OutlierRemove));
        BGroup = BGroup(~isoutlier(BGroup, OutlierRemove));
    end

    %In case of void data
    AGroup = AGroup(~isnan(AGroup));
    BGroup = BGroup(~isnan(BGroup));

    %Test if the variances are equal, Levene's test
    Data = [AGroup; BGroup];
    Group = [zeros(length(AGroup), 1); ones(length(BGroup), 1)];

    pValue = vartestn(Data, Group, 'TestType', 'LeveneAbsolute', 'Display', 'off');

    if pValue < 0.05 %Unequal variances
        %disp('Equal variances not assumed');
        [~, p] = ttest2(AGroup, BGroup, 'Vartype', 'unequal');
    else %Equal variances
        [~, p] = ttest2(AGroup, BGroup);
    end

end
