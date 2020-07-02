function MC=maximal_connected_components(neuron,MC,gsiz,C_corr,merge_thr)

    neuron.updateCentroid()
centroid_dist=pdist2(neuron.centroid,neuron.centroid);
n=size(MC,2);
for j=1:n
    ind=find(MC(:,j));
    if length(ind)==1
        continue
    end
    axis_length=[];
    for k=1:length(ind)
       bw=reshape(neuron.A(:,ind(k)),neuron.imageSize(1),neuron.imageSize(2))>0;
       stats=regionprops(full(bw),'MajorAxisLength');
       MajorAxisLength={stats.MajorAxisLength};
       axis_length(k)=sum(MajorAxisLength{1});
    end
    max_dist=gsiz/2-axis_length/2;
    ind(max_dist<0)=[];
    group_corr=C_corr(ind,ind);
    group_dist=centroid_dist(ind,ind);
    for l=1:length(ind)
        group_corr(l,group_dist(l,:)>max_dist(l))=0;
    end
        
    groups={};
    total=1;
    while max(max(group_corr))>merge_thr(2)
        [M,I]=max(reshape(group_corr,1,[]));
        [a,b]=ind2sub([length(ind),length(ind)],I);
        groups{total}=[a,b];
        while true
            curr_avail=min(group_corr(groups{total},:)>0,[],1);
            curr_avail=find(curr_avail);
            if isempty(curr_avail)
                break
            end
            [M,I]=max(max(group_corr(groups{total},curr_avail),[],1));
            if M>merge_thr(2)
            groups{total}(end+1)=curr_avail(I);
            else
                break
            end
        end
        group_corr(groups{total},:)=0;
        group_corr(:,groups{total})=0;
        total=total+1;
    end
    for k=1:length(groups)
        groups{k}=ind(groups{k});
        MC(groups{k},end+1)=1;
    end
    
end
for i=1:n
    MC(:,1)=[];
end
            
            
            
        
       