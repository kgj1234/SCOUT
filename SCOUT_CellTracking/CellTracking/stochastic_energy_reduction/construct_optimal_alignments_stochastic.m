function distance_matrix=construct_optimal_alignments_stochastic(dimensions,distance_matrix,penalty)
n1=dimensions(1);
initial_aligned=construct_greedy_alignments(dimensions,distance_matrix(1:n1,n1+1:end));
initial_energy=0;
for i=1:size(initial_aligned,1)
    initial_energy=initial_energy+1-distance_matrix(initial_aligned(i,1),initial_aligned(i,2));
end
initial_energy=initial_energy+(n1-size(initial_aligned,1))*(1-penalty);

total_vals=full(sum(distance_matrix>0,'all')/2);
iterations=min(150*dimensions(1),1000);
best_aligned=initial_aligned;
min_energy=initial_energy;
for ii=1:iterations
    remove_val=floor(exprnd(total_vals/3));
    if remove_val>total_vals/3 || remove_val<1
        remove_val=1;
    end
    dist_mat_temp=distance_matrix;
   
    dist_mat_temp=dist_mat_temp(1:n1,n1+1:end);
    [jj,kk]=find(dist_mat_temp);
    del_ind=randperm(total_vals,remove_val);
    for i=1:length(del_ind)
        dist_mat_temp(jj(del_ind(i)),kk(del_ind(i)))=0;
    end
    aligned=construct_greedy_alignments(dimensions,dist_mat_temp);
    curr_energy=0;
    for i=1:size(aligned,1)
        curr_energy=curr_energy+(1-distance_matrix(aligned(i,1),aligned(i,2)));
    end
    curr_energy=curr_energy+(n1-size(aligned,1))*(1-penalty);
    
    if curr_energy<min_energy
        min_energy=curr_energy;
        best_aligned=aligned;
    end
end




best_aligned(:,2)=best_aligned(:,2)-n1;    
initial_aligned(:,2)=initial_aligned(:,2)-n1;
permutation=construct_permutation(initial_aligned,best_aligned);
distance_matrix(1:n1,n1+1:end)=update_distance_matrix(distance_matrix(1:n1,n1+1:end),permutation,best_aligned);
distance_matrix(n1+1:end,1:n1)=distance_matrix(n1+1:end,1:n1);

