function edit_sh_file(sh_file_loc,folder)
data=txt_parser(sh_file_loc);
for k=length(data):-1:1
    if isempty(data{k});
        data(k)=[];
    end
end

data(end)=[];
data{end+1}=['~/SCOUT/HPC_code/full_pipeline/full_pipeline_hpc $''',folder,''''];


fid=fopen(sh_file_loc,'w');
for k=1:length(data)
    fprintf(fid,[data{k},'\n']);
end
fclose(fid);

