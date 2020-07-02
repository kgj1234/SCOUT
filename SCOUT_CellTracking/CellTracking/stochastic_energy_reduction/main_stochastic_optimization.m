function probabilities=main_stochastic_optimization(pair_aligned,probabilities,min_prob)
%Checks to see if adjusting probabilities slightly increases the number of identified neurons
%for two session identification.

%%Author Kevin Johnston

%%
distance_matrix=construct_distance_matrix(pair_aligned,probabilities);
%Construct connected componentss
[components,total_conn]=generate_connected_components(distance_matrix);
n1=max(pair_aligned(:,1));
n2=max(pair_aligned(:,2));
ind=cell(1,length(total_conn));
alignments=cell(1,length(total_conn));
ind1=cell(1,length(total_conn));
ind2=cell(1,length(total_conn));
for i=1:length(total_conn)
    ind{i}=find(components==i);
    ind1{i}=ind{i}(ind{i}<=n1);
    ind2{i}=ind{i}(ind{i}>n1);
    if total_conn(i)>2
        %Reshuffle to construct optimal alignments
        distance_matrix(ind{i},ind{i})=construct_optimal_alignments_stochastic([sum(ind{i}<=n1),sum(ind{i}>n1)],distance_matrix(ind{i},ind{i}),min_prob);
    end   
end


for i=1:size(pair_aligned,1)
    probabilities(i)=distance_matrix(pair_aligned(i,1),pair_aligned(i,2)+n1);
end
