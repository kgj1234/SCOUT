function neuron=demo_script_adapted_052219(Y,numNeurons)
%% load file
gcp;                            % start cluster
% addpath(genpath('utilities'));
% addpath(genpath('deconvolution'));
  
% [filename,pathname] = uigetfile('select neuron file');          % insert path to tiff stack here
% sframe=1;						% user input: first frame to read (optional, default 1)
% num2read=2000;					% user input: how many frames to read   (optional, default until the end)
% Y = read_file(nam,sframe,num2read);
% Y = read_file([pathname,filename],sframe);
Y1=Y;

%Y1 = Y - min(Y(:)); 
if ~isa(Y1,'single');    Y1 = single(Y1);  end         % convert to single

[d1,d2,T] = size(Y1);                                % dimensions of dataset
d = d1*d2;                                          % total number of pixels

%% Set parameters

K = numNeurons;                                           % number of components to be found
tau = 5;                                          % std of gaussian kernel (size of neuron) 
p = 2;

options = CNMFSetParms(...   
    'd1',d1,'d2',d2,...                         % dimensionality of the FOV
    'p',p,...                                   % order of AR dynamics    
    'gSig',tau,...                              % half size of neuron
    'merge_thr',0.80,...                        % merging threshold  
    'nb',2,...                                  % number of background components    
    'min_SNR',2,...                             % minimum SNR threshold
    'space_thresh',0.4,...                      % space correlation threshold
    'cnn_thr',0.2,...                            % threshold for CNN classifier   
    'ssub',2   );                               % spatially resample
    
%% Data pre-processing

[P,Y1] = preprocess_data(Y1,p);
%% fast initialization of spatial components using greedyROI and HALS

[Ain,Cin,bin,fin,center] = initialize_components(Y1,K,tau,options,P);  % initialize

% display centers of found components
Cn =  correlation_image(Y1); %reshape(P.sn,d1,d2);  %max(Y,[],3); %std(Y,[],3); % image statistic (only for display purposes)
figure;imagesc(Cn);
    axis equal; axis tight; hold all;
    scatter(center(:,2),center(:,1),'mo');
    title('Center of ROIs found from initialization algorithm');
    drawnow;


    %% manually refine components (optional)
refine_components = false;  % flag for manual refinement
if refine_components
    [Ain,Cin,center] = manually_refine_components(Y1,Ain,Cin,center,Cn,tau,options);
end
    
%% update spatial components
Yr = reshape(Y1,d,T);
[A,b,Cin] = update_spatial_components(Yr,Cin,fin,[Ain,bin],P,options);

%% update temporal components
P.p = 0;    % set AR temporarily to zero for speed
[C,f,P,S,YrA] = update_temporal_components(Yr,A,b,Cin,fin,P,options);

%% classify components

rval_space = classify_comp_corr(Y1,A,C,b,f,options);
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
ind_exc = (fitness < options.min_fitness);

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
[A2,b2,C2] = update_spatial_components(Yr,Cm,f,[Am,b],Pm,options);
[C2,f2,P2,S2,YrA2] = update_temporal_components(Yr,A2,b2,C2,f,Pm,options);


%% do some plotting

[A_or,C_or,S_or,P_or] = order_ROIs(A2,C2,S2,P2); % order components
K_m = size(C_or,1);
[C_df,~] = extract_DF_F(Yr,A_or,C_or,P_or,options); % extract DF/F values (optional)

figure;
[Coor,json_file] = plot_contours(A_or,Cn,options,1); % contour plot of spatial footprints
% saveas(gcf,'neuron_contour.fig');
% saveas(gcf,'neuron_contour.eps');
% saveas(gcf,'neuron_contour.tif');
%savejson('jmesh',json_file,'filename');        % optional save json file with component coordinates (requires matlab json library)

%% display components

% plot_components_adapted(Yr,A_or,C_or,b2,f2,Cn,options);
% saveas(gcf,'neuron_components.fig');
% saveas(gcf,'neuron_components.eps');
% saveas(gcf,'neuron_components.tif');

%% make movie
% options.name=[filename,'_final_result.avi'];
% if (0)  
%     make_patch_video(A_or,C_or,b2,f2,Yr,Coor,options)
% end

neuron = Sources2D('d1',d1,'d2',d2); % dimensions of datasets

neuron.C = C_or;
neuron.A = A_or;
neuron.S = S_or;
% neuron.imageSize = [size(Y,1),size(Y,2),size(Y,3)];
neuron.trace = neuron.C.*(max(neuron.A)'*ones(1,size(neuron.C,2)));
neuron.Cn = Cn;
neuron.C_df = C_df;
% neuron.Df = Df;
neuron.Coor=Coor;
neuron.P=P_or;

% thresh = 0.1*max(neuron.trace');
% neuronfiringtime=sum(double(neuron.trace'>thresh));

% save([filename,'_final_result.mat'],'neuron','neuronfiringtime');
% save([filename,'_all_variables.mat'],'-v7.3');
close all

