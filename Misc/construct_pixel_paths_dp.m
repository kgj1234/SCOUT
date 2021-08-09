function df=construct_pixel_paths_dp(image,max_comp,max_dist)
df=-1*ones(size(image,1),size(image,2));
for i=1:length(max_comp)
    df(max_comp{i})=i;
end

bw=df>0;
D=bwdist(bw);
df(D>max_dist)=0;
df(image<=0)=0;

while sum(sum(df==-1))>0
    temp_image=image;
    temp_image(df~=-1)=0;
 
    [i,j]=argmax_2d(temp_image);
      
     df=construct_pixel_paths(df,[i,j],size(image),image,[]);
       
   
end


end






function df=construct_pixel_paths(df,index,image_size,image,used)
if df(index(1),index(2))~=-1
    return
end
neighbors=[];
neighbors=[[index(1)-1,index(2)];[index(1)+1,index(2)];...
    [index(1),index(2)-1];[index(1),index(2)+1]];

neighbors(neighbors(:,1)<1,:)=[];
neighbors(neighbors(:,2)<1,:)=[];
neighbors(neighbors(:,1)>image_size(1),:)=[];
neighbors(neighbors(:,2)>image_size(2),:)=[];
if ~isempty(used)
neighb_ind=sub2ind(size(image),neighbors(:,1),neighbors(:,2));

used_ind=sub2ind(size(image),used(:,1),used(:,2));
unused=setdiff(neighb_ind,used_ind);
[neighbors_a,neighbors_b]=ind2sub(size(image),unused);
neighbors=[neighbors_a,neighbors_b];
end
values=[];
for k=1:size(neighbors,1)
    values(k)=image(neighbors(k,1),neighbors(k,2));
end
curr_val=image(index(1),index(2));
[values,srt]=sort(values,'descend');
neighbors=neighbors(srt,:);
neighbors(values<max(curr_val,0),:)=[];


if length(neighbors)==0
    df(index(1),index(2))=0;
end

for k=1:size(neighbors,1)
    if df(neighbors(k,1),neighbors(k,2))==-1
        
        df=construct_pixel_paths(df,neighbors(k,:),image_size,image,[used;index]);
    end
    if df(neighbors(k,1),neighbors(k,2))>0
        df(index(1),index(2))=df(neighbors(k,1),neighbors(k,2));
        break
    end
end
if df(index(1),index(2))==-1
    df(index(1),index(2))=0;
end
end
    

