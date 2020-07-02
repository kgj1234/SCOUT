function [centroid,cov]=calculateCentroid_and_Covariance(A_individual,height,width)
if size(A_individual,1)==1 ||size(A_individual,2)==1
    zero_indices=A_individual<.3*max(A_individual);
    A_individual(zero_indices)=0;
    A_individual=reshape(A_individual,[height,width]);
end
height=size(A_individual,1);
width=size(A_individual,2);
A_individual=A_individual/sum(sum(A_individual));
centroid=zeros(1,2);
temp=find(A_individual>0);
for l=1:length(temp)
    [i,j]=ind2sub([height,width],temp(l));
     centroid=centroid+[j,i]*A_individual(i,j);
    
end


cov(1,1)=0;
cov(2,2)=0;
cov(1,2)=0;
for i=1:height
    for j=1:width
        cov(1,1)=cov(1,1)+A_individual(i,j)*(j-centroid(1))^2;
        cov(1,2)=cov(1,2)+A_individual(i,j)*(j-centroid(1))*(i-centroid(2));
        cov(2,2)=cov(2,2)+A_individual(i,j)*(i-centroid(2))^2;
    end
end

cov(2,1)=cov(1,2);

