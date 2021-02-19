function probabilities=extract_weighted_probabilities(weights,corr_prob,dist_prob)
if weights(1)>0&exist('corr_prob','var')&~isempty(corr_prob)
    prob=corr_prob;
else
    prob=[];
    weights(1)=[];
end
if isempty(prob)
    prob=vertcat(dist_prob{:})';
else
    prob(:,end+1:length(dist_prob)+1)=vertcat(dist_prob{:})';
end
prob(isnan(prob))=0;


consensus_matrices=zeros(size(prob,1),size(prob,1),100);
curr_weights=zeros(100,length(weights));
parfor j=1:100
    curr_weights(j,:)=generate_weights(weights);
   
    
    curr_prob=sum(curr_weights(j,:).*prob,2);
    consensus_matrices(:,:,j)=bsxfun(@lt,curr_prob,curr_prob');
end
consensus_matrix=mean(consensus_matrices,3);
%consensus_matrix(consensus_matrix<.5)=0;
%consensus_matrix(consensus_matrix>=.5)=1;
consensus_score=mean(abs(consensus_matrices-consensus_matrix),[1,2]);
[~,I]=min(consensus_score);

% if isempty(corr_prob)
%     curr_weights(I,:)=[5,6,8]/(5+6+8);
% else
%     curr_weights(I,:)=[4,5,6,8]/(4+5+6+8);
% end
probabilities=sum(curr_weights(I,:).*prob,2);
end
    
    
