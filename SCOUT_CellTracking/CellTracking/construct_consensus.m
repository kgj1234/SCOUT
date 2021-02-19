function consensus_matrix=construct_consensus(idx,used,total_ind)
consensus_matrix=zeros(total_ind,total_ind);
denominator=zeros(total_ind,total_ind);


    

for j=1:length(idx)
    denominator(used{j},used{j})=denominator(used{j},used{j})+1;
    for k=1:max(idx{j})
        consensus_matrix(used{j}(idx{j}==k),used{j}(idx{j}==k))=consensus_matrix(used{j}(idx{j}==k),used{j}(idx{j}==k))+1;
    end
end
consensus_matrix=consensus_matrix./denominator;

        
        