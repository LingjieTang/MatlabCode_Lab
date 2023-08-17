function [newSkel, Branches, endPoint ] = fixOverlap(newSkel, StartPoints, Branches, endPoint, MIN_LEN, gap_size_pixel)
%fixOverlap tests for overlapping branches, keeps longest one and redetects
%new path for other starting point

% find overlapping parts (even if more than two branches overlap)
FlatBranch = Branches(~cellfun('isempty',Branches));
NeuriteMat = zeros(size(newSkel));
for m = 1:size(FlatBranch)
    NeuriteMat = NeuriteMat + FlatBranch{m};
end

%find largest overlap
overlapMax = max(NeuriteMat(:));

tempBranches = cell(size(Branches));


while overlapMax > 1
    % find longest path and remove it from skeleton
    [~, index] = max(cellfun(@nnz, Branches));
    tempBranches{index} = Branches{index};

    %%     Do not delete skeleton near branch points
    Branchpoints = bwmorph(newSkel, 'branchpoints') & Branches{index};
    % Branchpoints_backup = Branchpoints;
    [Row, Column] = find(Branchpoints);
    if(~isempty(Row))
        RowColumn = sortrows([Row, Column]);
        Branchpoints_dist2end = zeros(length(Row), 1);
        for ii = 1:length(Row)
            seed = RowColumn(ii, :);
            Branchpoints_dist2end(ii) = CalculateLength(Branches{index}, 'Method','geodesic','Seed',seed);
        end
        [Branchpoints_dist2end, SortIndex] = sort(Branchpoints_dist2end);
        RowColumn = RowColumn(SortIndex,:);
        dist2end = [gap_size_pixel;diff(Branchpoints_dist2end)];

        if(length(Row)>=2)
            for ii = 2:length(Row)
                if(dist2end(ii) < gap_size_pixel)
                    Branchpoints_gap = zeros(size(Branches{index}));
                    xmin = min(RowColumn(ii-1,1), RowColumn(ii,1));
                    xmax = max(RowColumn(ii-1,1), RowColumn(ii,1));
                    ymin = min(RowColumn(ii-1,2), RowColumn(ii,2));
                    ymax = max(RowColumn(ii-1,2), RowColumn(ii,2));
                    %Preclude false positive
                    if(xmax - xmin + ymax - ymin <2*gap_size_pixel)
                        Branchpoints_gap(xmin:xmax, ymin:ymax) = Branches{index}(xmin:xmax, ymin:ymax);
                        Branchpoints = Branchpoints | Branchpoints_gap;
                    end
                end
            end
        end
    end
    % for ii = 1:length(Row)-1
    %     for jj = ii+1 : length(Row)
    %         Branchpoints_distance = sum(RowColumn(jj, :) - RowColumn(ii,
    %         :)); if(Branchpoints_distance < gap_size_pixel)
    %             Branchpoints_gap = zeros(size(Branches{index}));
    %             Branchpoints_gap(RowColumn(ii,1):RowColumn(jj,1),
    %             RowColumn(ii,2):RowColumn(jj,2)) =
    %             Branches{index}(RowColumn(ii,1):RowColumn(jj,1),
    %             RowColumn(ii,2):RowColumn(jj,2)); Branchpoints =
    %             Branchpoints | Branchpoints_gap;
    %         end
    %     end
    % end
    %%
    newSkel = newSkel &~ Branches{index};
    newSkel = newSkel | Branchpoints;

    for k = flip(1:nnz(StartPoints)) % going backwards (in case one is removed)

        [Branches{k}, endPoint(k), newSkel] = findLongestConnected(StartPoints(k), newSkel);
        r = mod(StartPoints(k), size(newSkel,2));
        c = ceil(StartPoints(k)/size(newSkel,2));
        len = CalculateLength(Branches{k},'Method','geodesic','Seed', [r,c]);

        %len = nnz(Branches{k});
        % len = CalculateLength(Branches{k});

        % if length of Neurites{k} < MIN_LEN) -> remove path (& endpoint)
        if  len < MIN_LEN
            newSkel = newSkel & ~Branches{k};
            Branches{k} = [];
            endPoint(k) = [];
        end
    end

    % reassess overlap
    FlatBranch = Branches(~cellfun('isempty',Branches));
    NeuriteMat = zeros(size(newSkel));
    for m = 1:size(FlatBranch)
        NeuriteMat = NeuriteMat + FlatBranch{m};
    end

    %find largest overlap
    overlapMax = max(NeuriteMat(:));

end

% combine refined Branches
tempBranches = tempBranches(~cellfun('isempty',tempBranches));
Branches = [tempBranches; FlatBranch];



%% previous overlap detection
% sensitive to cases with >2 paths overlapping but much faster

%     for k = flip(1:(nnz(StartPoints)))
%
%         if isempty(Branches{k})
%             continue
%         else
%             % display(k); for j = flip(1:(nnz(StartPoints)-1))
%                 if isempty(Branches{j}) || isempty(Branches{k})
%                     continue
%                 elseif j == k % skip comparison to same neurite
%                     continue
% %                 elseif Branches{j} == Branches{k} % if two neurites are
% identical %                     Branches{k} = []; % delete currently
% checked Neurite
%                 else
%
%                 % find number of intersecting pixels n =
%                 numel(intersect(find(Branches{k}), find(Branches{j}))); %
%                 display(j) if n > 0
%                     % find longer of the two if nnz(Branches{k}) >
%                     nnz(Branches{j})
%                        % start shorter with NeuriteStartPoints on that
%                        index newSkel = newSkel &~(Branches{k} &
%                        largestOverlap); % newSkel = newSkel &
%                        ~Branches{k};
%                         Branches{j} = []; [Branches{j}, endPoint(j),
%                         newSkel] = findLongestConnected(StartPoints(j),
%                         newSkel); len = nnz(Branches{j});
%                             % if length of Neurites{k} < MIN_LEN) ->
%                             remove path (& start point)
%                         if  len < MIN_LEN
%                             newSkel = newSkel & ~Branches{j}; Branches{j}
%                             = []; endPoint(j) = [];
%
%                        end
%
%                     else
%                         newSkel = newSkel & ~(Branches{j} &
%                         largestOverlap); % newSkel = newSkel &
%                         ~Branches{j}; Branches{k} = []; [Branches{k},
%                         endPoint(k), newSkel] =
%                         findLongestConnected(StartPoints(k), newSkel);
%                         len = nnz(Branches{k}); if  len < MIN_LEN
%                             newSkel = newSkel & ~Branches{k}; Branches{k}
%                             = []; endPoint(k) = [];
%                         end
%                     end
%                 end end
%             end
%         end
%     end
end

