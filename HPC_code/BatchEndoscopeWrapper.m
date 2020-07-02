function BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,num_ext_per_batch,overlap_per_file,data_type)
% base_dir: Directory in which aligned video files are contained
%vids_per_batch: Number of videos to extract in each batch
%overlap_per_batch: Number of video overlap in each batch
%num_ext_per_batch: If this is larger than one, video files are
%concatenated together so that num_ext_per_batch files are extracted
%together.
if ~exist('vids_per_batch','var')||isempty(vids_per_batch)
    vids_per_batch=6;
end
if ~exist('overlap_per_batch','var')||isempty(overlap_per_batch)
    overlap_per_batch=2;
end
if ~exist('num_ext_per_batch','var')||isempty(num_ext_per_batch)
    num_ext_per_batch=2;
end
if ~exist('overlap_per_file','var')||isempty(overlap_per_file)
    overlap_per_file=5000;

end

if ischar(vids_per_batch)
    vids_per_batch=str2double(vids_per_batch);
end

if ischar(overlap_per_batch)
    overlap_per_batch=str2double(overlap_per_batch);
end

if ischar(num_ext_per_batch)
    num_ext_per_batch=str2double(num_ext_per_batch);
end
if ischar(overlap_per_file)
    overlap_per_file=str2double(overlap_per_file);
end

vids_per_batch
overlap_per_batch
num_ext_per_batch
overlap_per_file


mkdir([base_dir,'extractions'])
f=dir(base_dir);
total_files={f.name}
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
    k=1;
    temp_batch=[];
    
    while k<=length(batch_sizes{i})
        temp_batch(end+1)=sum(batch_sizes{i}(k:min(k+num_ext_per_batch-1,length(batch_sizes{i}))));
        k=k+num_ext_per_batch;
    end
    batch_sizes{i}=temp_batch;    
    
    
    j=j+vids_per_batch-overlap_per_batch;
    i=i+1;
    
end
end
batch_vids
base_dir
length(batch_sizes)
batch_sizes
if length(batch_sizes)<=3&&vids_per_batch>num_ext_per_batch
    for j=1:length(batch_sizes)
        try    
            Full_Extraction_Cell_Tracking(batch_vids{j},base_dir,batch_sizes{j},overlap_per_file,num_ext_per_batch,j);
        catch ME
            ME.message
            ME.stack   
            Full_Extraction_Cell_Tracking(batch_vids{j},base_dir,batch_sizes{j},overlap_per_file,num_ext_per_batch,j);

        end
    end
elseif length(batch_sizes)>3 &&vids_per_batch>num_ext_per_batch
    parfor j=1:length(batch_sizes)
        try    
            Full_Extraction_Cell_Tracking(batch_vids{j},base_dir,batch_sizes{j},overlap_per_file,num_ext_per_batch,j);
        catch ME
            ME.message
            ME.stack   
            Full_Extraction_Cell_Tracking(batch_vids{j},base_dir,batch_sizes{j},overlap_per_file,num_ext_per_batch,j);

        end
    end
else
    for i=1:5:length(batch_sizes)

	parfor j=i:min(length(batch_sizes),i+5)
        	mkdir([base_dir,'temp'])
        	save_temp_file(base_dir,batch_vids{j},j,overlap_per_file)
		try
        		neurons{j}=full_demo_endoscope([base_dir,'/temp/neuron',num2str(j),'.mat'],[1,batch_sizes{j}+1],.95,5,'prc');
    		catch ME
			ME.message
			ME.stack
        		neurons{j}=full_demo_endoscope([base_dir,'/temp/neuron',num2str(j),'.mat'],[1,batch_sizes{j}+1],.95,5,'prc');

	end
	end
	end
    for i=1:length(batch_sizes)
        neuron=neurons{i};
        save([base_dir,'extractions','/neuron',num2str(i)],'neuron','-v7.3')
    end


    
    
end
