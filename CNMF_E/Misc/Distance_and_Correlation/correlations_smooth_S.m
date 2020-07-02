function correlations=correlations_smooth_S(S1,S2,type)
if ~exist('type','var')||isempty(type)
    type='spearman';
end
correlations=zeros(size(S1,1),size(S2,1));

for k=1:size(S1,1)*size(S2,1)

        [i,j]=ind2sub([size(S1,1),size(S2,1)],k);
        indices1=S1(i,:)>0;
        std1=std(S1(i,indices1));
        
        indices2=S2(j,:)>0;
        std2=std(S2(j,indices2));
        
        
       
        correlations(k)=corr(gaussian_smooth(S1(i,:)/std1)',gaussian_smooth(S2(j,:)/std2)','type',type);
        
      
 
end
