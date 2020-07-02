function [aligned_neurons,aligned_probabilities]=mergeNeurons(aligned_neurons,aligned_probabilities);
%Merge neuron chains if every common element between chains is the same




total_indices=1:size(aligned_neurons,1);
iter=1;
while iter<=length(total_indices)
    i=total_indices(iter);
    
    if sum(aligned_neurons(i,:))>0
        pos_ind=find(aligned_neurons(i,:)>0);
        ind=find((sum((aligned_neurons(i,pos_ind)-aligned_neurons(:,pos_ind))==0,2)==length(pos_ind)));
        if length(ind)>1
            aligned_neurons(i,:)=0;
        else
            ind=[];
            pos_ind=find(aligned_neurons(i,:)>0);
            ind=find(sum((abs(~iszero(aligned_neurons(i,:)-aligned_neurons))-xor(~iszero(aligned_neurons(i,:)),...
                ~iszero(aligned_neurons))),2)==0&sum(aligned_neurons(i,:)-aligned_neurons>0,2)>0&sum(aligned_neurons(i,:)-aligned_neurons<0,2)>0&...
                sum(aligned_neurons(i,pos_ind)==aligned_neurons(:,pos_ind),2)>0);
            'hi';
            if length(ind)>0
                new_neurons=aligned_neurons(ind,:);
                new_neurons(:,pos_ind)=repmat(aligned_neurons(i,pos_ind),length(ind),1);
                new_prob=zeros(length(ind),size(aligned_probabilities,2));
                [new_neurons,new_prob]=Eliminate_Duplicates(new_neurons,new_prob);
                aligned_neurons=[aligned_neurons;new_neurons];
                aligned_probabilities=[aligned_probabilities;new_prob];
                used_ind=[];
                for k=size(aligned_neurons,1)-length(ind)+1:size(aligned_neurons,1)
                    used_ind=[used_ind,find(sum(abs(aligned_neurons(k,:)-aligned_neurons(1:end-length(ind),:)),2)==0)];
                end
                aligned_neurons(end-length(ind)+used_ind,:)=[];
                aligned_probabilities(end-length(ind)+used_ind,:)=[];
                end
       
        end
    
    end
    iter=iter+1;
end
rem_ind=find(sum(iszero(aligned_neurons),2)==size(aligned_neurons,2));
aligned_neurons(rem_ind,:)=[];
aligned_probabilities(rem_ind,:)=[];
[aligned_neurons,aligned_probabilities]=Eliminate_Duplicates(aligned_neurons,aligned_probabilities);
