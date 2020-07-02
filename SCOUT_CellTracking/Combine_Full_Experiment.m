function neuron=Combine_Full_Experiment(neurons,global_extraction_parameters,cell_tracking_options)
%Function creates connecting recordings based on batches of overlapped concatenated recordings
%inputs

%neurons (cell of Sources2D objects) extraction for each session
    %recording
%global_extraction_parameters (struct) fields described in
    %'Concatenated_Extraction_Cell_Tracking'
%cell_tracking_options (struct) fields described in 'cellTracking_SCOUT'
    
%output

%neuron Sources2D object, contains tracked cells through experiment

%Author: Kevin Johnston, University of California, Irvine

min_frame_overlap=ceil(cell_tracking_options.overlap);
cell_tracking_options.overlap=ceil(cell_tracking_options.overlap);

%Construct overlapping recordings
for i=1:length(neurons)
    temp_neurons{i}=neurons{i}.copy();
end
if min_frame_overlap>0
for i=1:length(neurons)-1
    mid_value(i)=ceil(sum(global_extraction_parameters.batch_sizes{i}(end-global_extraction_parameters.overlap_per_batch+1:end))/2);
    index(i)=sum(global_extraction_parameters.batch_sizes{i})-mid_value(i);
    
    links{i}=Sources2D;
    links{i}.C=neurons{i}.C(:,index-min_frame_overlap+1:index+min_frame_overlap);
    links{i}.S=neurons{i}.S(:,index-min_frame_overlap+1:index+min_frame_overlap);
    links{i}.C_raw=neurons{i}.C_raw(:,index-min_frame_overlap+1:index+min_frame_overlap);
    links{i}.centroid=neurons{i}.centroid;
    links{i}.A=neurons{i}.A;
    links{i}.centroid=neurons{i}.centroid;
    links{i}.imageSize=neurons{i}.imageSize;
    links{i}.P=neurons{i}.P;
    links{i}.Cn=neurons{i}.Cn;
    
 
end
else
    links=[];
end

temp_neurons{1}=neurons{1}.copy();
temp_neurons{1}.C=neurons{1}.C(:,1:end-mid_value(1));
temp_neurons{1}.S=neurons{1}.S(:,1:end-mid_value(1));
try
    temp_neurons{1}.C_raw=neurons{1}.C_raw(:,1:end-mid_value(1));
end

for i=2:length(neurons)-1
    temp_neurons{i}=neurons{i}.copy();
    temp_neurons{i}.C=neurons{i}.C(:,mid_value(i-1)+1:end-mid_value(i));
    temp_neurons{i}.S=neurons{i}.S(:,mid_value(i-1)+1:end-mid_value(i));
    try
        temp_neurons{i}.C_raw=neurons{i}.C_raw(:,mid_value(i-1)+1:end-mid_value(i));
        
    end
end

temp_neurons{end}=neurons{end}.copy();
temp_neurons{end}.C=neurons{end}.C(:,mid_value(end)+1:end);
temp_neurons{end}.S=neurons{end}.S(:,mid_value(end)+1:end);
try
    temp_neurons{end}.C_raw=neurons{end}.C_raw(:,mid_value(end)+1:end);
end






cell_tracking_options.links=links;
cell_tracking_options.single_corr=true;
%Cell tracking
neuron=cellTracking_SCOUT(temp_neurons,'cell_tracking_options',cell_tracking_options);