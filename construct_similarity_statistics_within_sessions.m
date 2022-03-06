function similarity=construct_similarity_statistics_within_sessions(neuron);
split_neurons{1}=Sources2D;
split_neurons{2}=Sources2D;
temp{1}=sum(split_neurons{1}.S>0,2);
temp{2}=sum(split_neurons{2}.S>0,2);



mid=floor(size(neuron.C,2)/2);
split_neurons{1}.C_raw=neuron.C_raw(:,1:mid);
split_neurons{2}.C_raw=neuron.C_raw(:,mid:end);
split_neurons{1}.S=neuron.S(:,1:mid);
split_neurons{2}.S=neuron.S(:,mid:end);



split_neurons{1}=estimate_decay_full(split_neurons{1});
split_neurons{2}=estimate_decay_full(split_neurons{2});
split_neurons{1}.C=neuron.C(:,1:mid);
split_neurons{2}.C=neuron.C(:,mid:end);
split_neurons{1}.A=neuron.A;
split_neurons{2}.A=neuron.A;
split_neurons{1}.centroid=neuron.centroid;
split_neurons{2}.centroid=neuron.centroid;

split_neurons{1}=calc_snr(split_neurons{1});
split_neurons{2}=calc_snr(split_neurons{2});
neurons=split_neurons;


neurons{1}.SNR(isoutlier(neurons{1}.SNR))=max(neurons{1}.SNR(setdiff(1:size(neuron.C_raw,1),find(isoutlier(neurons{1}.SNR)))));
neurons{2}.SNR(isoutlier(neurons{2}.SNR))=max(neurons{2}.SNR(setdiff(1:size(neuron.C_raw,1),find(isoutlier(neurons{2}.SNR)))));
neurons{1}.SNR=(neurons{1}.SNR-mean(neurons{1}.SNR))/std(neurons{1}.SNR);
neurons{2}.SNR=(neurons{2}.SNR-mean(neurons{2}.SNR))/std(neurons{2}.SNR);

overlap_matrices=construct_overlap_matrix(neurons);
distance_matrices=construct_distance_matrix(neurons);

SNR_dist{1,2}=pdist2(neurons{1}.SNR,neurons{2}.SNR);
decay_dist{1,2}=pdist2(neurons{1}.P.kernel_pars,neurons{2}.P.kernel_pars);

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
for k=1:size(neurons{1}.C,1);
    [~,ind]=sort(overlap_matrices{1,2}(k,:),'descend');
    ind1=find(overlap_matrices{1,2}(k,ind)==0);
    far_ind=ind(ind1);
    close_ind=setdiff(ind,far_ind);
    [~,ind2]=sort(overlap_matrices{1,2}(k,close_ind),'descend');
    close_ind=close_ind(ind2);
    
    [~,ind2]=sort(distance_matrices{1,2}(k,far_ind),'ascend');
    ind=[close_ind,far_ind(ind2)];
    closest_snr=[closest_snr,SNR_dist{1,2}(k,ind(1))];
    one_nn_snr=[one_nn_snr,SNR_dist{1,2}(k,ind(2))];
    three_nn_snr=[three_nn_snr,SNR_dist{1,2}(k,ind(2:4))];
    five_nn_snr=[five_nn_snr,SNR_dist{1,2}(k,ind(2:6))];
    all_nn_snr=[all_nn_snr,SNR_dist{1,2}(k,ind(2:end))];
    
    
    
    if ~isnan(decay_dist{1,2}(k,ind(1)))
        used(k)=1;
        closest_decay=[closest_decay,decay_dist{1,2}(k,ind(1))];
        ind(isnan(decay_dist{1,2}(k,ind)))=[];
        one_nn_decay=[one_nn_decay,decay_dist{1,2}(k,ind(2))];
        three_nn_decay=[three_nn_decay,decay_dist{1,2}(k,ind(2:4))];
        five_nn_decay=[five_nn_decay,decay_dist{1,2}(k,ind(2:6))];
        all_nn_decay=[all_nn_decay,decay_dist{1,2}(k,ind(2:end))];
    end
end
ind=[find(isoutlier(one_nn_decay)),find(isoutlier(closest_decay))];
closest_decay(ind)=[];
one_nn_decay(ind)=[];
similarity.decay.closest=closest_decay(~isnan(closest_decay));
similarity.decay.one_nn=one_nn_decay(~isnan(one_nn_decay));
similarity.decay.three_nn=three_nn_decay(~isnan(three_nn_decay));
similarity.decay.five_nn=five_nn_decay(~isnan(five_nn_decay));
similarity.decay.all=all_nn_decay(~isnan(all_nn_decay));

similarity.snr.closest=closest_snr;
similarity.snr.one_nn=one_nn_snr;
similarity.snr.three_nn=three_nn_snr;
similarity.snr.five_nn=five_nn_snr;
similarity.snr.all=all_nn_snr;


  