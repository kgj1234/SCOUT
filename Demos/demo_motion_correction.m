%Motion Correction Demonstration
%Currently, recordings must be saved as .mat

%This demo motion corrects all possible videos in the current folder

clear all
clc



%List directory contents and remove all files without .mat extension
vids=dir;
vids={vids.name};
for i=length(vids):-1:1
    [path,name,ext]=fileparts(vids{i});
    if ~isequal(ext,'.mat')||isequal(name,'.dir')
        vids(i)=[];
    end
end

%parfor i=1:length(vids)
for i=1:length(vids)
    %run motion correction, 
    runrigid2(vids{i});
end






