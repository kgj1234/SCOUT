function unsearched_elements=search_elements(column,index,aligned,unsearched_elements,...
        graph_elements,avail,max_pixel_dist,distance_metrics,max_sess_dist)

for k=1:length(unsearched_elements)
    if k<column & column-k<=max_sess_dist
        ind=find(aligned{k,column}(:,2)==index);
        new_vertices=aligned{k,column}(ind,1);
        for q=1:length(new_vertices)
            p=new_vertices(q);
            if ~ismember(p,graph_elements{k}) & ~ismember(p,unsearched_elements{k})...
                    &ismember(p,avail{k})
                %if k==orig_col 
                    unsearched_elements{k}(end+1)=p;
%                 elseif k<orig_col & dist_metrics{k,orig_col}{1}(p,orig_index)<max_pixel_dist(k,orig_col)
%                     unsearched_elements{k}(end+1)=p;
%                 elseif k>orig_col & dist_metrics{orig_col,k}{1}(orig_index,p)<max_pixel_dist(orig_col,k)
%                     unsearched_elements{k}(end+1)=p;
%                 end
                    
            end
        end
    elseif k>column &k-column<=max_sess_dist
        ind=find(aligned{column,k}(:,1)==index);
        new_vertices=aligned{column,k}(ind,2);
        for q=1:length(new_vertices)
            p=new_vertices(q);
            if ~ismember(p,graph_elements{k}) & ~ismember(p,unsearched_elements{k})&ismember(p,avail{k})
                %if k==orig_col 
                    unsearched_elements{k}(end+1)=p;
%                 elseif k<orig_col & dist_metrics{k,orig_col}{1}(p,orig_index)<max_pixel_dist(k,orig_col)
%                     unsearched_elements{k}(end+1)=p;
%                 elseif k>orig_col & dist_metrics{orig_col,k}{1}(orig_index,p)<max_pixel_dist(orig_col,k)
%                     unsearched_elements{k}(end+1)=p;
%                 end
            end
        end
        
    end
end
        

