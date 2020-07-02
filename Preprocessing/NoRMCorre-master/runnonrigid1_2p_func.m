% demo file for applying the NoRMCorre motion correction algorithm on 
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org

function Mr=runnonrigid1_2p_func(V)
gcp;
Yf = single(V);

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
    gSig = 4; %%original 7
    gSiz = 12; %%original 17
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
options_nonrigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),'grid_size',[64,64],'mot_uf',4,'bin_width',100,'max_shift',30,'max_dev',3,'us_fac',50,'init_batch',200,'correct_bidir',0);

%% register using the high pass filtered data and apply shifts to original data
tic; [M1,shifts1] = normcorre_batch(Y,options_nonrigid); toc % register filtered data
% exclude boundaries due to high pass filtering effects
tic; Mr = apply_shifts(Yf,shifts1,options_nonrigid,bound/2,bound/2); toc % apply shifts to full dataset
Mr=double(Mr);

% apply shifts on the whole movie
