%%Demonstration of cell tracking with SCOUT on recordings with large
%%between session discrepancies

load('neurons')
load('links')
%SCOUT obtains F1 score of 0.88, compared with 0.55 with CaImAn

%cell tracking options (fully defined in cellTracking_SCOUT)
cell_tracking_options.chain_prob=.65; %(Chain probability threshold)
cell_tracking_options.min_prob=.55; %(individual identification probability threshold)
cell_tracking_options.overlap=2950; %(Overlap size on each recording, 1/2 the length of the connecting recording)
cell_tracking_options.weights=[3,5,5,5,0,7]; %Ensemble weights
cell_tracking_options.probability_assignment_method='Kmeans'; %(Probabilistic method for assigning identification probabilities)
cell_tracking_options.max_gap=0; %(Number of allowed gaps for cell tracking, set to 0 to only extract neurons through full recording set)
cell_tracking_options.register_sessions=false;


neuron=cellTracking_SCOUT(neurons,links,'cell_tracking_options',cell_tracking_options);