function [per_neuron_results] = summarizeResults(per_neuron_results, Classified_processes, pix_size, k, error_code)
%Summarize_per_neuron summarizes relevant parameters for individual neurons
%   Input: existing matrix of results, Classified processes, pixel size,
%   iteration, error_code ('all fine', 'excluded', 'no soma', 'no neurites'
%   Output: appended matrix of results

per_neuron_results(k,1) = {Classified_processes.Image_name};

% check if any known problem is detected
switch error_code
    case 'all fine'
        per_neuron_results(k,2) = {Classified_processes.TimestampStart};
        per_neuron_results(k,3) = {Classified_processes.TimestampEnd};

        % total_neurite_length
        sklI_noSoma = Classified_processes.Initial_skeleton .* (~ bwmorph(Classified_processes.cBody,'thin',1));
        per_neuron_results(k,4) = {pix_size * nnz(sklI_noSoma)};
        %Hide Data
        per_neuron_results(k,5) = {NaN};
        per_neuron_results(k,6) = {NaN};
        per_neuron_results(k,7) = {NaN};
        per_neuron_results(k,8) = {NaN};
        per_neuron_results(k,9) = {NaN};
        per_neuron_results(k,10) = {NaN};
        per_neuron_results(k,11) = {NaN};
        per_neuron_results(k,12) = {NaN};
        per_neuron_results(k,13) = {NaN};
        per_neuron_results(k,14) = {NaN};
        % % soma_size per_neuron_results(k,5) = {pix_size * pix_size *
        % nnz(Classified_processes.cBody)}; % axon_length
        % per_neuron_results(k,6) = {pix_size *
        % nnz(Classified_processes.Axon{1})};
        %
        % % prim_branch_points prim_branch_points =
        % size(Classified_processes.AxonBranches{2});
        % per_neuron_results(k,7) = {prim_branch_points(1)}; %
        % prim_branch_length
        %
        % per_neuron_results(k,8) = {pix_size *
        % nnz(cell2mat(Classified_processes.AxonBranches{2}))};
        %
        % % sec_branch_points sec_branch_points =
        % size(Classified_processes.AxonBranches{3});
        %
        % per_neuron_results(k,9) = {sec_branch_points(1)};
        % %sec_branch_length
        %
        % per_neuron_results(k,10) = {pix_size *
        % nnz(cell2mat(Classified_processes.AxonBranches{3}))};
        %
        % %tert_branch_points tert_branch_points =
        % size(Classified_processes.AxonBranches{4});
        % per_neuron_results(k,11) = {tert_branch_points(1)};
        % %tert_branch_length per_neuron_results(k,12) = {pix_size *
        % nnz(cell2mat(Classified_processes.AxonBranches{4}))};
        %
        % % Axon branches axon_branch_points = 0; axon_branch_length = 0;
        % for l = 2:size(Classified_processes.AxonBranches)
        %     num = size(Classified_processes.AxonBranches{l});
        %     axon_branch_points = axon_branch_points + num(1); len =
        %     nnz(cell2mat(Classified_processes.AxonBranches{l}));
        %     axon_branch_length = axon_branch_length + len;
        % end
        %
        % per_neuron_results(k,13) = {axon_branch_points}; %
        % axon_branch_length per_neuron_results(k,14) = {axon_branch_length
        % * pix_size};


        % dendrite_number
        dendrite_number = size(Classified_processes.Neurites);
        per_neuron_results(k,15) = {dendrite_number(1)};
        % dendrite_length
        len = 0; len2 = 0;Str = "";
        for ii = 1:length(Classified_processes.Neurites)
          Dendrite = Classified_processes.Neurites{ii};
           [r,c] = find(bwmorph(Dendrite,'endpoints'));
           lennow = pix_size * max(max(bwdistgeodesic(Dendrite,c(1),r(1),'quasi-euclidean')));
           %Test(Dendrite);
           len = len + lennow;

           len2now = regionprops(Dendrite,'Perimeter');
           len2now = pix_size *len2now.Perimeter/2;
           len2 = len2 + len2now;

           Str = strcat(Str, sprintf("gdf:%f, para:%f. ", lennow, len2now));
        end            
        Str = strcat(Str, sprintf("  total %f,  %f", len, len2));
          per_neuron_results(k,16) = {Str};

        % Dendrite branches
        dendrite_branch_points = 0;
        dendrite_branch_length = 0;
        for l = 2:length(find((cellfun(@isempty, Classified_processes.NeuriteBranches)) == 0))
            num = size(Classified_processes.NeuriteBranches{l},1);
            dendrite_branch_points = dendrite_branch_points + num(1);

            % len = nnz(cell2mat(Classified_processes.NeuriteBranches{l}));
            len = regionprops(cell2mat(Classified_processes.NeuriteBranches{l}),'Perimeter');
            len = len.Perimeter/2;

            % % Geodesic Distance Transform:
            % [r,c] = find(bwmorph(cell2mat(Classified_processes.NeuriteBranches{l}),'endpoints'));
            %  len = max(max(bwdistgeodesic(cell2mat(Classified_processes.NeuriteBranches{l}),c(1),r(1),'quasi-euclidean')));

            dendrite_branch_length = dendrite_branch_length + len;
        end

        per_neuron_results(k,17) = {dendrite_branch_points};
        %dendrite_branch_length =
        per_neuron_results(k,18) = {dendrite_branch_length * pix_size};

        % % Total axon length per_neuron_results(k,19) = {
        % per_neuron_results{k,6} +  per_neuron_results{k,14}};
        per_neuron_results(k,19) = {NaN};
        % No comment
        per_neuron_results(k,20) = {''};
        per_neuron_results(k,4) = {per_neuron_results{k,16} + per_neuron_results{k,18}};

    case 'excluded'
        % how is k dealt with here? or with the others?
        per_neuron_results(k,2) = {'NA'};
        per_neuron_results(k,3) = {'NA'};
        per_neuron_results(k,4) = {NaN};
        per_neuron_results(k,5) = {NaN};
        per_neuron_results(k,6) = {NaN};
        per_neuron_results(k,7) = {NaN};
        per_neuron_results(k,8) = {NaN};
        per_neuron_results(k,9) = {NaN};
        per_neuron_results(k,10) = {NaN};
        per_neuron_results(k,11) = {NaN};
        per_neuron_results(k,12) = {NaN};
        per_neuron_results(k,13) = {NaN};
        per_neuron_results(k,14) = {NaN};
        per_neuron_results(k,15) = {NaN};
        per_neuron_results(k,16) = {NaN};
        per_neuron_results(k,17) = {NaN};
        per_neuron_results(k,18) = {NaN};
        per_neuron_results(k,19) = {NaN};
        per_neuron_results(k,20) = {'Excluded after segmentation'};

    case 'no soma'
        % no soma detected -> nothing summarized
        per_neuron_results(k,2) = {Classified_processes.TimestampStart};
        per_neuron_results(k,3) = {Classified_processes.TimestampEnd};
        per_neuron_results(k,4) = {NaN};
        per_neuron_results(k,5) = {NaN};
        per_neuron_results(k,6) = {NaN};
        per_neuron_results(k,7) = {NaN};
        per_neuron_results(k,8) = {NaN};
        per_neuron_results(k,9) = {NaN};
        per_neuron_results(k,10) = {NaN};
        per_neuron_results(k,11) = {NaN};
        per_neuron_results(k,12) = {NaN};
        per_neuron_results(k,13) = {NaN};
        per_neuron_results(k,14) = {NaN};
        per_neuron_results(k,15) = {NaN};
        per_neuron_results(k,16) = {NaN};
        per_neuron_results(k,17) = {NaN};
        per_neuron_results(k,18) = {NaN};
        per_neuron_results(k,19) = {NaN};
        per_neuron_results(k,20) = {'No soma detected'};

    case 'no neurites'
        per_neuron_results(k,2) = {Classified_processes.TimestampStart};
        per_neuron_results(k,3) = {Classified_processes.TimestampEnd};

        % total_neurite_length (does not depend on classification)
        sklI_noSoma = Classified_processes.Initial_skeleton .* (~ bwmorph(Classified_processes.cBody,'thin',1));
        per_neuron_results(k,4) = {pix_size * nnz(sklI_noSoma)};
        % soma_size
        per_neuron_results(k,5) = {pix_size * pix_size * nnz(Classified_processes.cBody)};

        % the rest is not summarized
        per_neuron_results(k,6) = {NaN};
        per_neuron_results(k,7) = {NaN};
        per_neuron_results(k,8) = {NaN};
        per_neuron_results(k,9) = {NaN};
        per_neuron_results(k,10) = {NaN};
        per_neuron_results(k,11) = {NaN};
        per_neuron_results(k,12) = {NaN};
        per_neuron_results(k,13) = {NaN};
        per_neuron_results(k,14) = {NaN};
        per_neuron_results(k,15) = {NaN};
        per_neuron_results(k,16) = {NaN};
        per_neuron_results(k,17) = {NaN};
        per_neuron_results(k,18) = {NaN};
        per_neuron_results(k,19) = {NaN};
        per_neuron_results(k,20) = {'No neurites detected'};
end

%1st and 2nd dendrite num
per_neuron_results(k,21) = size(Classified_processes.NeuriteBranches{2}, 1);
per_neuron_results(k,22) = size(Classified_processes.NeuriteBranches{3}, 1);

% Headers
header = {'NeuronIndex', 'TimeStart', 'TimeEnd',  'TotalNeuriteLength', 'SomaSize' , 'PrimaryAxonLength', 'PrimBranchNum' , 'PrimBranchLength', 'SecBranchNum' , 'SecBranchLength', 'TertBranchNum' , 'TertBranchLength', 'AxonBranchPoints', 'AxonBranchLength', 'DendriteNum' , 'TotalDendriteLength', 'DendBranchNum' , 'DendBranchLen', 'TotalAxonLength','Comment', '1stDenderiteNum', '2ndDendriteNum'};
per_neuron_results.Properties.VariableNames = header;




end

