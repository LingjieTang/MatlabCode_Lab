function [] = EnhanceImages()
%To enhance and binarize neuron images

pNameSeg = 'G:\Imaging\44. 230422_Dragonfly_CGC_B6BasalCurveAndTTXAPV\DIV3\WT';

cd(pNameSeg);
TifFiles = dir('*.tif');
numfiles = length(TifFiles);
mydata = cell(1, numfiles);

if ~exist(strcat(pNameSeg, '\MatlabEnhanced'), 'dir')
    mkdir MatlabEnhanced
end

for k = 4%1:numfiles
    mydata{k} = imread(TifFiles(k).name);
    I0 = mydata{k};

    %Brighten
    I1 = imlocalbrighten(I0);
    I2 = imlocalbrighten(I1);

    %Reduce haze and enhance contrast
    I3 = imreducehaze(I2);

    n = 1.2;
    Idouble = im2double(I3);
    avg = mean2(Idouble);
    sigma = std2(Idouble);
    I3 = imadjust(I3,[max(0,avg-n*sigma) avg+n*sigma],[]);

    %Binarize
    I4 = imbinarize(I3,"adaptive");

    %Remove object that area < 100 pixel^2
    I5 = medfilt2(I4);
    I6 = bwareaopen(I5, 100);

    %Bridge
    [EndPointsR,  EndPointsC]= find(bwmorph(I6,'endpoints'));
   %  imshow(I6)
   %  hold on
   % scatter(EndPointsC,  EndPointsR,'b')
    PixelList = regionprops(I6,'PixelList');
    [~, PixelListMaxIndex] = max(length(PixelList));
     PixelListMax = PixelList(PixelListMaxIndex).PixelList;

    for ii = 2:length(PixelList)
        PixelListNow = PixelList(ii).PixelList;
        [D,I] = pdist2(PixelListNow,PixelListMax,'euclidean','Largest',1);
        DistanceList = arrayfun(@(x) x(1)-PixelListMax(:,1)+x(2)-PixelListMax(:,2), PixelListNow);
    end
    

    %Remove object that area < 7000 pixel^2
    I7 = imclose(I6, strel('disk',3));
    I7 =  medfilt2(I7);
    I7 = bwareaopen(I7, 7000);
    I8 = medfilt2(I7);

    % imwrite(I8,['MatlabEnhanced\',TifFiles(k).name])
    figure
    montage({I0, I1, I2, I3,I4,I5,I6,I7,I8},'Size',[2,5])
end

end


