function [neuron,del_ind]=spatial_delete_main(neuron,num_to_view)
%Shows available neurons and allows for selection of false discoveries

%neuron (Sources2D)
%num_to_view (int) largeish(>50)
%%Author Kevin Johnston
% Drawing a rectangle selects all neurons 
%inside the rectangle to be deleted. Clicking individual neurons
%selects and deselects for deletion.
%Close the figure window to submit 




neuron1=neuron.copy();
neuron=neuron1.copy();
clear neuron1

neuron.A=full(neuron.A);
if isempty(neuron.imageSize)
    neuron.imageSize=[neuron.options.d1,neuron.options.d2];
end

neuron=update_centroid(neuron);

del_ind=[];
for k=1:ceil(size(neuron.C,1)/num_to_view);
    indices=[num_to_view*(k-1)+1,min(num_to_view*k,size(neuron.C,1))];
    
    del_ind=[del_ind,identify_spatial_irregularities(neuron,indices)];
end
figure('Name','Deleted Neurons')
if ~isempty(del_ind)
    imagesc(max(reshape(neuron.A(:,del_ind),neuron.imageSize(1),neuron.imageSize(2),[]),[],3))
end

neuron.delete(del_ind);
figure('Name','Retained Neurons')
imagesc(max(reshape(neuron.A,neuron.imageSize(1),neuron.imageSize(2),[]),[],3))
end