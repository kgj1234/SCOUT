clear all
clc

%Preprocess with motion correction


%List directory contents and remove all files without .mat extension
vids_directory='./'; % Specify directory containing videos (demo must be run inside Demos folder
                        %as this contains the video files. 
                        %No other .mat files can be in this folder
                        
                        


vids=dir(vids_directory);
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

cd motion_corrected

%Extraction parameters (unset fields revert to default values in
%full_demo_endoscope.m
extraction_options.JS=.06; %(spatial constraint parameter)


%cell tracking options (fully defined in cellTracking_SCOUT)
cell_tracking_options.chain_prob=.5; %(Chain probability threshold)
cell_tracking_options.min_prob=.5; %(individual identification probability threshold)
cell_tracking_options.overlap=250; %(Overlap size on each recording, 1/2 the length of the connecting recording)
cell_tracking_options.weights=[4,5,5,0,0,0]; %Ensemble weights
cell_tracking_options.probability_assignment_method='Kmeans'; %(Probabilistic method for assigning identification probabilities)


%Global cell tracking parameters
base_dir='./'; %(Directory containing video files)
vids_per_batch=1; %(Set to 1 for standard cell tracking. Increasing this parameter constructs concatenated 
                    %videos for use in longer term cell tracking) 
overlap_per_batch=0; %(Set to 0 for standard cell tracking. Must be at least one if vids_per_batch>1)
data_type='1p'; %1p or 2p

BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,extraction_options,cell_tracking_options)



