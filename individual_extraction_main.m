function neuron=individual_extraction_main(filename,gSiz,data_type,max_neurons,min_corr,corr_noise,indices,min_pnr,JS)
%Wrapper for neuron extraction. You can also use full_demo_endoscope (1p
%   data) or demo_script(2p data) directly. This script may not work in
%   parfor loops.

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

%% 

%Parameter setting
if exist('JS','var')
    if ischar(JS)
        JS=str2num(JS);
    end
    extraction_options.JS=JS;
else
    extraction_options.JS=0;
end
if exist('gSiz','var')
    if ischar(gSiz)
        gSiz=str2num(gSiz);
    end
    extraction_options.gSiz=gSiz;
else
    extraction_options.gSiz=25;
end
if exist('corr_noise','var')
    if ischar(corr_noise)
        corr_noise=str2num(corr_noise);
    end
    extraction_options.corr_noise=corr_noise;
else
    extraction_options.corr_noise=false;
end
if exist('min_corr','var')
    if ischar(min_corr)
        min_corr=str2num(min_corr);
    end
    extraction_options.min_corr=min_corr;
else
    extraction_options.min_corr=.8;
end

if exist('max_neurons','var')
    if ischar(max_neurons)
        max_neurons=str2num(max_neurons);
    end
    extraction_options.max_neurons=max_neurons;
else
    extraction_options.max_neurons=[];
end
if exist('indices','var')
    if ischar(indices)
        indices=str2num(indices);
    end
    extraction_options.indices=indices;
else
    extraction_options.indices=[];
end
if exist('min_pnr','var')
    if ischar(min_pnr)
        min_pnr=str2num(min_pnr);
    end
    extraction_options.min_pnr=min_pnr;
else
    extraction_options.min_pnr=5;
end


if isequal(data_type,'1p')
      neuron=full_demo_endoscope(filename,extraction_options);
   
elseif isequal(data_type,'2p')
       neuron=full_demo_endoscope_2p(filename,extraction_options);
else
    error('disallowed data_type variable')

end
