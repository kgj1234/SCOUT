function []=BatchEndoscopeAutoHPC_adjustedgraphsearch(vid_files,base_dir,batch_sizes,overlap,group_val,batch_index);


close all;
%Insert number of frames per day here
%batch_sizes=[8969,8962,8971];

%overlap=4000;
%load('batches');

%batch_sizes=batches;


%KL thresh for neuron rejection (not combination) 0 if none
KL_bound=.18;
min_pnr=5;
%Max thresh for neuron constraint ( 0 if none)

if ~exist('group_val','var')||isempty(group_val)
    suffix=['_trial_1'];
else
    suffix=['ext_',num2str(group_val),'_trial_1'];
end



tic

[path,name1,ext]=fileparts(vid_files{1});
[path,name2,ext]=fileparts(vid_files{end});
extraction_name=[name1,'_',name2];

index=1;
batch_indices=[];
linkage_indices=[];
i=1;


for i=1:length(batch_sizes)
    
    batch_indices=vertcat(batch_indices,[index,index+batch_sizes(i)]);
    index=index+batch_sizes(i);
    
end
for i=1:length(batch_indices)
    linkage_indices=vertcat(linkage_indices,[batch_indices(i,2)-overlap-1,batch_indices(i,2)+overlap-1]);
end

num_batches=size(batch_indices,1);
disp(horzcat('number of batches ',num2str(num_batches*2)))

mkdir(fullfile(base_dir, 'temp'));
save_temp_file(base_dir,vid_files,batch_index,overlap);
mkdir(fullfile(base_dir,'logs'))
previous_names=check_for_previous_extractions(base_dir);
cont=[];
if ~isempty(previous_names)
    disp(previous_names)
    cont_string=input('Continue Previous Extraction? Indicate with integer corresponding to extraction, or press return ','s');
    cont=str2num(cont_string);
end
if ~isempty(cont)
    extraction_name=previous_names{cont};
    [~,extraction_name,~]=fileparts(extraction_name);
    
    load(fullfile(base_dir,'extractions',['neurons',extraction_name,'.mat']))
    log_name=fullfile(base_dir,'logs',['log_',extraction_name,'.txt']);
    if length(neurons)<size(batch_indices,1)+size(linkage_indices,1)
        neurons{size(batch_indices,1)+size(linkage_indices,1)}=[];
    end
    
else
    iter=1;
    while true
        if any(strcmp(previous_names, extraction_name))
            extraction_name{end}=num2str(iter+1);
        else
            break
        end
    end
    
    neurons=cell(1,size(batch_indices,1)+size(linkage_indices,1)); %Structure to store neuron results
    log_name=fullfile(base_dir,'logs',['log_',extraction_name,'.txt']);
end
if ~(exist(log_name, 'file') == 2)
    %initialize log file
    log = fopen( log_name, 'wt' );
    fclose(log);
end



total_empty=0;
for i=1:length(neurons)
    if isempty(neurons{i})
        total_empty=total_empty+1;
    end
end
extract_iter=1;
while total_empty>0&extract_iter<=3
    if isempty(getCurrentTask)
        for i=1:size(batch_indices,1)+size(linkage_indices,1)
            
            
            
            if i<=size(batch_indices,1)&isempty(neurons{i})
                try
                    disp(strcat('batch',num2str(i),'initialization'))
                    neurons{i}=full_demo_endoscope([base_dir,'/temp/neuron',num2str(batch_index),'.mat'],batch_indices(i,:),KL_bound,min_pnr,'bound',26);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'successful\n']);
                    fclose(log);
                catch ME
                    
                    msgText = getReport(ME);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'unsuccessful\n ',msgText,'\n']);
                    
                    fclose(log);
                end
            elseif i>=size(batch_indices,1)&isempty(neurons{i})
                try
                    disp(strcat('batch',num2str(i),'initialization'))
                    neurons{i}=full_demo_endoscope([base_dir,'/temp/neuron',num2str(batch_index),'.mat'],linkage_indices(i-size(batch_indices,1),:),KL_bound,min_pnr,'bound',26);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'successful\n']);
                    fclose(log);
                catch ME
                    
                    msgText = getReport(ME);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'unsuccessful\n ',msgText,'\n']);
                    
                    fclose(log);
                end
            end
            
        end
    else
        for i=1:size(batch_indices,1)+size(linkage_indices,1)
            
            
            
            if i<=size(batch_indices,1)&isempty(neurons{i})
                try
                    disp(strcat('batch',num2str(i),'initialization'))
                    neurons{i}=full_demo_endoscope([base_dir,'/temp/neuron',num2str(batch_index),'.mat'],batch_indices(i,:),KL_prc,min_pnr,'prc',12);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'successful\n'])
                    fclose(log);
                catch ME
                    
                    msgText = getReport(ME);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'unsuccessful\n ',msgText,'\n'])
                    
                    fclose(log);
                end
            elseif i>size(batch_indices,1)&isempty(neurons{i})
                try
                    disp(strcat('batch',num2str(i),'initialization'))
                    neurons{i}=full_demo_endoscope([base_dir,'/temp/neuron',num2str(batch_index),'.mat'],linkage_indices(i-size(batch_indices,1),:),KL_prc,min_pnr,'prc',12);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'successful\n'])
                    fclose(log);
                catch ME
                    
                    msgText = getReport(ME);
                    log = fopen( log_name, 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'unsuccessful\n ',msgText,'\n'])
                    
                    fclose(log);
                end
            end
            
        end
    end
    extract_iter=extract_iter+1;
    total_empty=0;
    for i=1:length(neurons)
        if isempty(neurons{i})
            total_empty=total_empty+1;
        end
    end
    
end
save(horzcat(base_dir,'/extractions/','neurons',extraction_name,suffix),'neurons','-v7.3')
% data_shape=neurons{1}.imageSize;
% %align_spatial_neuron_data(neurons);
% for i=1:length(neurons)
%     neurons{i}.updateCentroid();
% end
% nn_centroid=[];
% nn_spatial=[];
% for i=1:ceil(length(neurons)/2)-1
%     centroid_distances=compute_pairwise_distance(neurons{i},neurons{i+1},data_shape(1),data_shape(2),'centroid_dist');
%     nn_centroid=[nn_centroid;min(centroid_distances,[],2)];
%     spatial_overlap=compute_pairwise_distance(neurons{i},neurons{i+1},data_shape(1),data_shape(2),'overlap');
%     nn_spatial=[nn_spatial;max(1-spatial_overlap,[],2)];
% end
% max_centroid_dist=20;
% nn_centroid(nn_centroid>max_centroid_dist)=[];
% nn_spatial(nn_spatial==0)=[];
% nn_spatial=1-nn_spatial;
%




links=neurons(end-size(linkage_indices,1)+1:end-1);
neurons=neurons(1:size(batch_indices,1));
data_shape=neurons{1}.imageSize;
%neurons{end+1}=neurons{1};

neuron=cellTracking_SCOUT(neurons,links,overlap);

save(horzcat(base_dir,'/extractions/','neuron',extraction_name,suffix),'neuron','-v7.3')

toc
