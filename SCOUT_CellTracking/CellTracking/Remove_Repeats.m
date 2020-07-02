
function [aligned_neurons,aligned_probabilities,rem_ind]=...
    Remove_Repeats(aligned_neurons,aligned_probabilities,size_vec,use_spat,probabilities,pair_aligned,spat_aligned,min_prob,dist_vals,max_sess_dist)

%Calls functions to remove repeated neurons from neuron chains

%Inputs

%aligned_neurons (matrix) current cell register
%aligned_probabilities (matrix or vector) current cell register
    %probabilities
%size_vec (vector) number of total available neurons per session
%use_spat (bool) use spatial criteria
%probabilities (cell array) identification probabilities between sessions
%pair_aligned (cell array) possible cell identifications between
    %consecutive sessions
%spat_aligned (cell array) identification probabilities between
    %non-consecutive sessions
%min_prob (float range [0,1]) min identification probability between
    %sessions
%dist_vals (cell array) metric similarity values between sessions
%max_sess_dist (int) maximum distance between sessions for computed
    %similarity metrics

%Outputs

%aligned_neurons (matrix) cell register
%aligned_probabilities (vector) chain probabilities
%rem_ind (vector) vector of deleted elements of cell register

%%Author Kevin Johnston

%% Parameter Setting
if ~exist('use_spat','var')||isempty(use_spat)
    use_spat=false;
end
if ~exist('probabilities','var')||isempty(use_spat)
    probabilities=[];
end
if ~exist('pair_aligned','var')||isempty(use_spat)
    pair_aligned=[];
end
if ~exist('spat_aligned','var')||isempty(use_spat)
    spat_aligned=[];
end
if ~exist('min_prob','var')||isempty(use_spat)
    min_prob=.5;
end


%% Remove Repeats
if size(aligned_probabilities,2)>1
    rem_ind=Eliminate_Repeats(aligned_neurons,aligned_probabilities);
    aligned_neurons(rem_ind,:)=[];
    aligned_probabilities(rem_ind,:)=[];
else
    [aligned_neurons,aligned_probabilities]=Eliminate_Repeats_Fill(aligned_neurons,aligned_probabilities,use_spat,probabilities,pair_aligned,spat_aligned,min_prob,dist_vals,max_sess_dist);
    rem_ind=[];
end


for i=1:size(aligned_neurons,2)
    
    ind=setdiff(1:size_vec(i),unique(aligned_neurons(:,i)));
    aligned_neurons(end+1:end+length(ind),i)=ind;
end
aligned_neurons(aligned_neurons==0)=0;
aligned_probabilities=[aligned_probabilities;zeros(size(aligned_neurons,1)-size(aligned_probabilities,1),1)];
