function [neuron,del_ind]=manual_deletion_main(neuron,num_to_view)
%Allows for manual identification of false discoveries

%Inputs
% neuron (Sources2D)
% num_to_view (int) Number of neurons to view simultaneously 
    %(try shrinking this if render time is too high)
%Outputs 
%neuron (Sources2D) neuron with false discoveries deleted
%del_ind (vector) false discovery indices

%%Author Kevin Johnston, University of California, Irvine, 2020



%Don't remember if you have to rename the object in matlab
neuron1=neuron.copy();
neuron=neuron1.copy();
clear neuron1

neuron.A=full(neuron.A);
if isempty(neuron.imageSize)
    neuron.imageSize=[neuron.options.d1,neuron.options.d2];
end

del_ind=[];
curr_iter=1;
while (curr_iter-1)*num_to_view+1<size(neuron.C,1)
    current_indices=(curr_iter-1)*num_to_view+1:min(size(neuron.C,1),(curr_iter*num_to_view));
    remove_ind=setdiff(1:size(neuron.C,1),current_indices);
    temp_neuron=neuron.copy();
    temp_neuron.delete(remove_ind);
    temp_neuron.Cn=neuron.Cn;
    del_ind=[del_ind,num_to_view*(curr_iter-1)+create_neuron_figure(temp_neuron)];
    curr_iter=curr_iter+1;
end


figure('Name','Deleted Neurons')
if ~isempty(del_ind)
    imagesc(max(reshape(neuron.A(:,del_ind),neuron.imageSize(1),neuron.imageSize(2),[]),[],3))
end
neuron.delete(del_ind);
figure('Name','Retained Neurons')
imagesc(max(reshape(neuron.A,neuron.imageSize(1),neuron.imageSize(2),[]),[],3))
end


    