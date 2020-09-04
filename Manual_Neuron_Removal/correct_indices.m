function base_indices=correct_indices(base_indices,removed_indices)
for i=1:length(removed_indices)
    ind=find(base_indices>=removed_indices(i));
    base_indices(ind)=base_indices(ind)+1;
end