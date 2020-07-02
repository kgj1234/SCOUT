function neuron=run_manual_endoscope(i)


display_merge = true;          % visually check the merged neurons
view_neurons = true; 
for m=1
    %temporal
    neuron.updateTemporal_endoscope(Ysignal);
    cnmfe_quick_merge;              % run neuron merges

    %spatial
    neuron.updateSpatial_endoscope(Ysignal, Nspatial, update_spatial_method);
    neuron.trimSpatial(0.01, 3); % for each neuron, apply imopen first and then remove pixels that are not connected with the center
    neuron.compactSpatial(); 
    cnmfe_merge_neighbors; 
end
fprintf('Time cost in updating spatial & temporal components:     %.2f seconds\n', toc);

b0 = mean(Y,2)-neuron.A*mean(neuron.C,2); 
Ybg = bsxfun(@plus, Ybg, b0-mean(Ybg, 2)); 
neuron.orderROIs('snr'); 
%

figure;
Cn = imresize(Cn, [d1, d2]);
[neuron.Coor,json_file,centroid] = plot_contours(neuron.A, Cn, 0.8, 1, [], [], 2);
% plot_contours(neuron.A, Cn, 0.8, 0, [], [], 2); % display no numbers
colormap winter;
title('contours of estimated neurons');
%%savejson('jmesh',json_file,'contoursJason8thGsig8Ds3manual2Auto'); %%Suoqin added this to save the image

figure
imagesc(Cn,[min(Cn(:)) max(Cn(:))])
% hold on
% scatter(centroid(:,2),centroid(:,1),'r')
axis tight; axis equal;axis off
colormap winter;

neuron.file = neuron;
neuron.numFrame = numFrame;
neuron.num2read = num2read;
neuron.centroid = centroid;
neuron.trace = neuron.C.*(max(neuron.A)'*ones(1,size(neuron.C,2)));
neuron.Cn = Cn;
[C_df,C_raw_df, Df] = extract_DF_F_endoscope(neuron,Ybg);
neuron.C_df = C_df;neuron.Df = Df;
close all

end
