function [aligned_neurons,aligned_probabilities]=align_neurons_fill_in(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,min_prob)
%% fill in aligned neurons matrix based on neurons in consecutive recordings
% input:
%   aligned_neurons: num_neurons x num_recordings-1 matrix
%   aligned_probabilities: num_neurons x num_recordings-1 matrix
%   pair_aligned: cell array, each element containing identifications
%   between consecutive recordings
%   probabilities: cell array, each element containing identification
%   probabilities between consecutive recordings
%   min_prob: constant, minimal probability of identification between
%   sessions
% output:
%   aligned_neurons: num_neurons x num_recordings-1 matrix
%   aligned_probabilities: num_neurons x num_recordings-1 matrix
%% Author: Kevin Johnston, University of California, Irvine.

req_bound=true;

%Fill in missing neurons from first recording based on second recording
for j=1:size(aligned_neurons,1)
    if iszero(aligned_neurons(j,1))&&~iszero(aligned_neurons(j,2))
        [aligned_neurons,aligned_probabilities]=fill_in_right_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,1,j,min_prob);
    end
end




%Fill in missing neurons in recordings 2 -> n-1 based on surrounding
%recordings
if req_bound==true
    for i=2:size(aligned_neurons,2)-1
        for j=1:size(aligned_neurons,1)
            if iszero(aligned_neurons(j,i))&&~iszero(aligned_neurons(j,i-1))&&~iszero(aligned_neurons(j,i+1))
                
                [aligned_neurons,aligned_probabilities]=fill_in_center_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
                
                
            end
        end
    end
    
    
else
    for i=2:size(aligned_neurons,2)-1
        for j=1:size(aligned_neurons,1)
            if iszero(aligned_neurons(j,i))&&~iszero(aligned_neurons(j,i-1))&&~iszero(aligned_neurons(j,i+1))
                
                
                [aligned_neurons,aligned_probabilities]=fill_in_center_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
                
                
            elseif iszero(aligned_neurons(j,i))&~iszero(aligned_neurons(j,i-1))
                
                [aligned_neurons,aligned_probabilities]=fill_in_left_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
            elseif iszero(aligned_neurons(j,i))&~iszero(aligned_neurons(j,i+1))
                [aligned_neurons,aligned_probabilities]=fill_in_right_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
            end
            
        end
    end
end


%Fill in neurons missed neurons in final recording based on second to the last recording
for j=1:size(aligned_neurons,1)
    if iszero(aligned_neurons(j,end))&&~iszero(aligned_neurons(j,end-1))
        [aligned_neurons,aligned_probabilities]=fill_in_left_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,size(aligned_neurons,2),j,min_prob);
        
    end
end










%Repeat from last recording to first
for i=size(aligned_neurons,2)-1:-1:2
    
    for j=1:size(aligned_neurons,1)
        if iszero(aligned_neurons(j,i))&&~iszero(aligned_neurons(j,i-1))&&~iszero(aligned_neurons(j,i+1))
            
            [aligned_neurons,aligned_probabilities]=fill_in_center_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
            
            
            
        elseif iszero(aligned_neurons(j,i))&~iszero(aligned_neurons(j,i-1))
            [aligned_neurons,aligned_probabilities]=fill_in_left_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
        elseif iszero(aligned_neurons(j,i))&~iszero(aligned_neurons(j,i+1))
            [aligned_neurons,aligned_probabilities]=fill_in_right_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,i,j,min_prob);
            
        end
        
    end
end

for j=1:size(aligned_neurons,1)
    if iszero(aligned_neurons(j,1))&&~iszero(aligned_neurons(j,2))
        [aligned_neurons,aligned_probabilities]=fill_in_right_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,1,j,min_prob);
    end
end
end