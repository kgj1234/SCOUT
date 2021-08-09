function[new_aligned,new_prob]=Eliminate_Repeats_Fill(aligned_neurons,aligned_probabilities,use_spat,probabilities,pair_aligned,spat_aligned,min_prob,dist_vals,max_sess_dist)
%Eliminate duplicate neurons from all but most probable neuron chains, and
%reconstitute new chains. 
%inputs
%   aligned_neurons: matrix of neuron chains
%   aligned_probabilities: vector of chain probabilities
%   use_spat: boolean, use non-consecutive recording similarities
%   probabilities: cell array of consecutive probabilities
%   pair_aligned: cell array of identified neurons from consecutive
%       recordings
%   spat_aligned; cell array of identified neurons from non-consecutive
%       recordings
%   min_prob: minimal single session probability
%outputs
%    new_aligned: matrix of neuron chains
%   new_prob: vector of chain probabilities
%%Author Kevin Johnston

%%

new_aligned=[];
new_prob=[];
num_sess=sum(~iszero(aligned_neurons),2);

for i=max(num_sess):-1:1
    while max(num_sess)==i
        avail_ind=find(num_sess==i);
        [~,I]=max(aligned_probabilities(num_sess==i));
        I=avail_ind(I);
        current_aligned=aligned_neurons(I,:);
        %Eliminate neurons from duplicate chains
        for k=1:size(aligned_neurons,2)
            ind=find(aligned_neurons(:,k)==current_aligned(k));
            ind=setdiff(ind,I);
            
            
            aligned_neurons(ind,k)=0;
        end
        new_aligned=[new_aligned;aligned_neurons(I,:)];
        new_prob=[new_prob;aligned_probabilities(I)];
        aligned_neurons(I,:)=0;
        aligned_probabilities(I)=0;
        num_sess=sum(~iszero(aligned_neurons),2);
        if max(num_sess)<i
            %Reconstitute neuron chains
            aligned_neurons(num_sess==0,:)=[];
            aligned_probabilities(num_sess==0,:)=[];
            [aligned_neurons,aligned_probabilities]=Eliminate_Duplicates(aligned_neurons,aligned_probabilities);
            [aligned_neurons,aligned_probabilities]=mergeNeurons(aligned_neurons,aligned_probabilities);
            num_sess=sum(~iszero(aligned_neurons),2);
            if use_spat
                aligned_probabilities=construct_combined_probabilities(aligned_neurons,probabilities,pair_aligned,spat_aligned,dist_vals,min_prob,[],[],max_sess_dist);
            elseif ~isempty(probabilities)
                aligned_probabilities=construct_consecutive_probabilities(aligned_neurons,probabilities,pair_aligned);
            end
            rem_ind=find(aligned_probabilities<min_prob);
            aligned_probabilities(rem_ind)=[];
            aligned_neurons(rem_ind,:)=[];
            num_sess=sum(~iszero(aligned_neurons),2);
         
        end
    end
end
