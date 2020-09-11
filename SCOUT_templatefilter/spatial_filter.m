function [neuron,JS,Ysignal]=spatial_filter(neuron,spatial_filter_options)
% This function applies a spatial filter defined by the user to neuron
% footprints

%Input

%neuron (Sources2D) neuron containing neural footprint information
%spatial_filter_options (struct) with fields
    %JS: (float, positive) the spatial filter threshold
    %data_shape (vector, 2 elements) spatial footprint dimensions
    %trim (bool) trim neurons
    %gSizMax (positive float) maximum neuron size
    %gSizMin (positive float) minimum neuron size
    %filter (bool) apply spatial filter
    %threshold_per (float)
    %Ysignal (vector, optional) modified recording
    
%Ouptut

%neuron (Sources2D) filter neuron
%JS (vector) JS similarity scores for all neurons
%Ysignal (vector,optional) modified recording

%%Author Kevin Johnston


%%
if ~isfield(spatial_filter_options,'threshold_per')||isempty(spatial_filter_options.threshold_per)
    threshold_per=.1;
else
    threshold_per=spatial_filter_options.threshold_per;
end


if ~isfield(spatial_filter_options,'gSizMin')||isempty(spatial_filter_options.gSizMin);
    gSizMin=7;
else
    gSizMin=max(spatial_filter_options.gSizMin,2);
end

sigma=(gSizMin-1)/6;
h=fspecial('gaussian',[ceil(gSizMin),ceil(gSizMin)],sigma);

gSizMax=spatial_filter_options.gSiz;

data_shape=squeeze(spatial_filter_options.data_shape);
JS_thresh=spatial_filter_options.JS;
trim=spatial_filter_options.trim;
filter=spatial_filter_options.filter;

raw_neuron=neuron.copy();

JS=[];
A={};
for i=1:size(neuron.A,2);
    A{i}=full(neuron.A(:,i));
end
ind_del=[];
n=length(A);
JS1=2*ones(1,length(A));
JS2=2*ones(size(JS1));

extra_neurons=cell(1,n);
%This may need to be turned into a for loop when definining new
%distributions, otherwise it may be left as parfor
for i=1:n
    
    try
        A1=A{i};
        
        A1=reshape(A1,data_shape);
        
        
        
        curr_thresh=min(threshold_per,.85);
        A3=A1;
        keep=true;
        %Shrink neurons to less than gSizMax, and extract individual
        %components
        while curr_thresh<=.85
            
            
            thresh_ind=A1<curr_thresh*max(max(A1));
            A1(thresh_ind)=0;
            bw=A1>0;
            stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength');
            MajorAxis={stats.MajorAxisLength};
            MinorAxis={stats.MinorAxisLength};
            MajorAxis=cell2mat(MajorAxis);
            MinorAxis=cell2mat(MinorAxis);
            MajorAxisLength=max(MajorAxis);
            MinorAxisLength=max(MinorAxis);
            CC = bwconncomp(bw);
            if length(CC.PixelIdxList)>1
                for p=length(MajorAxis):-1:1
                    if MinorAxis(p)<gSizMin
                        CC.PixelIdxList(p)=[];
                    end
                end
                if length(CC.PixelIdxList)>=1
                    A{i}=zeros(size(A{i}));
                    A{i}(CC.PixelIdxList{1})=A1(CC.PixelIdxList{1});
                    
                    for p=2:length(CC.PixelIdxList)
                        temp_A=zeros(size(A1));
                        temp_A(CC.PixelIdxList{p})=A1(CC.PixelIdxList{p});
                        extra_neurons{i}{end+1}=temp_A;
                        
                    end
                    
                    
                else
                    keep=false;
                    break;
                end
            end
            
            if MinorAxisLength<gSizMin
                keep=false;
                
                break
            end
            if MajorAxisLength<.95*gSizMax
                
                break
            end
            
            curr_thresh=curr_thresh+.05;
        end
        
        
        if keep==false
            
            continue;
        end
        
        
        
        
        sum_A=sum(sum(A1));
        A1=A1/sum_A;
        A1=reshape(A1,data_shape);
        
        %Construct comparison footprints
        temp_A=A1;
        if isequal(spatial_filter_options.method,'elliptical')
            
            
            try
                [A1_comp,A2_comp]=construct_comparison_footprint_ellipse(temp_A);
            catch
                [A1_comp,A2_comp]=construct_comparison_footprint_gaussian(temp_A);
            end
            
        elseif isequal(spatial_filter_options.method,'gaussian')
            [A1_comp,A2_comp]=construct_comparison_footprint_gaussian(temp_A);
        else
            [A1_comp,A2_comp]=eval(spatial_filter_options.method);
        end
        
        
        JS1(i)=JSDiv(reshape(A1,1,[]),reshape(A1_comp,1,[]));
        JS2(i)=JSDiv(reshape(A1,1,[]),reshape(A2_comp,1,[]));
        
        if JS2(i)<JS1(i)
            best_choice=2;
        end
        if best_choice==1
            
            thresh_indices=A1_comp<.1*max(max(A1_comp));
            A1(thresh_indices)=0;
          
            
            
        else
            
                thresh_indices=A2_comp<.1*max(max(A2_comp));
                A1(thresh_indices)=0;
            
            
            
        end
        max_A1=max(max(A1));
        A1=imfilter(A1,h);
        A1=A1/max(max(A1))*max_A1;
        A1=A1*sum_A;
        
        if ~trim
            A1=A3;
        end
        
        
    catch
        
        JS1(i)=JS_thresh+2;
        JS2(i)=JS_thresh+2;
        
        
    end
    
    
    
    
    A{i}=reshape(A1,1,[]);
    
end
% Repeat previous but with extra components found after thresholding
% original neurons
for i=1:n
    for p=length(extra_neurons{i}):-1:1
        
        try
            A1=extra_neurons{i}{p};
            
            A1=reshape(A1,data_shape);
            
            
            
            curr_thresh=min(threshold_per,.85);
            A3=A1;
            keep=true;
            while curr_thresh<=.85
                
                %A1=imgaussfilt(A1,1.3);
                thresh_ind=A1<curr_thresh*max(max(A1));
                A1(thresh_ind)=0;
                bw=A1>0;
                stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength');
                MajorAxis={stats.MajorAxisLength};
                MinorAxis={stats.MinorAxisLength};
                MajorAxis=cell2mat(MajorAxis);
                MinorAxis=cell2mat(MinorAxis);
                MajorAxisLength=max(MajorAxis);
                MinorAxisLength=max(MinorAxis);
                CC = bwconncomp(bw);
                if length(CC.PixelIdxList)>1
                    for p=length(MajorAxis):-1:1
                        if MinorAxis(p)<gSizMin
                            CC.PixelIdxList(p)=[];
                        end
                    end
                    if length(CC.PixelIdxList)>=1
                        A{i}=zeros(size(A{i}));
                        A{i}(CC.PixelIdxList{1})=A1(CC.PixelIdxList{1});
                        
                        for p=2:length(CC.PixelIdxList)
                            temp_A=zeros(size(A1));
                            temp_A(CC.PixelIdxList{p})=A1(CC.PixelIdxList{p});
                            extra_neurons{i}{end+1}=temp_A;
                            
                        end
                        
                        
                    else
                        keep=false;
                        break;
                    end
                end
                
                if MinorAxisLength<gSizMin
                    keep=false;
                    break
                end
                if MajorAxisLength<.95*gSizMax
                    
                    break
                end
                
                curr_thresh=curr_thresh+.05;
            end
            
            
            if keep==false
                try
                    extra_neurons{i}(p)=[];
                end
            end
            
            
            
            
            sum_A=sum(sum(A1));
            A1=A1/sum_A;
            
            
            temp_A=A1;
            if isequal(spatial_filter_options.method,'elliptical')
                
                
                try
                    [A1_comp,A2_comp]=construct_comparison_footprint_ellipse(temp_A);
                catch
                    [A1_comp,A2_comp]=construct_comparison_footprint_gaussian(temp_A);
                end
                
            elseif isequal(spatial_filter_options.method,'gaussian')
                [A1_comp,A2_comp]=construct_comparison_footprint_gaussian(temp_A);
            else
                [A1_comp,A2_comp]=eval(spatial_filter_options.method);
            end
            JS1_temp=JSDiv(reshape(A3,1,[]),reshape(A1_comp,1,[]));
            JS2_temp=JSDiv(reshape(A3,1,[]),reshape(A2_comp,1,[]));
            
            best_choice=1;
            if JS2_temp<JS1_temp
                best_choice=2;
            end
            if best_choice==1
           
                    thresh_indices=A1_comp<.1*max(max(A1_comp));
                    A3(thresh_indices)=0;
                
                
                
            else
               
                    thresh_indices=A2_comp<.1*max(max(A2_comp));
                    A3(thresh_indices)=0;
                
                
                
            end
            max_A1=max(max(A1));
            A1=imfilter(A1,h);
            A1=A1/max(max(A1))*max_A1;
            A1=A1*sum_A;
            if ~trim
                A1=A3;
            end
            if min(JS1_temp,JS2_temp)>JS_thresh
                try
                    extra_neurons{i}(p)=[];
                end
            else
                extra_neurons{i}{p}=reshape(A1,1,[]);
            end
            
        catch
            try
                extra_neurons{i}(p)=[];
            end
        end
    end
end





%Reconstitute original neuron
for i=1:length(A)
    neuron.A(:,i)=reshape(A{i},[],1);
    for p=1:length(extra_neurons{i})
        neuron.A(:,end+1)=reshape(extra_neurons{i}{p},[],1);
        neuron.C(end+1,:)=neuron.C(i,:);
        try
            neuron.S(end+1,:)=neuron.S(i,:);
            neuron.C_raw(end+1,:)=neuron.C_raw(i,:);
            neuron.P.kernel_pars(end+1,:)=neuron.P.kernel_pars(i,:);
        end
    end
end

%Apply filter threshold
JS1=[JS1,zeros(1,size(neuron.A,2)-length(JS1))];

JS2=[JS2,zeros(1,size(neuron.A,2)-length(JS2))];


neuron.delete(ind_del)
neuron.A=sparse(neuron.A);
if filter==true
    JS=min([reshape(JS1,1,[]);reshape(JS2,1,[])]);
    
    
    
    
    
    
    
    
    
    
    
    indices=find(JS>JS_thresh);
    
else
    indices=[];
end


for i=1:size(neuron.A,2)
    if sum(neuron.A(:,i))<=0
        indices=[indices,i];
    end
end
if exist('Ysignal','var')
    
    Ysignal=Ysignal-neuron.A(:,indices)*neuron.C(indices,:);
else
    Ysignal=[];
end
neuron.delete(indices);
JS(indices)=[];

m=size(neuron.C,1);
disp(['Neurons Deleted by Spatial Filter: ',num2str(length(indices))]);
end
