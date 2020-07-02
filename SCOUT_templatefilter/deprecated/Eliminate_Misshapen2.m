function [neuron,KL]=Eliminate_Misshapen2(neuron,KL_thresh,data_shape,constraint_type,trim,gSizMax,gSizMin,filter,threshold_per)
size(neuron.A)
%constraint_type: 'bound', 'prc'
%try
if ~exist('constraint_type','var')||isempty(constraint_type)
    constraint_type='prc';
end
if ~exist('threshold_per','var')||isempty(threshold_per)
    threshold_per=.35;
end
if size(data_shape,1)>1;
    data_shape=squeeze(data_shape');
end
det_cov=[];
eig_ratio=[];
KL=[];
for i=1:size(neuron.A,2);
    A{i}=full(neuron.A(:,i));
end

for i=1:length(A)
    try
    A1=A{i};
    
    A1=reshape(A1,data_shape(1),data_shape(2));
    A1=imgaussfilt(A1);
    
        thresh_indices=A1<.8*max(max(A1));
        A2=A1;
        A2(thresh_indices)=0;
        %A1=imgaussfilt(A1,1);
        A2=A2/sum(sum(A2));
        bw=A2>0;
    
        
        CC=bwconncomp(bw);
    stats=CC.PixelIdxList;
    for l=length(stats):-1:1
        if length(stats{l})<=gSizMin
            stats(l)=[];
        end
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
    
    [X,Y]=meshgrid(1:data_shape(1),1:data_shape(2));
    X=reshape(X,[],1);
    Y=reshape(Y,[],1);
    avail_ind=[X,Y];
    
    indices=cell(1,length(stats));
    distance=pdist2(centroids,avail_ind);
    [~,groups]=min(distance,[],1);
    for l=1:length(indices)
        group_assignments{l}=avail_ind(groups==l,:);
    end
    
    for k=1:length(num_elements)
        if num_elements(k)~=max(num_elements)
            
            curr_ind=group_assignments{k};
            curr_ind=sub2ind(data_shape,curr_ind(:,1),curr_ind(:,2));
            
            A{end+1}=zeros(size(A1,1)*size(A1,2),1); new_A=zeros(data_shape);
            new_A(curr_ind)=A1(curr_ind);
            
            A{end}=reshape(imgaussfilt(new_A,1.5),[],1);
            neuron.C(end+1,:)=neuron.C(i,:);
            
            neuron.S(end+1,:)=neuron.S(i,:);
            neuron.C_raw(end+1,:)=neuron.C_raw(i,:);
            neuron.P.kernel_pars(end+1,:)=neuron.P.kernel_pars(i,:);
            A1(curr_ind)=0;
        elseif num_elements(k)~=max(num_elements)
            curr_ind=group_assignments{k};
            curr_ind=sub2ind(data_shape,curr_ind(:,1),curr_ind(:,2));
            
            A1(curr_ind)=0;
        
        end
    end
    end
    curr_thresh=threshold_per;
    A1=imgaussfilt(A1,2);
    while true
        
    A3=A1;
    thresh_ind=A1<curr_thresh*max(max(A1));
    A1(thresh_ind)=0;
    bw=A1>0;
    stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength');
    MajorAxisLength={stats.MajorAxisLength};
    MinorAxisLength={stats.MinorAxisLength};
    MajorAxisLength=MajorAxisLength{1};
    MinorAxisLength=MinorAxisLength{1};
     if MajorAxisLength<.95*gSizMax
            break
        end
        curr_thresh=curr_thresh+.05;
    end
    
    [centroid,cov]=calculateCentroid_and_Covariance(A1,data_shape(1),data_shape(2));
    
    
    
   
    
    bw=A1>0;
    CC=bwconncomp(bw);
    stats=CC.PixelIdxList;
    curr_rem_ind=[];
    num_elements=[];
    for l=1:length(stats)
        num_elements(l)=length(stats{l});
    end
    for l=1:length(stats)
        if length(stats{l})~=max(num_elements)
            curr_rem_ind=[curr_rem_ind;stats{l}];
        end
    end
    A2=A1;
    A2(curr_rem_ind)=0;
    bw=A2>0;
    stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength','Orientation');
    MajorAxisLength=stats.MajorAxisLength;
    
    MinorAxisLength=stats.MinorAxisLength;
   
    Orientation=stats.Orientation;
   
    max_diam(i)=MajorAxisLength;
    min_diam(i)=MinorAxisLength;
    
    %Estimate appropriate power to use
    x=round(MajorAxisLength*cos(Orientation*pi/180));
    y=round(MajorAxisLength*sin(Orientation*pi/180));
    edge_vec=centroid+[x,y];
    x_coord=[centroid(1),edge_vec(1)];
    y_coord=[centroid(2),edge_vec(2)];
    c = improfile(A1,x_coord,y_coord);
    
    c=c/max(c);
    c(c==0)=[];
    x=1;
    try
        val=c(2);
    
    
        n=log(val)/(log(1-x/(length(c)-1)));
        n=real(n);
    catch
        n=0;
    end
    if n>.99
        n=.99;
    elseif n<.3
        n=.3;
    end
    
    A1_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),n,Orientation*pi/180,centroid,data_shape);
    A2_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),n,Orientation*pi/180+pi/2,centroid,data_shape);
    
    [KL1(i),mass1(i)]=KLDiv(A1,A1_comp);
    [KL2(i),mass2(i)]=KLDiv(A1,A2_comp);
    best_choice=1;
    if KL2(i)<KL1(i)
        best_choice=2;
    end
    if best_choice==1
        thresh_indices=A1_comp<.1*max(max(A1_comp));
        A1(thresh_indices)=0;
    else
        thresh_indices=A2_comp<.1*max(max(A2_comp));
        A1(thresh_indices)=0;
    end
    A1=imgaussfilt(A1,1);
    if ~trim
        A1=A3;
    end
%     
%     
    catch
        mass1(i)=1;
        mass2(i)=1;
        KL1(i)=KL_thresh+2;
        KL2(i)=KL_thresh+2;
    end
    
    
    

    A{i}=reshape(A1,1,[]);
    i=i+1;
end

for i=1:length(A)
    neuron.A(:,i)=reshape(A{i},[],1);
end
neuron.A=sparse(neuron.A);
if filter==true
KL=min([reshape(KL1,1,[]);reshape(KL2,1,[])]);





mass=min([reshape(mass1,1,[]);reshape(mass2,1,[])]);




indices=KL>2;


try
    neuron.P.kernel_pars(indices)=[];

end
try
    neuron.P.sn_neuron(indices)=[];
end
try
    neuron.combined(indices,:)=[];
    neuron.scores(indices,:)=[];
catch
    'display no error';
end
try
    neuron.overlap_corr(indices,:)=[];
    neuron.overlap_KL(indices,:)=[];
catch
    'no error';
end
neuron.A(:,indices)=[];
neuron.C(indices,:)=[];
neuron.C_raw(indices,:)=[];
neuron.S(indices,:)=[];

KL(indices)=[];
mass(indices)=[];



if isequal(constraint_type,'prc')
    try
        KL=(KL-mean(KL))/std(KL);
        KL_thresh=norminv(KL_thresh);
    end
end
%size_thresh_rem=find(max_diam>gSizMax|min_diam<gSizMin);
size_thresh_rem=[];


    %indices=find(isoutlier(KL,'gesd','MaxNumOutliers',floor(.05*size(neuron.C,1))));
    indices=find(KL>KL_thresh);
else
    indices=[];
end
% if width_crit==true
%     %indices=[indices,find(isoutlier(max_diam,'gesd','MaxNumOutliers',floor(.05*size(neuron.C,1))))];
%     a=1;
%     
% end

for i=1:size(neuron.A,2);
    if sum(neuron.A(:,i))<=0
        indices=[indices,i];
    end
end

try
    neuron.P.kernel_pars(indices)=[];

end
try
    neuron.P.sn_neuron(indices)=[];
end
try
    neuron.combined(indices,:)=[];
    neuron.scores(indices,:)=[];
catch
    'display no error';
end
try
    neuron.overlap_corr(indices,:)=[];
    neuron.overlap_KL(indices,:)=[];
catch
    'no error';
end
neuron.A(:,indices)=[];
neuron.C(indices,:)=[];
neuron.C_raw(indices,:)=[];
neuron.S(indices,:)=[];
% catch
%     KL=0;
%     disp('Eliminate_Misshapen Failed')
%     neuron=neuron;
% end
size(neuron.A)