function [assign,medoidIndex,k]=avg_cluster(xDist,k,assign,medoidIndex,maxIterations,alpha,session_ids,chain_prob);




n = size(xDist,1);
for indl=1:k
    dup_sess(indl)=~(length(session_ids(assign==indl))==length(unique(session_ids(assign==indl))));
end                



if isempty(assign)
    [~,assign] = min(xDist(:,medoidIndex),[],2);
end
if isempty(maxIterations)
    maxIterations=100;
end
if length(unique(assign))~=k
    ind=randperm(length(assign),k);
    assign(ind)=1:k;
end
total=0;
for j=1:size(xDist,1)
    if sum(xDist(j,:)>=1)==size(xDist,1)-1
        total=total+1;
    end
end
if total>k
    k=total;
end
   
gain=zeros(1,k);
gaini=zeros(k,n-k);
swapgain=zeros(k,n);
min_swap=-inf;
min_shift=-inf;
swapped=[0,0];
dup_swap=[];


swap_iter=1;

change=[];
for kter = 1:maxIterations
    %change=[];
    nochange = false;
    
        


    if k==1
        gaint = mean(xDist,'all');
        nochange=true;
    else
        for j=1:k
            group_mem(j)=sum(assign==j);
            group_score(j)=sum(xDist(assign==j,assign==j),'all')/((group_mem(j)^2-group_mem(j)));
            group_one(j)=sum(xDist(assign==j,assign==j)>=1,'all');
            group_score(isnan(group_score))=0;
            if group_mem(j)<=1
                group_one_score(j)=0;
            else
                group_one_score(j)=group_one(j)/(group_mem(j)^2-group_mem(j));
            end
        end
        

        for j=1:k
            for l=1:n
                if assign(l)~=j& ~any(session_ids(l)==session_ids(assign==j))&...
                        (isempty(change)||(ismember(assign(l),change)||ismember(j,change)))
                    temp_assign=assign;
                    temp_assign(l)=j;
                    ind_old=assign(l);
                    ind_new=j;
                    temp_one(ind_new)=sum(xDist(temp_assign==ind_new,temp_assign==ind_new)>=1,'all');
                    temp_one(ind_old)=sum(xDist(temp_assign==ind_old,temp_assign==ind_old)>=1,'all');
                    temp_score(ind_new)=sum(xDist(temp_assign==ind_new,temp_assign==ind_new),'all')/((sum(temp_assign==ind_new)^2-sum(temp_assign==ind_new)));
                    temp_score(ind_old)=sum(xDist(temp_assign==ind_old,temp_assign==ind_old),'all')/((sum(temp_assign==ind_old)^2-sum(temp_assign==ind_old)));
                    
                    temp_one_score(ind_old)=temp_one(ind_old)/(sum(temp_assign==ind_old)^2-sum(temp_assign==ind_old));
                    temp_one_score(ind_new)=temp_one(ind_new)/(sum(temp_assign==ind_new)^2-sum(temp_assign==ind_new));
                    temp_score(isnan(temp_score))=0;
                    temp_one_score(isnan(temp_one_score))=0;
                    
                    dup_sess(ind_old)=~(length(session_ids(temp_assign==ind_old))==length(unique(session_ids(temp_assign==ind_old))));
                    dup_sess(ind_new)=~(length(session_ids(temp_assign==ind_new))==length(unique(session_ids(temp_assign==ind_new))));
                   
                   
                    %shiftgain(j,l)=(-sum(NaN20(xDist(l,(assign==assign(l)&((1:n)'~=l))))==1)+...
                    %sum(NaN20(xDist(l,assign==j))==1));
                    shiftgain(j,l)=temp_one(ind_old)-group_one(ind_old)+temp_one(ind_new)-group_one(ind_new)+...
                        10^(-2)*(temp_score(ind_old)-group_score(ind_old)+temp_score(ind_new)-group_score(ind_new));
%                     if max(groupcounts((session_ids(assign==assign(l))')))>1
%                         shiftgain(j,l)=shiftgain(j,l)+(-NaN20(mean(xDist(l,(assign==assign(l)&((1:n)'~=l))),'all'))+...
%                     NaN20(mean(xDist(l,assign==j),'all')));
%                     else
%                         shiftgain(j,l)=shiftgain(j,l)+(10^(-2))*(-NaN20(mean(xDist(l,(assign==assign(l)&((1:n)'~=l))),'all'))+...
%                     NaN20(mean(xDist(l,assign==j),'all')));
%                     end
                    %if (temp_one_score(ind_old)>=1-chain_prob||temp_score(ind_old)>=1-chain_prob)||temp_score(ind_new)>=1-chain_prob||temp_one_score(ind_new)>=1-chain_prob||dup_sess(ind_new)||dup_sess(ind_old)
                    %    shiftgain(j,l)=inf;
                    if group_mem(j)<group_mem(assign(l))-1&group_one_score(ind_old)<=1-chain_prob&group_score(ind_old)<=1-chain_prob
                        %shiftgain(j,l)=shiftgain(j,l)+alpha;
                        shiftgain(j,l)=inf;
                    elseif (group_mem(j)>=group_mem(assign(l))&(temp_one_score(ind_new)<=1-chain_prob&temp_score(ind_new)<=1-chain_prob))||...
                            group_one_score(ind_old)>=1-chain_prob||group_score(ind_old)>=1-chain_prob||(group_one_score(ind_new)>=1-chain_prob||group_score(ind_new)>=1-chain_prob)
                        shiftgain(j,l)=shiftgain(j,l)-alpha;
                    elseif group_mem(j)<group_mem(assign(l))-1&((temp_one_score(ind_old)>=1-chain_prob||temp_score(ind_old)>=1-chain_prob)||temp_score(ind_new)>=1-chain_prob||temp_one_score(ind_new)>=1-chain_prob||dup_sess(ind_new)||dup_sess(ind_old))
                        shiftgain(j,l)=shiftgain(j,l)+alpha;
                    
                    end
                    
                    
                      
                  
                       %temp_one_score(isnan(temp_one_score))=1;
                    if temp_one_score(ind_old)==1||temp_one_score(ind_new)==1
                        shiftgain(j,l)=inf;
                    end
                    
                    
                else
                    shiftgain(j,l)=inf;
                end
                
            end
        end
        for j=1:n
            for l=j+1:n
                if assign(l)~=assign(j)&l>j&...
                        ~any(session_ids(l)==(session_ids((assign==assign(j))&((1:n)'~=j))))&...
                        ~any(session_ids(j)==(session_ids((assign==assign(l))&((1:n)'~=l))))&...
                        (isempty(change)||(ismember(assign(l),change)||ismember(assign(j),change)))
                    temp_assign=assign;
                    temp_assign([j,l])=assign([l,j]);
                    indj=assign(j);
                    indl=assign(l);
                    temp_one(indj)=sum(xDist(temp_assign==indj,temp_assign==indj)>=1,'all');
                    temp_one(indl)=sum(xDist(temp_assign==indl,temp_assign==indl)>=1,'all');
                    temp_score(indj)=sum(xDist(temp_assign==indj,temp_assign==indj),'all')/((sum(temp_assign==indj)^2-sum(temp_assign==indj)));
           
                    temp_score(indl)=sum(xDist(temp_assign==indl,temp_assign==indl),'all')/((sum(temp_assign==indl)^2-sum(temp_assign==indl)));
           
                    temp_score(isnan(temp_score))=0;
                    temp_one_score(indj)=temp_one(indj)/(group_mem(indj)^2-group_mem(indj));
                    temp_one_score(indl)=temp_one(indl)/(group_mem(indl)^2-group_mem(indl));
                    temp_one_score(isnan(temp_one_score))=0;
                    
                    
                    dup_sess(indl)=~(length(session_ids(temp_assign==indl))==length(unique(session_ids(temp_assign==indl))));
                    dup_sess(indj)=~(length(session_ids(temp_assign==indj))==length(unique(session_ids(temp_assign==indj))));
                   
                    if temp_one_score(indj)>=1||temp_one_score(indl)>=1||dup_sess(indj)||dup_sess(indl)
                        swapgain(j,l)=inf;
                    elseif group_mem(indl)==group_mem(indj)
                        
                        if temp_one(indj)+temp_one(indl)<group_one(indj)+group_one(indl)
                         
                            swapgain(j,l)=temp_one(indj)+temp_one(indl)-group_one(indj)-group_one(indl);
                        elseif temp_one(indj)+temp_one(indl)==group_one(indj)+group_one(indl)
                            swapgain(j,l)=10^(-2)*(temp_score(indj)+temp_score(indl)-group_score(indj)-group_score(indl));
                            if (min(temp_score(indj),temp_score(indl))<min(group_score(indj),group_score(indl)))
                                swapgain(j,l)=swapgain(j,l)-alpha;
                            elseif min(temp_score(indj),temp_score(indl))>min(group_score(indj),group_score(indl))
                                swapgain(j,l)=swapgain(j,l)+alpha;
                            end
                        else
                            swapgain(j,l)=inf;
                            
                        end
                    elseif group_mem(indl)>group_mem(indj)
                        if temp_one(indl)<group_one(indl)
                            swapgain(j,l)=temp_one(indl)-group_one(indl);
                        elseif temp_score(indl)<group_score(indl)&temp_one(indl)==group_one(indl)
                            swapgain(j,l)=10^(-2)*(temp_score(indl)-group_score(indl));
                        else
                            swapgain(j,l)=inf;
                        end
                    elseif group_mem(indj)>group_mem(indl)
                        if temp_one(indj)<group_one(indj)
                            swapgain(j,l)=temp_one(indj)-group_one(indj);
                        elseif temp_score(indj)<group_score(indj)&temp_one(indj)==group_one(indj)
                            swapgain(j,l)=10^(-2)*(temp_score(indj)-group_score(indj));
                        else
                            swapgain(j,l)=inf;
                        end
                    else
                        swapgain(j,l)=inf;
                    end
                    
                    

                    
                    
%                     if (group_mem(assign(j))>group_mem(assign(l)))&(valjgjnoj_zeros+10^(-4)*valjgjnoj<vallgjnoj_zeros+10^(-4)*vallgjnoj)
%                         swapgain(j,l)=inf;
%                     end
%                     if ((group_mem(assign(j))<group_mem(assign(l))))&(vallglnol_zeros+10^(-4)*vallglnol<valjglnol_zeros+10^(-4)*valjglnol)
%                         swapgain(j,l)=inf;
%                     end
%                     if min(group_score(assign(j))-valjgjnoj+vallgjnoj,group_score(assign(l))-vallglnol+valjglnol)>min(group_score(assign(j)),group_score(assign(l)));
%                         %swapgain(j,l)=swapgain(j,l)+alpha;
%                         swapgain(j,l)=inf;
%                     end
%                     if min(group_score(assign(j))-valjgjnoj+vallgjnoj,group_score(assign(l))-vallglnol+valjglnol)<min(group_score(assign(j)),group_score(assign(l)));
%                         %swapgain(j,l)=swapgain(j,l)-alpha;
%                         swapgain(j,l)=swapgain(j,l)-alpha;
%                     end
%         
                        
                        
                else
                    swapgain(j,l)=inf;
                end
            end
        end
        
        swapgain(dup_swap,:)=inf;
        swapgain(:,dup_swap)=inf;
                    
        while true
            [M,I]=argmin_2d(shiftgain);
            if length(assign==assign(I(2)))==1 &~isinf(M)
                shiftgain(I(1),I(2))=inf;
            else
                break
            end
        end
        if kter>5
            
            temp_swap=min(swapgain,[],'all');
            
            if temp_swap>min_swap
                min_swap=temp_swap;
                freeze_assign=assign;
                swap_iter=1;
            else
                swap_iter=swap_iter+1;
                if swap_iter>5
                    assign=freeze_assign;
                    nochange=true;
                    break
                end
            end
        end
        
        iter=1;
        change=[];
        while true
        [M1,I1]=argmin_2d(swapgain);
        [M2,I2]=argmin_2d(shiftgain);
        %Instigate randomness?
        if min(M1,M2)>=-10^(-6)
            if iter==1
                nochange=true;
            end
            break
        elseif M1<M2
%             ind=find(swapgain<0);
%             weights=swapgain(ind);
%             weights=abs(weights)/sum(abs(weights));
%             rand=randsample(length(weights),1,true,weights);
%             [I1(1),I1(2)]=ind2sub(size(swapgain),ind(rand));
            
            val1=assign(I1(1));
            val2=assign(I1(2));
            assign(I1(1))=val2;
            assign(I1(2))=val1;
            
            swapgain(assign==assign(I1(1)),:)=inf;
            swapgain(:,assign==assign(I1(1)))=inf;
            swapgain(assign==assign(I1(2)),:)=inf;
            swapgain(:,assign==assign(I1(2)))=inf;
            
            shiftgain(assign(I1(1)),:)=inf;
            shiftgain(assign(I1(2)),:)=inf;
            shiftgain(:,assign==assign(I1(1)))=inf;
            shiftgain(:,assign==assign(I1(2)))=inf;
            
            change=[change,val1,val2];
            if ismember(I1,swapped,'rows')
                dup_swap=[dup_swap,I1];
            else
                swapped=[swapped;I1];
            end
        else
            change=[change,assign(I2(2)),I2(1)];
            
            shiftgain(I2(1),:)=inf;
            shiftgain(assign(I2(2)),:)=inf;
            shiftgain(:,assign==assign(I2(2)))=inf;
            shiftgain(:,assign==I2(1))=inf;
            
            
            swapgain(assign==change(end-1),:)=inf;
            swapgain(assign==change(end),:)=inf;
            swapgain(:,assign==change(end-1))=inf;
            swapgain(:,assign==change(end))=inf;
            
            assign(I2(2))=I2(1);
        end
        iter=iter+1;
        end
         
    end
            
    
    
    
    
    if nochange
        
        for j=1:size(xDist,1)
            if (sum(xDist(j,assign==assign(j))>=1)==sum(assign==assign(j))-1)&sum(assign==assign(j))>1
                k=k+1;
                change=[change,assign(j),k];
                assign(j)=k;
                nochange=false;
                
                break
            end
        end
    end
    if nochange
        for j=1:k
            group_mem(j)=sum(assign==j);
            group_score(j)=sum(xDist(assign==j,assign==j),'all')/((group_mem(j)^2-group_mem(j)));
            group_score(isnan(group_score))=0;
            group_one(j)=sum(xDist(assign==j,assign==j)>=1,'all');
            if group_mem(j)<=1
                group_one_score(j)=0;
            else
                group_one_score(j)=group_one(j)/(group_mem(j)^2-group_mem(j));
            end
            if group_one_score(j)>=1-chain_prob||group_score(j)>=1-chain_prob
                change=[change,j];
                [~,I]=max(mean(xDist(assign==j,assign==j),2));
                ind=find(assign==j);
               
                for l=1:k
                    temp_assign=assign;
                    temp_assign(ind(I))=l;
                    if ~ismember(session_ids(ind(I)),session_ids(assign==l))
                        temp_one(l)=sum(xDist(temp_assign==l,temp_assign==l)>=1,'all');
                        temp_score(l)=sum(xDist(temp_assign==l,temp_assign==l),'all')/((sum(temp_assign==l))^2-(sum(temp_assign==l)));
             
                        temp_one_score(l)=temp_one(l)/((sum(temp_assign==l))^2-(sum(temp_assign==l)));
                    else
                        temp_one_score(l)=inf;
                        temp_score(l)=inf;
                    end
                end
                
                if min(max(temp_one_score,temp_score))<1-chain_prob
                    [~,I1]=min(temp_one_score);
                    assign(ind(I))=I1;
                    dup_swap(end+1)=ind(I);
                else
                   k=k+1;
                   assign(ind(I))=k;
                   change(end+1)=k;
                   nochange=false;
                   break
                end
            end
        end
    end
                
                
    if nochange
        break
    end
    
    
end
% 
% 
% for j=1:k
%     try
%         group_score(j)=sum(xDist(assign==j,assign==j),'all');
%     catch
%         group_score(j)=0;
%     end
% end
% %Try permutations
% for l=1:1000
%     temp_assign=assign;
%     for j=1:max(session_ids)
%         
%         ind=find(session_ids==j);
% 
%         
%         
%         curr_set=1:k;
%         data=assign(ind);
%         perm=randperm(length(data));
%        
%         assign_temp(ind)=data(perm);
%     end
%     for j=1:k
%         group_temp(j)=sum(xDist(assign_temp==j,assign_temp==j),'all');
% 
%     end
%     if sum(group_temp)<sum(group_score)
%         assign=assign_temp;
%         group_score=group_temp;
%     end
%     
% end
%         
        
    
    
for j=1:k
    group_mem(j)=sum(assign==j);
    group_score(j)=sum(xDist(assign==j,assign==j),'all')/((group_mem(j)^2-group_mem(j)));
    group_score(isnan(group_score))=0;
    group_one(j)=sum(xDist(assign==j,assign==j)>=1,'all');
    if group_mem(j)<=1
        group_one_score(j)=0;
    else
        group_one_score(j)=group_one(j)/(group_mem(j)^2-group_mem(j));
    end
    if group_one_score(j)>=1-chain_prob||group_score(j)>=1-chain_prob

        [~,I]=max(mean(xDist(assign==j,assign==j),2));
        ind=find(assign==j);

        for l=1:k
            temp_assign=assign;
            temp_assign(ind(I))=l;
            if ~ismember(session_ids(ind(I)),session_ids(assign==l))
                temp_score(l)=sum(xDist(temp_assign==l,temp_assign==l),'all')/((sum(temp_assign==l))^2-(sum(temp_assign==l)));
                temp_one(l)=sum(xDist(temp_assign==l,temp_assign==l)>=1,'all');
                temp_one_score(l)=temp_one(l)/((sum(temp_assign==l))^2-(sum(temp_assign==l)));
            else
                temp_one_score(l)=inf;
                temp_score(l)=inf;
            end
        end

        if min(max(temp_one_score,temp_score))<1-chain_prob
            [~,I1]=min(temp_one_score);
            assign(ind(I))=I1;

        else
           k=k+1;
           assign(ind(I))=k;


        end
    end
    
end

    

beg_ind=1;
end_ind=k;
while beg_ind<=k
    while sum(assign==beg_ind)==0&end_ind>=beg_ind
        
            assign(assign==end_ind)=beg_ind;
            end_ind=end_ind-1;
            
        
    end
    
    beg_ind=beg_ind+1;
end

k=max(assign);
for j=1:k
    try
    nodes=find(assign==j);
    [M,I]=min(mean(xDist(assign==j,assign==j),2));
    medoidIndex(j)=nodes(I);
    end
end

