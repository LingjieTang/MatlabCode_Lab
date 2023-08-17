function [Neurites, newSkel, axon, newEndPoints] = FindSomaNeurites(inputSkl, cBody, prevEndPoints, MIN_LEN, gap_size_pixel, ClassifyModel)     %% ps = [endPoints; branchPoints]
%FindSomaNeurites finds all longest paths originating from soma and returns
%the longest as the axon


%% find starting points on Soma
% remove cell body
noBody = inputSkl  & ~imerode(cBody,  strel('disk',2)); % imerode to make sure dendrites get a start point

% more stable via bodyBorderPoints, it adds more computation but fails less
NeuriteStartPoints = find(bwmorph(cBody, 'endpoints'));
NeuriteStartPoints2 = find(bwmorph(bwmorph(cBody, 'spur'), 'endpoints'));


% remove start points outside the skeleton
NeuriteStartPoints = intersect(NeuriteStartPoints, find(noBody));
NeuriteStartPoints2 = intersect(NeuriteStartPoints2, find(noBody));
NeuriteStartPoints = union(NeuriteStartPoints, NeuriteStartPoints2);


Neurites = cell(size(NeuriteStartPoints));
newEndPoints = zeros(size(NeuriteStartPoints));


%% for each starting point find longest path in skeleton
disp('finding neurites');

% %Refine 'noBody'
% endPoints= find(bwmorph(noBody,'endpoints'));
% [endPointsR,  endPointsC] =  ind2sub(size(noBody), endPoints);
% [NeuriteStartPointsR, NeuriteStartPointsC] =  ind2sub(size(noBody), NeuriteStartPoints);
% 
% for xx = 1:length(endPoints)
%     Distance = [endPointsR(xx), endPointsC(xx)] - [NeuriteStartPointsR, NeuriteStartPointsC];
%     MaxAbsDistance = max(abs(Distance(:,1)), abs(Distance(:,2)));
%      %If the endpoint is a startpoint, or the distance to all start points >
%     %2 pixels, skip it
%     while (~ismember(endPoints(xx), NeuriteStartPoints) && any(MaxAbsDistance<=2))
%         noBody(endPoints(xx)) = false;
%         endPoints= find(bwmorph(noBody,'endpoints'));
%     end  
% end
% NeuriteStartPoints = intersect(NeuriteStartPoints,  find(bwmorph(noBody,'endpoints')));

for k = flip(1:nnz(NeuriteStartPoints)) % going backwards (in case one is removed)

    [Neurites{k}, newEndPoints(k), noBody] = findLongestConnected(NeuriteStartPoints(k), noBody);

    r = mod(NeuriteStartPoints(k), size(noBody,2));
    c = ceil(NeuriteStartPoints(k)/size(noBody,2));
    len = CalculateLength(Neurites{k},'Method','geodesic','Seed', [r,c]);
    %len = nnz(Neurites{k});

    % if length of Neurites{k} < MIN_LEN) -> remove path (& endpoint)
    if  len < MIN_LEN
        noBody = noBody & ~Neurites{k};
        Neurites{k} = [];
        % remove endpoints
        prevEndPoints = setdiff(prevEndPoints, newEndPoints(k));
        newEndPoints(k) = [];
    end


end

%% Test for overlap and fix if there is
newSkel = noBody;
disp('refining neurites');
[newSkel, Neurites, newEndPoints ] = fixOverlap(newSkel, NeuriteStartPoints, Neurites, newEndPoints, MIN_LEN, gap_size_pixel);


%% classify as axon & dendrites
switch ClassifyModel
    case '2 border or longest'
        %The neurites near the border (5% Threshold) is judged as axon
        %(max:2), if no, the longest one is judged as the axon
        axon_len = [0, 0];
        axon =  cell(1, 2);
        axonIndex = [0,0];

        neurites_longest = 0;
        longest_index = 0;

        Threshold = 0.066;
        xThreshold = [Threshold, (1-Threshold)]*size(Neurites{1}, 1);
        yThreshold = [Threshold, (1-Threshold)]*size(Neurites{1}, 2);

        for k = flip(1:size(Neurites)) % going backwards (in case one is removed)
            len = CalculateLength(Neurites{k});
            if len > neurites_longest
                neurites_longest = len;
                longest_index = k;
            end

            [r,c] = find(bwmorph(Neurites{k},'endpoints'));
            %Out of threshold, judged as axon
            if(any(r<xThreshold(1))|| any(r>xThreshold(2)) || any(c<yThreshold(1)) || any(c>yThreshold(2)))
                if len > axon_len(1)    % find the longest one
                    if(axon_len(1)~=0)
                        %Replace axon2 by existed axon1
                        axon{2} = axon{1};
                        axon_len(2) = axon_len(1);
                        axonIndex(2) = axonIndex(1);
                    end
                    axon{1} = Neurites{k};
                    axon_len(1) = len;
                    axonIndex(1) = k;

                elseif( len > axon_len(2))
                    axon{2} = Neurites{k};
                    axon_len(2) = len;
                    axonIndex(2) = k;
                end
            end
            %len = nnz(Neurites{k});
            % if len > axon_len(1)    % find the longest one
            %     if(axon_len(1)~=0)
            %         %Replace axon2 by existed axon1 axon{2} = axon{1};
            %         axon_len(2) = axon_len(1); axonIndex(2) =
            %         axonIndex(1);
            %     end
            %
            %     axon{1} = Neurites{k}; axon_len(1) = len; axonIndex(1) =
            %     k;
            %
            % elseif( len > axon_len(2))
            %     axon{2} = Neurites{k}; axon_len(2) = len; axonIndex(2) =
            %     k;
            % end

            % also remove already classified parts from skeleton now
            if ~isempty(Neurites{k})
                newSkel = newSkel & ~Neurites{k};
            end
        end

        %If no neurites is out of threshold, the longest one becomes the
        %axon
        if(axon_len(1) == 0)
            % axon_len = neurites_longest;
            axonIndex = longest_index;
            axon = cell(1,1);
            axon{1} = Neurites{axonIndex};
            %If only 1 axon is found
        elseif(axon_len(2) == 0)
            axonIndex = axonIndex(1);
            axon = axon(1);
        end

        % remove axon from Neurites{} and treat rest as Dendrites
        axonIndex = sort(axonIndex);
        for ii = flip(1:length(axonIndex))
            Neurites{axonIndex(ii)} = [];
            Neurites = Neurites(~cellfun('isempty',Neurites));

            newEndPoints = setdiff(prevEndPoints, newEndPoints);
        end

    case '1 border and longest'
        axon_len = [0, 0];
        axon =  cell(1, 2);
        axonIndex = [0,0];

        neurites_longest = 0;
        longest_index = 0;

        Threshold = 0.066;
        xThreshold = [Threshold, (1-Threshold)]*size(Neurites{1}, 1);
        yThreshold = [Threshold, (1-Threshold)]*size(Neurites{1}, 2);

        for k = flip(1:size(Neurites)) % going backwards (in case one is removed)
            len = CalculateLength(Neurites{k});

            [r,c] = find(bwmorph(Neurites{k},'endpoints'));
            %Out of threshold, judged as axon
            if(any(r<xThreshold(1))|| any(r>xThreshold(2)) || any(c<yThreshold(1)) || any(c>yThreshold(2)))
                if len > axon_len(1)    % find the border one
                    axon{1} = Neurites{k};
                    axon_len(1) = len;
                    axonIndex(1) = k;
                end

            elseif(len > neurites_longest)
                    neurites_longest = len;
                    longest_index = k;
                    axon{2} = Neurites{k};
                    axon_len(2) = neurites_longest;
                    axonIndex(2) = longest_index;
            end
          
            % also remove already classified parts from skeleton now
            if ~isempty(Neurites{k})
                newSkel = newSkel & ~Neurites{k};
            end
        end

        % remove axon from Neurites{} and treat rest as Dendrites
        axonIndex = sort(axonIndex);
        for ii = flip(1:length(axonIndex))
            Neurites{axonIndex(ii)} = [];
            Neurites = Neurites(~cellfun('isempty',Neurites));

            newEndPoints = setdiff(prevEndPoints, newEndPoints);
        end
    case 'no axon'
         axon =  cell(1, 2);
end



end