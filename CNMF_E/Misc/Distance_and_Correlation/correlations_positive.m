function correlations=correlations_positive(neuron1,neuron2,type)
if ~exist('type','var')||isempty(type)
    type='spearman';
end

    
if ~isequal(type,'S')
    if ismatrix(neuron1)
        C1=neuron1;
        C2=neuron2;
    else
        C1=neuron1.C;
        C2=neuron2.C;
    end
   
        
correlations=zeros(size(C1,1),size(C2,1));

%correlations_binary=zeros(size(C1,1),size(C2,1));
for k=1:size(C1,1)*size(C2,1)
%for k=3671
        [i,j]=ind2sub([size(C1,1),size(C2,1)],k);
        avail_ind=1:size(C1,2);
      
        corrs=zeros(1,15);
        for l=1:5
        indices1=C1(i,:)>=.5^(3*(l));
        outliers=isoutlier(avail_ind(indices1));
        indices1(outliers)=0;
        range=min(find(indices1)):max(find(indices1));
        indices1(range)=1;
        indices2=C2(j,:)>=.5^l;
        outliers=isoutlier(avail_ind(indices2));
        indices2(outliers)=0;
        range=min(find(indices2)):max(find(indices2));
        indices2(range)=1;
        
        
        indices=find(indices1&indices2);
       
                
        %if length(indices)>0
        %    correlations(k)=max(corr(C1(i,indices)',C2(j,indices)','type',type),corr(C1(i,:)',C2(j,:)','type',type));
            
        %else
            if length(indices)>0
            corrs(l)=corr(C1(i,indices)',C2(j,indices)','type',type);
            else
                corrs(l)=1;
            end
            indices1=C1(i,:)>=.5^(3*(l));
        
        indices2=C2(j,:)>=.5^(3*l);
        
        
        indices=find(indices1&indices2);
        try
            corrs(l)=max(corrs(l),corr(C1(i,indices)',C2(i,indices)','type',type));
        end
        end
        correlations(k)=max(corrs);
        %end
        %indices1=C1(i,:)>.1*max(C1(i,:));
        %indices2=C2(j,:)>.1*max(C2(j,:));
        %indices=find(indices1|indices2);
        %C1_binary=zeros(1,length(indices1));
        %C1_binary(indices1)=1;
        %C2_binary=zeros(1,length(indices2));
        %C2_binary(indices2)=1;
        %if length(indices)>0
        %    correlations_binary(k)=corr(C1_binary',C2_binary');
        %end
        
end
else
    if ismatrix(neuron1)
        S1=neuron1;
        S2=neuron2;
    else
        S1=neuron1.S;
        S2=neuron2.S;
    end
    %correlations=zeros(size(S1,1),size(S2,1));
    %for k=1:size(S1,1)*size(S2,1)

        %[i,j]=ind2sub([size(S1,1),size(S2,1)],k);
     
        for k=1:size(S1,1)
        indices1=S1(k,:)>0;
        std1(k)=std(S1(k,indices1));
        if std1(k)==0
            std1(k)=1;
        end
     end
     for k=1:size(S2,1)
        
        indices2=S2(k,:)>0;
        std2(k)=std(S2(k,indices2));
        if std2(k)==0
            std2(k)=1;
        end
     end
     
        S1=imgaussfilt(S1,10,'FilterSize',[1,99])./std1';
        S2=imgaussfilt(S2,10,'FilterSize',[1,99])./std2';
       
        correlations=corr(S1',S2','type','pearson');
        
      
 
    end
end
