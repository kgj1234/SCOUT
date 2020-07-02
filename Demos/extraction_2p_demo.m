%This is currently not ready for use.

% 2p neuron extraction with SCOUT
%Remove 1p extraction code from matlab path
clear all
clc

file_path = mfilename('fullpath');
if isempty(file_path)
    file_path=pwd;
end
[path,~,~]=fileparts(file_path);
endout=regexp(path,filesep,'split');
for i=1:length(endout)
    if isequal(endout{i},'SCOUT')
        final_index=i;
        break
    end
end

if ~exist('final_index','var')
    error('Unable to find SCOUT on filepath. Ensure function is in SCOUT directory tree')
else
    if ~ispc
        scoutpath=filesep;
    else
        scoutpath='';
    end
    for i=1:final_index
    	scoutpath=fullfile(scoutpath,endout{i});
    end
end
warning('off','all')
rmpath(genpath(fullfile(scoutpath,'CNMF_E')));
warning('on','all')

% extraction_options (struct) with fields 
    %min_snr: (postive float) minimum signal-to-noise ratio for neuron initialization
    %gSiz: (float) maximum neuron width in image plane
    %max_neurons: (int) maximum number of detected neurons
    %min_corr: (float between 0 and 1) sets min correlation threshold for
        %neuron initialization
    %corr_noise: (bool) true: add noise when calculating correlation image.
        %Typically requires a low min_corr parameter, but reduces noise.
%outputs

%neuron (CNMF) extracted neural activity



%%Authors: Pengcheng Zhou, Kevin Johnston


%%

file='vid1.mat';
extraction_options.indices=[];

extraction_options.min_pnr=5;
extraction_options.gSiz=25;
extraction_options.max_neurons=400;
extraction_options.min_corr=.3;
extraction_options.corr_noise=false;



%%
   









%% load file
gcp;                            % start cluster
if ischar(file)
    [path,name,ext]=fileparts(file);
    if isequal(ext,'.mat')
        Y=struct2cell(load(file));
        Y=Y{1};
    elseif isequal(ext,'.avi')
        v=VideoReader(file);
        Y=v.read();
    else
        error('filetype not yet supported')
    end
else
    Y=file;
end



if ~isa(Y,'single');    Y = single(Y);  end         % convert to single

[d1,d2,T] = size(Y);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels
if ~isfield(extraction_options,'indices')||isempty(extraction_options.indices)
    Y=Y;
else
    indices=extraction_options.indices;
    Y=Y(:,:,indices(1):indices(2));
end

%% Set parameters
if ~isfield(extraction_options,'max_neurons')||isempty(extraction_options.max_neurons)
    K = 200;                                          % number of components to be found
else
    K=extraction_options.max_neurons;
end
if ~isfield(extraction_options,'min_pnr')||isempty(extraction_options.min_pnr);
    min_snr=extraction_options.min_pnr;
else
    min_snr=.5;
end

if ~isfield(extraction_options,'gSiz')||isempty(extraction_options.gSiz)
    gSiz = 25; %max neuron size
    tau=round(gSiz/3);
else
    gSiz=extraction_options.gSiz;
    tau=round(gSiz/3);
end
if ~isfield(extraction_options,'min_corr')||isempty(extraction_options.min_corr)
    min_corr=.5;
else
    min_corr=extraction_options.min_corr;
end
if ~isfield(extraction_options,'corr_noise')||isempty(extraction_options.corr_noise)
    corr_noise=false;
    
else
    corr_noise=extraction_options.corr_noise;
end    

p = 2;

options = CNMFSetParms(...   
    'd1',d1,'d2',d2,...                         % dimensionality of the FOV
    'p',p,...                                   % order of AR dynamics    
    'gSig',tau,...                              % half size of neuron
    'gSiz',gSiz,...
    'merge_thr',0.65,...                        % merging threshold  
    'nb',2,...                                  % number of background components    
    'min_SNR',min_snr,...                             % minimum SNR threshold
    'space_thresh',0.5,...                      % space correlation threshold
    'cnn_thr',0.5,...                            % threshold for CNN classifier    
    'min_corr',min_corr,...
    'init_method','greedy_corr',...
    'noise_norm', false...
    );
options.add_noise=corr_noise;
%% Data pre-processing

[P,Y] = preprocess_data(Y,p);
%% fast initialization of spatial components using greedyROI and HALS

[Ain,Cin,bin,fin,center] = initialize_components(Y,K,tau,options,P);  % initialize
neuron=CNMF;
neuron.A=Ain;
neuron.C=Cin;
neuron.options=options;

neuron.compactSpatial();

Ain=neuron.A;
Cin=neuron.C;
neuron.imageSize=[d1,d2];
neuron.updateCentroid();

center=neuron.centroid;

% display centers of found components
Cn =  correlation_image(Y); %reshape(P.sn,d1,d2);  %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
Cn=Cn-mean(mean(mean(Cn)));
Cn(Cn<0)=0;
Cn=Cn/(max(max(Cn))+.000001);
min_corr=-1;
Ain=full(Ain);
for i=1:size(Ain,2);
    a=find(Ain(:,i)>0);
    a=a(find(Ain(a,i)>.75*max(Ain(a,i))));
    avg_corr(i)=mean(Cn(a));
end
Ain=Ain(:,avg_corr>min_corr);
Cin=Cin(avg_corr>min_corr,:);
center=center(avg_corr>min_corr,:);

Ain=sparse(Ain);
figure;imagesc(Cn);
    axis equal; axis tight; hold all;
    scatter(center(:,2),center(:,1),'mo');
    title('Center of ROIs found from initialization algorithm');
    drawnow;
    %% manually refine components (optional)
refine_components = false;  % flag for manual refinement
if refine_components
    [Ain,Cin,center] = manually_refine_components(Y,Ain,Cin,center,Cn,tau,options);
end
if size(Ain,2)==1
    Ain=cat(2,Ain,Ain);
    Cin=cat(1,Cin,Cin);
    center=[center;center];
end



%% update spatial components
Yr = reshape(Y,d,T);
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,[Ain,bin],P,options);

%% update temporal components
P.p = 0;    % set AR temporarily to zero for speed
[C,f,P,S,YrA] = update_temporal_components(Yr,A,b,Cin,fin,P,options);

%% classify components

rval_space = classify_comp_corr(Y,A,C,b,f,options);
ind_corr = rval_space > options.space_thresh;           % components that pass the correlation test
                                        % this test will keep processes
                                        
%% further classification with cnn_classifier
try  % matlab 2017b or later is needed
    [ind_cnn,value] = cnn_classifier(A,[d1,d2],'cnn_model',options.cnn_thr);
catch
    ind_cnn = true(size(A,2),1);                        % components that pass the CNN classifier
end     
                            
%% event exceptionality

fitness = compute_event_exceptionality(C+YrA,options.N_samples_exc,options.robust_std);
options.min_fitness=-30;
ind_exc = (fitness < options.min_fitness);
ind_exc=true(size(A,2),1);   

%% select components

keep = (ind_corr | ind_cnn) & ind_exc;

%% display kept and discarded components
A_keep = A(:,keep);
C_keep = C(keep,:);
figure;
    subplot(121); montage(extract_patch(A(:,keep),[d1,d2],[30,30]),'DisplayRange',[0,0.15]);
        title('Kept Components');
    subplot(122); montage(extract_patch(A(:,~keep),[d1,d2],[30,30]),'DisplayRange',[0,0.15])
        title('Discarded Components');
%% merge found components



[Am,Cm,K_m,merged_ROIs,Pm,Sm] = merge_components(Yr,A_keep,b,C_keep,f,P,S,options);

%%
display_merging = 1; % flag for displaying merging example
if and(display_merging, ~isempty(merged_ROIs))
    i = 1; %randi(length(merged_ROIs));
    ln = length(merged_ROIs{i});
    figure;
        set(gcf,'Position',[300,300,(ln+2)*300,300]);
        for j = 1:ln
            subplot(1,ln+2,j); imagesc(reshape(A_keep(:,merged_ROIs{i}(j)),d1,d2)); 
                title(sprintf('Component %i',j),'fontsize',16,'fontweight','bold'); axis equal; axis tight;
        end
        subplot(1,ln+2,ln+1); imagesc(reshape(Am(:,K_m-length(merged_ROIs)+i),d1,d2));
                title('Merged Component','fontsize',16,'fontweight','bold');axis equal; axis tight; 
        subplot(1,ln+2,ln+2);
            plot(1:T,(diag(max(C_keep(merged_ROIs{i},:),[],2))\C_keep(merged_ROIs{i},:))'); 
            hold all; plot(1:T,Cm(K_m-length(merged_ROIs)+i,:)/max(Cm(K_m-length(merged_ROIs)+i,:)),'--k')
            title('Temporal Components','fontsize',16,'fontweight','bold')
        drawnow;
end

%% refine estimates excluding rejected components

Pm.p = p;    % restore AR value
if size(Am,2)==1
    Am=cat(2,Am,Am);
    Cm=cat(1,Cm,Cm);
    center=[center;center];
end

[A2,b2,C2] = update_spatial_components(Yr,Cm,f,[Am,b],Pm,options);
[C2,f2,P2,S2,YrA2] = update_temporal_components(Yr,A2,b2,C2,f,Pm,options);
neuron=CNMF;
neuron.options.d1=d1;
neuron.options.d2=d2;
neuron.A=A2;
neuron.C=C2;
neuron.S=S2;
%This splits neurons, but tends to overestimate the number of required
%splits.
% neuron=split_neurons(neuron,[d1,d2],ceil(options.gSig),ceil(options.gSig));


neuron.compactSpatial();

A2=neuron.A;
C2=neuron.C;
neuron.imageSize=[d1,d2];
neuron.updateCentroid();

center=neuron.centroid;
S2=neuron.S;
[C2,f2,P2,S2,YrA2] = update_temporal_components(Yr,A2,b2,C2,f,Pm,options);

%% do some plotting

[A_or,C_or,S_or,P_or] = order_ROIs(A2,C2,S2,P2); % order components
K_m = size(C_or,1);
[C_df,~] = extract_DF_F(Yr,A_or,C_or,P_or,options); % extract DF/F values (optional)

figure;
[Coor,json_file] = plot_contours(A_or,Cn,options,1); % contour plot of spatial footprints
%savejson('jmesh',json_file,'filename');        % optional save json file with component coordinates (requires matlab json library)

%% display components

plot_components_GUI(Yr,A_or,C_or,b2,f2,Cn,options);

%% make movie
%if (0)  
%    make_patch_video(A_or,C_or,b2,f2,Yr,Coor,options)
%end
neuron=CNMF;
neuron.A=full(A_or);
neuron.C=C_or;
neuron.S=S_or;
neuron.C_df=C_df;
neuron.imageSize=[d1,d2];
close all


addpath(genpath(scoutpath))
