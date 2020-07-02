function neuron=eliminate_nonexistent(neuron)
%fix this
%indices=[find(sum(neuron.A>0,1)<3),find(sum(neuron.S,2)==0)];
%neuron.delete(indices);
% try
%     neuron.P.kernel_pars(indices)=[];
% 
% end
% try
%     neuron.P.sn_neuron=[];
% end
% neuron.A(:,indices)=[];
% neuron.C(indices,:)=[];
% neuron.C_raw(indices,:)=[];
% neuron.S(indices,:)=[];