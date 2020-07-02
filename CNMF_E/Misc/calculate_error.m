function [error1,error2,index1,index2]=calculate_error(neuron,alignment_matrix)
error1=0;
error2=0;
index1=[];
index2=[];
if ~isequal(class(neuron),'Sources2D')
    neuron1=Sources2D;
    neuron1.existant_indices=neuron;
    neuron=neuron1;
end
for i=1:size(neuron.existant_indices,1)
    ind=find(alignment_matrix(:,1)==neuron.existant_indices(i,1));
    if isempty(ind)
        error1=error1+1;
        index1=[index1,i];
    elseif sum(isnan(alignment_matrix(ind,:)),2)>0
        error1=error1+1;
        index1=[index1,i];
    elseif sum(alignment_matrix(ind,:)~=neuron.existant_indices(i,:))>0
        error2=error2+1;
        index2=[index2,i];
    end
end



        