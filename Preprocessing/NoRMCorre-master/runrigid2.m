function Y=runrigid2(file,conv_uint8,save_file)
% demo file for applying the NoRMCorre motion correction algorithm on 
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org

%file (3 dimensional matrix variable or filename of .mat recording)
%conv_uint8 (bool) convert final result to uint8
%save_file (bool) save resulting files

if ~exist('save','var')||isempty(save_file)
    save_file=true;
end
if ~exist('conv_uint8','var')||isempty(conv_uint8);
    conv_uint8=true;
end
gcp;

%addpath(genpath('../../NoRMCorre'));
from_file=true;
if ischar(file)
    [path,name,ext]=fileparts(file);
    if isequal(ext,'.mat')
        Yf = struct2cell(load(file));
        Yf = single(Yf{1});
    elseif isequal(ext,'.avi')
        v=VideoReader(file);
        Yf=read(v);
        Yf=single(Yf);
    elseif (isequal(ext,'.tif')||isequal(ext,'.tiff'))
        Yf=loadtiff(file);
    end
else
    Yf=single(file);
    from_file=false;
end

if length(size(Yf))==4
    Yf=squeeze(max(Yf,[],3));
end
[d1,d2,T] = size(Yf);

%% perform some sort of deblurring/high pass filtering

% if (0)    
%     hLarge = fspecial('average', 40);
%     hSmall = fspecial('average', 2); 
%     for t = 1:T
%         Y(:,:,t) = filter2(hSmall,Yf(:,:,t)) - filter2(hLarge, Yf(:,:,t));
%     end
%     %Ypc = Yf - Y;
%     bound = size(hLarge,1);
% else
%     gSig = 3; %%original 7
%     gSiz = 7; %%original 17
%     psf = fspecial('gaussian', round(gSiz), gSig);
%     ind_nonzero = (psf(:)>=max(psf(:,1)));
%     psf = psf-mean(psf(ind_nonzero));
%     psf(~ind_nonzero) = 0;   % only use pixels within the center disk
%     %Y = imfilter(Yf,psf,'same');
%     %bound = 2*ceil(gSiz/2);
%     Y = imfilter(Yf,psf,'symmetric');
%     bound = 50;
% end
bound=0;
Y=Yf;
%% first try out rigid motion correction
    % exclude boundaries due to high pass filtering effects
options_r = NoRMCorreSetParms('d1',d1-bound,'d2',d2-bound,'bin_width',40,'max_shift',8,'iter',2,'correct_bidir',false);
options_r.upd_template=true;
options_r.init_batch=50;
%% register using the high pass filtered data and apply shifts to original data
tic;
%template=max(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,500:end),[],3);
try
    [M1,shifts1,template1] = normcorre_batch(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,:),options_r);  % register filtered data
catch
    [M1,shifts1,template1] = normcorre(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,:),options_r);  % register filtered data
end
toc
    % exclude boundaries due to high pass filtering effects
tic; Mr = apply_shifts(Yf,shifts1,options_r,bound/2,bound/2); toc % apply shifts to full dataset
    % apply shifts on the whole movie
%% save video as .mat file
if conv_uint8
    Y=uint8(Mr);
else
    Y=Mr;
end
Ysiz=size(Y);
if save_file & from_file
mkdir motion_corrected
[path,name,ext]=fileparts(file);
if ~isempty(path)
save(fullfile(path,'motion_corrected',[name,'_motion_corrected','.mat']),'Y','Ysiz','-v7.3')
else
save(fullfile('.','motion_corrected',[name,'_motion_corrected','.mat']),'Y','Ysiz','-v7.3')
end
end
