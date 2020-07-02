function [neuron,KL]=Eliminate_Misshapen(neuron,KL_thresh,data_shape,constraint_type,width_crit,gSizMax,gSizMin,filter)

%constraint_type: 'bound', 'prc'
%try
if ~exist('constraint_type','var')||isempty(constraint_type)
    constraint_type='prc';
end

if size(data_shape,1)>1;
    data_shape=squeeze(data_shape');
end
det_cov=[];
eig_ratio=[];
KL=[];
for i=1:size(neuron.A,2);
    A{i}=full(neuron.A(:,i));
end
for i=1:length(A)
    A1=A{i};
    
    A1=reshape(A1,data_shape(1),data_shape(2));
    
    thresh_indices=A1<.4*max(max(A1));
    A1(thresh_indices)=0;
    A1=imgaussfilt(A1,1);
    
    [centroid,cov]=calculateCentroid_and_Covariance(A1,data_shape(1),data_shape(2));
%det_cov(i)=det(cov);
%if isnan(det_cov(i))
%    det_cov(i)=0;
%end
%try
%eigs=eig(cov);
%eig_ratio(i)=min(abs(eigs(1)/eigs(2)),abs(eigs(2)/eigs(1)));
%catch
%    eig_ratio(i)=0;
%end
%indices_rem=[];
try 
    [X,Y]=meshgrid(1:data_shape(2),1:data_shape(1));
    X1=reshape(X,[],1);
    Y1=reshape(Y,[],1);
    

    gauss_A=mvnpdf([X1,Y1],centroid,cov);
    gauss_A=gauss_A/sum(sum(gauss_A));
    gauss_A=reshape(gauss_A,data_shape(1),data_shape(2));
    

    
    [KL(i),mass(i)]=KLDiv(gauss_A,A1);
    thresh_indices=gauss_A<.1*max(max(gauss_A));
    A1(thresh_indices)=0;
    A1=imgaussfilt(A1);
    
    A1_temp=A1;
    
    
    
    bw=A1>0;
    
    stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength');
    max_diam(i)=stats.MajorAxisLength;
    min_diam(i)=stats.MinorAxisLength;
    
catch
    KL(i)=KL_thresh+10;
end
    A{i}=reshape(A1,1,[]);
end
for i=1:length(A)
    neuron.A(:,i)=reshape(A{i},[],1);
end
neuron.A=sparse(neuron.A);
if isequal(constraint_type,'prc')
    try
        KL=(KL-mean(KL))/std(KL);
        KL_thresh=norminv(KL_thresh);
    end
end
size_thresh_rem=find(max_diam>gSizMax|min_diam<gSizMin);
%size_thresh_rem=[];

if filter==true
    indices=find(isoutlier(KL,'gesd','MaxNumOutliers',floor(.05*size(neuron.C,1))));
else
    indices=[];
end
if width_crit==true
    indices=[indices,find(isoutlier(max_diam,'gesd','MaxNumOutliers',floor(.05*size(neuron.C,1))))];

    
end

for i=1:size(neuron.A,2);
    if sum(neuron.A(:,i))<=0
        indices=[indices,i];
    end
end
indices=[indices,size_thresh_rem];
try
    neuron.P.kernel_pars(indices)=[];

end
try
    neuron.P.sn_neuron(indices)=[];
end
try
    neuron.combined(indices,:)=[];
    neuron.scores(indices,:)=[];
catch
    'display no error';
end
try
    neuron.overlap_corr(indices,:)=[];
    neuron.overlap_KL(indices,:)=[];
catch
    'no error';
end
neuron.A(:,indices)=[];
neuron.C(indices,:)=[];
neuron.C_raw(indices,:)=[];
neuron.S(indices,:)=[];
% catch
%     KL=0;
%     disp('Eliminate_Misshapen Failed')
%     neuron=neuron;
% end