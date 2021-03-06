function new_correlations=construct_correlation_between_sessions(neuron1,link,neuron2,overlap)
%Helper function, construction correlation of neurons on consecutive
%sessions via a connecting recording
%input
%   neuron1/neuron2: Sources2D extracted from consecutive recordings
%   link: extraction of connecting recording between neuron1/neuron2
%   overlap: frames of overlap connecting recording has with neuron1. Must
%       be the same as the frames of overlap with neuron2
%output
%   correlation between neurons in consecutive recordings
%Author: Kevin Johnston, University of California, Irvine


%Construct correlations between neurons and link
temp1=neuron1.copy();
temp1.C=neuron1.C(:,end-overlap+1:end);
temp1.S=neuron1.S(:,end-overlap+1:end);
temp2=link.copy();
temp2.C=link.C(:,1:overlap);
temp2.S=link.S(:,1:overlap);

correlations=spike_train_correlation(temp1,temp2,[.5,.5],max(neuron1.imageSize));
temp1=link.copy();
temp1.C=link.C(:,end-overlap+1:end);
temp1.S=link.S(:,end-overlap+1:end);
temp2=neuron2.copy();
temp2.C=neuron2.C(:,1:overlap);
temp2.S=neuron2.S(:,1:overlap);



correlations1=spike_train_correlation(temp1,temp2,[.5,.5],max(neuron1.imageSize));

new_correlations=zeros(size(neuron1.C,1),size(neuron2.C,1));

%Track neurons across link and average correlation in both direction to get
%correlation across link
for i=1:size(neuron1.C,1)
    for j=1:size(neuron2.C,1);
        max_corr=[0,0];
        for k=1:size(link.C,1)
            temp_corr=[correlations(i,k),correlations1(k,j)];
            if mean(temp_corr)>mean(max_corr)&sum(temp_corr>0)==2
                max_corr=temp_corr;
            end
        end
        new_correlations(i,j)=mean(max_corr);
    end
end

                