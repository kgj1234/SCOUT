function neuron=BatchEndoscopeAutoHPC();
clear;
clc;
close all;
overlap=1500;
batch_size=3000;
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
indices=[];
i=1;
disp('Splitting into batches')
data_shape
while index<data_shape(3)-batch_size;
   
    indices=vertcat(indices,[index,index+batch_size]);
    index=index+batch_size-overlap;
    i=i+1;
end
indices=vertcat(indices,[index,data_shape(3)+1]);
data_shape=data_shape(1:2);
if size(data_shape,1)>1
    data_shape=data_shape';
end
data_shape=squeeze(data_shape);

num_batches=size(indices,1);
disp(horzcat('number of batches ',num2str(num_batches)))



neurons={}; %Structure to store neuron results
for i=1:11:size(indices,1)
    parfor j=i:min(i+10,num_batches)
        disp(strcat('batch',num2str(j),'initialization'))
    
        neurons{j}=full_demo_endoscope(horzcat(filename,'.mat'),data_shape,indices(j,:),true,0,6);
    end
    %save(horzcat('neuron',num2str(i)),'neuron','-v7.3')
end


save('neurons','neurons','-v7.3')


dist_meas='overlap'; %options 'KL','Overlap','centroid_dist', Overlap must be between 0 and 1.
corr_type='spearman'; %options 'spearman','pearson'
align_type='graphsearch'; %options 'pairwise','graphsearch' 

dist_thresh=12; %Search for neurons with centroids withing threshold pixels
corr_thresh=.5;

if isequal(dist_meas,'Overlap')
    dist_thresh=1-dist_thresh; %Turns overlap into distance measure. 
end
if isequal(align_type,'pairwise')
    [aligned_neurons_matrix,corr_scores,dist,corr_prc,dist_prc]=align_and_eliminate_duplicates(neurons,corr_thresh,dist_thresh,overlap,data_shape,corr_type,dist_meas);
else
    score_thresh=.3*dist_thresh+.7*corr_thresh;
    [aligned_neurons_matrix,corr_scores,dist,corr_prc,dist_prc]=align_and_eliminate_duplicates_graph(neurons,score_thresh,corr_thresh,dist_thresh,overlap,data_shape,corr_type,dist_meas);
end



%% 


% Combine batch information into single neuron

    neuron=Sources2D;
    for j=1:length(neurons)
        
       new_C=zeros(size(aligned_neurons_matrix,1),size(neurons{j}.C,2));
       new_S=zeros(size(aligned_neurons_matrix,1),size(neurons{j}.C,2));
       new_C_raw=zeros(size(aligned_neurons_matrix,1),size(neurons{j}.C,2));
       for i=1:size(aligned_neurons_matrix,1)
           if aligned_neurons_matrix(i,j)~=0;
               new_C(i,:)=neurons{j}.C(aligned_neurons_matrix(i,j),:);
               new_C_raw(i,:)=neurons{j}.C_raw(aligned_neurons_matrix(i,j),:);
               new_S(i,:)=neurons{j}.S(aligned_neurons_matrix(i,j),:);
           end
       end
       current_C=getfield(neuron,'C');
       current_S=getfield(neuron,'S');
       current_C_raw=getfield(neuron,'C_raw');
       neuron.A_per_batch{j}=zeros(data_shape(1)*data_shape(2),size(aligned_neurons_matrix,1));
       neuron.centroids_per_batch{j}=zeros(size(aligned_neurons_matrix,1),2);
       for i=1:size(aligned_neurons_matrix,1)
           if aligned_neurons_matrix(i,j)~=0;
               neuron.centroids_per_batch{j}(i,:)=neurons{j}.centroid(aligned_neurons_matrix(i,j),:);
               neuron.A_per_batch{j}(:,i)=neurons{j}.A(:,aligned_neurons_matrix(i,j));
           end
       end
       if j~=1
             neuron=setfield(neuron,'C',horzcat(current_C(:,1:end),new_C(:,overlap+1:end)));
              neuron=setfield(neuron,'C_raw',horzcat(current_C_raw(:,1:end),new_C_raw(:,overlap+1:end)));
             neuron=setfield(neuron,'S',horzcat(current_S(:,1:end),new_S(:,overlap+1:end)));
       else
           neuron=setfield(neuron,'C',horzcat(current_C,new_C)); 
            neuron=setfield(neuron,'C_raw',horzcat(current_C_raw,new_C_raw)); 
           neuron=setfield(neuron,'S',horzcat(current_S,new_S)); 
       end
    end
neuron.num_batches=num_batches;
neuron.corr_scores=corr_scores;
neuron.dist=dist;
neuron.corr_prc=corr_prc;
neuron.dist_prc=dist_prc;

[neuron_A,neuron_B]=split_neuron(neuron);
comparison_scores=compare_activity_across_nonzero_indices(neuron_A,neuron_B);
indices=comparison_scores>.5&comparison_scores<1;

indices=find(indices);
neuron=combined_neurons(neuron_A,neuron_B,indices);

neuron.options=neurons{1}.options;  
neuron.options.deconv_options=neurons{1}.options.deconv_options;



A=zeros(size(neuron.A_per_batch{1}));
for i=1:length(neuron.A_per_batch)
    A=A+neuron.A_per_batch{i};
end
neuron.A=A;
%save('neuron1','neuron','-v7.3')

neuron.combined=ones(1,size(neuron.C,1));





merge=quickMerge(neuron,[.1,.6,-.1]);
indices=sum(neuron.corr_scores,2)==0;
neuron.corr_scores(indices,:)=[];
neuron.corr_prc(indices,:)=[];
neuron.dist(indices,:)=[];
neuron.dist_prc(indices,:)=[];
for i=1:length(merge);
    for j=1:length(neuron.A_per_batch);
        neuron.A_per_batch{j}(:,merge{i}(1))=sum(neuron.A_per_batch{j}(:,merge{i}),2)/length(merge{i});
        neuron.A_per_batch{j}(:,merge{i}(2:end))=0;
    end
end
for i=1:length(neuron.A_per_batch)
    
    neuron.A_per_batch{i}(:,sum(neuron.A_per_batch{i},1)==0)=[];
end
neuron.imageSize=data_shape(1:2);
for i=1:length(neuron.A_per_batch)
    neuron.centroids_per_batch{i}=[];
    for j=1:size(neuron.A_per_batch{i},2)
        [centroid,~]=calculateCentroid_and_Covariance(neuron.A_per_batch{i}(:,j),neuron.imageSize(1),neuron.imageSize(2));
        neuron.centroids_per_batch{i}=[neuron.centroids_per_batch{i};centroid];
    end
end
for i=1:size(neuron.A,2)
    [centroid,~]=calculateCentroid_and_Covariance(neuron.A(:,i),neuron.imageSize(1),neuron.imageSize(2));
    neuron.centroid=[neuron.centroid;centroid];
end




save('neuron','neuron','-v7.3')




 toc