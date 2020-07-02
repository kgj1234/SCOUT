function [pair_aligned,correlation,dist,overlap,KL,corr_prob,dist_prob,overlap_prob,KL_prob]=compute_aligned_pairwise_probability_single_full_patch(correlation_matrices,...
    overlap_matrix,dist_self,distance_matrix,distance_links,KL_matrix,max_dist,use_corr,base_patch_size,single_corr,method);
if ~exist('max_dist','var')||isempty(max_dist)
    max_dist=16;
end
if (~exist('use_corr','var')||isempty(use_corr))&~isempty(correlation_matrices)
    use_corr=true;
end
if ~exist('base_patch_size','var')||isempty(base_patch_size)
    base_patch_size=25;
end
if ~exist('single_corr','var')||isempty(single_corr)
    single_corr=true;
end
if ~exist('method','var')||isempty(method)
    method='Kmeans';
end
max_patch_size=500;

corr_score=cell(1,size(distance_matrix,1));
dist_score=cell(size(corr_score));
overlap_score=cell(size(corr_score));
KL_score=cell(size(corr_score));
correlation=cell(1,size(distance_matrix,1));
dist=cell(size(corr_score));
overlap=cell(size(corr_score));
KL=cell(size(corr_score));
aligned=cell(size(corr_score));

for i=1:size(distance_matrix,1)
    tic
    patch_size=base_patch_size;
    nearby_ind=find(dist_self(i,:)<patch_size);
    while length(nearby_ind)<7
        patch_size=patch_size+5;
        
        nearby_ind=find(dist_self(i,:)<patch_size);
    end
    if patch_size>max_patch_size
        continue;
    end
    
    if length(nearby_ind)<5
        corr_score{i}=[];
        correlation{i}=[];
        dist_score{i}=[];
        overlap_score{i}=[];
        KL_score{i}=[];
        dist{i}=[];
        overlap{i}=[];
        KL{i}=[];
        aligned{i}=[];
        continue;
    else
        NN_corr1=[];
        NN_corr2=[];
        NN_overlap=[];
        NN_KL=[];
        NN_dist=[];
        
        for j=1:length(nearby_ind)
            avail_ind=find(distance_matrix(nearby_ind(j),:)<max_dist);
            NN_overlap=[NN_overlap,overlap_matrix(nearby_ind(j),avail_ind)];
            NN_dist=[NN_dist,distance_matrix(nearby_ind(j),avail_ind)];
            NN_KL=[NN_KL,KL_matrix(nearby_ind(j),avail_ind)];
            if use_corr
                avail_ind1=find(distance_links{1}(nearby_ind(j),:)<max_dist);
                if ~single_corr
                    avail_ind2=[];
                    for l=1:length(avail_ind)
                        avail_ind2=[avail_ind2,find(distance_links{2}(:,avail_ind(l))'<max_dist)];
                    end
                    link_ind=intersect(avail_ind1,avail_ind2);
                else
                    link_ind=[nearby_ind(j)];
                end
                for l=1:length(avail_ind)
                    corr_score_max=[0,0];
                    for k=1:length(link_ind)
                        corr_score_temp=[correlation_matrices{1}(nearby_ind(j),link_ind(k)),correlation_matrices{2}(link_ind(k),avail_ind(l))];
                        if single_corr
                            if mean(corr_score_temp)>mean(corr_score_max)
                                corr_score_max=corr_score_temp;
                            end
                        elseif mean(corr_score_temp)>mean(corr_score_max)
                            corr_score_max=corr_score_temp;
                        end
                        
                    end
                    NN_corr1=[NN_corr1,corr_score_max(1)];
                    NN_corr2=[NN_corr2,corr_score_max(2)];
                end
            end
        end
    end
    
    avail_ind=find(distance_matrix(i,:)<max_dist);
    if isempty(avail_ind)
        dist_score{i}=[];
        overlap_score{i}=[];
        KL_score{i}=[];
        dist{i}=[];
        overlap{i}=[];
        KL{i}=[];
        aligned{i}=[];
        corr_score{i}=[];
        corr_prob{i}=[];
        continue
    else
        
            X=NN_dist(~isnan(NN_dist));
            f=@(x) construct_probability_function(X,method,'left');
            dist_score{i}=f(distance_matrix(i,avail_ind));
        if isempty(dist_score{i})
            f=@(x)construct_probability_function(X,'percentile','left');
            dist_score{i}=f(distance_matrix(i,avail_ind));
        end
        
        
        
        
            X=NN_overlap(~isnan(NN_overlap));
            
            
            f=@(x)construct_probability_function(X,method,'right');
            %f=@(x)construct_probability_function(X,'gmm','right');
            
            overlap_score{i}=f(overlap_matrix(i,avail_ind));
        if isempty(overlap_score{i})
            f=@(x)construct_probability_function(X,'percentile','right');
            overlap_score{i}=f(overlap_matrix(i,avail_ind));
        end
        
        
        
        
            X=NN_KL(~isnan(NN_KL));
            X(X>1)=[];
            
            f=@(x)construct_probability_function(X,method,'left');
            KL_score{i}=f(KL_matrix(i,avail_ind));
        if isempty(KL_score{i})
            f=@(x)construct_probability_function(X,'percentile','left');
            KL_score{i}=f(KL_matrix(i,avail_ind));
        end
        
        
        dist{i}=distance_matrix(i,avail_ind);
        overlap{i}=overlap_matrix(i,avail_ind);
        KL{i}=KL_matrix(i,avail_ind);
        aligned{i}=avail_ind;
        
    end
    
    if use_corr
        avail_ind1=find(distance_links{1}(i,:)<max_dist);
        if ~single_corr
            avail_ind2=[];
            for j=1:length(avail_ind)
                avail_ind2=[avail_ind2,find(distance_links{2}(:,avail_ind(j))'<max_dist)];
            end
            link_ind=intersect(avail_ind1,avail_ind2);
        else
            link_ind=[i];
        end
        if isempty(link_ind)
            corr_score{i}=nan(1,length(dist_score{i}));
            correlation{i}=nan(length(dist_score{i}),2);
            
        else
            
                X=NN_corr1(~isnan(NN_corr1));
                
                
                f1=@(x)construct_probability_function(X,method,'right');
              
            if isempty(f1(1))
                f1=@(x)construct_probability_function(X,'percentile','right');
            end
            
            
                X=NN_corr2(~isnan(NN_corr2));
                f2=@(x)construct_probability_function(X,method,'right');
                if isempty(f2(1))
            
                f2=@(x)construct_probability_function(X,'percentile','right');
            
                end
            
            
            
            
            for j=1:length(avail_ind)
                
                corr_max=[0,0];
                for k=1:length(link_ind)
                    
                    score1=correlation_matrices{1}(i,link_ind(k));
                    temp=correlation_matrices{2}(link_ind(k),avail_ind(j));
                    if single_corr
                        if temp>corr_max(2)
                            corr_max=[1,temp];
                        end
                    else
                        if (score1+temp)/2>mean(corr_max)
                            corr_max=[score1,temp];
                        end
                    end
                    
                    
                end
                if single_corr
                    iter=1;
                    val=[];
                    while isempty(val)&iter<1000
                    val=f2(corr_max(2));
                    
                    
                        
                   iter=iter+1;
                    end
                    if ~isempty(val)
                     corr_score{i}(j)=val;
                    else
                        corr_score{i}(j)=nan;
                    end
                    
                else
                    val=[];
                    iter=1;
                    while isempty(val)&iter<1000
                    val=(f1(corr_max(1))+f2(corr_max(2)))/2;
                    iter=iter+1;
                    
                        
                   
                    end
                    if ~isempty(val)
                     corr_score{i}(j)=val;
                    else
                        corr_score{i}(j)=nan;
                    end
                end
                correlation{i}(j,:)=corr_max;
                
            end
            
        end
    end
    toc
end


probability=[];
pair_aligned=[];

for i=1:size(distance_matrix,1)
    pair_aligned=[pair_aligned;[i*ones(length(aligned{i}),1),aligned{i}']];
    %     if use_corr==true
    %     curr_prob=(corr_score{i}+overlap_score{i}+(1-dist_score{i}))/3;
    %     else
    %         curr_prob=(overlap_score{i}+(1-dist_score{i}))/2;
    %     end
    %     probability=[probability;curr_prob'];
end


overlap_prob=horzcat(overlap_score{:})';
dist_prob=horzcat(dist_score{:})';
KL_prob=horzcat(KL_score{:})';

overlap=horzcat(overlap{:})';
dist=horzcat(dist{:})';
KL=horzcat(KL{:})';
if use_corr==true
    correlation=vertcat(correlation{:});
    try
    corr_prob=vertcat(corr_score{:});
    catch
        corr_prob=horzcat(corr_score{:})';
    end
else
    correlation=[];
    corr_prob=[];
end


