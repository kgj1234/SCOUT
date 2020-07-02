clear;
clc;
close all;
overlap=5000;
batch_size=40000;
spatial_downsample=2;
temporal_downsample=2;



filename='mouse5croppedDouble.tif'; %Input filenames for experiment;
disp('loading data')
[Experiment_data,Nframes]=imread_big(filename);
%Split into batches
disp('data size')
data_shape=size(Experiment_data)

index=1;
batches={};
i=1;
disp('Splitting into batches and saving')
while index<Nframes-batch_size;
    batches{i}=Experiment_data(:,:,index:index+batch_size);
    
    index=index+batch_size-overlap;
    i=i+1;
end
batches{end+1}=Experiment_data(:,:,index:end);

num_batches=length(batches);
disp(horzcat('number of batches ',num2str(num_batches)))
filenames={};
for i=1:num_batches
    Y=batches{i};
    Ysiz=transpose(size(Y));
    filename=horzcat('./split',num2str(i),'.mat');
    save(filename, 'Y', 'Ysiz', '-v7.3'); 
    filenames{i}=filename;
end
clear batches
    


neurons={};

for i=1:length(filenames)
    disp(strcat('batch',num2str(i),'initialization'))
    
    neurons{i}=run_demo_endoscope(filenames{i});
end
% 
% for i=1:length(filenames)
%     disp(strcat('batch',num2str(i),'manual neuron trimming'))
%     neurons{i}=run_manual_endoscope(i);
%    
% end

save('neurons','neurons','-v7.3')





disp(strcat('Number of possible neurons: ', num2str(size(neurons{1}.centroid,1))))

method='auto';
threshold=12; %Search for neurons with centroids withing threshold pixels
corr_thresh=.7;
aligned_neurons_matrix=align_neurons(neurons,data_shape(1),data_shape(2),method,threshold,corr_thresh,overlap);
scores=score_aligned_matrix(neurons,aligned_neurons_matrix,overlap);
aligned_neurons_matrix=remove_duplicates(aligned_neurons_matrix,scores);
neuron=Sources2D;

fields={'C','S','C_raw','Df','C_df','trace'};
aligned_neurons_matrix=aligned_neurons_matrix(aligned_neurons_matrix(:,1)>0,:);

neuron.centroid=neurons{1}.centroid(aligned_neurons_matrix(:,1),:);
%% 
for k=1:length(fields)
    
    for j=1:length(neurons)
        
       current=getfield(neuron,fields{k});
           
       new=getfield(neurons{j},fields{k});
      
       neuron.A_per_batch{j}=neurons{j}.A(:,aligned_neurons_matrix(:,j));
       neuron.centroids_per_batch{j}=neurons{j}.centroid;
       if j~=1
             neuron=setfield(neuron,fields{k},horzcat(current(:,1:end-1),new(aligned_neurons_matrix(:,j),overlap+1:end)));
       else
           neuron=setfield(neuron,fields{k},horzcat(current(:,1:end-1),new(aligned_neurons_matrix(:,j),:))); 
       end
    end
end
neuron.num_batches=num_batches;
neuron.scores=scores(scores(:,1)>0,:);
                
save('neuron','neuron','-v7.3')