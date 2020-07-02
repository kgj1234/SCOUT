function [aligned_neurons,aligned_probabilities]=fill_in_left_adj(aligned_neurons,aligned_probabilities,pair_aligned,probabilities,session_ind,neuron_ind,min_prob)
               try
                 ind=find(pair_aligned{session_ind-1}(:,1)==aligned_neurons(neuron_ind,session_ind-1));
               catch
                   ind=[];
               end
                 if isempty(ind)
                return
                 end
                  try
                 avail=pair_aligned{session_ind-1}(ind,2);
                  catch
                      ind=[];
                  end
            probabilities_agg=probabilities{session_ind-1,session_ind}(ind);

            rem_ind=probabilities_agg<min_prob;
            probabilities_agg(rem_ind,:)=[];
            
      
            ind(rem_ind)=[];
            avail(rem_ind)=[];
            if isempty(ind)
                return
            end
            for q=1:length(ind)
                aligned_neurons(end+1,:)=aligned_neurons(neuron_ind,:);
                    aligned_neurons(end,session_ind)=avail(q);
                aligned_probabilities(end+1,:)=aligned_probabilities(neuron_ind,:);
                aligned_probabilities(end,session_ind-1)=probabilities_agg(q);
               
                
                end
            
            
           
               
                
                
                
                
                
                
                
                aligned_neurons(neuron_ind,:)=[];
                aligned_probabilities(neuron_ind,:)=[];

            