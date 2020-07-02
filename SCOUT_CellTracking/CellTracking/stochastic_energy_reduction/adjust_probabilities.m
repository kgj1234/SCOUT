function probabilities=adjust_probabilities(aligned_neurons,aligned_neurons_old,pair_aligned,probabilities)
aligned_neurons(sum(isnan(aligned_neurons),2)>0,:)=[];
aligned_neurons_old(sum(isnan(aligned_neurons_old),2)>0,:)=[];
dist=pdist2(aligned_neurons,aligned_neurons_old);
minim=min(dist,[],2);
changed_indices=find(minim>0);
for i=1:length(changed_indices)
    index1=find(pair_aligned(:,1)==aligned_neurons(changed_indices(i),1));
    index2=find(pair_aligned(index1,2)==aligned_neurons(changed_indices(i),2));
    [M,I]=max(probabilities(index1));