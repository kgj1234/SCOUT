function [aligned_neurons,corr_probabilities,dist_probabilities,KL_probabilities,overlap_probabilities, correlations,dists,overlaps,KLs]=fill_in_right(aligned_neurons,...
    corr_probabilities,dist_probabilities,KL_probabilities,overlap_probabilities, correlations,dists,overlaps,KLs,pair_aligned,corr_prob,KL_prob,dist_prob,overlap_prob,correlation,dist,...
    overlap,KL,session_ind,neuron_ind,min_prob,measures,weights)

                
           used={};
            ind=find(pair_aligned{session_ind}(:,2)==aligned_neurons(neuron_ind,session_ind+1));
            
            for k=length(ind):-1:1
                used{k}=find(pair_aligned{session_ind}(ind(k),1)==aligned_neurons(:,session_ind));
                
                for j=1:length(used{k})
                    if sum(sum(aligned_neurons(used{k}(j),:)==aligned_neurons(neuron_ind,:),2)-sum(~isnan(aligned_neurons(used{k}(j),:))&...
                            ~isnan(aligned_neurons(neuron_ind,:)),2))~=0
                    
                    used{k}(j)=nan;
                    end
                    
                end
                used{k}(isnan(used{k}))=[];
                if sum(~isnan(used{k}))==0
                    used{k}=[];
                    ind(k)=[];
                end
            end
           
            if ~isempty(ind)
               used(isempty(used))=[];  
            probabilities=sum(weights.*[corr_prob{session_ind}(ind),KL_prob{session_ind}(ind),overlap_prob{session_ind}(ind),dist_prob{session_ind}(ind)],2,'omitnan');
            %num_pos=sum(probabilities-min_prob>0,2);
            %used(num_pos<max(num_pos))=[];
            %ind(num_pos<max(num_pos))=[];
            %probabilities(num_pos<max(num_pos),:)=[];
            [M,I]=max(mean(probabilities,2));
            ind=ind(I);
            try
                used=used{I};
            catch
                error('something is wrong')
            end
            [M,I]=max(sum(~isnan(aligned_neurons(used,:)),2));
            used=used(I);
            for m=1:size(aligned_neurons,2)
                if ~isnan(aligned_neurons(used,m))
                    aligned_neurons(neuron_ind,m)=aligned_neurons(used,m);
                end
                try
                if ~isnan(corr_probabilities(used,m))
                corr_probabilities(neuron_ind,m)=corr_probabilities(used,m);
                dist_probabilities(neuron_ind,m)=dist_probabilities(used,m);
                KL_probabilities(neuron_ind,m)=KL_probabilities(used,m);
                overlap_probabilities(neuron_ind,m)=overlap_probabilities(used,m);
                correlations(neuron_ind,2*m-1:2*m)=correlations(used,2*m-1:2*m);
                dists(neuron_ind,m)=dists(used,m);
                overlaps(neuron_ind,m)=overlaps(used,m);
                KLs(neuron_ind,m)=KLs(used,m);
                end
                end
            end
            aligned_neurons(neuron_ind,session_ind)=pair_aligned{session_ind}(ind,1);
            corr_probabilities(neuron_ind,session_ind)=corr_prob{session_ind}(ind);
            dist_probabilities(neuron_ind,session_ind)=dist_prob{session_ind}(ind);
            KL_probabilities(neuron_ind,session_ind)=KL_prob{session_ind}(ind);
            overlap_probabilities(neuron_ind,session_ind)=overlap_prob{session_ind}(ind);
            correlations(neuron_ind,2*(session_ind)-1:2*(session_ind))=correlation{session_ind}(ind,:);
            dists(neuron_ind,session_ind)=dist{session_ind}(ind);
            overlaps(neuron_ind,session_ind)=overlap{session_ind}(ind);
            KLs(neuron_ind,session_ind)=KL{session_ind}(ind);
            end
