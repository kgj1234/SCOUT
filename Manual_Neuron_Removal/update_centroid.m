function neuron=update_centroid(neuron)
    neuron.centroid=[];
    for i=1:size(neuron.A,2)
        curr_centroid=calculateCentroid(neuron.A(:,i),neuron.imageSize(1),neuron.imageSize(2));
        neuron.centroid=[neuron.centroid;curr_centroid];

    end
    centroid=neuron.centroid;
    neuron.centroid(:,2)=centroid(:,1);
    neuron.centroid(:,1)=centroid(:,2);
end