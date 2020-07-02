function neuron=filter_SNR(neuron,prc)

SNR=(neuron.SNR-mean(neuron.SNR))/std(neuron.SNR);

thresh=norminv(prc);

indices=SNR<thresh;

neuron.delete(indices);

neuron.centroid(indices,:)=[];

try
    neuron.trace(indices,:)=[]; 
    neuron.C_df(incies,:)=[];
    neuron.Coor(indices,:)=[];
    neuron.Df(indices,:)=[];
end
neuron.SNR(indices)=[];
