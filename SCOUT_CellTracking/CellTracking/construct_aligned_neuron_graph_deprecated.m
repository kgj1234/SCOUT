function [aligned_neurons,aligned_probabilities,avail]=construct_aligned_neuron_graph(aligned,...
    probabilities,index,column,avail,size_vec,dist_vals,min_prob,method,penalty,max_sess_dist,chain_prob,max_gap,max_pixel_dist,distance_metrics)
%max_pixel_dist(max_pixel_dist>0)=max(max_pixel_dist(:));
for k=1:length(avail)
    graph_elements{k}=[];
    unsearched_elements{k}=[];
end

unsearched_elements{column}(1)=index;

while true
    for k=1:length(unsearched_elements)
        if length(unsearched_elements{k})>0 
            for j=1:length(unsearched_elements{k})
                unsearched_elements=search_elements(k,unsearched_elements{k}(j),aligned,...
                    unsearched_elements,graph_elements,avail,max_pixel_dist,distance_metrics,max_sess_dist);
                graph_elements{k}(end+1)=unsearched_elements{k}(j);
            end
            unsearched_elements{k}=[];
        end
    end
    %unsearched_elements{column}=[];
    total=0;
    for k=1:length(unsearched_elements)
        if length(unsearched_elements{k})>0
            total=1;
        end
    end
    if total==0
        break
    end
end
curr_overlap=cell(size(probabilities));
curr_dist=cell(size(probabilities));
for k=1:size(curr_dist,1)
    for j=k+1:size(curr_dist,2)
        matrix=zeros(length(graph_elements{k}),length(graph_elements{j}));
        matrix1=ones(size(matrix));
        for p=1:size(matrix,1)
            for q=1:size(matrix,2);
                matrix(p,q)=distance_metrics{k,j}{1}(graph_elements{k}(p),graph_elements{j}(q));
                matrix1(p,q)=distance_metrics{k,j}{2}(graph_elements{k}(p),graph_elements{j}(q));
               
            end
        end
        matrix(matrix>max_pixel_dist(k,j))=nan;
        matrix(matrix1<=.0001)=nan;
        
        curr_dist{k,j}=matrix;
        
    end
end
for k=1:length(graph_elements)
    element_length(k)=length(graph_elements{k});
end


aligned_neurons=cell(sum(element_length),1);
parfor l=1:(sum(element_length))
    for k=0:length(element_length)-1
        if sum(element_length(1:k))<l & sum(element_length(1:k+1))>=l
            j=l-sum(element_length(1:k));
            k=k+1;
            break
        end
    end
   
    
    
    
    temp_aligned=zeros(1,length(avail));
    temp_aligned(k)=graph_elements{k}(j);
    aligned_neurons{l}=construct_aligned_neurons_row(temp_aligned,graph_elements,k+1,curr_dist,max_sess_dist,max_gap);

    
    
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
max_gap,max_sess_dist,chain_prob);

for k=1:length(avail)
    avail{k}=setdiff(avail{k},graph_elements{k});
end




                