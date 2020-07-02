function correl=compare_correlation_existant_indices(C,neuron,num_frames)
total_indices{1}=1:num_frames;
for i=2:size(neuron.existant_indices,2)
    total_indices{i}=(1:num_frames)+total_indices{i-1}(end);
end
correl=zeros(size(neuron.C,1),size(C,1));
for i=1:size(neuron.C,1)
    temp_indices=total_indices(~isnan(neuron.existant_indices(i,:)));
    temp_indices=horzcat(temp_indices{:});
    for j=1:size(C,1)
        correl(i,j)=corr(neuron.C(i,temp_indices)',C(j,temp_indices)');
    end
end
