function [aligned_neurons,corr_probabilities,dist_probabilities,KL_probabilities,overlap_probabilities, correlations,dists,overlaps,KLs]=fill_in_center(aligned_neurons,...
    corr_probabilities,dist_probabilities,KL_probabilities,overlap_probabilities, correlations,dists,overlaps,KLs,pair_aligned,corr_prob,KL_prob,dist_prob,overlap_prob,correlation,dist,...
    overlap,KL,session_ind,neuron_ind,min_prob,measures,weights)
         







                avail1=pair_aligned{session_ind-1}(find(pair_aligned{session_ind-1}(:,1)==aligned_neurons(neuron_ind,session_ind-1)),2);
                avail2=pair_aligned{session_ind}(find(pair_aligned{session_ind}(:,2)==aligned_neurons(neuron_ind,session_ind+1)),1);
                avail=intersect(avail1,avail2);
                
                
                for k=length(avail):-1:1
                used{k}=find(avail(k)==aligned_neurons(:,session_ind));
                
                for j=1:length(used{k})
                    if sum(sum(aligned_neurons(used{k}(j),:)==aligned_neurons(neuron_ind,:),2)-sum(~isnan(aligned_neurons(used{k}(j),:))&...
                            ~isnan(aligned_neurons(neuron_ind,:)),2))~=0
                    
                    used{k}(j)=nan;
                    end
                    
                end
                used{k}(isnan(used{k}))=[];
                if sum(~isnan(used{k}))==0
                    used{k}=[];
                    avail(k)=[];
                end
                end

                
                
                if isempty(avail)
                    return
                end
                probabilities={};
                for k=1:length(avail)
                ind1=find(pair_aligned{session_ind-1}(:,2)==avail(k));
                ind2=find(pair_aligned{session_ind}(:,1)==avail(k));
                ind1_a=find(pair_aligned{session_ind-1}(:,1)==aligned_neurons(neuron_ind,session_ind-1));
                ind2_a=find(pair_aligned{session_ind}(:,2)==aligned_neurons(neuron_ind,session_ind+1));
            ind1=intersect(ind1,ind1_a);
            ind2=intersect(ind2,ind2_a);
            probabilities1=sum(weights.*[corr_prob{session_ind-1}(ind1),KL_prob{session_ind-1}(ind1),overlap_prob{session_ind-1}(ind1),dist_prob{session_ind-1}(ind1)],2,'omitnan');
            probabilities2=sum(weights.*[corr_prob{session_ind}(ind2),KL_prob{session_ind}(ind2),overlap_prob{session_ind}(ind2),dist_prob{session_ind}(ind2)],2,'omitnan');
            probabilities{k}=(max(probabilities1,[],1)+max(probabilities2,[],1))/2;
                end
                probabilities=vertcat(probabilities{:});
            %num_pos=sum(probabilities-min_prob>0,2);
            %avail(num_pos<max(num_pos))=[];
            %used(num_pos<max(num_pos))=[];
            %probabilities(num_pos<max(num_pos))=[];
            [M,I]=max(mean(probabilities,2));
            avail=avail(I);
            used=used{I};
            [M,I]=max(sum(~isnan(aligned_neurons(used,:)),2));
            used=used(I);
            
            ind1=find(pair_aligned{session_ind-1}(:,1)==aligned_neurons(neuron_ind,session_ind-1)&pair_aligned{session_ind-1}(:,2)==avail);
            probabilities=sum(weights.*[corr_prob{session_ind-1}(ind1),KL_prob{session_ind-1}(ind1),overlap_prob{session_ind-1}(ind1),dist_prob{session_ind-1}(ind1)]);
            %num_pos=sum(probabilities-min_prob>0,2);
            %probabilities(num_pos<2,:)=[];
            %ind1(num_pos<2,:)=[];
            [M,I]=max(mean(probabilities,2));
            ind1=ind1(I);
            
            
            ind2=find(pair_aligned{session_ind}(:,2)==aligned_neurons(neuron_ind,session_ind+1)&pair_aligned{session_ind}(:,1)==avail);
            probabilities=sum(weights.*[corr_prob{session_ind}(ind2),KL_prob{session_ind}(ind2),overlap_prob{session_ind}(ind2),dist_prob{session_ind}(ind2)]);
            %num_pos=sum(probabilities-min_prob>0,2);
            %probabilities(num_pos<2,:)=[];
            %ind2(num_pos<2,:)=[];
            [M,I]=max(mean(probabilities,2));
            ind2=ind2(I);
            
            
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
            
            
            aligned_neurons(neuron_ind,session_ind)=avail;
            corr_probabilities(neuron_ind,session_ind-1)=corr_prob{session_ind-1}(ind1);
            dist_probabilities(neuron_ind,session_ind-1)=dist_prob{session_ind-1}(ind1);
            KL_probabilities(neuron_ind,session_ind-1)=KL_prob{session_ind-1}(ind1);
            overlap_probabilities(neuron_ind,session_ind-1)=overlap_prob{session_ind-1}(ind1);
            correlations(neuron_ind,2*(session_ind-1)-1:2*(session_ind-1))=correlation{session_ind-1}(ind1,:);
            dists(neuron_ind,session_ind-1)=dist{session_ind-1}(ind1);
            overlaps(neuron_ind,session_ind-1)=overlap{session_ind-1}(ind1);
            KLs(neuron_ind,session_ind-1)=KL{session_ind-1}(ind1);
            
            
             corr_probabilities(neuron_ind,session_ind)=corr_prob{session_ind}(ind2);
            dist_probabilities(neuron_ind,session_ind)=dist_prob{session_ind}(ind2);
            KL_probabilities(neuron_ind,session_ind)=KL_prob{session_ind}(ind2);
            overlap_probabilities(neuron_ind,session_ind)=overlap_prob{session_ind}(ind2);
            correlations(neuron_ind,2*(session_ind)-1:2*(session_ind))=correlation{session_ind}(ind2,:);
            dists(neuron_ind,session_ind)=dist{session_ind}(ind2);
            overlaps(neuron_ind,session_ind)=overlap{session_ind}(ind2);
            KLs(neuron_ind,session_ind)=KL{session_ind}(ind2);