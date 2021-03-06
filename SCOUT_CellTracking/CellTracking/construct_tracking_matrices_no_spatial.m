function [aligned_neurons,aligned_probabilities]=...
    construct_tracking_matrices_no_spatial(aligned,probabilities,size_vec,min_prob,distance_metrics)


disp('Constructing Initial Tracking Matrices')

%Construct initial cell tracking matrix
[aligned_neurons,aligned_probabilities]=...
    align_neurons_pairwise(aligned,probabilities,size_vec);


%fill in missed neurons
fill_in_iter=2;
for j=1:fill_in_iter
    
    

pair_aligned={};
for k=1:length(aligned)-1
    pair_aligned{k}=aligned{k,k+1};
end
disp('Attempting To Fill In Gaps')
try
[aligned_neurons,aligned_probabilities]=...
    align_neurons_fill_in(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,min_prob);

end

%Update and order tracking matrices and probabilities
for k = 0: length(distance_metrics)
    curr_ind=find(sum(iszero(aligned_neurons),2)==k);
    
    aligned_temp{k+1}=aligned_neurons(curr_ind,:);
    aligned_prob_temp{k+1}=aligned_probabilities(curr_ind,:);
    
end

aligned_neurons=vertcat(aligned_temp{:});
aligned_probabilities=vertcat(aligned_prob_temp{:});




end
    



for k=0:length(distance_metrics)
    curr_ind=find(sum(iszero(aligned_neurons),2)==k);
    
    aligned_temp{k+1}=aligned_neurons(curr_ind,:);
    aligned_prob_temp{k+1}=aligned_probabilities(curr_ind,:);
    
end

aligned_neurons=vertcat(aligned_temp{:});
aligned_probabilities=vertcat(aligned_prob_temp{:});
