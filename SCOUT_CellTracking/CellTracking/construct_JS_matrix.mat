function JS_matrices=construct_JS_matrix(neurons,max_dist_construct,max_sess_dist)

%Construct JS distance between all neuron pairs extracted from
%different recordings
%inputs
%   neurons: cell array of extracted neural activity from each recording,
%       Sources2D

%outputs
%   JS_matrices: cell array of JS distance matrices
%Author: Kevin Johnston, University of California, Irvine


total=0;
clear display_progress_bar
display_progress_bar('Computing JS matrices: ',false);
num_vids=length(neurons);
JS_matrices=cell(num_vids-1,num_vids);
parfor i=1:(num_vids-1)*num_vids
    [a,b]=ind2sub([num_vids-1,num_vids],i);
    if b>a & (isempty(max_sess_dist)||b-a<= max_sess_dist)
        JS_matrices{i}=KLDiv_full(neurons{a},neurons{b},max_dist_construct);
    elseif b>a
        JS_matrices{i}=[];
        %total=total+1;
        %display_progress_bar((total/((length(neurons)+1)*(length(neurons))/2-1)*100),false);
    end
end

display_progress_bar(' Completed',false);
display_progress_bar('terminated',true);