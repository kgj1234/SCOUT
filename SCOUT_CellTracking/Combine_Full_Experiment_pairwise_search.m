function neuron=Combine_Full_Experiment_pairwise_search(shift_val,batch_dir,num_files,min_frame_overlaps,neurons)
%Function creates connecting recordings based on batches of overlapped concatenated recordings
%input

%shift_val: integer representing index shift between batches. num_vids_per_batch-num_overlap_per_batch
%batch_dir: directory containing the combined extractions from each batch. Extractions should be saved as neuroni.mat where i is the batch number, with the variable neuron inside the file containing the 
%sources2D extraction
%min_frame_overlaps: scalar bounded above by minimal number of frames in overlap between batches.
%output
%neuron Sources2D object, contains tracked cells through experiment

%Author: Kevin Johnston, University of California, Irvine


load(batch_dir)
if ~exist('neurons','var')||isempty(neurons)
neurons={};
  

for i=1:num_files
    load(['neuron',num2str(i)])
    neurons{i}=neuron;

end
end
%Construct overlapping recordings
for i=1:num_files-1
    j=i*shift_val+1;
    index=sum(batches(j-shift_val:j-1));
    links{i}=Sources2D;
    links{i}.C=neurons{i}.C(:,index-min_frame_overlaps+1:index+min_frame_overlaps);
    links{i}.S=neurons{i}.S(:,index-min_frame_overlaps+1:index+min_frame_overlaps);
    links{i}.C_raw=neurons{i}.C_raw(:,index-min_frame_overlaps+1:index+min_frame_overlaps);
    links{i}.centroid=neurons{i}.centroid;
    links{i}.A=neurons{i}.A;
    links{i}.centroid=neurons{i}.centroid;
    links{i}.imageSize=neurons{i}.imageSize;
    links{i}.P=neurons{i}.P;
    links{i}.Cn=neurons{i}.Cn;
    
    temp_neurons{i}=neurons{i}.copy();
    temp_neurons{i}.C=neurons{i}.C(:,1:index);
    temp_neurons{i}.S=neurons{i}.S(:,1:index);
    temp_neurons{i}.C_raw=neurons{i}.C_raw(:,1:index);
    
    
    
    
    
end
temp_neurons{end+1}=neurons{end}.copy();
%Cell tracking
neuron=cellTracking_SCOUT(temp_neurons,'links',links,'overlap',min_frame_overlaps,'register_sessions',false,'weights',[2.5,1,8,0,0,0],'registration_template','spatial','max_dist',12,'registration_method','non-rigid','min_prob',.5,'corr_thresh',.7,'probability_assignment_method','Kmeans','chain_prob',.5,'single_corr','true','max_gap',0,'binary_corr',false);