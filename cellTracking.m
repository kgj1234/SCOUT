function [neuron,cell_register,neurons,links]=cellTracking(correlation_matrices,distance_links,distance_metrics,...
    similarity_pref,weights,max_dist,min_prob,chain_prob,max_sess_dist,neurons,links)

base=floor(length(neurons)/2);
probability_assignment_method='Kmeans';
max_gap=0;
single_corr=false;
corr_thresh=[];
use_spat=true;
scale_factor=1.5;
min_num_neighbors=1.5;
binary_corr=false;
reconstitute=true;

% if weights(6)==0
%     weights(6)=[];
% end
% if weights(5)==0
%     weights(5)=[];
% end

for k=1:length(neurons)
    centroids{k}=neurons{k}.centroid;
end
tic

[cell_register,aligned_probabilities,reg_prob]=compute_cell_register_kmedoids(correlation_matrices,distance_links,distance_metrics,...
    similarity_pref,weights,probability_assignment_method,max_dist,max_gap,min_prob,single_corr,corr_thresh,use_spat,min_num_neighbors,...
    chain_prob,binary_corr,max_sess_dist,centroids,scale_factor,reconstitute);
time=toc;
disp(['Tracking: ', num2str(time), ' seconds'])
%neurons=neurons1;
%links=links1;
%% Construct Neuron Throughout Sessions Using Extracted Registration
if isempty(cell_register)
    neuron=Sources2D;
    return
end
data_shape=neurons{1}.imageSize;



neuron=Sources2D;

total = 0;
start=[];
ends=[];
for k=1:length(neurons)
    start(k)=total+1;
    total = total + size(neurons{k}.C,2); 
    ends(k)=total;
end

neuron.C = zeros(size(cell_register, 1), total);
neuron.C_raw = zeros(size(cell_register, 1), total);
neuron.S = zeros(size(cell_register, 1), total);
neuron.C_df = zeros(size(cell_register, 1), total);
neuron.trace = zeros(size(cell_register,1),total);


%Construct Sources2D object representing neurons over full recording

A_per_session=zeros(size(neurons{1}.A,1),size(cell_register,1),length(neurons));
A=zeros(size(neurons{1}.A,1),size(cell_register,1));
identified=zeros(size(cell_register,1),1);
decays=zeros(size(cell_register,1),1);

for k=1:size(cell_register,2)
    
    
    
    ind = cell_register(:,k)~=0;
    index = find(ind);
    identified=identified+ind;
    if isprop(neurons{k}, 'C') && ~isempty(neurons{k}.C)
       neuron.C(index, start(k):ends(k)) = neurons{k}.C(cell_register(ind,k),:); 
    end
    
    if isprop(neurons{k}, 'C_raw') && ~isempty(neurons{k}.C_raw)
        neuron.C_raw(index, start(k):ends(k)) = neurons{k}.C_raw(cell_register(ind, k),:);
    end
    
    if isprop(neurons{k}, 'C_df') && ~isempty(neurons{k}.C_df)
        neuron.C_df(index, start(k):ends(k)) = neurons{k}.C_df(cell_register(ind, k),:);
    end
    
    if isprop(neurons{k}, 'S') && ~isempty(neurons{k}.S)
        neuron.S(index, start(k):ends(k)) = neurons{k}.S(cell_register(ind, k),:);
    end
    if isprop(neurons{k}, 'trace') && ~isempty(neurons{k}.trace)
        neuron.trace(index, start(k):ends(k)) = neurons{k}.trace(cell_register(ind, k),:);
    end
    
    
    A(:,index)=A(:,index)+neurons{k}.A(:,cell_register(ind,k));
    A_per_session(:,index,k)=neurons{k}.A(:,cell_register(ind,k));
    if isprop(neurons{k}.P,'kernel_pars')
        decays(index)=decays(index)+neurons{k}.P.kernel_pars(cell_register(ind,k));
    end
    
end

neuron.A=A./identified';
neuron.P.kernel_pars=decays./identified;
neuron.A_per_session=A_per_session;


try
    neuron.Cn=neurons{base}.Cn;
end
neuron.imageSize=neurons{base}.imageSize;
neuron.updateCentroid();
try
    neuron=calc_snr(neuron);
end
neuron.connectiveness=aligned_probabilities;
neuron.probabilities=reg_prob;

neuron.cell_register=cell_register;
try
    neuron.options=neurons{1}.options;
end

neuron.delete(neuron.probabilities<chain_prob);
neuron.delete(neuron.connectiveness<chain_prob);
cell_register=neuron.cell_register;