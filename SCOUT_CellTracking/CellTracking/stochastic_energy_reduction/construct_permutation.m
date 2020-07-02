function permutation=construct_permutation(initial_aligned,best_aligned)
permutation=zeros(2,size(initial_aligned,1));
for i=1:size(permutation,2)
    ind=find(best_aligned(:,2)==initial_aligned(i,2));
    permutation(1,i)=initial_aligned(i,1);
    if ~isempty(ind)
    permutation(2,i)=best_aligned(ind,1);
    end
end
