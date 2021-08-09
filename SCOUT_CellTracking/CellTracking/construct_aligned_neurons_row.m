function aligned_neurons_row=construct_aligned_neurons_row(aligned_neurons_row,graph_element,col,cell_dist,max_sess_dist,max_gap)
ind=sum(aligned_neurons_row(:,1:col-1)==0,2)>max_gap;
aligned_neurons_row(ind,:)=[];

if col<=size(aligned_neurons_row,2)
    min_val=max(1,col-max_sess_dist);
    max_val=min(col+max_sess_dist,size(aligned_neurons_row,2));
    unique_rows=unique(aligned_neurons_row(:,min_val:max_val),'rows');
    unique_rows=[zeros(size(unique_rows,1),min_val-1),unique_rows];
    for k=1:size(unique_rows,1)
        non_zero=find(unique_rows(k,1:col-1)>0);
        non_zero(abs(non_zero-col)>max_sess_dist)=[];
        poss_ind=1:length(graph_element{col});
        for j=non_zero
            index=find(graph_element{j}==unique_rows(k,j));
            poss_ind=intersect(poss_ind,find(~isnan(cell_dist{j,col}(index,:))));
            
        end
        sim_ind=find(all(aligned_neurons_row(:,min_val:max_val)==unique_rows(k,min_val:max_val),2));
        temp=aligned_neurons_row(sim_ind,:);
        temp=reshape(repmat(temp,[1,length(graph_element{col}(poss_ind))])',size(aligned_neurons_row,2),[])';
        temp(:,col)=repmat(graph_element{col}(poss_ind)',[length(sim_ind),1]);
        aligned_neurons_row=[aligned_neurons_row;temp];
%     aligned_neurons_row1=aligned_neurons_row;
%     aligned_neurons_row=[];
%     n=size(aligned_neurons_row1,1);
%     for k=1:n
%         aligned_neurons_row=[aligned_neurons_row;repmat(aligned_neurons_row1(k,:),[length(graph_search_elements{col}),1])];
%     end
%     
%     aligned_neurons_row(:,col)=reshape(repmat(graph_search_elements{col},[1,n]),[],1);
%     aligned_neurons_row=construct_aligned_neurons_row(aligned_neurons_row,graph_search_elements,col+1);
    end
    
    aligned_neurons_row=construct_aligned_neurons_row(aligned_neurons_row,graph_element,col+1,cell_dist,max_sess_dist,max_gap);

end

    