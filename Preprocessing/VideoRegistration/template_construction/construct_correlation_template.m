function Cn=construct_correlation_template(filename,indices,KL,min_pnr,KL_constraint,gSiz,data_type)




%% clear workspace

global  d1 d2 numFrame sframe num2read Fs neuron neuron_ds ...
    neuron_full Ybg_weights; %#ok<NUSED> % global variables, don't change them manually



ssub=2;
tsub=2;

if ~exist('KL','var')||isempty('KL')
   KL=0;
end

if ~exist('KL_constraint','var')||isempty(KL_constraint)
    KL_constraint='bound'; %Options 'bound' (KL variable is the actual bound on the maximum KL value) 
                      %prc (KL variable indicates a percentile range.
                      %Anything outside the range is deleted. Typically .95
                      %or .9
end
%% select data and map it to the RAM
nam = filename;
if isnumeric(nam)
    Y=nam;
    neuron=Sources2D;
    neuron_full=Sources2D;
    [d1,d2,T]=size(Y);
    neuron.options.d1=ceil(d1/2);
    neuron.options.d2=ceil(d2/2);
    neuron_full.options.d1=d1;
    neuron_full.options.d2=d2;
    d1s=neuron.options.d1;
    d2s=neuron.options.d2;
else
    cnmfe_choose_data;
end
%% create Source2D class object for storing results and parameters
Fs = 15;             % frame rate
        % spatial downsampling factor
         % temporal downsampling factor
gSig = 3;           % width of the gaussian kernel, which can approximates the average neuron shape
if ~exist('gSiz','var')||isempty(gSiz)
    gSiz = 13;          % maximum diameter of neurons in the image plane. larger values are preferred.
end
gSizMin=2;          % minimum diameter of neurons in the image plane.
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
merge_thr = [0.7, 0.75, -1];     % thresholds for merging neurons; [spatial overlap ratio, temporal correlation of calcium traces, spike correlation]
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
    if ~exist('Y','var')
        sframe=1;
        num2read=Ysiz(3);
    else
        sframe=1;
        num2read=size(Y,3);
    end
end
tic;
if ~exist('Y','var')
    cnmfe_load_data;
else
    Y=imresize(Y,[floor(size(Y,1)/2),floor(size(Y,2)/2)]);
end
fprintf('Time cost in downsapling data:     %.2f seconds\n', toc);



Y = neuron.reshape(Y, 1);       % convert a 3D video into a 2D matrix
Y=single(Y);
%% compute correlation image and peak-to-noise ratio image.
%cnmfe_show_corr_pnr;    % this step is not necessary, but it can give you some...
                        % hints on parameter selection, e.g., min_corr & min_pnr

%% initialization of A, C
% parameters
debug_on = false;   % visualize the initialization procedue. 
save_avi = false;   %save the initialization procedure as an avi movie. 
patch_par = [1,1]*1; %1;  % divide the optical field into m X n patches and do initialization patch by patch. It can be used when the data is too large 
K = 1; % maximum number of neurons to search within each patch. you can use [] to search the number automatically

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
neuron.options.nk = 1;  % number of knots for detrending 

%Add noise to correlation image? (If so, reduce min_corr threshold)
neuron_full.options.add_noise=false;
neuron.options.add_noise=false;
neuron.options.gSiz=gSiz;
neuron.options.gSig=gSig;
if isequal(data_type,'2p')
    
    spatial_constraints=struct('connected',true,'circular',false);
    %Background Options
    bg_model = 'svd';  % model of the background {'ring', 'svd'(default), 'nmf'}
    nb = 1;             % number of background sources for each patch (only be used in SVD and NMF model)
    bg_neuron_factor = 0.5;  
    ring_radius = round(bg_neuron_factor * gSiz);
    neuron.updateParams('min_corr', min_corr, 'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, 'bd', bd,'ring_radius',ring_radius,'spatial_constraints',spatial_constraints,...
    'background_model',bg_model,'ring_radius',ring_radius,'center_psf',false);
    neuron_full.updateParams('min_corr', min_corr, 'min_pnr', min_pnr, ...
    'min_pixel', min_pixel, 'bd', bd,'ring_radius',ring_radius,'spatial_constraints',spatial_constraints,...
    'background_model',bg_model,'ring_radius',ring_radius,'center_psf',false);
    neuron_full.options.add_noise=false;
    neuron.options.add_noise=false;
end




% greedy method for initialization
tic;

Cn=correlation_image(Y,[],d1s,d2s,[],[],true);

if exist('neuron_centers','var')

    [center, Cn, pnr] = neuron.initComponents_endoscope(Y, K, patch_par, debug_on, save_avi,neuron_centers);
else
    [center,Cn,pnr]=neuron.initComponents_endoscope(Y, K, patch_par, debug_on, save_avi);
           
         
end
Cn=imresize(Cn,[d1,d2]);
%Cn=imgaussfilt(Cn);
end