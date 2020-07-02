function [aligned_neurons,aligned_probabilities]=fill_in_center_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,session_ind,neuron_ind,min_prob)
       






                try
                avail1=pair_aligned{session_ind-1}(find(pair_aligned{session_ind-1}(:,1)==aligned_neurons(neuron_ind,session_ind-1)),2);
                avail2=pair_aligned{session_ind}(find(pair_aligned{session_ind}(:,2)==aligned_neurons(neuron_ind,session_ind+1)),1);
                avail=intersect(avail1,avail2);
                catch
                    avail=[];
                end

                
                
                if isempty(avail)
                    return
                end
                
                for k=1:length(avail)
                    try
                ind1=find(pair_aligned{session_ind-1}(:,2)==avail(k));
                ind2=find(pair_aligned{session_ind}(:,1)==avail(k));
                ind1_a=find(pair_aligned{session_ind-1}(:,1)==aligned_neurons(neuron_ind,session_ind-1));
                ind2_a=find(pair_aligned{session_ind}(:,2)==aligned_neurons(neuron_ind,session_ind+1));
            ind1=intersect(ind1,ind1_a);
            ind2=intersect(ind2,ind2_a);
            probabilities_agg1=probabilities{session_ind-1,session_ind}(ind1);
            probabilities_agg2=probabilities{session_ind,session_ind+1}(ind2);
          
            
            del_ind=probabilities_agg1<min_prob;
            probabilities_agg1(del_ind)=[];
            ind1(del_ind)=[];
           
            del_ind=probabilities_agg2<min_prob;
            probabilities_agg2(del_ind)=[];
            
            ind2(del_ind)=[];
                    catch
                        
                        return
                    end
            if isempty(ind1)||isempty(ind2)
                return
            end
            for q=1:length(ind1)
                for l=1:length(ind2)
                    aligned_neurons(end+1,:)=aligned_neurons(neuron_ind,:);
                    aligned_neurons(end,session_ind)=avail(k);
                    aligned_probabilities(end+1,:)=aligned_probabilities(neuron_ind,:);
                    aligned_probabilities(end,session_ind-1)=probabilities_agg1(q);
                    aligned_probabilities(end,session_ind)=probabilities_agg2(l);
                
                 
                
                end
            end
            
           
               
                
                
                
                end
                
                
                
                aligned_neurons(neuron_ind,:)=[];
                aligned_probabilities(neuron_ind,:)=[];
               