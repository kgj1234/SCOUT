function Y=runrigid3(Yfilter,Y,conv_uint8,save_file)
% demo file for applying the NoRMCorre motion correction algorithm on 
% 1-photon widefield imaging data
% Example files can be obtained through the miniscope project page
% www.miniscope.org

%file (3 dimensional matrix variable or filename of .mat recording)
%conv_uint8 (bool) convert final result to uint8 (make sure pixel values
    %are in the correct range)
%save_file (bool) save resulting files

if ~exist('save','var')||isempty(save_file)
    save_file=true;
end
if ~exist('conv_uint8','var')||isempty(conv_uint8);
    conv_uint8=true;
end
gcp;

%addpath(genpath('../../NoRMCorre'));
% [path,name,ext]=fileparts(file);
% if ischar(file)&isequal(ext,'.mat')
%     Yf = struct2cell(load(file));
%     Yf = single(Yf{1});
% elseif ischar(file)&isequal(ext,'.avi')
%     v=VideoReader(file);
%     Yf=read(v);
%     Yf=single(Yf);
% elseif ischar(file)&(isequal(ext,'.tif')||isequal(ext,'.tiff'))
%     Yf=loadtiff(file);
% else
%     Yf=single(file);
% end
% 
% Y=Yf;

T = size(Y,ndims(Y));
d1=size(Y,1);
d2=size(Y,2);

bound=0;
%% first try out rigid motion correction
    % exclude boundaries due to high pass filtering effects
options_r = NoRMCorreSetParms('d1',d1-bound,'d2',d2-bound,'bin_width',40,'max_shift',8,'iter',2,'correct_bidir',false);
options_r.upd_template=true;
options_r.init_batch=50;
%% register using the high pass filtered data and apply shifts to original data
tic;
%template=max(Y(bound/2+1:end-bound/2,bound/2+1:end-bound/2,500:end),[],3);
try
    [M1,shifts1,template1] = normcorre_batch(Yfilter,options_r);  % register filtered data
catch
    [M1,shifts1,template1] = normcorre(Yfilter,options_r);  % register filtered data
end
toc
    % exclude boundaries due to high pass filtering effects
tic; Mr = apply_shifts(Y,shifts1,options_r,bound/2,bound/2); toc % apply shifts to full dataset
    % apply shifts on the whole movie
%% save video as .mat file
if conv_uint8
    Y=uint8(Mr);
else
    Y=Mr;
end

% if save_file
% mkdir motion_corrected
% [path,name,ext]=fileparts(file);
% if ~isempty(path)
% save(fullfile(path,'motion_corrected',[name,'_motion_corrected','.mat']),'Y','Ysiz','-v7.3')
% else
% save(fullfile('.','motion_corrected',[name,'_motion_corrected','.mat']),'Y','Ysiz','-v7.3')
% end
end
