function []=concatenate_behav(direc,save_folder,num_dir)
files=dir(direc);
files = {files.name};
vid_files={};
prefix='behavCam';



for i=1:length(files)
    %Change prefix here if necessary
    startIndex = strfind(files{i},prefix);
    if ~isempty(startIndex)
        vid_files{end+1}=files{i};
    end
end
if ~isempty(vid_files)
try
for i=1:length(vid_files)
    %Change prefix here as well
    vid_files{i}=[prefix,num2str(i),'.avi'];
end

current=[];
try
for i=1:length(vid_files)
    try
    mov = VideoReader(fullfile(direc,vid_files{i}));
    Y=mov.read;
    Y=squeeze(Y);
    
    current=cat(4,current,uint8(Y));
    end
end
catch
    'concatenation failed'
    direc
    
end
if ~isempty(current)
endout=regexp(direc,filesep,'split');
endout{1}=[];

if ~exist('num_dir','var')||isempty(num_dir)
    num_dir=length(endout);
end
name=[];
curr=1;
for i=max(length(endout)-num_dir+1,1):length(endout)
    name{curr}=endout{i};
    curr=curr+1;
end
folder=[save_folder,'/'];
for i=1:length(name)-1
    folder=[folder,name{i},'/'];
end
mkdir(folder)
behav=current;
%Ysiz=size(Y);

save(fullfile(folder,name{end}),'behav','-v7.3');

end
end
end