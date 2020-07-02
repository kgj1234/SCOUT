function templates=construct_correlation_template_main()
mkdir templates
vid_files=dir;
vid_files={vid_files.name};
vids={};
for i=1:length(vid_files)
    if isfile(vid_files{i})&&~isequal(vid_files{i},'.dir.mat')
        vids{end+1}=vid_files{i};
    end
end
vids_lower=lower(vids);
[~,ind]=sort(vids_lower);
vids=vids(ind);
for i=1:length(vids)
    
    templates{i}=construct_correlation_template(['./',vids{i}],[],20,12,'prc',12);
    
end

cd templates
for i=1:length(templates)
    template=templates{i};
    save(['templates',num2str(i)],'template')
end


cd ..
    