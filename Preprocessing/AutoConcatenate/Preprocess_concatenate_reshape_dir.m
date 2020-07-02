function []=Preprocess_concatenate_reshape_dir(base_dir,save_dir)
%Takes in the base dir containing all desired files, and recursively
%searches through directories, locating any directory containing files with
%name msCam(i), where i is an integer. The msCam files from each directory
%are then concatenated and reshaped, and the resulting files are saved in
%the save_dir.

%If connection is lost, some files may not be concatenated, the base
%folders will be displayed if this occurs.

%On my linux, subdir required me to navigate to the subdir, and use './' (.\ in windows) as
%the base_dir input

temp={'./day22_02062020','./day23_02082020','./day24_02092020','./day25_02102020','./day26_02112020','./day27_02132020(extinction)'};

if isequal(save_dir(end),'/')||isequal(save_dir(end),'\')
    save_dir=save_dir(1:end-1);
end


files={};
%files=subdir(base_dir);
%files={files.name};
for i=1:length(temp)
    temp_files=subdir(temp{i});
    temp_files={temp_files.name};
    for j=1:length(temp_files)
        files{end+1}=temp_files{j};
    end
end


folders={};
for i=1:length(files)
    [folders{end+1},~,~]=fileparts(files{i});
end
folders=unique(folders);
% for i=length(folders):-1:1
%     [~,name,~]=fileparts(folders{i});
%     if isempty(regexp(name,'m2+'))
%         folders(i)=[];
%     end
% end


for i=1:length(folders)
   if ~isempty(strfind(folders{i},'3413M_S')) 
   Preprocess_concatenate_reshape(folders{i},save_dir);
   %concatenate_behav(folders{i},save_dir);
   end
end
