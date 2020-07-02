function total_diff=total_different(neuron,neuron1)
for i=1:size(neuron.C)
    maxim=0;
    for j=1:size(neuron1.C)
        if sum(neuron.existant_indices(i,:)==neuron1.existant_indices(j,:))>maxim
            maxim=sum(neuron.existant_indices(i,:)==neuron1.existant_indices(j,:));
        end
    end
    total_diff(i)=maxim;
end
total_diff=size(neuron.existant_indices,2)-total_diff;