clear;
clc;
close all;
overlap=5000;
batch_size=25000;
global ssub tsub;
ssub=2;
tsub=2;

tic



filename='./Double'; %Input filenames for experiment, no file extension
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
indices=vertcat(indices,[index,data_shape(3)]);
data_shape=data_shape(1:2);
if size(data_shape,1)>1
    data_shape=data_shape';
end
data_shape=squeeze(data_shape);

num_batches=size(indices,1);
disp(horzcat('number of batches ',num2str(num_batches)))




neurons={}; %Structure to store neuron results
for i=1:size(indices,1)
    disp(strcat('batch',num2str(i),'initialization'))
    
    neurons{i}=full_demo_endoscope(horzcat(filename,'.mat'),data_shape,indices(i,:),true);
    %save(horzcat('neuron',num2str(i)),'neuron','-v7.3')
end


save('neurons','neurons','-v7.3')





disp(strcat('Number of possible neurons: ', num2str(size(neurons{1}.centroid,1))))

method='auto';
threshold=12; %Search for neurons with centroids withing threshold pixels
corr_thresh=.7;
[aligned_neurons_matrix,scores]=align_and_eliminate_duplicates(neurons,threshold,corr_thresh,overlap);




%% 


% Combine batch information into single neuron

    neuron=Sources2D;
    for j=1:length(neurons)
        
       new_C=zeros(size(aligned_neurons_matrix,1),size(neurons{j}.C,2));
       new_S=zeros(size(aligned_neurons_matrix,1),size(neurons{j}.C,2));
       for i=1:size(aligned_neurons_matrix,1)
           if aligned_neurons_matrix(i,j)~=0;
               new_C(i,:)=neurons{j}.C(aligned_neurons_matrix(i,j),:);
               new_S(i,:)=neurons{j}.S(aligned_neurons_matrix(i,j),:);
           end
       end
       current_C=getfield(neuron,'C');
       current_S=getfield(neuron,'S');
       neuron.A_per_batch{j}=zeros(data_shape(1)*data_shape(2),size(aligned_neurons_matrix,1));
       neuron.centroids_per_batch{j}=zeros(size(aligned_neurons_matrix,1),2);
       for i=1:size(aligned_neurons_matrix,1)
           if aligned_neurons_matrix(i,j)~=0;
               neuron.centroids_per_batch{j}(i,:)=neurons{j}.centroid(aligned_neurons_matrix(i,j),:);
               neuron.A_per_batch{j}(:,i)=neurons{j}.A(:,aligned_neurons_matrix(i,j));
           end
       end
       if j~=1
             neuron=setfield(neuron,'C',horzcat(current_C(:,1:end-1),new_C(:,overlap+1:end)));
             neuron=setfield(neuron,'S',horzcat(current_S(:,1:end-1),new_S(:,overlap+1:end)));
       else
           neuron=setfield(neuron,'C',horzcat(current_C,new_C)); 
           neuron=setfield(neuron,'S',horzcat(current_S,new_S)); 
       end
    end
neuron.num_batches=num_batches;
neuron.scores=scores;

[neuron_A,neuron_B]=split_neuron(neuron);
comparison_scores=compare_activity_across_nonzero_indices(neuron_A,neuron_B);
indices=comparison_scores>corr_thresh&comparison_scores<1;

indices=find(indices);
neuron=combined_neurons(neuron_A,neuron_B,indices);

save('neuron1','neuron','-v7.3')
neuron=calculate_footprints_centroids(neuron);
neuron=remove_duplicate_neurons(neuron);

save('neuron','neuron','-v7.3')




 toc