function []=BatchEndoscopeAutoHPC_adjusted();
clear;
clc;
close all;
%Insert number of frames per day here
%batch_sizes=[8969,8962,8971];

%overlap=4000;
%load('batches');

%batch_sizes=batches;
overlap=1000;
batch_sizes=[2000,2000,2000,2000,2000];
%KL thresh for neuron rejection (not combination) 0 if none
KL=.25;
%Max thresh for neuron constraint ( 0 if none)
max_thresh=.4;




global ssub tsub;
ssub=2;
tsub=2;

tic

filename='./Ydouble'; %Input filenames for experiment, no file extension
disp('loading data')
if isequal(exist(horzcat(filename,'.mat'),'file'),2)
    disp('Data already converted to .mat file')
    data_shape=load(horzcat(filename,'.mat'),'Ysiz');
    data_shape=data_shape.Ysiz;
else
    [Y,Nframes]=imread_big(horzcat(filename,'.tif'));
    save(horzcat(filename,'.mat'),'Y','Ysiz','-v7.3');
    data_shape=Y.shape;
    
end
clear Y Ysiz
%Split into batches
disp('data size')
data_shape


index=1;
batch_indices=[];
linkage_indices=[];
i=1;

data_shape
for i=1:length(batch_sizes)
   
    batch_indices=vertcat(batch_indices,[index,index+batch_sizes(i)]);
    index=index+batch_sizes(i);
    
end
for i=1:length(batch_indices)
    linkage_indices=vertcat(linkage_indices,[batch_indices(i,2)-overlap-1,batch_indices(i,2)+overlap-1]);
end

data_shape=data_shape(1:2);
if size(data_shape,1)>1
    data_shape=data_shape';
end
data_shape=squeeze(data_shape);

num_batches=size(batch_indices,1);
disp(horzcat('number of batches ',num2str(num_batches)))



neurons={}; %Structure to store neuron results
links={};
for i=1:3:size(batch_indices,1)
    parfor j=i:min(i+2,num_batches)
        disp(strcat('batch',num2str(j),'initialization'))
    
        neurons{j}=full_demo_endoscope(horzcat(filename,'.mat'),data_shape,batch_indices(j,:),true);
    end
    %save(horzcat('neuron',num2str(i)),'neuron','-v7.3')
end
for i=1:3:size(linkage_indices,1)
    parfor j=i:min(i+2,size(linkage_indices,1))
        disp(strcat('link',num2str(j),'initialization'))
    
        links{j}=full_demo_endoscope(horzcat(filename,'.mat'),data_shape,linkage_indices(j,:),true);
    end
    %save(horzcat('neuron',num2str(i)),'neuron','-v7.3')
end
neurons(end+1:end+length(neurons))=neurons;
links(end+1:end+length(links)-1)=links(1:end-1);
save('neurons','neurons','-v7.3')

save('links','links','-v7.3')



disp(strcat('Number of possible neurons: ', num2str(size(neurons{1}.centroid,1))))



[aligned_neurons_matrix,corr_scores,KL_scores]=align_using_linkage(neurons,links,overlap,data_shape(1),data_shape(2));

neuron=Sources2D;
batch_sizes=[batch_sizes,batch_sizes];
for i=1:size(aligned_neurons_matrix,1)
   linked_indices=find(aligned_neurons_matrix(i,:)>0);
   A=zeros(size(neurons{1}.A(:,1))); 
   C={};
   S={};
   C_raw={};
   for k=linked_indices
       C{k}=neurons{k}.C(aligned_neurons_matrix(i,k),:);
       C_raw{k}=neurons{k}.C_raw(aligned_neurons_matrix(i,k),:);
       S{k}=neurons{k}.S(aligned_neurons_matrix(i,k),:);
       A=A+neurons{k}.A(:,aligned_neurons_matrix(i,k));
   end
   for k=1:size(aligned_neurons_matrix,2)-1
       if k<=(size(aligned_neurons_matrix,2)-1)/2&&isempty(C{k})
           C{k}=C{k+(size(aligned_neurons_matrix,2)-1)/2};
           S{k}=S{k+(size(aligned_neurons_matrix,2)-1)/2};
           C_raw{k}=C_raw{k+(size(aligned_neurons_matrix,2)-1)/2};
           corr_scores(i,k)=corr_scores(i,k+(size(aligned_neurons_matrix,2)-1)/2);
           KL_scores(i,k)=KL_scores(i,k+(size(aligned_neurons_matrix,2)-1)/2);
       end
   end
   
   A=A/length(linked_indices);
   neuron.A=horzcat(neuron.A,A);
   neuron.C=vertcat(neuron.C,horzcat(C{1:(size(aligned_neurons_matrix,2)-1)/2}));
   neuron.C_raw=vertcat(neuron.C_raw,horzcat(C_raw{1:(size(aligned_neurons_matrix,2)-1)/2}));
   neuron.S=vertcat(neuron.S,horzcat(S{1:(size(aligned_neurons_matrix,2)-1)/2}));
   centroid=calculateCentroid(A,data_shape(1),data_shape(2));
   neuron.centroid=vertcat(neuron.centroid,centroid);
   neuron.corr_scores=vertcat(neuron.corr_scores,corr_scores(i,1:length(neurons)/2));
   neuron.KL_scores=vertcat(neuron.KL_scores,KL_scores(i,1:length(neurons)/2));
end

save('neuron1','neuron')
neuron=remove_duplicate_neurons_adj(neuron);

corr_thresh=.45;
KL_thresh=6;
removed=[];
for i=1:size(neuron.corr_scores,1)
    if min(neuron.corr_scores(i,neuron.corr_scores(i,:)~=0))<corr_thresh||max(neuron.KL_scores(i,:))>KL_thresh
        removed=[removed,i];
    end
end
neuron.C(removed,:)=[];
neuron.C_raw(removed,:)=[];
neuron.S(removed,:)=[];
neuron.centroid(removed,:)=[];
neuron.corr_scores(removed,:)=[];
neuron.KL_scores(removed,:)=[];
neuron.A(:,removed)=[];

save('neuron','neuron','-v7.3')


 toc