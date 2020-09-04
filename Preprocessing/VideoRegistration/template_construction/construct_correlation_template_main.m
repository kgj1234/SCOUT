function templates=construct_correlation_template_main(data_type)
if ~exist('data_type','var')||isempty(data_type)
    data_type='1p';
end
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
vids=vid_files;
vids_lower=lower(vid_files);


vids(del_ind)=[];
vids_lower(del_ind)=[];
[~,ind]=sort_nat(vids_lower);
vids=vids(ind);

for i=1:length(vids)
    
    templates{i}=construct_correlation_template(['./',vids{i}],[],20,12,'prc',18,data_type);
    
end

cd templates
for i=1:length(templates)
    template=templates{i};
    save(['templates',num2str(i)],'template')
end


cd ..
    