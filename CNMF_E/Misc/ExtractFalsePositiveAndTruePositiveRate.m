function [false_positives,true_positives]=ExtractFalsePositiveAndTruePositiveRate(neurons,C,false_pos_max,true_pos_min)
false_positives={};
for i=1:length(neurons)
    false_positives{i}.KL=neurons{i}.KL;
    false_positives{i}.min_pnr=neurons{i}.options.min_pnr;
   
    true_positives{i}.KL=neurons{i}.KL;
    true_positives{i}.min_pnr=neurons{i}.options.min_pnr;
    
    correlations=correlations_positive(neurons{i}.C,C);
    maxim=max(correlations,[],2);
    maxim1=max(correlations,[],1);
    
    false_positives{i}.false_pos_num=sum(maxim<false_pos_max);
    false_positives{i}.false_pos_rate=false_positives{i}.false_pos_num/length(maxim);
    
    true_positives{i}.true_neurons_detected=sum(maxim1>true_pos_min);
    true_positives{i}.per_neurons_detected=true_positives{i}.true_neurons_detected/length(maxim1);
    
    true_positives{i}.true_pos_num=sum(maxim>true_pos_min);
    true_positives{i}.true_pos_rate=true_positives{i}.true_pos_num/length(maxim);
    
    
    
end