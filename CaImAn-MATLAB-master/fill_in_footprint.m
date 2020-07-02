function ai=fill_in_footprint(ai,min_neighbors,max_iter);


centroid=calculateCentroid(ai,size(ai));
positive_ind=find(ai>0);
[positive_ind_sub(:,1),positive_ind_sub(:,2)]=ind2sub(size(ai),positive_ind);
dists=pdist2(positive_ind_sub,centroid);
max_dist=max(dists);
total_index=1:size(ai,1)*size(ai,2);
[total_index_sub(:,1),total_index_sub(:,2)]=ind2sub(size(ai),total_index);
dists=pdist2(total_index_sub,centroid);
fill_in_pixels=setdiff(total_index(dists<max_dist),positive_ind);
iter=0;
while iter<max_iter || min(min(ai(fill_in_pixels)))==0

% zero_ind=find(ai==0);
% bw=ai>0;
% neighbors=zeros(size(ai));
% for k=1:length(ai(:));
%     [i,j]=ind2sub(size(ai),k);
%     rsub=max(1,i-1):min(size(ai,1),i+1);
%     csub=max(1,j-1):min(size(ai,2),j+1);
%     [cind, rind] = meshgrid(csub, rsub);
%     neigh_ind=sub2ind(size(ai),rind(:),cind(:));
%     neighbors(k)=sum(bw(neigh_ind));
% end
% fill_in_pixels=intersect(zero_ind,find(neighbors>=min_neighbors|bwconvhull(bw)>0));
for k=1:length(fill_in_pixels)

     [r,c]=ind2sub(size(ai),fill_in_pixels(k));
    rsub=max(1,r-1):min(size(ai,1),r+1);
    csub=max(1,c-1):min(size(ai,2),c+1);
    [cind, rind] = meshgrid(csub, rsub);
    neigh_ind=sub2ind(size(ai),rind(:),cind(:));
%     neigh_ind=[r-1,c;r+1,c;r,c-1;r,c+1];
%     neigh_ind(neigh_ind(:,1)<1|neigh_ind(:,1)>size(ai,1),:)=[];
%      neigh_ind(neigh_ind(:,2)<1|neigh_ind(:,2)>size(ai,2),:)=[];
%       neigh_ind=sub2ind(size(ai),neigh_ind(:,1),neigh_ind(:,2));
    ai(fill_in_pixels(k))=sum(ai(neigh_ind))/length(neigh_ind);
    iter=iter+1;
end
end

        


