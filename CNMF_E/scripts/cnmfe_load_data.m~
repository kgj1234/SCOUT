if and(ssub==1, tsub==1)
    neuron = neuron_full;
    if exist('var','data')
        Y = double(data.Y(:, :, sframe:sframe+num2read-1));
    end
    [d1s,d2s, T] = size(Y);
    fprintf('\nThe data has been loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
else
    if exist('Y','var')
        ssub = neuron_full.options.ssub;    % spatial downsampling factor
        tsub = neuron_full.options.tsub;    % temporal downsampling factor
        [d1,d2,T]=size(Y);
        neuron_full.options.d1=d1;
        neuron_full.options.d2=d2;
        neuron=neuron_full.copy();
        
        Tbatch = round((2^28)/(d1*d2)/tsub)*tsub; % maximum memory usage is 2GB
        Y1=Y;
        [neuron_ds, Y] = neuron.downSample(double(Y));
        T=floor(T/tsub);
        
        neuron=neuron_ds.copy();
    elseif exist(nam_mat, 'file')
        [Y, neuron_ds] = neuron_full.load_data(nam_mat, sframe, num2read);
        [d1s,d2s, T] = size(Y);
        fprintf('\nThe data has been downsampled and loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
        neuron = neuron_ds.copy();
    else
        [Y, neuron_ds] = neuron_full.load_data(nam, sframe, num2read);
        [d1s,d2s, T] = size(Y);
        fprintf('\nThe data has been downsampled and loaded into RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1s, d2s, T, d1s*d2s*T*8/(2^30));
        neuron = neuron_ds.copy();
    end
end
