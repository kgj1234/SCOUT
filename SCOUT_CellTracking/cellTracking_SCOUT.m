function [neuron,cell_register,neurons,links]=cellTracking_SCOUT(neurons,varargin)
%Author: Kevin Johnston
%Main function for cell registration between sessions
%Inputs
%neurons (cell of class Sources2D objects containing neural data from each
%           session, A,C,imageSize required entries)
%Optional Inputs (input as 'parameter_name', parameter in function)
%  links: (cell array of Sources2D) extractions of connecting sesssions, required for correlation
%               registration. Cell of Sources2D structs

%  overlap: (int) temporal overlap between connecting sessions
%  max_dist: (float) max distance between registered neurons between sessions
%  weights: (vector) weights for linking methods. 4 element numeric vector. Order correlation, JS, overlap, centroid dist
%  chain_prob: (float range [0,1]) Total probability threshold for neuron chains, numeric value between 0 and 1
%  corr_thresh (float range [0,1]) Probability threshold for correlation link
%               between neurons, numeric value between 0 and 1. Usually 0
%               unless binary_corr is true
%  patch: (int) Patch size if neuron density varies significantly across the
%               recording (currently has no effect.  "in progress")
%  register_sessions: (bool) indicating whether to register sessions.
%       Default true
%  registration_type: (str) 'align_to_base' or 'consecutive', Determines if
%       sessions are registered to base session, or registered
%       consecutively.
%  registration_method: (str) 'affine' or 'non-rigid', method for session
%       registration
%  registration_template: (str) Use spatial positions of neurons 'spatial', or
%       correlation map 'correlation' for registration
%  use_corr: (boolean) indicating whether to use correlation cell registration
%           requires links
%  use_spat: (boolean) indicating whether to use spatial cell registration.
%       This should be false only if resources are low, or registration
%       cannot be guaranteed between all sessions
%   max_gap: (int) indicating largest gap between sessions for cell
%       registration. 0 indicates cells must appear in each session
%   probability_assignment_method: (str) either 'percentile', 'gmm',
%       'gemm','glmm' 'default' or 'Kmeans'
%   base: (int range [1,length(neurons)]) base session for alignment
%   min_prob: (float, range [0,1]) minimum probability for identification between
%   sessions
%   binary_corr: (bool) treat correlation on connecting recordings as binary
%      variable
%   max_sess_dist: (int) limits number of compared sessions to reduce
%     runtime. Leave as [] for no reduction.
%   footprint_threshold (float range [0,1]) percentile to threshold
    %   spatial footprints
%   single_corr (bool) use this if correlation is to be calculated only on
%       the second recording in each consecutive pair (this should almost
%       always be false)
%   cell_tracking_options (struct) with fields that contains some or all previously stated optional
    %   parameters
% Outputs
%  neuron: (Sources2D) containing neural activity extracted through the set
%           of sessions
%  cell_register: (matrix) Registration Indices Per Session for each identified cell
%  

%% Assign variables
optional_parameters={'links','weights','max_dist','overlap','chain_prob','corr_thresh','register_sessions','registration_type','registration_method',...
    'registration_template','use_corr','use_spat','max_gap','probability_assignment_method','base','min_prob','binary_corr','max_sess_dist',...
    'footprint_threshold','cell_tracking_options','single_corr'};
defaults={{},[4,5,5,2,0],45,[],.5,.6,true,'align-to-base','non-rigid','spatial',false,true,0,'Kmeans',ceil(length(neurons)/2),.5,false,20,.1,struct,false};

p=inputParser;

addRequired(p,'neurons');
for i=1:length(optional_parameters)
    addOptional(p,optional_parameters{i},defaults{i},@(x) isequal(class(defaults{i}),class(x))||isempty(x)); 
end

parse(p,neurons,varargin{:});
for i=1:length(p.Parameters)
    if isfield(p.Results.cell_tracking_options,p.Parameters{i})
        val=getfield(p.Results.cell_tracking_options,p.Parameters{i});
    else
        val=getfield(p.Results,p.Parameters{i});
    end
    eval([p.Parameters{i},'=val',';'])
end
if isempty(links)
    weights(1)=0;
    overlap=0;
    corr_thresh=[];
    links=[];
end
if isequal(registration_template,'correlation')&isempty(neurons{1}.Cn)
    registration_template='spatial';
end
if weights(1)==0
    links=[];
    overlap=0;
    corr_thresh=[];
end
%% Copy neurons and links to new memory locations, standardize FOV size for each session


%Sources2D is mutable, copy a new version, copy a version without trimmed
%neurons
neurons1=neurons;
links1=links;
for i=1:length(neurons)
    neurons1{i}=neurons{i}.copy();
end
clear neurons
neurons=neurons1;
clear neurons1;
for i=1:length(neurons)
    neurons1{i}=neurons{i}.copy();
    neurons{i}=thresholdNeuron(neurons{i},footprint_threshold);
end
for i=1:length(links)
    links1{i}=links1{i}.copy();
end
clear links
links=links1;
clear links1;
for i=1:length(links)
    links1{i}=links{i}.copy();
    links{i}=thresholdNeuron(links{i},footprint_threshold);
end
%Normalize FOV for each session
for i=1:length(neurons)
    
    
    max_dims1(i)=neurons{i}.imageSize(1);
    max_dims2(i)=neurons{i}.imageSize(2);
end
for i=1:length(links)
    max_dims1(end+1)=links{i}.imageSize(1);
    max_dims2(end+1)=links{i}.imageSize(2);
end
max_dims1=max(max_dims1);
max_dims2=max(max_dims2);
for i=1:length(neurons)
    curr_dim1=max_dims1-neurons{i}.imageSize(1);
    curr_dim2=max_dims2-neurons{i}.imageSize(2);
    neurons{i}.A=reshape(neurons{i}.A,neurons{i}.imageSize(1),neurons{i}.imageSize(2),[]);
    neurons{i}.A=[neurons{i}.A;zeros(curr_dim1,size(neurons{i}.A,2),size(neurons{i}.A,3))];
    neurons{i}.A=[neurons{i}.A,zeros(size(neurons{i}.A,1),curr_dim2,size(neurons{i}.A,3))];
    neurons{i}.imageSize=[max_dims1,max_dims2];
    neurons{i}.A=reshape(neurons{i}.A,max_dims1*max_dims2,[]);
    try
        neurons{i}.Cn=[neurons{i}.Cn;zeros(curr_dim1,size(neurons{i}.Cn,2))];
        neurons{i}.Cn=[neurons{i}.Cn,zeros(size(neurons{i}.Cn,1),curr_dim2)];
    catch
    end
end
if ~isempty(links)
    for i=1:length(links)
        curr_dim1=max_dims1-links{i}.imageSize(1);
        curr_dim2=max_dims2-links{i}.imageSize(2);
        links{i}.A=reshape(links{i}.A,links{i}.imageSize(1),links{i}.imageSize(2),[]);
        links{i}.A=[links{i}.A;zeros(curr_dim1,size(links{i}.A,2),size(links{i}.A,3))];
        links{i}.A=[links{i}.A,zeros(size(links{i}.A,1),curr_dim2,size(links{i}.A,3))];
        links{i}.imageSize=[max_dims1,max_dims2];
        links{i}.A=reshape(links{i}.A,max_dims1*max_dims2,[]);
        try
            links{i}.Cn=[links{i}.Cn;zeros(curr_dim1,size(links{i}.Cn,2))];
            links{i}.Cn=[links{i}.Cn,zeros(size(links{i}.Cn,1),curr_dim2)];
        catch
        end
    end
end


%% Register Sessions (Global)


if register_sessions
    
   [neurons,links]=register_neurons_links(neurons,links,registration_template,registration_type,registration_method,base);
end
for i=1:length(neurons)
    neurons{i}.updateCentroid();
end
if ~isempty(links)
    for i=1:length(links)
        links{i}.updateCentroid();
    end
end



%% Construct Distance Metrics Between Sessions 
if ~isempty(links)
    correlation_matrices=construct_correlation_matrix(neurons,links,overlap,max_dist);
else
    for i=1:2*length(neurons)
        correlation_matrices{i}=[];
    end
end


%Insert any new distance metrics below, and add them to the
%distance_metrics cell

%Weights order: correlation, centroid_dist,overlap,JS,SNR,decay
%overlap similarity
if weights(3)>0
    overlap_matrices=construct_overlap_matrix(neurons);
else
    overlap_matrices=cell(length(neurons)-1,length(neurons));
end

%centroid distance (this metric is required, though  the weight may be 0)
distance_matrices=construct_distance_matrix(neurons);





distance_links=cell(1,length(neurons)*2-2);
for i=1:length(neurons)-1
    if ~isempty(links)
        distance_links{2*i-1}=pdist2(neurons{i}.centroid,links{i}.centroid);
        distance_links{2*i}=pdist2(links{i}.centroid,neurons{i+1}.centroid);
    else
        distance_links{2*i-1}=[];
        distance_links{2*i}=[];
    end
end

%JS distance
if weights(4)>0
    JS_matrices=construct_JS_matrix(neurons,max_dist,max_sess_dist);
else
    JS_matrices=cell(length(neurons)-1,length(neurons));
end
if weights(5)>0
for i=1:length(neurons)
    for j=i:length(neurons)
        SNR_dist{i,j}=pdist2(neurons{i}.SNR,neurons{j}.SNR)./((repmat(neurons{i}.SNR,1,size(neurons{j}.SNR,1))+repmat(neurons{j}.SNR',size(neurons{i}.SNR,1),1))/2);
    end
end
else
    SNR_dist=cell(length(neurons),length(neurons));
end
if weights(6)>0
for i=1:length(neurons)
    for j=i:length(neurons)
        decay_dist{i,j}=pdist2(neurons{i}.P.kernel_pars,neurons{j}.P.kernel_pars)./((repmat(neurons{i}.P.kernel_pars,1,size(neurons{j}.P.kernel_pars,1))+repmat(neurons{j}.P.kernel_pars',size(neurons{i}.P.kernel_pars,1),1))/2);
    end
end
else
    decay_dist=cell(length(neurons),length(neurons));
end


%Add additional metrics to the end of this cell. Make sure distance
%matrices is the first element of the cell.
for i=1:size(distance_matrices,1)
    for j=1:size(distance_matrices,2)
        distance_metrics{i,j}={distance_matrices{i,j},overlap_matrices{i,j},JS_matrices{i,j},SNR_dist{i,j},decay_dist{i,j}};
        ind=find(weights(3:end)==0);
        distance_metrics{i,j}(ind+1)=[];
    end
end



% cell of strings 'low', and 'high', indicating whether the distance
% similarity prefers low or high values (centroid distance: low, overlap:
% high) 
% First element should be low, corresponding to centroid distance.
similarity_pref={'low','high','low','low','low'};
similarity_pref(ind+1)=[];

disp('Beginning Cell Tracking')

%vector of weights for total metrics (including correlation) If no links are used,
%set first elements of this vector to 0.
weights=weights/sum(weights);
min_num_neighbors=1.5;
%% Construct Cell Register
[cell_register,aligned_probabilities]=compute_cell_register(correlation_matrices,distance_links,distance_metrics,...
    similarity_pref,weights,probability_assignment_method,max_dist,max_gap,min_prob,single_corr,corr_thresh,use_spat,min_num_neighbors,chain_prob,binary_corr,max_sess_dist);
%neurons=neurons1;
%links=links1;
%% Construct Neuron Throughout Sessions Using Extracted Registration
if isempty(cell_register)
    neuron=Sources2D;
    return
end
data_shape=neurons{1}.imageSize;



neuron=Sources2D;
%Construct Sources2D object representing neurons over full recording
%This is really slow, optimize later

A_per_session=zeros(size(neurons{1}.A,1),size(cell_register,1),length(neurons));
for i=1:size(cell_register,1)
    
    A=zeros(size(neurons{1}.A(:,1)));
    
    C={};
    S={};
    C_raw={};
    for k=1:size(cell_register,2)
        if ~iszero(cell_register(i,k))
            C{k}=neurons{k}.C(cell_register(i,k),:);
            try
              C_raw{k}=neurons{k}.C_raw(cell_register(i,k),:);
            end
            try
                S{k}=neurons{k}.S(cell_register(i,k),:);
            end
            A=A+neurons{k}.A(:,cell_register(i,k));
            A_per_session(:,i,k)=neurons{k}.A(:,cell_register(i,k));
        else
            C{k}=zeros(1,size(neurons{k}.C,2));
            try
             C_raw{k}=zeros(1,size(neurons{k}.C,2));
            end
            try
                S{k}=zeros(1,size(neurons{k}.C,2));
            end
        end
    end
    
    
    A=A/size(cell_register,2);
    neuron.A=horzcat(neuron.A,A);
    neuron.C=vertcat(neuron.C,horzcat(C{:}));
    try
        neuron.C_raw=vertcat(neuron.C_raw,horzcat(C_raw{:}));
    end
    try
        neuron.S=vertcat(neuron.S,horzcat(S{:}));
    end
    centroid=calculateCentroid(A,data_shape(1),data_shape(2));
    neuron.centroid=vertcat(neuron.centroid,centroid);
    decays=[];
    try
    for q=1:size(cell_register,2)
        decays=[decays,neurons{q}.P.kernel_pars(cell_register(i,q))];
    end
 
    neuron.P.kernel_pars(i,1)=mean(decays);
    end
end
try
    neuron.Cn=neurons{base}.Cn;
end
neuron.imageSize=neurons{base}.imageSize;
neuron.updateCentroid();
try
    neuron=calc_snr(neuron);
end
neuron.probabilities=aligned_probabilities;

neuron.cell_register=cell_register;
try
    neuron.options=neurons{1}.options;
end

%Eliminate remaining neurons falling below chain_prob
neuron.A_per_session=A_per_session;
neuron.delete(neuron.probabilities<chain_prob);
