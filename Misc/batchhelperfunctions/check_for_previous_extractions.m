function name=checck_for_previous_extractions(base_dir)
name={};
vids=dir(fullfile(base_dir,'extractions'));
vids={vids.name};
for i=1:length(vids)
    if length(findstr(vids{i},'neurons'))>0
        name{end+1}=vids{i}(8:end);
    end
end
