function [neuron,KL]=Eliminate_Misshapen_adj(neuron,data_shape)


if size(data_shape,1)>1;
    data_shape=squeeze(data_shape');
end
det_cov=[];
eig_ratio=[];
KL=[];
for i=1:size(neuron.A,2);

A=zeros(data_shape(1),data_shape(2));
[centroid,cov]=calculateCentroid_and_Covariance(neuron.A(:,i),data_shape(1),data_shape(2));
det_cov(i)=det(cov);
eigs=eig(cov);
eig_ratio(i)=min(abs(eigs(1)/eigs(2)),abs(eigs(2)/eigs(1)));
indices_rem=[];
try 
    for j=1:data_shape(1)*data_shape(2);
    [ind1,ind2]=ind2sub(data_shape,j);  
    A(j)=mvnpdf([ind2,ind1],centroid,cov);
    end
    A1=reshape(neuron.A(:,i),data_shape(1),data_shape(2));

    A=reshape(A,1,[]);
    [KL(i),mass(i)]=KLDiv(A,A1);
    %thresh_indices=A<.1*max(max(A));
    %neuron.A(thresh_indices,i)=0;
    
catch
    indices_rem=[indices_rem,i];
end
end



for i=1:size(neuron.A,2);
    if sum(neuron.A(:,i))<=0
        indices_rem=[indices_rem,i];
    end
end



try
    neuron.P.kernel_pars(indices_rem)=[];
catch
    'display no error';
end
try
    
    neuron.combined(indices_rem,:)=[];
catch
    'display no error';
end
try
    
    neuron.scores(indices_rem,:)=[];
catch
    'display no error';
end
try
    neuron.overlap_corr(indices_rem,:)=[];
    neuron.overlap_dist(indices_rem,:)=[];
catch
    'no error';
end
try
    neuron.corr_scores(indices_rem,:)=[];
    neuron.corr_prc(indices_rem,:)=[];
    neuron.dist(indices_rem,:)=[];
    neuron.dist_prc(indices_rem,:)=[];
catch
    'no error';
end

neuron.A(:,indices_rem)=[];
neuron.C(indices_rem,:)=[];
neuron.C_raw(indices_rem,:)=[];
neuron.S(indices_rem,:)=[];


KL(indices_rem)=[];
det_cov(indices_rem)=[];
eig_ratio(indices_rem)=[];

indices_rem=[find(isoutlier(KL)),find(isoutlier(det_cov)),find(isoutlier(eig_ratio))];






try
    neuron.P.kernel_pars(indices_rem)=[];
catch
    'display no error';
end
try
    
    neuron.combined(indices_rem,:)=[];
catch
    'display no error';
end
try
    
    neuron.scores(indices_rem,:)=[];
catch
    'display no error';
end
try
    neuron.overlap_corr(indices_rem,:)=[];
    neuron.overlap_dist(indices_rem,:)=[];
catch
    'no error';
end
try
    neuron.corr_scores(indices_rem,:)=[];
    neuron.corr_prc(indices_rem,:)=[];
    neuron.dist(indices_rem,:)=[];
    neuron.dist_prc(indices_rem,:)=[];
catch
    'no error';
end

neuron.A(:,indices_rem)=[];
neuron.C(indices_rem,:)=[];
neuron.C_raw(indices_rem,:)=[];
neuron.S(indices_rem,:)=[];


KL(indices_rem)=[];
det_cov(indices_rem)=[];
eig_ratio(indices_rem)=[];

