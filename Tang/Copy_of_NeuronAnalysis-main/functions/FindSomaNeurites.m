function [Neurites, newSkel, axon, newEndPoints] = FindSomaNeurites(inputSkl, cBody, prevEndPoints, MIN_LEN)     %% ps = [endPoints; branchPoints]
%FindSomaNeurites finds all longest paths originating from soma and returns
%the longest as the axon


%% find starting points on Soma
% remove cell body
noBody = inputSkl  & ~imerode(cBody,  strel('disk',1)); % imerode to make sure dendrites get a start point

% more stable via bodyBorderPoints, it adds more computation but fails less
NeuriteStartPoints = find(bwmorph(cBody, 'endpoints'));

% remove start points outside the skeleton
NeuriteStartPoints = intersect(NeuriteStartPoints, find(noBody));


Neurites = cell(size(NeuriteStartPoints));
newEndPoints = zeros(size(NeuriteStartPoints));


%% for each starting point find longest path in skeleton
disp('finding neurites');
for k = flip(1:nnz(NeuriteStartPoints)) % going backwards (in case one is removed)

    [Neurites{k}, newEndPoints(k), noBody] = findLongestConnected(NeuriteStartPoints(k), noBody);

    len = nnz(Neurites{k});

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
[newSkel, Neurites, newEndPoints ] = fixOverlap(newSkel, NeuriteStartPoints, Neurites, newEndPoints, MIN_LEN );


%% classify as axon & dendrites

axon_len = [0, 0];
axon =  cell(1, 2);
axonIndex = [0,0];

for k = flip(1:size(Neurites)) % going backwards (in case one is removed)
    len = nnz(Neurites{k});
    % if len > axon_len(1)    % find the longest one
    %     if(axon_len(1)~=0)
    %         %Replace axon2 by existed axon1
    %         axon{2} = axon{1};
    %         axon_len(2) = axon_len(1);
    %         axonIndex(2) = axonIndex(1);
    %     end
    % 
    %     axon{1} = Neurites{k};
    %     axon_len(1) = len;
    %     axonIndex(1) = k;
    % 
    % elseif( len > axon_len(2))
    %     axon{2} = Neurites{k};
    %     axon_len(2) = len;
    %     axonIndex(2) = k;
    % end

    % also remove already classified parts from skeleton now
    if ~isempty(Neurites{k})
        newSkel = newSkel & ~Neurites{k};
    end
end


% remove axon from Neurites{} and treat rest as Dendrites
% axonIndex = sort(axonIndex);
% for ii = flip(1:length(axonIndex))
% Neurites{axonIndex(ii)} = [];
% Neurites = Neurites(~cellfun('isempty',Neurites));
% 
% newEndPoints = setdiff(prevEndPoints, newEndPoints);
% end



end