function [aligned_neurons,max_miss_conn,smallest_gap,first_bad,first_comp]=generate_register_rows(aligned_neurons,col,graph_elements,...
    curr_dist,max_gap,max_miss_conn,curr_gap,curr_miss_conn,max_sess_dist,first,chain_prob,req_conn,first_comp)

if exist('first_bad','var')&first_bad
    aligned_neurons=[];
    smallest_gap=max_gap;
    return
end
if ~exist('first_comp','var')
    first_comp=false;
end

first_bad=false;
smallest_gap=max_gap;
ind=curr_gap>max_gap|curr_miss_conn>max_miss_conn(col);
aligned_neurons(ind,:)=[];
curr_gap(ind,:)=[];
curr_miss_conn(ind,:)=[];
if isempty(aligned_neurons)|isempty(curr_gap)|isempty(curr_miss_conn)
    return
end

new_aligned=[];

if col>size(aligned_neurons,2)
    max_miss_conn(end)=min(min(curr_miss_conn(curr_gap==min(curr_gap))),max_miss_conn(end));
    smallest_gap=min(curr_gap);
    first_comp=true;
    ind=curr_gap>max_gap|curr_miss_conn>max_miss_conn(end);
    aligned_neurons(ind,:)=[];
    curr_gap(ind,:)=[];
    curr_miss_conn(ind,:)=[];
    return
end
if col<=size(aligned_neurons,2)
    
    
    
    
    min_val=max(1,col-max_sess_dist);
    max_val=min(col+max_sess_dist,size(aligned_neurons,2));
    unique_rows=unique(aligned_neurons(:,min_val:max_val),'rows','stable');
    unique_rows=[zeros(size(unique_rows,1),min_val-1),unique_rows];
    
    
    for k=1:size(unique_rows,1)
        non_zero=find(unique_rows(k,1:col-1)>0);
        non_zero(abs(non_zero-col)>max_sess_dist)=[];
        poss_ind=1:length(graph_elements{col});
        row_miss=zeros(length(poss_ind),1);
        for j=non_zero
            index=find(graph_elements{j}==unique_rows(k,j));
            row_miss=row_miss+~isnan(curr_dist{j,col}(index,:))';
      
            
            
        end
        row_miss=length(non_zero)-row_miss;
        sim_ind=find(all(aligned_neurons(:,min_val:max_val)==unique_rows(k,min_val:max_val),2));
        temp=aligned_neurons(sim_ind,:);
        temp=reshape(repmat(temp,[1,length(graph_elements{col}(poss_ind))])',size(aligned_neurons,2),[])';
        
        temp_miss=curr_miss_conn(sim_ind,:);
        temp_miss=reshape(repmat(temp_miss,[1,length(graph_elements{col}(poss_ind))])',1,[])';
        
        temp_gap=curr_gap(sim_ind,:);
        temp_gap=reshape(repmat(temp_gap,[1,length(graph_elements{col}(poss_ind))])',1,[])';
        
        
        temp(:,col)=repmat(graph_elements{col}(poss_ind)',[length(sim_ind),1]);
        temp_miss=temp_miss+repmat(row_miss,[length(sim_ind),1]);
        
        if ~exist('smallest_gap','var')
            smallest_gap=max_gap;
        end
        del_ind=temp_gap>=smallest_gap&temp_miss>max_miss_conn(col);
        keep_miss=min(temp_miss);
        temp(del_ind,:)=[];
        temp_miss(del_ind)=[];
        temp_gap(del_ind)=[];
        
        if isempty(temp)
            continue
        end
        
        min_gap_ind=find(temp_gap==min(temp_gap));
        [~,idx]=sort(temp_miss(min_gap_ind));
      
        min_temp=temp(idx,:);
        temp(min_gap_ind,:)=[];
        temp=[min_temp;temp];
        
        min_miss=temp_miss(idx);
        temp_miss(min_gap_ind,:)=[];
        temp_miss=[min_miss;temp_miss];
        
        min_gap=temp_gap(idx);
        temp_gap(min_gap_ind,:)=[];
        temp_gap=[min_gap,temp_gap];
        
        
        curr_first=false;
        if k==1
            curr_first=true;
        end
        max_miss_conn(col)=min(max_miss_conn(col),1.5*(1+min(temp_miss)));
        [temp,max_miss_conn,smallest_gap,first_bad,first_comp]=generate_register_rows(temp,col+1,graph_elements,curr_dist,max_gap,max_miss_conn,temp_gap,temp_miss,max_sess_dist,curr_first&first,chain_prob,req_conn,first_comp);
        
        curr_conn=construct_req_conn(col+1,max_sess_dist,min(curr_gap));
        if ((isempty(temp)&(curr_conn-keep_miss<.9*(curr_conn*chain_prob)))|first_bad)
            if ~first_comp
                first_bad=true;
                break
            
            end
        end
        
        new_aligned=[new_aligned; temp];
    end
  
    gap_ind=curr_gap<max_gap;
    gap_aligned=generate_register_rows(aligned_neurons(gap_ind,:),col+1,graph_elements,curr_dist,max_gap,...
        max_miss_conn,curr_gap(gap_ind,:)+1,curr_miss_conn(gap_ind,:),max_sess_dist,first,chain_prob,req_conn,first_comp);
    new_aligned=[new_aligned;gap_aligned];
    
end
if first_bad
    aligned_neurons=[];
    smallest_gap=max_gap;
    return
end
aligned_neurons=new_aligned;
if ~exist('smallest_gap','var')
    smallest_gap=min(curr_gap);
end
    