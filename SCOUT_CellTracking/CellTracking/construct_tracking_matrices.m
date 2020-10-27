function [aligned_neurons,aligned_probabilities]=construct_tracking_matrices(aligned,probabilities,...
    min_prob,chain_prob,dist_vals,max_sess_dist,size_vec,method,penalty,max_gap,max_pixel_dist,distance_metrics)


disp('Tracking Using Spatial Criterion')
%Update chains based on probabilities between all recording pairs
for k=1:length(size_vec)
    avail{k}=1:size_vec(k);
end
aligned_neurons=[];
aligned_probabilities=[];
for k=1:length(avail)
    while length(avail{k})>0
    
        [temp_aligned,temp_probabilities,avail]=construct_aligned_neuron_graph(aligned,...
            probabilities,avail{k}(1),k,avail,size_vec,dist_vals,min_prob,...
            [],penalty,max_sess_dist,chain_prob,max_gap,max_pixel_dist,distance_metrics);
        aligned_neurons=[aligned_neurons;temp_aligned];
        aligned_probabilities=[aligned_probabilities;temp_probabilities];
    end

end
