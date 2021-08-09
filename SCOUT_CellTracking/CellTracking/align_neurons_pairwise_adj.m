function [aligned_neurons,aligned_probabilities]=align_neurons_pairwise_adj(aligned,probabilities,size_vec)
 


%% Initial identification of neurons of consecutive recordings
% input:
%   
%   pair_aligned: cell array, each element containing identifications
%   between consecutive recordings
%   probabilities: cell array, each element containing identification
%   size_vec: vector, contains number of neurons extracted from each
%   recording
% output:
%   aligned_neurons: num_neurons x num_recordings-1 matrix
%   aligned_probabilities: num_neurons x num_recordings-1 matrix
%% Author: Kevin Johnston, University of California, Irvine.

%This is currently memory intensive, optimize later


aligned_neurons{1}=(1:size_vec(1))';
aligned_probabilities{1}=zeros(size(aligned_neurons{1}));

for i=1:(length(probabilities)-1)
   used=[];
    for j=1:size(aligned_neurons{i}(:,end),1)
        %Consecutively construct all possible neuron chains through
        %consecutive recordings
        try
            pair_ind=find(aligned{i,i+1}(:,end-1)==aligned_neurons{i}(j,end));
        catch
            pair_ind=[];
        end
        if ~isempty(pair_ind)
      
        curr_aligned{j}=[repmat(aligned_neurons{i}(j,:),length(pair_ind),1),aligned{i,i+1}(pair_ind,2)];
        curr_align_prob{j}=[repmat(aligned_probabilities{i}(j,:),length(pair_ind),1),probabilities{i,i+1}(pair_ind,:)];
        
        used=[used,pair_ind'];
         
        else
            curr_aligned{j}=[aligned_neurons{i}(j,:),0];
            curr_align_prob{j}=[aligned_probabilities{i}(j,:),0];
            
            
        end
    end
    %Include all neurons from each recording in aligned_neurons, adding in
    %missed neurons as unidentified with any neuron in consecutive
    %recordings
    aligned_neurons{i+1}=vertcat(curr_aligned{:});
    if isempty(aligned{i,i+1})
        unused=1:size_vec(i+1);
    else
        unused=setdiff(1:size_vec(i+1),aligned{i,i+1}(used,end));
    end
    aligned_neurons{i+1}(end+1:end+length(unused),:)=[zeros(length(unused),size(aligned_neurons{i},2)),unused'];
    aligned_probabilities{i+1}=vertcat(curr_align_prob{:});
    aligned_probabilities{i+1}=[aligned_probabilities{i+1};zeros(length(unused),size(aligned_probabilities{i+1},2))];

end

aligned_neurons=aligned_neurons{end};
aligned_probabilities=aligned_probabilities{end};

aligned_probabilities(:,1)=[];

