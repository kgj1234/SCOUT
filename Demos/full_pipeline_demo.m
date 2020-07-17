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
    if ~(isequal(ext,'.mat')||isequal(ext,'.avi')||isequal(ext,'.tif')||...
            isequal(ext,'.tiff'))||isequal(name,'.dir')
        vids(i)=[];
    end
end

%parfor i=1:length(vids)
for i=1:length(vids)
    %run motion correction, 
    runrigid2(vids{i});
end

cd(fullfile(vids_directory,'motion_corrected'))

%Automatic session registration
video_registration_main(true,ceil(length(vids)/2),'correlation',true)

%Extraction parameters (unset fields revert to default values in
%full_demo_endoscope.m
extraction_options.JS=.09; %(spatial constraint parameter, this is too low for in vivo data, it should be at least 0.1)


%cell tracking options (fully defined in cellTracking_SCOUT)
cell_tracking_options.chain_prob=.5; %(Chain probability threshold)
cell_tracking_options.min_prob=.5; %(individual identification probability threshold)
cell_tracking_options.overlap=[]; %(Overlap size on each recording, 1/2 the length of the connecting recording, set to [] for max frames)
cell_tracking_options.weights=[4,5,5,0,0,0]; %Ensemble weights
cell_tracking_options.probability_assignment_method='Kmeans'; %(Probabilistic method for assigning identification probabilities)
cell_tracking_options.max_gap=0; %(Only report neurons tracked through full experiment)
cell_tracking_options.max_dist=40; %(maximum distance between neurons, larger values preferred, this value is corrected, so don't worry about making it too big)



%Global cell tracking parameters
base_dir='./'; %(Directory containing video files)
vids_per_batch=1; %(Set to 1 for standard cell tracking. Increasing this parameter constructs concatenated 
                    %videos for use in longer term cell tracking) 
overlap_per_batch=0; %(Set to 0 for standard cell tracking (with vids_per_batch=1) )
data_type='1p'; %1p or 2p
threads=4; %Number of sessions to extract simultaneously, high values can easily exceed memory threshold, but significantly boost speed



BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options)



load('SCOUT_neuron','neuron')
load(fullfile('..','..','..','Ground_Truth','C'))
correlations=corr(neuron.C',C');
maxim=max(correlations,[],2);
histogram(maxim)
title('Correlations With Ground Truth')
figure()
plot_contours(neuron.A,neuron.Cn,0.8, 1, [], [], 2)
title('Correlation Image')
figure()
imagesc(max(reshape(neuron.A,256,256,[]),[],3))
title('Spatial Footprints')


