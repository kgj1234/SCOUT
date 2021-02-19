function [assign,medoidIndex]=avg_cluster(xDist,k,assign,medoidIndex,maxIterations,alpha,session_ids,chain_prob);




n = size(xDist,1);
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
gain=zeros(1,k);
gaini=zeros(k,n-k);
swapgain=zeros(k,n);
min_swap=-inf;
min_shift=-inf;

swap_iter=1;
for kter = 1:maxIterations
    nochange = false;
    
        


    if k==1
        gaint = mean(xDist,'all');
        nochange=true;
    else
        for j=1:k
            group_mem(j)=sum(assign==j);
            group_score(j)=mean(xDist(assign==j,assign==j),'all');
            group_one(j)=sum(xDist(assign==j,assign==j)>=1,'all');
            if group_mem(j)==1
                group_one_score(j)=0;
            else
                group_one_score(j)=group_one(j)/(group_mem(j)^2-group_mem(j));
            end
        end
        

        for j=1:k
            for l=1:n
                if assign(l)~=j& ~any(session_ids(l)==session_ids(assign==j))
                    shiftgain(j,l)=(-sum(NaN20(xDist(l,(assign==assign(l)&((1:n)'~=l))))==1)+...
                    sum(NaN20(xDist(l,assign==j))==1));
                    if max(groupcounts((session_ids(assign==assign(l))')))>1
                        shiftgain(j,l)=shiftgain(j,l)+(-NaN20(mean(xDist(l,(assign==assign(l)&((1:n)'~=l))),'all'))+...
                    NaN20(mean(xDist(l,assign==j),'all')));
                    else
                        shiftgain(j,l)=shiftgain(j,l)+(10^(-2))*(-NaN20(mean(xDist(l,(assign==assign(l)&((1:n)'~=l))),'all'))+...
                    NaN20(mean(xDist(l,assign==j),'all')));
                    end
                    if group_mem(j)<group_mem(assign(l))-1
                        shiftgain(j,l)=shiftgain(j,l)+alpha;
                    elseif group_mem(j)>=group_mem(assign(l))&group_one_score(assign(l))<1-chain_prob&group_score(assign(l))<1-chain_prob
                        shiftgain(j,l)=shiftgain(j,l)-alpha;
                    end
                else
                    shiftgain(j,l)=inf;
                end
                
            end
        end
        for j=1:n
            for l=1:n
                if assign(l)~=assign(j)&l>j&...
                        ~any(session_ids(l)==(session_ids((assign==assign(j))&((1:n)'~=j))))&...
                        ~any(session_ids(j)==(session_ids((assign==assign(l))&((1:n)'~=l))))
                    temp_assign=assign;
                    temp_assign([j,l])=assign([l,j]);
                    indj=assign(j);
                    indl=assign(l);
                    temp_one(indj)=sum(xDist(temp_assign==indj,temp_assign==indj)>=1,'all');
                    temp_one(indl)=sum(xDist(temp_assign==indl,temp_assign==indl)>=1,'all');
                    temp_score(indj)=mean(xDist(temp_assign==indj,temp_assign==indj),'all');
                    temp_score(indl)=mean(xDist(temp_assign==indl,temp_assign==indl),'all');
                    if group_mem(indl)==group_mem(indj)
                        
                        if temp_one(indj)+temp_one(indl)<group_one(indj)+group_one(indl)
                         
                            swapgain(j,l)=temp_one(indj)+temp_one(indl)-group_one(indj)-group_one(indl);
                        elseif temp_one(indj)+temp_one(indl)==group_one(indj)+group_one(indl)
                            swapgain(j,l)=10^(-4)*(temp_score(indj)+temp_score(indl)-group_score(indj)-group_score(indl));
                            if min(temp_score(indj),temp_score(indl))<min(group_score(indj),group_score(indl))
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
                            swapgain(j,l)=10^(-4)*(temp_score(indl)-group_score(indl));
                        else
                            swapgain(j,l)=inf;
                        end
                    elseif group_mem(indj)>group_mem(indl)
                        if temp_one(indj)<group_one(indj)
                            swapgain(j,l)=temp_one(indj)-group_one(indj);
                        elseif temp_score(indj)<group_score(indj)&temp_one(indj)==group_one(indj)
                            swapgain(j,l)=10^(-4)*(temp_score(indj)-group_score(indj));
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
        
                    
        while true
            [M,I]=argmin_2d(shiftgain);
            if length(assign==assign(I(2)))==1 &~isinf(M)
                shiftgain(I(1),I(2))=inf;
            else
                break
            end
        end
        if kter>10
            
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
            
        [M1,I1]=argmin_2d(swapgain);
        [M2,I2]=argmin_2d(shiftgain);
        
        if min(M1,M2)>=0

            nochange=true;
        
        elseif M1<M2
            val1=assign(I1(1));
            val2=assign(I1(2));
            assign(I1(1))=val2;
            assign(I1(2))=val1;
        else
            assign(I2(2))=I2(1);
        end
         
    end
            
    
    
    
    
    if nochange
        break
    end
    
end


for j=1:k
    group_score(assign(j))=sum(xDist(assign==j,assign==j),'all');
end
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
    try
    nodes=find(assign==j);
    [M,I]=min(mean(xDist(assign==j,assign==j),2));
    medoidIndex(j)=nodes(I);
    catch
        'hi'
    end
end

