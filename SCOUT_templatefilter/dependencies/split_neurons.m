function neuron=split_neurons(neuron,data_shape,d_min,gSizMin)

if size(data_shape,1)>1;
    data_shape=squeeze(data_shape');
end

for i=1:size(neuron.A,2);
    A{i}=full(neuron.A(:,i));
end

filter_size=(gSizMin-1)/6;
h=fspecial('gaussian',[ceil(gSizMin),ceil(gSizMin)],filter_size);
ind_del=[];
for i=1:length(A)
    A1=A{i};
    
    A1=reshape(A1,data_shape(1),data_shape(2));
    A1=imfilter(A1,h);
    A2=A1;
    A2(A2<.2*max(max(A2)))=0;
    A2=reshape(A2,data_shape(1),data_shape(2));
    
    A2=imregionalmax(A2);
    
        bw=A2>0;
        
        
        CC=bwconncomp(bw);
    stats=CC.PixelIdxList;
    for q=length(stats):-1:1
        if max(max(A1(stats{q})))<max(max(A1))*.4
            stats(q)=[];
        end
    end
    if length(stats)>4||length(stats)==0
        ind_del=[ind_del,i];
        continue
%         max_val=[];
%         for p=1:length(stats)
%             max_val(p)=max(max(A1(stats{p})));
%         end
%         [~,index]=sort(max_val);
%         stats(index(1:end-4))=[];
%         
    end
    
    if length(stats)>1
    num_elements=[];
    centroids=[];
    for k=1:length(stats)
        bw=zeros(data_shape);
        num_elements(k)=size(stats{k},1);
        bw(stats{k})=1;
        centroids=[centroids;calculateCentroid(bw,data_shape(1),data_shape(2))];
    end
    temp=centroids(:,1);
    centroids(:,1)=centroids(:,2);
    centroids(:,2)=temp;
    distance=squareform(pdist(centroids));
    distance=distance+eye(size(centroids,1))*max(max(distance));
    for q=1:length(distance)
        if min(distance(q,:))<d_min(1)
            ind=find(distance(q,:)<d_min(1));
            [M,I]=max(mean(distance(:,ind),1));
            ind=setdiff(ind,I);
            distance(:,ind)=nan;
            distance(ind,:)=nan;
            for l=1:length(ind)
                stats{ind(l)}=[];
            end
            centroids(ind,:)=nan;
        end
    end
    distance(isnan(distance))=[];
    stats(isempty(stats))=[];
    centroids(isnan(centroids))=[];
    if size(distance,1)>1
    A2=A1;
    A2(A2<max(max(A2))/50)=0;
    A2=A2/min(min(A2(A2>0)));
    
    A2(isnan(A2))=0;
    X=[];
    for p=1:size(A2,1)
        for q=1:size(A2,2)
            if A2(p,q)>0
                
                X=[X;repmat([q,p],floor(A2(p,q)),1)];
            end
        end
    end
    GM={};
    options = statset('MaxIter',1000);
    parfor p=1:size(distance,1)
        GM{p}=fitgmdist(X,p,'regularization',10^(-4),'Options',options);
    end
    BIC=[];
    for p=1:length(GM)
        BIC(p)=GM{p}.BIC;
    end
    for p=1:length(BIC)-1
        %If decrease from increasing parameters is too low, do not consider
        %high parameter models.
        if BIC(p)/BIC(p+1)<1.005||BIC(p)<BIC(p+1)
            BIC(p+1:end)=[];
            break
        end
    end
    [M,I]=min(BIC);
    if I>8
        %ind_del=[ind_del,i];
        continue;
    else
        JS=[];
        for p=1:I
            [X,Y]=meshgrid(1:size(A2,2),1:size(A2,1));
            X=reshape(X,[],1);
            Y=reshape(Y,[],1);
            P=GM{p}.pdf([X,Y]);
            P=reshape(P,size(A2,1),size(A2,2));
            JS(p)=JSDiv(reshape(A2,1,[]),reshape(P,1,[]));
        end
    end
    [~,I]=min(JS);
    if I==1
        continue
    end
    GM=GM{I};
    
    
    [X,Y]=meshgrid(1:size(A2,2),1:size(A2,1));
            X=reshape(X,[],1);
            Y=reshape(Y,[],1);
            P=GM.posterior([X,Y]);
            
    for p=1:size(GM.mu,1)
        
    
        
        
        
     
        P1=reshape(P(:,p),size(A2,1),size(A2,2));
        P1(P1<.5)=0;
        A2=A1;
        A2(P1==0)=0;
        P1=A2;
        
        try
            index=min(pdist2(centroids,GM.mu(p,:)));
       
            P1=P1*max(max(A1(stats{index})));
        catch
            P1=P1*max(max(A1));
        end
            
            
            A{end+1}=reshape(P1,[],1);
            neuron.C(end+1,:)=neuron.C(i,:);
            try
            neuron.S(end+1,:)=neuron.S(i,:);
            neuron.C_raw(end+1,:)=neuron.C_raw(i,:);
            neuron.P.kernel_pars(end+1,:)=neuron.P.kernel_pars(i,:);
            end
       
        
        end
        ind_del=[ind_del,i];
    end
    
    end
end  
    
 neuron.A=[];
 for i=1:length(A)
     neuron.A=[neuron.A,A{i}];
 end
 neuron.delete(ind_del);