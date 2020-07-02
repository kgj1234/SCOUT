function BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,extraction_options,cell_tracking_options)
%Wrapper for cell extraction followed by cell tracking

%inputs
% base_dir: Directory in which aligned video files are contained. All files
% must be converted to .mat, and contain two variables, (Y: video, Ysiz:
    % video size)
%vids_per_batch: (int) Number of videos to extract in each batch, set to 1
    % and overlap_per_batch to 0 for standard cell tracking
%overlap_per_batch: (int, between 1 and vids_per_batch unles vids_per_batch=1) Number of video overlaps between batches
    

%data_type (str) '1p' or '2p'
% extraction_options (struct) see options in full_demo_endoscope (1p) or
    % demo_script (2p)
% cell_tracking_options (struct) see options in full_demo_endoscope
    % (overlap and links will be overwritten if use_corr is true)
%Author Kevin Johnston

%% Parameter Setting
if ~exist('vids_per_batch','var')||isempty(vids_per_batch)
    vids_per_batch=6;
end
if vids_per_batch>1 & overlap_per_batch>= vids_per_batch
    error('vids_per_batch must be less than overlap_per_batch')
end
if ~exist('overlap_per_batch','var')||isempty(overlap_per_batch)
    overlap_per_batch=2;
end



if ischar(vids_per_batch)
    vids_per_batch=str2double(vids_per_batch);
end

if ischar(overlap_per_batch)
    overlap_per_batch=str2double(overlap_per_batch);
end



f=dir(base_dir);
total_files={f.name};
vid_files={};
for i=1:length(total_files);
    [filepath,name,ext]= fileparts(total_files{i});
    if isequal(ext,'.tif')||isequal(ext,'.mat')
	
        vid_files{end+1}=horzcat(filepath,name,ext);
        
    end
end

bad_index=strfind(vid_files,'.dir.mat');
for i=1:length(bad_index)
    if length(bad_index{i})>0
        vid_files(i)=[];
    end
end
vid_files=sort(vid_files);


for i=1:length(vid_files)
    Y=matfile([base_dir,vid_files{i}]);
    batches(i)=Y.Ysiz(1,3);
end


batch_sizes={};
batch_vids={};
j=1;
i=1;
if overlap_per_batch==length(batches)
    batch_vids{1}=vid_files;
    batch_sizes{1}=batches;
else
while j<length(batches)-overlap_per_batch+1
    batch_vids{i}=vid_files(j:min(j+vids_per_batch-1,length(batches)));
   
    batch_sizes{i}=batches(j:min(j+vids_per_batch-1,length(batches)));
    if overlap_per_batch>0
    try
        overlap_sizes(i)=sum(batch_sizes{i}(end-overlap_per_batch+1:end))-2;
    end
    else
        overlap_sizes(i)=batch_sizes{i}-1;
    end
    
    
    
    j=j+vids_per_batch-overlap_per_batch;
    i=i+1;
    
end
end
if ~isfield(cell_tracking_options,'overlap')
    cell_tracking_options.overlap=min(12000,min(overlap_sizes));
else
    try
        cell_tracking_options.overlap=min([12000,min(overlap_sizes),cell_tracking_options.overlap]);
    catch
        cell_tracking_options.overlap=0;
    end
end

if vids_per_batch>1
       
     Concatenated_Extraction_Cell_Tracking(batch_vids,base_dir,batch_sizes,data_type,overlap_per_batch,extraction_options,cell_tracking_options);
elseif vids_per_batch==1
    
     Full_Extraction_Cell_Tracking(batch_vids,base_dir,batch_sizes,data_type,extraction_options,cell_tracking_options);
end
    
    
end
