function neuron=calculate_footprints_centroids(neuron)
%A=max(neuron.A_per_batch{1},neuron.A_per_batch{2});
%for i=3:length(neuron.A_per_batch)
%    A=max(A,neuron.A_per_batch{i});
%end
A=zeros(size(neuron.A_per_batch{1}));
for i=1:length(neuron.A_per_batch);
    A=A+neuron.A_per_batch{i};
end
A=A/length(neuron.A_per_batch);


neuron.A=A;
centroids=zeros(size(neuron.centroids_per_batch{1}));
for i=1:length(neuron.centroids_per_batch)
    centroids=centroids+neuron.centroids_per_batch{i};
end
neuron.centroid=centroids/length(neuron.centroids_per_batch);
