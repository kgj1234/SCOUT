function [idx,dup]=elim_dup(idx)
groups=cell(1,length(idx));
for j=1:length(idx)
    curr_index=1:length(idx{j});
    while length(curr_index)>0
        groups{j}{end+1}=find(idx{j}==idx{j}(curr_index(1)));
        curr_index=setdiff(curr_index,groups{j}{end});
    end
    
end
rem=(1);
dup(1)=1;
for j=2:length(idx)
    new=true;
    for l=1:length(rem)
        if isequal(groups{j},groups{rem(l)})
            new=false;
            dup(l)=dup(l)+1;
        end
    end
    if new
        dup(end+1)=1;
        rem(end+1)=j;
    end
end
idx=idx(rem);                     
                
                
        

        