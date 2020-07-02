function [aligned_neurons,aligned_probabilities]=compute_aligned_pairwise_probability(correlation_matrices,distance_links,...
    distance_metrics,similarity_pref,weights,method,max_dist,max_miss,min_prob,single_corr,corr_thresh,use_spatial,min_num_neighbors,chain_prob,binary_corr)


%% Track cells through multiple recordings
% input:
%   correlation_matrices: cell array containing correlation on overlap
%       between recordings and links
%   distance_links: centroid distance between neurons in recordings and
%       connecting recordings
%   distance_metrics: distances between neurons in each recording, for each
%       similarity metric (except temporal correlation)
%   similarity_pref: cell array of similarity preferences for each similarity metric
%       ('low' or 'high') 
%   weights: weights for simlarity metrics
%   method: probability assignment method,
%       ('Kmeans','gmm','gemm','glmm','percentile','default')
%   max_dist: maximum distance between centroids for identification
%   max_miss: maximum number of missed sesssions for neuron tracking
%   min_prob: minimal probability for identification between sessions
%   single_corr: default false, set true if connections are constructed
%       using Combine_Full_Experiment_pairwise_search
%   corr_thresh: minimal correlation on connections acceptable for
%        identification of neurons (usually zero unless binary_corr_prob is
%        true)
%   use_spatial: construct chains using spatial info from non-consecutive
%       sessions, this should be true if session registration across all
%       sessions is acceptable
%   min_num_neighbors: constant factor governing minimal number of neighbors for
%       mixture model decomposition in terms of total neurons per session
%   chain_prob: minimal probability for each chain of neurons
%   binary_corr: Treat correlation on connections as binary variable based
%       on corr_thresh as threshold. Used if more neuron identifications
%       are desired, or recording registration is poor.
% output:
%   aligned_neurons: matrix of cells tracked through recordings
%   aligned_probabilities: chain probabilities for each cell
%% Author: Kevin Johnston, University of California, Irvine.


%Parameters

if ~exist('min_num_neighbors','var')||isempty(min_num_neighbors)
    min_num_neighbors=false;
end

size_vec=[];
for i=1:length(distance_metrics)
    size_vec(i)=size(distance_metrics{1,i}{1},2);
end

if weights(1)==0
    use_corr=false;
else
    use_corr=true;
end
distance_vals=cell(size(distance_metrics));
%Construct probabilities between consecutive recordings
disp('Constructing Pairwise Distances Between Consecutive Sessions For All Metrics')
for i=1:size(distance_metrics,1)
  [pair_aligned{i},correlation{i},temp_dist{i},corr_prob{i},distance_prob{i}]=compute_aligned_pairwise_probability_single_full(...
        correlation_matrices(2*i-1:2*i),distance_links(2*i-1:2*i),distance_metrics{i,i}{1},distance_metrics{i,i+1},...
        similarity_pref,max_dist,use_corr,single_corr,method,corr_thresh,min_num_neighbors,min_prob);
   
end
disp('Constructing Initial Tracking Matrices')
%construct weighted identification probabilities, perform stochastic
%update, normalized probabilities
for i=1:length(pair_aligned)
    distance_vals{i,i+1}=temp_dist{i};
    corr_prob{i}(isnan(corr_prob{i}))=0;
    if binary_corr
        corr_prob{i}(mean(correlation{i},2)<=corr_thresh)=0;
        corr_prob{i}(mean(correlation{i},2)>corr_thresh)=1;
 
    end
    
    for j=1:length(distance_prob{i})
        distance_prob{i}{j}(iszero(distance_prob{i}{j}))=0;
    end
    if weights(1)>0
        probabilities{i,i+1}=corr_prob{i}*weights(1);
    else
        probabilities{i,i+1}=zeros(size(distance_prob{i}{1},2),1);
    end
    for j=1:length(distance_prob{i})
        probabilities{i,i+1}=probabilities{i,i+1}+weights(j+1)*distance_prob{i}{j}';
        probabilities{i,i+1}(isnan(probabilities{i,i+1}))=0;
    end
    
    ind_del=find(probabilities{i,i+1}<min_prob);
    
    
    
    pair_aligned{i}(ind_del,:)=[];
    
    probabilities{i,i+1}(ind_del)=[];
    for p=1:sum(weights(2:end)>0)
        try
        distance_vals{i,i+1}{p}(ind_del)=[];
        end
    end
   try
        probabilities{i,i+1}=main_stochastic_optimization(pair_aligned{i},probabilities{i,i+1},min_prob);
   end
    temp_prob=probabilities{i,i+1};
%     for k=1:length(probabilities{i,i+1});
%        ind=find(pair_aligned{i}(:,1)==pair_aligned{i}(k,1));
%        if length(ind)>1
%        probabilities{i,i+1}(k)=temp_prob(k)/sum(temp_prob(ind));
%        end
%     end
    ind_del=find(probabilities{i,i+1}<min_prob);
    
    
    
    pair_aligned{i}(ind_del,:)=[];
    
    probabilities{i,i+1}(ind_del)=[];
end
%Construct initial alignments
[aligned_neurons,aligned_probabilities]=...
    align_neurons_pairwise(pair_aligned,probabilities,size_vec);


%fill in missed neurons
fill_in_iter=2;
for j=1:fill_in_iter
    
    


disp('Attempting To Fill In Gaps')
try
[aligned_neurons,aligned_probabilities]=...
    align_neurons_fill_in(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,min_prob);

end


for i=0:length(distance_metrics)
    curr_ind=find(sum(iszero(aligned_neurons),2)==i);
    
    aligned_temp{i+1}=aligned_neurons(curr_ind,:);
    aligned_prob_temp{i+1}=aligned_probabilities(curr_ind,:);
    
end

aligned_neurons=vertcat(aligned_temp{:});
aligned_probabilities=vertcat(aligned_prob_temp{:});




end
    



for i=0:length(distance_metrics)
    curr_ind=find(sum(iszero(aligned_neurons),2)==i);
    
    aligned_temp{i+1}=aligned_neurons(curr_ind,:);
    aligned_prob_temp{i+1}=aligned_probabilities(curr_ind,:);
    
end

aligned_neurons=vertcat(aligned_temp{:});
aligned_probabilities=vertcat(aligned_prob_temp{:});


if use_spatial&sum(weights(2:end))>0&length(distance_metrics)>2
disp('Construct Spatial Distances Between All Available Sessions')


    %Parallelize this across both loops sometime.
    
    
    %Construct identification probabilities for all recording pairs

weights(2:end)=weights(2:end)/sum(weights(2:end));    
for i=1:size(distance_metrics,1)
    spat_temp=cell(1,length(distance_metrics));
    corr_temp=cell(size(spat_temp));
    distance_temp_vals=cell(size(spat_temp));
    corr_prob_temp=cell(size(spat_temp));
    dist_prob_temp=cell(size(spat_temp));
    temp_prob=cell(size(spat_temp));
    for j=i+2:min(i+10,length(distance_metrics))
          [spat_temp{j},corr_temp{j},distance_temp_vals{j},corr_prob_temp{j},dist_prob_temp{j}]=compute_aligned_pairwise_probability_single_full(...
                [],[],distance_metrics{i,i}{1},distance_metrics{i,j},...
                similarity_pref,max_dist,false,single_corr,method,corr_thresh,min_num_neighbors);
            try
                temp_prob{j}=zeros(size(dist_prob_temp{j}{1},2),1);
            catch
                temp_prob{j}=[];
            end
      for k=1:length(dist_prob_temp{j})
          try
                dist_prob_temp{j}{k}(isnan(dist_prob_temp{j}{k}))=0;
                temp_prob{j}=temp_prob{j}+weights(k+1)*dist_prob_temp{j}{k}';
          end
    end
    try
    ind_del=find(temp_prob{j}<min_prob);
    end
    
    try
    spat_temp{j}(ind_del,:)=[];
    
    temp_prob{j}(ind_del)=[];
    for p=1:length(distance_temp_vals{j})
        distance_temp_vals{j}{p}(ind_del)=[];
    end
    end
    try
        temp_prob{j}=main_stochastic_optimization(spat_temp{j},temp_prob{j},min_prob);
    end
    temp_prob_curr=temp_prob{j};
%     for k=1:length(temp_prob{j});
%        ind=find(spat_temp{j}(:,1)==spat_temp{j}(k,1));
%        if length(ind)>1
%        temp_prob{j}(k)=temp_prob{j}(k)/sum(temp_prob_curr(ind));
%        end
%     end
    try
    ind_del=find(temp_prob{j}<min_prob);
    
    
    
    spat_temp{j}(ind_del,:)=[];
    
    temp_prob{j}(ind_del)=[];    
    end   
    end
    spat_aligned_temp{i}=spat_temp;
    spat_prob{i}=temp_prob;
    temp_vals{i}=distance_temp_vals;
    
    
    
end

for i=1:length(distance_metrics)
    for j=i+2:length(distance_metrics)
        spat_aligned{i,j}=spat_aligned_temp{i}{j};
        probabilities{i,j}=spat_prob{i}{j};
        distance_vals{i,j}=temp_vals{i}{j};
    end
end
if exist('spat_aligned','var')
disp('Secondary Tracking Using Spatial Criterion')
%Update chains based on probabilities between all recording pairs
[aligned_neurons,aligned_probabilities]=align_via_spatial(aligned_neurons,aligned_probabilities,pair_aligned,spat_aligned,probabilities,min_prob,chain_prob,distance_vals);
%[aligned_neurons,aligned_probabilities]=...
%    align_neurons_fill_in(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,min_prob);


%Construct chain probabilities
aligned_probabilities=construct_combined_probabilities(aligned_neurons,probabilities,pair_aligned,spat_aligned,distance_vals,min_prob);
end

%Remove duplicate neurons from chains
[aligned_neurons,aligned_probabilities]=...
    Remove_Repeats(aligned_neurons,aligned_probabilities,size_vec,use_spatial,probabilities,pair_aligned,spat_aligned,min_prob,distance_vals);



 



else

if size(aligned_probabilities,2)>1    
    aligned_probabilities=min(aligned_probabilities,[],1);
end

[aligned_neurons,aligned_probabilities]=...
    Remove_Repeats(aligned_neurons,aligned_probabilities,size_vec,use_spatial,probabilities,pair_aligned,[],min_prob,distance_vals);


   

end













%Delete neurons that span insufficient recording sessions
aligned_probabilities=round(aligned_probabilities,4);
aligned_probabilities(aligned_probabilities>1)=1;
rem_ind=sum(iszero(aligned_neurons),2)>max_miss;
aligned_neurons(rem_ind,:)=[];
aligned_probabilities(rem_ind,:)=[];




