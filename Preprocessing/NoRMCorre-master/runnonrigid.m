% demo file for applying the NoRMCorre motion correction algorithm on 
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org

function Mr=runnonrigid(V)
delete(gcp('nocreate'))
parpool(4)
%% read data and convert to double
% [filename, filepath] = uigetfile('Select Template','.tif');
% templatename= [filepath,filename];
% template_test=imread(templatename);
% [filename, filepath] = uigetfile('Select Video','.tif');
% name = [filepath,filename];
% %addpath(genpath('../../NoRMCorre'));
% Yf = read_file(name);

Yf = single(V);
[d1,d2,T] = size(Yf);

%% perform some sort of deblurring/high pass filtering

if (0)    
    hLarge = fspecial('average', 12);
    hSmall = fspecial('average', 4); 
    for t = 1:T
        Y(:,:,t) = filter2(hSmall,Yf(:,:,t)) - filter2(hLarge, Yf(:,:,t));
    end
    %Ypc = Yf - Y;
    bound = size(hLarge,1);
else
    gSig = 7; %%original 7
    gSiz = 40; %%original 17
    psf = fspecial('gaussian', round(gSiz), gSig);
    ind_nonzero = (psf(:)>=max(psf(:,1)));
    psf = psf-mean(psf(ind_nonzero));
    psf(~ind_nonzero) = 0;   % only use pixels within the center disk
    %Y = imfilter(Yf,psf,'same');
    %bound = 2*ceil(gSiz/2);
    Y = imfilter(Yf,psf,'symmetric');
    bound = 0;
end
%% first try out rigid motion correction
    % exclude boundaries due to high pass filtering effects
options_nonrigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'grid_size',[32,32],'mot_uf',4,'bin_width',50,'max_shift',50,'max_dev',3,'us_fac',50,'init_batch',200);

%% register using the high pass filtered data and apply shifts to original data
tic; [M1,shifts1,template1] = normcorre_batch(Y,options_nonrigid); toc
    % exclude boundaries due to high pass filtering effects
tic; Mr = apply_shifts(Yf,shifts1,options_nonrigid,bound/2,bound/2); toc % apply shifts to full dataset
    % apply shifts on the whole movie
%% save video as .avi file
% n = size(Yf);
% framenumber = n(3);
% [savename,savepath]=uiputfile('*.avi','Save video as');
% sav=[savepath,savename];
% aviobj = VideoWriter(sav,'Grayscale AVI');
% aviobj.FrameRate=20;
% 
% open(aviobj);
% for i=1:T
%     frame=uint8(Mr(:,:,i));
%     writeVideo(aviobj,frame);
% end
% close(aviobj);
