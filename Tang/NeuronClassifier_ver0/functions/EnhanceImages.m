function [] = EnhanceImages()

pNameSeg = 'G:\OneDrive - Kyoto University\Imaging\44. 230422_Dragonfly_CGC_B6BasalCurveAndTTXAPV\DIV4\WT';

cd(pNameSeg);
TifFiles = dir('*.tif');

numfiles = length(TifFiles);
mydata = cell(1, numfiles);

Folder1 = strcat(pNameSeg, '\Matlab_Segmented');
Folder2 = strcat(pNameSeg, '\Matlab_Reference');
if ~exist(Folder1, 'dir')
    mkdir(Folder1)
end
if ~exist(Folder2, 'dir')
    mkdir(Folder2)
end

Range = 1:numfiles;
for k = Range
    mydata{k} = imread(TifFiles(k).name);
    I0 = mydata{k};

    %Brighten
    I1 = imlocalbrighten(I0);
    I2 = imlocalbrighten(I1);

    %Enhance contrast
    I3 = imreducehaze(I2);
    n = 1.2;
    Idouble = im2double(I3);
    avg = mean2(Idouble);
    sigma = std2(Idouble);
    I3 = imadjust(I3,[max(0,avg-n*sigma) avg+n*sigma],[]);

    %Binarize
    I4 = imbinarize(I3,"adaptive");

    %Remove regions < 100 pixel^2
    I5 = medfilt2(I4);
    I6 = bwareaopen(I5, 200);

    while 1
        %Remove regions < 7000 pixel^2
        binaryImage = I6;
        % Find connected components (objects) in the binary image
        labeledImage = bwlabel(binaryImage);
        numObjects = max(labeledImage(:));

        % Calculate the area of each object
        objectAreas = regionprops(binaryImage, 'Area');
        objectAreas = [objectAreas.Area];

        % Find the largest object
        [~, largestObjectIndex] = max(objectAreas);

        % Get the pixel coordinates of the largest object
        largestObjectMask = labeledImage == largestObjectIndex;
        [largestObjectRows, largestObjectCols] = find(largestObjectMask);

        % Calculate the distances from other objects to the largest object
        distances = zeros(numObjects, 1);
        closestPoints = cell(numObjects, 1);

        for i = 1:numObjects
            if i ~= largestObjectIndex
                % Get the pixel coordinates of the current object
                currentObjectMask = labeledImage == i;
                [currentObjectRows, currentObjectCols] = find(currentObjectMask);

                % Calculate the distances from current object to the
                % largest object
                currentDistances = pdist2([largestObjectRows, largestObjectCols], [currentObjectRows, currentObjectCols]);

                % Find the closest distance and its corresponding points
                [minDistance, minIndex] = min(currentDistances(:));
                [closestRow, closestCol] = ind2sub(size(currentDistances), minIndex);

                % Store the closest distance and points
                distances(i) = minDistance;
                closestPoints{i} = [largestObjectRows(closestRow), largestObjectCols(closestRow); currentObjectRows(closestCol), currentObjectCols(closestCol)];
            end
        end

        % Bridge the closest points if distance is shorter than the
        % threshold
        threshold = 70;

        Finished = true;
        for i = 1:numObjects
            if i ~= largestObjectIndex && distances(i) <= threshold
                Finished = false;
                points = closestPoints{i};

                % Set the pixel values on the line to 1 in the binary image
                linePoints = round([points(1, :); points(2, :)]);
                % Compute the line coordinates using Bresenham's line
                % algorithm
                x1 = linePoints(1,1);
                y1 = linePoints(1,2);
                x2 = linePoints(2,1);
                y2 = linePoints(2,2);
                dx = abs(x2 - x1);
                dy = abs(y2 - y1);
                sx = sign(x2 - x1);
                sy = sign(y2 - y1);
                err = dx - dy;

                lineCoordinates = [x1, y1];

                while ~(x1 == x2 && y1 == y2)
                    e2 = 2 * err;

                    if e2 > -dy
                        err = err - dy;
                        x1 = x1 + sx;
                    end

                    if e2 < dx
                        err = err + dx;
                        y1 = y1 + sy;
                    end

                    lineCoordinates = [lineCoordinates; x1, y1];
                end

                % Set the value of pixels along the line to 1 in the
                % logical array
                for ii = 1:size(lineCoordinates, 1)
                    x = lineCoordinates(ii, 1);
                    y = lineCoordinates(ii, 2);
                    I6(x, y) = 1;
                end

                % Display the resulting logical array

                % hold on
                % scatter(lineCoordinates(:,2),lineCoordinates(:,1),'b');

            end
        end
        if(Finished)
            break
        end
    end

    I7 = bwareaopen(I6, 7000);

    I8 = bwmorph(I7,"clean",Inf);
    I8 = bwmorph(I8,"spur",Inf);
    imwrite(uint8(I5) * 255,strcat(Folder2,'\','Before',TifFiles(k).name))
    imwrite(uint8(I8) * 255,strcat(Folder1,'\','After',TifFiles(k).name))

    % montage({I0, I1, I2, I3,I4,I5,I6,I7,I8},'Size',[2,5])

    % Create the uifigure
    % FigureName = sprintf('%d of image %d', k, numfiles);
    % if(k == Range(1))
    %     fig = uifigure('Name',  FigureName, 'Position', [600, 200, 750, 600]);
    % 
    %     % Load and display the image
    %     imageAxes = uiaxes(fig, 'Position', [0, 0, 900, 600]);
    % end
    % 
    % % Get the image data from the imshowpair subplot
    % set(fig, 'Name', FigureName);
    % imshowpair(I5,I8,'montage',"Parent",imageAxes);
    % axis(imageAxes, 'off');
    % 
    % % Create the toggle buttons
    % toggleButtonGroup = uibuttongroup(fig, 'Position', [200, 100, 350, 30], 'SelectionChangedFcn', @buttonGroupCallback);
    % toggleButton1 = uitogglebutton(toggleButtonGroup, 'Text', 'Fine', 'Position', [10, 5, 80, 20],'Value',false);
    % toggleButton2 = uitogglebutton(toggleButtonGroup, 'Text', 'Not yet', 'Position', [260, 5, 80, 20],'Value',false);
    % toggleButton3 = uitogglebutton(toggleButtonGroup, 'Text', 'Default', 'Position', [160, 5, 80, 20],'Value',true,'Visible','off');
    % 
    % 
    % % Pause the execution until a button is pressed
    % uiwait(fig);
    % 
    % 
    % % Check if any option is selected
    % if   toggleButton3.Value
    %     disp('No option selected. Exiting...');
    %     return;
    % end
    % 
    % % Continue with the rest of the code based on the selected option
    % if  toggleButton2.Value
    %     imwrite(uint8(I5) * 255,strcat(Folder2,'\','Before',TifFiles(k).name))
    %     imwrite(uint8(I8) * 255,strcat(Folder2,'\','After',TifFiles(k).name))
    % elseif  toggleButton1.Value
    %     imwrite(uint8(I8) * 255,strcat(Folder1,'\',TifFiles(k).name))
    % end
    % if(k == Range(end))
    %     close(fig)
    % end
    
end

end

% Button group selection changed callback function
function buttonGroupCallback(src, event)
% Resume the execution of the code after a button is pressed
uiresume(src.Parent);
end

