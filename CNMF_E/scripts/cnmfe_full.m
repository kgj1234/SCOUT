%% upsample the CNMF results 
A0 = neuron_ds.reshape(neuron_ds.A, 2); 
C0 = neuron_ds.C; 
C0_raw = neuron_ds.C_raw; 
kernel_pars = neuron_ds.P.kernel_pars; 
K = size(C0, 1);     % number of the neuron 

neuron.A = neuron.reshape(imresize(A0, [d1, d2]), 1); 
C = zeros(K, num2read); 
C(:, 1:T*tsub) = resample(C0', tsub, 1)';
temp = num2read - T*tsub; 
if temp>0
    C(:, (num2read-temp+1):end) = C(:, T*tsub) * ones(1, temp); 
end
neuron.C = C; 
neuron.C_raw = zeros(K, num2read); 
neuron.S = zeros(K, num2read); 
neuron.P.kernel_pars = kernel_pars * tsub; 

%% load data 
try
    Y = data.Y(:, :, sframe:(sframe+num2read-1)); 
catch
    Y=Y1;
end
Y = neuron.reshape(double(Y), 1); 
clear Y1

if ssub ==1 
    neuron.P.sn = sn; 
elseif ~isfield(neuron.P, 'sn') || isempty(neuron.P.sn)
    sn = neuron.estNoise(Y);
    neuron.P.sn = sn; 
else
    sn = neuron.P.sn; 
end
neuron.P.sn(isnan(neuron.P.sn)|neuron.P.sn==0)=1;
neuron.P.kernel_pars(isnan(neuron.P.kernel_pars)|neuron.P.kernel_pars==0)=1;
%% estimate the background 
rr = bg_neuron_ratio * neuron.options.gSiz; 
cnmfe_update_BG; 

%% update the spatial and components
maxIter = 1; 
for miter=1:maxIter
    fprintf('Iteration %d/%d to update spatial and temporal components\n', miter, maxIter); 
    tic;
    neuron.updateSpatial_endoscope(Ysignal, Nspatial, update_spatial_method);
    neuron.trimSpatial(0.02); 
    fprintf('Time cost in updating neuronal spatial components:     %.2f seconds\n', toc);
    
    neuron.updateTemporal_endoscope(Ysignal);
    fprintf('Time cost in updating neuronal temporal components:     %.2f seconds\n', toc);   
    neuron.remove_false_positives();

end
    