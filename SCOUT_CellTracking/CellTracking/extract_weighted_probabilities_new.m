function probabilities=extract_weighted_probabilities_new(weights,corr_prob,dist_prob)
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
weights=generate_weights(weights);
probabilities=sum(weights.*prob,2);
