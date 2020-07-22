% This script demonstrates usage of the cell tracking Wrapper function
% Extraction and cell tracking parameters are specified prior to
% extraction, and the Wrapper constructs the connecting recordings and
% performes cell tracking

%Extraction parameters (unset fields revert to default values in
%full_demo_endoscope.m
extraction_options.JS=.1; %(spatial constraint parameter)
extraction_options.gSiz=23;
extraction_options.min_corr=.75;
extraction_options.max_neurons=300;



%cell tracking options (fully defined in cellTracking_SCOUT)
cell_tracking_options.chain_prob=.5; %(Chain probability threshold)
cell_tracking_options.min_prob=.5; %(individual identification probability threshold)
cell_tracking_options.overlap=2000; %(overlap size on each recording, 1/2 the length of the connecting recording)
cell_tracking_options.weights=[4,5,5,0,0,0]; %Ensemble weights
cell_tracking_options.probability_assignment_method='Kmeans'; %(Probabilistic method for assigning identification probabilities)


%Global cell tracking parameters
base_dir='./'; %(Directory containing video files)
vids_per_batch=1; %(Set to 1 for standard cell tracking. Increasing this parameter constructs concatenated 
                    %videos for use in longer term cell tracking) 
overlap_per_batch=0; %(Set to 0 for standard cell tracking. Must be at least one if vids_per_batch>1)
data_type='1p';
threads=4; %Number of sessions to extract simultaneously, high values can easily exceed memory threshold, but significantly boost speed


BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options)



