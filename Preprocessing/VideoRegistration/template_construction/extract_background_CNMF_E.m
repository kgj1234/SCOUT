function template=extract_background_CNMF_E(filename,data_shape,indices,min_pnr)
global  d1 d2 numFrame sframe num2read Fs neuron neuron_ds ...
    neuron_full Ybg_weights; %#ok<NUSED> % global variables, don't change them manually
ssub=2;
tsub=2;
if ~exist('batch_mode','var')||isempty('batch_mode')
    batch_mode=false;
end
if ~exist('KL','var')||isempty('KL')
   KL=0;
end
if ~exist('max_thresh','var')||isempty('max_thresh')
    max_thresh=0;
end
%% select data and map it to the RAM
nam = filename;

cnmfe_choose_data;

%% create Source2D class object for storing results and parameters
Fs = 15;             % frame rate
        % spatial downsampling factor
         % temporal downsampling factor
gSig = 3;           % width of the gaussian kernel, which can approximates the average neuron shape
gSiz = 13;          % maximum diameter of neurons in the image plane. larger values are preferred.
neuron_full = Sources2D('d1',d1,'d2',d2, ... % dimensions of datasets
    'ssub', ssub, 'tsub', tsub, ...  % downsampleing
    'gSig', gSig,...    % sigma of the 2D gaussian that approximates cell bodies
    'gSiz', gSiz);      % average neuron size (diameter)
neuron_full.Fs = Fs;         % frame rate

% with dendrites or not 
with_dendrites = false;
if with_dendrites
    % determine the search locations by dilating the current neuron shapes
    neuron_full.options.search_method = 'dilate'; 
    neuron_full.options.bSiz = 20;
else
    % determine the search locations by selecting a round area
    neuron_full.options.search_method = 'ellipse';
    neuron_full.options.dist = 3;
end
neuron.KL=KL;
neuron_full.KL=KL;
merge_thr = [0.15, 0.7, -1];     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation]
dmin = 1;
%% options for running deconvolution 
neuron_full.options.deconv_flag = true; 
neuron_full.options.deconv_options = struct('type', 'ar1', ... % model of the calcium traces. {'ar1', 'ar2'}
    'method', 'foopsi', ... % method for running deconvolution {'foopsi', 'constrained', 'thresholded'}
    'smin', -5, ...         % minimum spike size. When the value is negative, the actual threshold is abs(smin)*noise level
    'optimize_pars', true, ...  % optimize AR coefficients
    'optimize_b', true, ...% optimize the baseline);
    'max_tau', 100);    % maximum decay time (unit: frame);

%% downsample data for fast and better initialization
if ~isempty(indices)
    sframe=indices(1);						% user input: first frame to read (optional, default:1)
    num2read= indices(2)-indices(1);             % user input: how many frames to read   (optional, default: until the end)

else
    sframe=1;
    num2read=Ysiz(3);
end
tic;
cnmfe_load_data;
fprintf('Time cost in downsapling data:     %.2f seconds\n', toc);



Y = neuron.reshape(Y, 1);       % convert a 3D video into a 2D matrix

%% compute correlation image and peak-to-noise ratio image.
%cnmfe_show_corr_pnr;    % this step is not necessary, but it can give you some...
                        % hints on parameter selection, e.g., min_corr & min_pnr

%% initialization of A, C
% parameters
debug_on = false;   % visualize the initialization procedue. 
save_avi = false;   %save the initialization procedure as an avi movie. 
patch_par = [1,1]*1; %1;  % divide the optical field into m X n patches and do initialization patch by patch. It can be used when the data is too large 
K = 200; % maximum number of neurons to search within each patch. you can use [] to search the number automatically

min_corr = 0.8;     % minimum local correlation for a seeding pixel
if ~exist('min_pnr','var')||isempty('min_pnr')
    min_pnr = 8;       % minimum peak-to-noise ratio for a seeding pixel
end
min_pixel = gSig^2;      % minimum number of nonzero pixels for each neuron
bd = 1;             % number of rows/columns to be ignored in the boundary (mainly for motion corrected data)
neuron.updateParams('min_corr', min_corr, 'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, 'bd', bd);
neuron_full.updateParams('min_corr', min_corr, 'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, 'bd', bd);
neuron.options.nk = 5;  % number of knots for detrending 

% greedy method for initialization
tic;
if exist('neuron_centers','var')

    [center, Cn, pnr] = neuron.initComponents_endoscope(Y, K, patch_par, debug_on, save_avi,neuron_centers);
else
    [center,Cn,pnr]=neuron.initComponents_endoscope(Y, K, patch_par, debug_on, save_avi);
end
fprintf('Time cost in initializing neurons:     %.2f seconds\n', toc);

% show results
figure;
imagesc(Cn, [0.1, 0.95]);
hold on; plot(center(:, 2), center(:, 1), 'or');
colormap; axis off tight equal;

% sort neurons
neuron.orderROIs('snr');
neuron_init = neuron.copy();

%% iteratively update A, C and B
% parameters, merge neurons
display_merge = false;          % visually check the merged neurons
view_neurons = false;           % view all neurons

% parameters, estimate the background
spatial_ds_factor = ssub;    % spatial downsampling factor. it's for faster estimation
thresh = 10;     % threshold for detecting frames with large cellular activity. (mean of neighbors' activity  + thresh*sn)

bg_neuron_ratio = 1.5;  % spatial range / diameter of neurons

% parameters, estimate the spatial components
update_spatial_method = 'hals';  % the method for updating spatial components {'hals', 'hals_thresh', 'nnls', 'lars'}
Nspatial = 5;       % this variable has different meanings: 
                    %1) udpate_spatial_method=='hals' or 'hals_thresh',
                    %then Nspatial is the maximum iteration 
                    %2) update_spatial_method== 'nnls', it is the maximum
                    %number of neurons overlapping at one pixel 
               
% parameters for running iteratiosn 
nC = size(neuron.C, 1);    % number of neurons 

maxIter = 2;        % maximum number of iterations 
miter = 1; 


    %% merge neurons
    cnmfe_quick_merge;              % run neuron merges
    cnmfe_merge_neighbors;          % merge neurons if two neurons' peak pixels are too close 
    
    %% udpate background 
    % estimate the background
    tic;
    
    % neuron.playMovie(Ysignal); % play the video data after subtracting the background components.
    
    %% update spatial & temporal components
    tic;
    for m=1:2
        cnmfe_update_BG;
        fprintf('Time cost in estimating the background:        %.2f seconds\n', toc);
       
       
        %temporal
        neuron.updateTemporal_endoscope(Ysignal);
        cnmfe_quick_merge;              % run neuron merges
        %spatial
        neuron.updateSpatial_endoscope(Ysignal, Nspatial, update_spatial_method);
        
        % post process the spatial components (you can run either of these two operations, or both of them)
        neuron.trimSpatial(0.01, 3); % for each neuron, apply imopen first and then remove pixels that are not connected with the center
        neuron.compactSpatial();    % run this line if neuron shapes are circular 
        cnmfe_merge_neighbors; 
%         neuron=eliminate_nonexistent(neuron);
        % stop the iteration when neuron numbers are unchanged. 
        if isempty(merged_ROI)
            break;
        end
        
    end
    if KL>0
            [~,KL_score]=Eliminate_Misshapen(neuron,KL,[ceil(d1/ssub),ceil(d2/ssub)],[],false);
         
    end
    neuron=eliminate_nonexistent(neuron); 
    neuron=thresholdNeuron(neuron,.45);
    
 template=imresize(max(reshape(full(neuron.A),240/2,376/2,[]),[],3),[240,376]);