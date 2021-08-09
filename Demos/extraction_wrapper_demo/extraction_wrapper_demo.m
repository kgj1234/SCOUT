%This demonstrates a cell extraction wrapper that allows you to specify
%certain commonly varied parameters. 

clear all
clc



%inputs 

%final argument only relevant if 1p data, see full_demo_endoscope.m

%filename: filepath of recording, 2p data currently supports '.mat', and '.avi' extensions 
%gSiz: maximum neuron size
%min_pnr: min-peak to noise ratio (number, typically larger than 4)
%data_type: '1p' or '2p'
%indices: video indices to extract, leave as [] for full video extraction
%min_pnr (min_snr for 2p) : minimum peak(signal)-to-noise ratio for data selection
%JS: JS constraint value for 1p data
%min_corr: (float in range [0,1]) min_corr threshold for neuron
    %initialization
%corr_noise: (bool) add noise when calculating correlation_image;

%outputs

%neuron (Sources2D) extracted neural activity
%scoutpath (string) path to scout on local drive

%%Author Kevin Johnston


filename=fullfile('..','vid1.mat');
gSiz=25;
data_type='1p';
max_neurons=400;
min_corr=.8; %(set to .8 for restricted initialization)
corr_noise=false;
indices=[];
min_pnr=5;
JS=.06; %(spatial filter threshold, set to 0 for CNMF-E extraction)

neuron=individual_extraction_main(filename,gSiz,data_type,max_neurons,min_corr,corr_noise,indices,min_pnr,JS);

load(fullfile('Ground_Truth','C'))
C=C(:,1:500);
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



