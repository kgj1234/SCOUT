function distance_matrix=construct_distance_matrix(pair_aligned,probabilities)
n1=max(pair_aligned(:,1));
n2=max(pair_aligned(:,2));
distance_matrix=sparse([]);
for i=1:size(pair_aligned,1)
    distance_matrix(pair_aligned(i,1),pair_aligned(i,2)+n1)=probabilities(i);
    distance_matrix(n1+pair_aligned(i,2),pair_aligned(i,1))=probabilities(i);
end
%for i=1:n1+n2
%    distance_matrix(i,i)=1;
%end