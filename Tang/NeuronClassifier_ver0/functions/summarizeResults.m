function [per_neuron_results] = summarizeResults(per_neuron_results, Classified_processes, pix_size, k, error_code)
%Summarize_per_neuron summarizes relevant parameters for individual neurons
%   Input: existing matrix of results, Classified processes, pixel size,
%   iteration, error_code ('all fine', 'excluded', 'no soma', 'no neurites'
%   Output: appended matrix of results

% check if any known problem is detected
switch error_code
    case 'all fine'
        %1st and 2nd dendrite num
        per_neuron_results{k,1} = size(Classified_processes.NeuriteBranches{1}, 1);
        per_neuron_results{k,2} = size(Classified_processes.NeuriteBranches{2}, 1);

        %No of tips
        per_neuron_results{k,3} = 0;
        NumNeuriteBranches = find(~cellfun(@isempty, Classified_processes.NeuriteBranches));
        for ii = 1:NumNeuriteBranches
            per_neuron_results{k,3} = per_neuron_results{k,3} + size(Classified_processes.NeuriteBranches{ii}, 1);
        end

        % dendrite_length
        len = 0;
        % len2 = 0;Str = "";
        for ii = 1:length(Classified_processes.Neurites)
           Dendrite = Classified_processes.Neurites{ii};
           [r,c] = find(bwmorph(Dendrite,'endpoints'));
           lennow = pix_size * CalculateLength(Dendrite, 'Method','geodesic', 'Seed',[r(1),c(1)]);
           %Test(Dendrite);
           len = len + lennow;
           % len2now = pix_size * CalculateLength(Dendrite);
           % len2 = len2 + len2now;
           % 
           % Str = strcat(Str, sprintf("gdf:%f, para:%f. ", lennow, len2now));
        end            
        per_neuron_results{k,4} = len;
        per_neuron_results(k,5) = {Classified_processes.Image_name};
        per_neuron_results(k,6) = {Classified_processes.TimestampStart};
        per_neuron_results(k,7) = {Classified_processes.TimestampEnd};  
        per_neuron_results(k,8) = {NaN};

        % % Dendrite branches
        % dendrite_branch_points = 0;
        % %dendrite_branch_length = 0;
        % dendrite_branch_length = len;
        % for l = 2:length(find((cellfun(@isempty, Classified_processes.NeuriteBranches)) == 0))
        %     num = size(Classified_processes.NeuriteBranches{l},1);
        %     dendrite_branch_points = dendrite_branch_points + num(1);
        % 
        %     WholeBranches = cell2mat(Classified_processes.NeuriteBranches{l});
        %     [Row, Column] = find(bwmorph(WholeBranches, "endpoints"));
        %     for ii = 1:length(Row)
        %         len = CalculateLength(WholeBranches, 'Method', 'geodesic', 'Seed', [Row(ii), Column(ii)]);
        %         dendrite_branch_length = dendrite_branch_length + pix_size *len/2;
        %     end
        % end

    case 'excluded'
        % how is k dealt with here? or with the others?
        per_neuron_results(k,2) = {'NA'};
        per_neuron_results(k,3) = {'NA'};
        per_neuron_results(k,4) = {NaN};
        per_neuron_results(k,5) = {NaN};
        per_neuron_results(k,6) = {NaN};
        per_neuron_results(k,7) = {NaN};
        per_neuron_results(k,8) = {'Excluded after segmentation'};

    case 'no soma'
        % no soma detected -> nothing summarized
        per_neuron_results(k,2) = {Classified_processes.TimestampStart};
        per_neuron_results(k,3) = {Classified_processes.TimestampEnd};
        per_neuron_results(k,4) = {NaN};
        per_neuron_results(k,5) = {NaN};
        per_neuron_results(k,6) = {NaN};
        per_neuron_results(k,7) = {NaN};   
        per_neuron_results(k,8) = {'No soma detected'};

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
        per_neuron_results(k,8) = {'No neurites detected'};
end

% Headers
header = {'No_of_primary_dendrite', 'No_of_secondary_dendrite', 'No_of_tips', 'Total_length', 'NeuronIndex', 'TimeStart', 'TimeEnd','Comment'};
per_neuron_results.Properties.VariableNames = header;

end

