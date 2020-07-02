function alignment_matrix=construct_true_alignments(neurons,C,A)
neuron=Sources2D;
%  A=reshape(A,256,256,[]);
%  A=A(20:end-19,20:end-19,:);
%  A=reshape(A,218*218,[]);
%  neuron.imageSize=[218,218];

neuron.imageSize=neurons{1}.imageSize;

neuron.C=C;
neuron.A=A;
max_dist=35;
neuron.updateCentroid();


alignment_matrix=zeros(size(C,1),length(neurons));
index=1;
threshold=.8;
for j=1:length(neurons)
    correlations=corr(C(:,index:index+size(neurons{j}.C,2)-1)',neurons{j}.C');
    dist=pdist2(neuron.centroid,neurons{j}.centroid);
    for i=1:size(C,1)
    ind=find(dist(i,:)<max_dist);
    [M,I]=max(correlations(i,ind));
    if M>threshold
        alignment_matrix(i,j)=ind(I);
    
    
    end
    end
    index=index+size(neurons{j}.C,2);
end
alignment_matrix(alignment_matrix==0)=nan;

    
    