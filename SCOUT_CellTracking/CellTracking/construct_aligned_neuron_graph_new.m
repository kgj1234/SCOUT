function [aligned_neurons,aligned_probabilities,avail]=construct_aligned_neuron_graph_new(aligned,...
    probabilities,index,column,avail,size_vec,dist_vals,min_prob,method,penalty,max_sess_dist,chain_prob,max_gap,max_pixel_dist,distance_metrics,centroids)
%max_pixel_dist(max_pixel_dist>0)=max(max_pixel_dist(:));
for k=1:length(avail)
    central_elements{k}=[];
    noncentral_elements{k}=[];
    all_elements{k}=[];
    
end

for k=1:length(all_elements)
    dist=pdist2(centroids{column}(index,:),centroids{k});
    ind=find(dist<max_pixel_dist(column,k)/2);
    central_elements{k}=ind;
    ind=find(dist<max_pixel_dist(column,k));
    all_elements{k}=ind;
    noncentral_elements{k}=setdiff(all_elements{k},central_elements{k});
%     central_elements{k}=intersect(central_elements{k},avail{k});
%     all_elements{k}=intersect(all_elements{k},avail{k});
%     noncentral_elements{k}=intersect(noncentral_elements{k},avail{k});
    
end
if ~ismember(index,central_elements{column})
    central_elements{column}(end+1)=index;
    all_elements{column}(end+1)=index;
end

for k=1:length(avail)
    avail{k}=setdiff(avail{k},central_elements{k});
end


curr_overlap=cell(size(probabilities));
curr_dist=cell(size(probabilities));
for k=1:size(curr_dist,1)
    for j=k+1:size(curr_dist,2)
        if abs(k-j)<=max_sess_dist
            
        matrix=zeros(length(all_elements{k}),length(all_elements{j}));
      
        for p=1:size(matrix,1)
            for q=1:size(matrix,2);
                temp=find(sum([all_elements{k}(p),all_elements{j}(q)]==aligned{k,j},2)==2);
                if length(temp)>0
                    matrix(p,q)=probabilities{k,j}(temp);
                else
                    matrix(p,q)=nan;
                end
            end
        end
        
        
        curr_dist{k,j}=matrix;
        end
    end
end
test_elements=all_elements;
test_central=central_elements;
element_length=cellfun(@length,all_elements);

curr_missing=0;
curr_gap=0;
curr_aligned=[];
while curr_gap<=max_gap & sum(element_length)>0 
  
    aligned_neurons={};
    element_length=cellfun(@length,all_elements);
    if length(all_elements)-sum(element_length>0)>max_gap
        break
    end
    central_element_length=cellfun(@length,central_elements);
    if length(all_elements)-sum(element_length>0)<=curr_gap&sum(central_element_length)>0
    
    total_conn=construct_req_conn(length(all_elements),max_sess_dist,curr_gap);
    req_conn=ceil(chain_prob*total_conn);
%     decrease_index=ceil(total_conn/5);
%     vals=total_conn:-decrease_index:req_conn;
%     vals(1)=total_conn-3;
%     
%     vals(vals<total_conn-3)=[];
%     if vals(end)~=req_conn
%         vals(end+1)=req_conn;
%     end
    vals=req_conn;
    for j=vals
        aligned_neurons={};
        
        central_element_length=cellfun(@length,central_elements);
        index=find(central_element_length);
        if isempty(index)
            break
        end
        index=index(1);
        if index>curr_gap+1
            break
        end
        aligned_neurons=cell(length(central_elements{index}),1);
        for k=1:length(central_elements{index})
            temp_aligned=zeros(1,length(all_elements));
            temp_aligned(index)=central_elements{index}(k);
            aligned_neurons{k}=generate_register_rows(temp_aligned,index+1,all_elements,...
                curr_dist,curr_gap,total_conn-j*ones(1,length(all_elements)+1),index-1,0,max_sess_dist,true,chain_prob,req_conn,false);
        end
        aligned_neurons=reshape(aligned_neurons,[],1);
        aligned_neurons=vertcat(aligned_neurons{:});
        %Construct chain probabilities
        aligned_probabilities=construct_combined_probabilities_adj(aligned_neurons,probabilities,aligned,dist_vals,min_prob,method,penalty,max_sess_dist);
        del_ind=aligned_probabilities<chain_prob;
        aligned_neurons(del_ind,:)=[];
        aligned_probabilities(del_ind,:)=[];
        
        [aligned_neurons,aligned_probabilities]=...
            Remove_Repeats_adj(aligned_neurons,aligned_probabilities,...
            size_vec,true,probabilities,aligned,min_prob,dist_vals,...
        max_gap,max_sess_dist,chain_prob,false);
        if ~isempty(aligned_neurons)
        for k=1:length(avail)
            for j=k+1:length(avail)
                try
                    ind1=ismember(all_elements{k},aligned_neurons(:,k));
                    curr_dist{k,j}(ind1,:)=[];
                end
                try
                    ind2=ismember(all_elements{j},aligned_neurons(:,j));
                    curr_dist{k,j}(:,ind2)=[];
                end
        end
        end
        for k=1:length(avail)
            try
                ind1=ismember(all_elements{k},aligned_neurons(:,k));
                all_elements{k}(ind1)=[];
            end
            try
                ind1=ismember(central_elements{k},aligned_neurons(:,k));
                central_elements{k}(ind1)=[];
            end
            try
                ind1=ismember(noncentral_elements{k},aligned_neurons(:,k));
                noncentral_elements{k}(ind1)=[];
            end
        end
        end
        curr_aligned=[curr_aligned;aligned_neurons];
        
    end
    if ~exist('aligned_neurons','var')|isempty(aligned_neurons)
        curr_gap=curr_gap+1;
    end
    else
        curr_gap=curr_gap+1;
    end
end

for k=1:length(avail)
    try
    avail{k}=setdiff(avail{k},curr_aligned(:,k));
    end
end
aligned_neurons=curr_aligned;
aligned_probabilities=construct_combined_probabilities_adj(aligned_neurons,probabilities,aligned,dist_vals,min_prob,method,penalty,max_sess_dist);
     

