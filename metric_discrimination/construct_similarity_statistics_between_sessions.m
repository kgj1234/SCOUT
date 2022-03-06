function similarity=construct_similarity_statistics_between_sessions(neuron1,neuron2,link,overlap,type);

neurons={neuron1.copy(),neuron2.copy()};
%neurons{1}=estimate_decay_full(neurons{1});
%neurons{2}=estimate_decay_full(neurons{2});
overlap_matrices=construct_overlap_matrix(neurons);
distance_matrices=construct_distance_matrix(neurons);
correlation_matrix=compute_correlation_similarity(neurons,{link},overlap);
JS_matrices=construct_JS_matrix(neurons,inf,overlap_matrices);

ind=find(isoutlier(neurons{1}.SNR));
neurons{1}.SNR(ind)=max(neurons{1}.SNR(setdiff(1:size(neurons{1}.SNR,1),ind)));
ind=find(isoutlier(neurons{2}.SNR));
neurons{2}.SNR(ind)=max(neurons{2}.SNR(setdiff(1:size(neurons{2}.SNR,1),ind)));
neurons{1}.SNR=(neurons{1}.SNR-mean(neurons{1}.SNR))/std(neurons{1}.SNR);
neurons{2}.SNR=(neurons{2}.SNR-mean(neurons{2}.SNR))/std(neurons{2}.SNR);


SNR_dist{1,2}=pdist2(neurons{1}.SNR,neurons{2}.SNR);
decay_dist{1,2}=pdist2(neurons{1}.P.kernel_pars,neurons{2}.P.kernel_pars);

closest_corr=[];
one_nn_corr=[];
three_nn_corr=[];
five_nn_corr=[];
all_nn_corr=[];
closest_snr=[];
one_nn_snr=[];
three_nn_snr=[];
five_nn_snr=[];
all_nn_snr=[];
closest_decay=[];
one_nn_decay=[];
three_nn_decay=[];
five_nn_decay=[];
all_nn_decay=[];

closest_cent=[];
one_nn_cent=[];

closest_JS=[];
one_nn_JS=[];

closest_overlap=[];
one_nn_overlap=[];
for k=1:size(neurons{1}.C,1);
    if min(distance_matrices{1,2}(k,:))>4
        continue
    end
    if isequal(type,'1p')
        close_ind=find(overlap_matrices{1,2}(k,:)>.9);
        if isempty(close_ind)
           continue
        end
    else
        [~,close_ind]=max(overlap_matrices{1,2}(k,:));
    end
    %[~,close_ind]=min(overlap_matrices{1,2}(k,:));
    ind=setdiff(1:size(overlap_matrices{1,2},2),close_ind);
    [~,ind]=sort(distance_matrices{1,2}(k,ind));
    closest_corr=[closest_corr,max(correlation_matrix(k,close_ind))];
    one_nn_corr=[one_nn_corr,correlation_matrix(k,ind(1))];
    three_nn_corr=[three_nn_corr,correlation_matrix(k,ind(1:3))];
    five_nn_corr=[five_nn_corr,correlation_matrix(k,ind(1:5))];
    all_nn_corr=[all_nn_corr,correlation_matrix(k,ind(1:end))];
    
    closest_snr=[closest_snr,min(SNR_dist{1,2}(k,close_ind))];
    one_nn_snr=[one_nn_snr,SNR_dist{1,2}(k,ind(1))];
    three_nn_snr=[three_nn_snr,SNR_dist{1,2}(k,ind(1:3))];
    five_nn_snr=[five_nn_snr,SNR_dist{1,2}(k,ind(1:5))];
    all_nn_snr=[all_nn_snr,SNR_dist{1,2}(k,ind(1:end))];
    
    closest_decay=[closest_decay,min(decay_dist{1,2}(k,close_ind))];
    one_nn_decay=[one_nn_decay,decay_dist{1,2}(k,ind(1))];
    three_nn_decay=[three_nn_decay,decay_dist{1,2}(k,ind(1:3))];
    five_nn_decay=[five_nn_decay,decay_dist{1,2}(k,ind(1:5))];
    all_nn_decay=[all_nn_decay,decay_dist{1,2}(k,ind(1:end))];
    
    closest_cent=[closest_cent,min(distance_matrices{1,2}(k,close_ind))];
    one_nn_cent=[one_nn_cent,distance_matrices{1,2}(k,ind(1))];
    
    closest_JS=[closest_JS,min(JS_matrices{1,2}(k,close_ind))];
    one_nn_JS=[one_nn_JS,JS_matrices{1,2}(k,ind(1))];
   
    closest_overlap=[closest_overlap,max(overlap_matrices{1,2}(k,close_ind))];
    one_nn_overlap=[one_nn_overlap,overlap_matrices{1,2}(k,ind(1))];
   
    
end
similarity.decay.closest=closest_decay;
similarity.decay.one_nn=one_nn_decay;
similarity.decay.three_nn=three_nn_decay;
similarity.decay.five_nn=five_nn_decay;
similarity.decay.all=all_nn_decay;

similarity.corr.closest=closest_corr(~isnan(closest_corr));
similarity.corr.one_nn=one_nn_corr(~isnan(one_nn_corr));
similarity.corr.three_nn=three_nn_corr(~isnan(three_nn_corr));
similarity.corr.five_nn=five_nn_corr(~isnan(five_nn_corr));
similarity.corr.all=all_nn_corr(~isnan(all_nn_corr));

similarity.snr.closest=closest_snr;
similarity.snr.one_nn=one_nn_snr;
similarity.snr.three_nn=three_nn_snr;
similarity.snr.five_nn=five_nn_snr;
similarity.snr.all=all_nn_snr;

similarity.cent.closest=closest_cent;
similarity.cent.one_nn=one_nn_cent;

similarity.JS.closest=closest_JS;
similarity.JS.one_nn=one_nn_JS;

similarity.overlap.closest=closest_overlap;
similarity.overlap.one_nn=one_nn_overlap;
    
