function [idx] = kmedoids_cluster_constrained(X, k,chain_prob,num_sessions,session_ids)

for l=1:max(session_ids)
    ind=find(session_ids==l);
    X(ind,ind)=-10000000;
end
for l=1:size(X,1)
    X(l,l)=1;
end

[a,b]=groupcounts(session_ids');
[M,I]=max(a);
start=find(session_ids==b(I));
if length(start)<k
    remain=setdiff(1:length(session_ids),start);
    perm=randperm(length(remain),k-length(start));
    start=[start,remain(perm)];
end

idx=randi(k,size(X,1),1);
[idx,start]=avg_cluster(1-X,k,idx,start,15,100,session_ids,chain_prob);
[idx,start]=avg_cluster(1-X,k,idx,start,15,0.002,session_ids,chain_prob);



while true
    break_loop=true;
    for l=1:max(idx)
        nodes=find(idx==l);
        curr_mat=X(nodes,nodes);
        node_prob=1-(sum(curr_mat<=0,'all'))/(length(nodes)^2);
      
        if node_prob<chain_prob || length(nodes)>num_sessions ||sum(X(nodes,nodes)<0,'all')>0
            break_loop=false;
            vals=sum(curr_mat,1);
            [~,I]=min(vals);
            idx(nodes(I))=max(idx)+1;
            start(end+1)=nodes(I);
            k=k+1;
            break
        end
    end

    
    [idx,start]=avg_cluster(1-X,k,idx,start,15,.002,session_ids,chain_prob);
    if break_loop
        while true
            break_secondloop=true;
        for q=1:max(idx)
            nodes=find(idx==q);
            sessions=session_ids(nodes);
            if length(unique(sessions))~=length(sessions)
                break_secondloop=false;
                [~,uniq_vals]=unique(sessions);
                dup=sessions(setdiff(1:length(sessions),uniq_vals));
                dup_nodes=nodes(ismember(sessions,dup));
                vals=sum(X(dup_nodes,nodes),2);
                [~,I]=min(vals);
                
                
                poss_clust=zeros(1,max(idx));
                for l=1:max(idx)
                    if l~=q
                        tempnode=find(idx==l);
                        tempnode1=[tempnode,nodes(I)];
                        poss_clust(l)=1-(sum(X(tempnode1,tempnode1)==0,'all')-length(tempnode1))/(length(tempnode1)^2-length(tempnode1))+10^(-6)*mean(X(tempnode1,tempnode1),'all');
                        if ismember(sessions(I),session_ids(tempnode));
                            poss_clust(l)=0;
                        end
                    end
                end
                
                [M,J]=max(poss_clust);
                if M>chain_prob
                    idx(nodes(I))=J;
                else
                    idx(dup_nodes(I))=max(idx)+1;
                    start(end+1)=dup_nodes(I);
                    k=k+1;
                    
                end
            end
            
        end
        if break_secondloop==true
            break
        end
        end
            
        if break_loop
            break
        end
    end
                
            
            
        
        
        
    end
    
end

    
    
    
    
    


