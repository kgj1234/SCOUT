function neuron=filter_few_spikes(neuron,thresh,prc)
spike_num=sum(neuron.S>0,2);
if exist('prc','var')&&~isempty(prc)
    try
        spike_num_norm=(spike_num-mean(spike_num))/std(spike_num);
        indices1=spike_num_norm<norminv(prc);
    catch
        indices1=[];
    end
end
indices2=spike_num<=thresh;
indices=indices1|indices2;


neuron.A(:,indices)=[];
neuron.C(indices,:)=[];
neuron.S(indices,:)=[];
neuron.C_raw(indices,:)=[];
if ~isempty(neuron.centroid)
    neuron.centroid(indices,:)=[];
end

if ~isempty(neuron.combined)
    neuron.combined(indices)=[];
end
if ~isempty(neuron.scores)
    neuron.scores(indices)=[];
end
if ~isempty(neuron.corr_scores)
    neuron.corr_scores(indices,:)=[];
    neuron.corr_prc(indices,:)=[];
    neuron.dist(indices,:)=[];
    neuron.dist_prc(indices,:)=[];
end



        