function templates=construct_correlation_template_main()
mkdir templates
vid_files=dir;
vid_files={vid_files.name};
vids={};
for i=1:length(vid_files)
    [~,name,ext]=fileparts(vid_files{i});
    if (~isequal(ext,'.mat') && ~isequal(ext,'.avi'))||isequal(name,'.dir')||isequal(ext,'.m')
        del_ind(i)=1;
    end
end
del_ind=find(del_ind);
vids_lower=lower(vid_files);

vids=vids_lower;
vids(del_ind)=[];
[~,ind]=sort(vids);
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
    