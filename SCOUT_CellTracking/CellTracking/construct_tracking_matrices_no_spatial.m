function [aligned_neurons,aligned_probabilities]=...
    construct_tracking_matrices_no_spatial(aligned,probabilities,size_vec,min_prob)


disp('Constructing Initial Tracking Matrices')

%Construct initial cell tracking matrix
[aligned_neurons,aligned_probabilities]=...
    align_neurons_pairwise(aligned,probabilities,size_vec);


%fill in missed neurons
fill_in_iter=2;
for j=1:fill_in_iter
    
    

pair_aligned={};
for k=1:length(aligned)
    pair_aligned{i}=aligned{i,i+1};
end
disp('Attempting To Fill In Gaps')
try
[aligned_neurons,aligned_probabilities]=...
    align_neurons_fill_in(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,min_prob);

end

%Update and order tracking matrices and probabilities
for i=0:length(distance_metrics)
    curr_ind=find(sum(iszero(aligned_neurons),2)==i);
    
    aligned_temp{i+1}=aligned_neurons(curr_ind,:);
    aligned_prob_temp{i+1}=aligned_probabilities(curr_ind,:);
    
end

aligned_neurons=vertcat(aligned_temp{:});
aligned_probabilities=vertcat(aligned_prob_temp{:});




end
    



for i=0:length(distance_metrics)
    curr_ind=find(sum(iszero(aligned_neurons),2)==i);
    
    aligned_temp{i+1}=aligned_neurons(curr_ind,:);
    aligned_prob_temp{i+1}=aligned_probabilities(curr_ind,:);
    
end

aligned_neurons=vertcat(aligned_temp{:});
aligned_probabilities=vertcat(aligned_prob_temp{:});
