function [] = EnhanceImages()

% [file, pNameSeg] = uigetfile('*.tif', 'Select a folder, and all the tif
% files will be loaded');
%
% if(isequal(file,0)) %If cancelled
%     disp('User selected Cancel')
% else
pNameSeg = 'G:\Imaging\44. 230422_Dragonfly_CGC_B6BasalCurveAndTTXAPV\DIV3';

cd(pNameSeg);
TifFiles = dir('*.tif');
numfiles = length(TifFiles);
mydata = cell(1, numfiles);

mkdir MatlabEnhanced

for k = 5:10%1:numfiles
    mydata{k} = imread(TifFiles(k).name);
    I0 = mydata{k};
    I1 = imlocalbrighten(I0);
    I2 = imlocalbrighten(I1);
    
    I3 = imreducehaze(I2);


   % I3 = imadjust(I3);
    n = 1.2;  
    Idouble = im2double(I3); 
   avg = mean2(Idouble);
   sigma = std2(Idouble);

 I3 = imadjust(I3,[max(0,avg-n*sigma) avg+n*sigma],[]);
   
   
    
   
    
    %I3 = imlocalbrighten(I2);
    % I2 = imlocalbrighten(I1);
    
    %I3 = imadjust(I2);

    I4 = imbinarize(I3,"adaptive");
    I5 = medfilt2(I4);

    I6 = bwareaopen(I5, 100);
    
    I7 = imclose(I6, strel('disk',3));
    I7 =  medfilt2(I7);
    I7 = bwareaopen(I7, 7000);
    I8 = medfilt2(I7);
    

 % imwrite(I8,['MatlabEnhanced\',TifFiles(k).name])
  figure
    montage({I0, I1, I2, I3,I4,I5,I6,I7,I8},'Size',[2,5])
end

end


