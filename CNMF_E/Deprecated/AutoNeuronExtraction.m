function neuron=AutoNeuronExtraction(filename,pnr_vec,KL_vec)
% filename: string name of mat file you want to perform extraction on
% data_shape: Ysiz vector contained in variable, size of data (width,height,num_frames)
%pnr_vec: vector containing possible pnr values to attempt, example [5,10,15]
%KL_vec: vector containing possible KL criteria to attempt, example [0,.2,.3,.5]





Y=matfile(filename);
data_shape=size(Y,'Y');
data_shape=data_shape(1:2);
%try
%    delete(gcp('nocreate'))
%end


for i=1:length(pnr_vec)*length(KL_vec)
     [j,k]=ind2sub([length(pnr_vec),length(KL_vec)],i);
     
     neurons{i}=full_demo_endoscope(filename,[],KL_vec(k),pnr_vec(j),'bound');
     %neurons{i}.combined=ones(size(neurons{i}.C,1),1);
     
     
end

neuron=neurons{1}.copy();
save('new_neurons_a','neurons','-v7.3')
%Fix this
% if length(neurons)>30
%     
% for i=2:length(neurons)
%     neuron.C=vertcat(neuron.C,neurons{i}.C);
%     neuron.S=vertcat(neuron.S,neurons{i}.S);
%     neuron.C_raw=vertcat(neuron.C_raw,neurons{i}.C_raw);
%     neuron.centroid=vertcat(neuron.centroid,neurons{i}.centroid);
%     neuron.A=horzcat(neuron.A,neurons{i}.A);
%     
%     neuron.combined=vertcat(neuron.combined,neurons{i}.combined);
%     
%     neuron=thresholdNeuron(neuron,.35);
% 
%     quickMerge(neuron,[.5,.7,-1]);
%    
%  
%     
% 
%   
%     neuron.centroid=[];
%     for i=1:size(neuron.A,2)
%         neuron.centroid=vertcat(neuron.centroid,calculateCentroid(neuron.A(:,i),data_shape(1),data_shape(2)));
%     end
% end
% end
