function [nonempty,indices]=number_nonempty(current_list);
nonempty=0;
indices=[];
for i=1:length(current_list)
    if ~isempty(current_list{i})
        nonempty=nonempty+1;
        indices=[indices,i];
    end
end
end
