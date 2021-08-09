function [idx] = kmedoids_cluster_constrained2(X, k,chain_prob,num_sessions,session_ids)

for l=1:max(session_ids)
    ind=find(session_ids==l);
    X(ind,ind)=-10000000;
end
for l=1:size(X,1)
    X(l,l)=1;
end

[a,b]=groupcounts(session_ids');
[M,I]=max(a);
start=find(session_ids==b(I));
if length(start)<k
    remain=setdiff(1:length(session_ids),start);
    perm=randperm(length(remain),k-length(start));
    start=[start,remain(perm)];
end

idx=randi(k,size(X,1),1);

[idx,start,k]=avg_cluster(1-X,k,idx,start,15,1,session_ids,chain_prob);
[idx,start,k]=avg_cluster(1-X,k,idx,start,15,.002,session_ids,chain_prob);
[idx,start,k]=avg_cluster_swap(1-X,k,idx,start,100,0,session_ids,chain_prob);
