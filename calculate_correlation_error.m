function [error,index]=calculate_correlation_error(C,A,comp_neuron,overlap,min_corr,max_num_sess)
neuron=Sources2D;
A=reshape(A,256,256,[]);
A=A(20:end-19,20:end-19,:);
A=reshape(A,218*218,[]);
neuron.imageSize=[218,218];
neuron.C=C;
neuron.A=A;
neuron.imageSize=comp_neuron.imageSize;
neuron.updateCentroid();
%temp=neuron.centroid(:,2);
%neuron.centroid(:,2)=neuron.centroid(:,1);
%neuron.centroid(:,1)=temp;
max_dist=25;
dist=pdist2(comp_neuron.centroid,neuron.centroid);
total_miss=zeros(size(comp_neuron.C,1),1);
correlations=corr(comp_neuron.C',C');

for i=1:size(correlations,1)
    match{i}=find(correlations(i,:)>min_corr);
   
end
for k=1:size(correlations,1)
    if ~isempty(match{k})
    for l=1:length(match{k})
        
        total=0;
        for j=1:max_num_sess
            try
                corrs=corr(comp_neuron.C(k,(j-1)*overlap+1:j*overlap)',C(match{k}(l),(j-1)*overlap+1:j*overlap)');
                if corrs<min_corr
                    total=total+1;
                end
            end
        end
        if total==0
            true_neuron(k)=1;
            break
        end
    end
    else
        true_neuron(k)=0;
    end
end
error=1-true_neuron;
index=find(error>0);
error=sum(error);
