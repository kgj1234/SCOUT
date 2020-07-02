function BatchEndoscopeWrapperTriple()
base_dir='~/Desktop/mouseC/higherdirectory/';
f= dir(base_dir); 


vids_per_batch=6
overlap_per_batch=2

total_files={f.name};
vid_files={};
for i=1:length(total_files)
    [filepath,name,ext]= fileparts(total_files{i});
    if isequal(ext,'.tif')||isequal(ext,'.mat')
        vid_files{end+1}=horzcat(filepath,name,ext);
    end
end

vid_files=sort(vid_files);
load('~/Desktop/mouseC/higherdirectory/batches');
%load('./batches')
%batches=[2000,2000];
batch_sizes={};
j=1;
i=1;
while j<length(batches)-overlap_per_batch+1
    
curr_batches=batches(j:min(j+vids_per_batch-1,length(batches)));

if mod(length(curr_batches),3)==0
    batch_sizes{i}=curr_batches(1:3:end)+curr_batches(2:3:end)+curr_batches(3:3:end);
elseif mod(length(curr_batches),3)==1
	batch_sizes{i}=[curr_batches(1:3:end-1)+curr_batches(2:3:end)+curr_batches(3:3:end),curr_batches(end)];
else
batch_sizes{i}=[curr_batches(1:3:end-2)+curr_batches(2:3:end-1)+curr_batches(3:3:end),curr_batches(end-1)+curr_batches(end-2)];
end
	j=j+vids_per_batch-overlap_per_batch;
    i=i+1;
end
%for i=1:length(batch_sizes)
%	batch_sizes{i}
%end
for j=1:length(batch_sizes)
try    
    BatchEndoscopeAutoHPC_adjustedgraphsearch([base_dir,vid_files{j}],batch_sizes{j},10000,base_dir,3);
catch ME
    ME.message
   end 
end
