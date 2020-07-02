function []=Preprocess_concatenate_reshape_frames(direc,save_folder,num_dir)
%num_dir is an integer indicating the number of directories to use in the
%outputed name of the file.
files=dir(direc);
files = {files.name};
vid_files={};
for i=1:length(files)
    startIndex = regexp(files{i},'msCam*');
    if ~isempty(startIndex)
        vid_files{end+1}=files{i};
    end
end
try
vid_files=asort(vid_files);
vid_files=vid_files.anr;
current=[];
try
for i=length(vid_files)
    mov = VideoReader(fullfile(direc,vid_files{i}));
    frames=ceil(mov.NumberOfFrames/2)+500*(length(vid_files)-1);
    
end
catch

end
endout=regexp(direc,filesep,'split');
endout{1}=[];
if ~exist('num_dir','var')||isempty(num_dir)
    num_dir=length(endout);
end
name=[];
for i=max(length(endout)-num_dir+1,1):length(endout)
    name=[name,endout{i}];
end

save(fullfile(save_folder,name),'frames');


end
