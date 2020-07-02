function BatchEndoscopeWrapperSimple(base_dir)
% base_dir: Directory in which aligned video files are contained
%vids_per_batch: Number of videos to extract in each batch
%overlap_per_batch: Number of video overlap in each batch
%num_ext_per_batch: If this is larger than one, video files are
%concatenated together so that num_ext_per_batch files are extracted
%together.
vids=dir(base_dir);
vids={vids.name};
vids(1:2)=[];
if isequal(vids{1},'.dir.mat');
    vids(1)=[];
end
vid_files={};
for i=1:length(vids)
    if isfile([base_dir,vids{i}])
        vid_files{end+1}=vids{i};
    end
end

mkdir([base_dir,'temp'])
save_temp_file_simple(base_dir,vid_files)
neuron=full_demo_endoscope([base_dir,'/temp/neuron','.mat'],[],.95,9,'prc',18);
save([base_dir,'/neuron'],'neuron')