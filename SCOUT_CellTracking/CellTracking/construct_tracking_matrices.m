function [aligned_neurons,aligned_probabilities]=construct_tracking_matrices(aligned,probabilities,...
    min_prob,chain_prob,dist_vals,max_sess_dist,size_vec,method,penalty,max_gap,max_pixel_dist,distance_metrics,centroids,reconstitute)


disp('Tracking Using Spatial Criterion')
%Update chains based on probabilities between all recording pairs
for k=1:length(size_vec)
    avail{k}=1:size_vec(k);
end
aligned_neurons=[];
aligned_probabilities=[];
for k=1:length(avail)-1
    avail_elements_length=cellfun(@length,avail);
    while sum(avail_elements_length==0)<=max_gap&~isempty(avail{k})
    
        [temp_aligned,temp_probabilities,avail]=construct_aligned_neuron_graph_new(aligned,...
            probabilities,avail{k}(1),k,avail,size_vec,dist_vals,min_prob,...
            [],penalty,max_sess_dist,chain_prob,max_gap,max_pixel_dist,distance_metrics,centroids);
        aligned_neurons=[aligned_neurons;temp_aligned];
        aligned_probabilities=[aligned_probabilities;temp_probabilities];
    end

end
if max_gap>=length(avail)-1
    temp_aligned=zeros(length(avail{end}),size(aligned_neurons,2));
    temp_aligned(:,end)=avail{end};
    temp_prob=ones(length(avail{end}),1);
    aligned_neurons=[aligned_neurons;temp_aligned];
    aligned_probabilities=[aligned_probabilities;temp_prob];
end

[aligned_neurons,aligned_probabilities]=...
            Remove_Repeats_adj(aligned_neurons,aligned_probabilities,...
            size_vec,true,probabilities,aligned,min_prob,dist_vals,...
        max_gap,max_sess_dist,chain_prob,reconstitute);
