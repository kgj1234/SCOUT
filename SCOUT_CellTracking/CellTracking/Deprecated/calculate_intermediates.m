function neuron=calculate_intermediates(neuron,correlation_matrices)
for i=1:size(neuron.C,1)
    for j=1:size(neuron.corr_prob,2)
        if ~isnan(neuron.corr_prob(i,j))&neuron.corr_scores(i,2*j-1)>0
           ind1=find(correlation_matrices{2*j-1}(neuron.existant_indices(i,j),:)==neuron.corr_scores(i,2*j-1));
           indices(i,j)=ind1;
        end
    end
end
indices(indices==0)=nan;

