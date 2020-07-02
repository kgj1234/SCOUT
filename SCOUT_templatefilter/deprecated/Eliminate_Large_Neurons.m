function Eliminate_Large_Neurons(neuron,size_thresh,prc)

if (~exist('size_thresh','var')||isempty(size_thresh))&&(~exist('prc','var')||isempty(prc))
    prc=.93;
    size_thresh=[];
end
if exist('prc','var')
    size_thresh=[];
end


sizes=sum(neuron.A>0,1);

if ~isempty(size_thresh)
    indices=find(sizes>size_thresh);
else
    try
        new_sizes=(sizes-mean(sizes))/std(sizes);
        size_thresh=norminv(prc);
        indices=find(new_sizes>size_thresh);
    catch
        indices=[];
    end
end
for i=1:size(neuron.A,2);
    if sum(neuron.A(:,i))<=0
        indices=[indices,i];
    end
end
try
    neuron.P.kernel_pars(indices)=[];
catch
    'display no error';
end
try
    neuron.combined(indices,:)=[];
    
catch
    'display no error';
end
try
    neuron.scores(indices,:)=[];
end
try
    neuron.overlap_corr(indices,:)=[];
    neuron.overlap_dist(indices,:)=[];
catch
    'no error';
end
try
    neuron.corr_scores(indices,:)=[];
    neuron.corr_prc(indices,:)=[];
    neuron.dist(indices,:)=[];
    neuron.dist_prc(indices,:)=[];
catch
    'no error';
end






neuron.A(:,indices)=[];
neuron.C(indices,:)=[];
neuron.C_raw(indices,:)=[];
neuron.S(indices,:)=[];

 