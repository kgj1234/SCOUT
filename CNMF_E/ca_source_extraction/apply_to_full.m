function neuron=apply_to_full(i,spatial_downsample,temporal_downsample)
spatial_ds_factor = 2;
disp(strcat('./batch',num2str(i),'.mat'))
load(strcat('./batch',num2str(i),'.mat'))
disp('loaded')
%% apply results to the full resolution
%These can be adjusted. ssub appears to be an actual function.
tsub=temporal_downsample;
ssub=spatial_downsample;
if or(ssub>1, tsub>1)
    neuron_ds = neuron.copy();  % save the result
    neuron = neuron_full.copy();
    cnmfe_full;
    neuron_full = neuron.copy();
end
%
%% delete some neurons and run CNMF-E iteration 
neuron.orderROIs('decay_time');  % you can also use {'snr', 'mean', 'decay_time'} 
Cn = imresize(Cn, [d1, d2]);
[neuron.Coor,json_file,centroid] = plot_contours(neuron.A, Cn, 0.8, 1, [], [], 2);

%neuron.file = neuron;
neuron.numFrame = numFrame;
neuron.num2read = num2read;
neuron.centroid = centroid;
neuron.trace = neuron.C.*(max(neuron.A)'*ones(1,size(neuron.C,2)));
neuron.Cn = Cn;
[C_df,C_raw_df, Df] = extract_DF_F_endoscope(neuron,Ybg);
neuron.C_df = C_df;neuron.Df = Df;
close all
end
