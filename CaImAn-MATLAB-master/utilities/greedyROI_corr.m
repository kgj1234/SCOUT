function [Ain, Cin,  bin, fin, center, res] = greedyROI_corr(Y, K, options, sn, debug_on, save_avi)
%% a greedy method for detecting ROIs and initializing CNMF. in each iteration,
% it searches the one with large (peak-median)/noise level and large local
% correlation
%% Input:
%   Y:  d X T matrx, imaging data
%   K:  scalar, maximum number of neurons to be detected.
%   options: struct data of paramters/options
%       d1:     number of rows
%       d2:     number of columns
%       gSiz:   maximum size of a neuron
%       nb:     number of background
%       min_corr: minimum threshold of correlation for segementing neurons
%   sn:     d X 1 vector, noise level of each pixel
%   debug_on: options for showing procedure of detecting neurons
%% Output:
%       Ain:  d X K' matrix, estimated spatial component
%       Cin:  K'X T matrix, estimated temporal component
%       bin:  d X nb matrix/vector, spatial components of the background
%       Cin:  nb X T matrix/vector, temporal components of the background
%       center: K' X 2, coordinate of each neuron's center
%       res:  d X T, residual after initializing Ain, Cin, bin, fin

%% Author: Pengcheng Zhou, Carnegie Mellon University.
% the method is an modification of greedyROI method used in Neuron paper of Eftychios
% Pnevmatikakis et.al. https://github.com/epnev/ca_source_extraction/blob/master/utilities/greedyROI2d.m
%% In each iteration of initializing neurons, it searchs the one with maximum
% value of (max-median)/noise * Cn, which selects pixels with high SNR and
% local correlation.

%% parameters
if exist('sn', 'var')
    Y_std = sn;
else
    Y_std = std(Y, 0, ndims(Y));
end
Y_std = Y_std(:);
if ~exist('debug_on', 'var'); debug_on = false; end

[d1,d2, ~] = size(Y);
gSig = options.gSig;
gSiz = options.gSiz;
if and(isempty(gSiz), isempty(gSig)); gSig = 3; gSiz = 10; end
if isempty(gSiz); gSiz=3*gSig; end 
if isempty(gSig); gSig=gSiz/3; end
min_corr = options.min_corr;    % minimum local correaltion value to start one neuron
nb = options.nb;        % number of the background
pSiz = round(gSig/2);       % after selecting one pixel, take the mean of square box
%near the pixel as temporal activity. the box size is (2*pSiz+1)
psf = ones(gSig)/(gSig^2);

min_snr = options.min_SNR;        % minimum value of (peak-median)/sig 
maxIter = 5;            % iterations for refining results
sz = 4;            %distance of neighbouring pixels for computing local correlation
if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end;
[~, T] = size(Y);       % number of frames
Ain = zeros(d1*d2, K);  % spatial components
Cin = zeros(K, T);      % temporal components
center = zeros(K, 2);   % center of the initialized components

if ~isfield(options,'rem_prct') || isempty(options.rem_prct); options.rem_prct = 20; end

%% compute correlation image and (max-median)/std ratio
ind_frame = round(linspace(1, T, min(T, 8000)));    % select few frames for speed issues
%tmp_noise = randn(d1*d2, length(ind_frame)); 
%% Taken from CNMF-E
%preprocessing data
% create a spatial filter for removing background
options.center_psf=true;
if gSig>0
    
    if options.center_psf
        psf = fspecial('gaussian', ceil(gSig*4+1), ceil(gSig));
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
    else
        psf = fspecial('gaussian', round(gSiz), gSig/4);
    end
else
    psf = [];
end

% filter the data
if isempty(psf)
    % no filtering
    HY = Y;
else
    HY = imfilter(reshape(Y, d1,d2,[]), psf, 'replicate');
end

HY = reshape(HY, d1*d2, []);
% HY_med = median(HY, 2);
% HY_max = max(HY, [], 2)-HY_med;    % maximum projection
HY = bsxfun(@minus, HY, median(HY, 2));
HY_max = max(HY, [], 2);
Ysig = GetSn(HY);
PNR = reshape(HY_max./Ysig, d1, d2);
PNR0 = PNR;

PNR(PNR<options.min_pnr) = 0;

% estimate noise level and thrshold diff(HY)
% dHY = diff(HY(:, 1:nf:end), 1, 2);  %
% Ysig = std(dHY(:, 1:5:end), 0, 2);
% dHY(bsxfun(@lt, dHY, Ysig*sig)) =0;    % all negative and noisy spikes are removed
HY_thr = HY;
HY_thr(bsxfun(@lt, HY_thr, Ysig*3)) = 0;

% compute loal correlation
if options.add_noise
    Cn=correlation_image(HY_thr,[1,2],d1,d2,[],[],true);
else
    Cn = correlation_image(HY_thr, [1,2], d1,d2,[],[],false);
end



C1 = Cn;
Cb =  zeros(size(C1)); %correlation_image(full(Y(:, ind_frame(1:3:end)))+tmp_noise(:, 1:3:end), [gSiz, gSiz+1], d1, d2);  %backgroung correlatin 
Cn = C1-Cb; %here Cb is the background correlation. for 2photon imaging results. It might be useful when the background signal is large 
Y_median = prctile(Y(:, ind_frame),options.rem_prct,2);
Y = bsxfun(@minus, Y, Y_median);
% Y_std = sqrt(mean(Y.*Y, 2));

%% find local maximum
k = 0;      %number of found components
min_pixel = gSig^2/2;  % minimum number of pixels to be a neuron
%Y_std(Y_std<1)=0;
%peak_ratio = full(max(Y, [], 2))./Y_std; %(max-median)/std
peak_ratio=Y_std;
peak_ratio(isinf(peak_ratio)) = 0;  % avoid constant values
save_avi = false;   %save procedures for demo
if debug_on
    figure('position', [100, 100, 800, 650]); %#ok<*UNRCH>
    subplot(331);
    imagesc(Cn, [0,1]); colorbar;
    axis equal off tight; hold on;
    title('correlation image');
    if save_avi
        avi_file = VideoWriter('greedyROI_example.avi', 'FPS', 10);
        avi_file.open();
    end
end

max_thresh = min_snr * (min_corr);
activity_field=peak_ratio.*(Cn(:)).*(Cn(:)>min_corr).*(peak_ratio>min_snr);
JS_temp=[];
max_dist_temp=[];
keep_ind=[];
while k<K&max(max(activity_field))>max_thresh
    %% find the pixel with the maximum ratio
    connected_comp=bwconncomp(reshape(activity_field,d1,d2));
    component_size=cellfun(@length,connected_comp.PixelIdxList);
    drop_components=find(component_size<min_pixel);
    for i=1:length(drop_components)
        peak_ratio(connected_comp.PixelIdxList{drop_components(i)})=0;
    end
    activity_field=peak_ratio.*(Cn(:)).*(Cn(:)>min_corr).*(peak_ratio>min_snr);
    activity_field=imgaussfilt(activity_field,1.5);
    
    [max_v, ind_p] = max(activity_field);
        
    [r, c] = ind2sub([d1,d2], ind_p);
    
    % select its neighbours for computing correlation
    rsub = max(1, -gSiz+r):min(d1, gSiz+r);
    csub = max(1, -gSiz+c):min(d2, gSiz+c);
    [cind, rind] = meshgrid(csub, rsub);
    nr = length(rsub);  %size of the neighboring matrix
    nc = length(csub);
    ind_nhood = sub2ind([d1, d2], rind(:), cind(:));
    Y_box = HY(ind_nhood, :);
    
    % draw a small area near the peak and extract the mean activities
    r0 = rsub(1); c0 = csub(1);
    rsub = (max(1, -pSiz+r):min(d1, pSiz+r)) - r0+1;
    csub = (max(1, -pSiz+c):min(d2, pSiz+c)) -c0+1;
    [cind, rind] = meshgrid(csub, rsub);
    ind_peak = sub2ind([nr, nc], rind(:), cind(:));
    y0 = mean(Y_box(ind_peak, :), 1);
    y0(y0<0) = 0;
    
    % compute the correlation between the peak and its neighbours
    temp = reshape(corr(y0', Y_box'), nr, nc);
    temp_act=reshape(activity_field(ind_nhood),nr,nc);
    temp_corr=reshape(Cn(ind_nhood),nr,nc);
    temp_peak=reshape(peak_ratio(ind_nhood),nr,nc);
    components=imregionalmax(temp_act);
    conn=bwconncomp(components);
    conn=conn.PixelIdxList;
    
    
    
    
    pixel_identification=construct_pixel_paths_dp(temp_act,conn,size(temp_act,1)*size(temp_act,2));
    
        
    max_index=sub2ind(size(temp_act),ceil(size(temp_act,1)/2),ceil(size(temp_act,2)/2));
    
    for i=1:length(conn)
        if ~isempty(intersect(max_index,conn{i}))
            conn_index=i;
            break
        end
    end
    clear temp_center
    for i=1:length(conn)
        %This assumes each regional max is only one pixel
        temp_center(i)=conn{i}(1);
    end
    clear comp_center
    [comp_center(:,1),comp_center(:,2)]=ind2sub(size(temp_act),temp_center);
    pixel_identification(temp_act==0)=0;
    temp_pixel=pixel_identification;
    for i=1:max(max(pixel_identification))
        hull=bwconvhull(pixel_identification==i);
        pixel_identification(hull)=i;
    end
    for i=1:max(max(pixel_identification))
        pixel_identification(temp_pixel==i)=i;
    end
    
    for i=1:size(pixel_identification,1)
        for j=1:size(pixel_identification,2)
            if pixel_identification(i,j)==0&temp_act(i,j)>0
                %Not the best method to fill in
                dists=pdist2(comp_center,[i,j]);
                [~,pixel_identification(i,j)]=min(dists);
            end
        end
    end
    
                
    for i=1:length(conn)
        [a,b]=ind2sub(size(temp_act),conn{i});
        if exist('conn_index','var')&norm([a,b]-[ceil(size(temp_act,1)/2),ceil(size(temp_act,2)/2)])<gSig
            pixel_identification(pixel_identification==i)=conn_index;
        end
        %if max(temp_act(conn{i}))<.75*max(max(temp_act))||max(temp_act(conn{i}))<max_thresh||...
        %        max(temp_corr(conn{i}))<min_corr||max(temp_peak(conn{i}))<min_snr&norm([a,b]-[ceil(size(temp_act,1)/2),ceil(size(temp_act,2)/2)])<gSiz
        %    pixel_identification(pixel_identification==i)=conn_index;
        %end
    end
    
    if ~exist('conn_index','var')
        conn_index=1;
    end
    
    active_pixel = full(temp>0)&pixel_identification==conn_index;
    
    l = bwlabel(active_pixel, 8);   % remove disconnected components
    active_pixel(l~=l(max_index)) = false;
   
    
    tmp_v = sum(active_pixel(:));    %number of pixels with above-threshold correlation
    if debug_on
        subplot(332); cla;
        imagesc(reshape(peak_ratio.*Cn(:), d1, d2), [0, max_v]); colorbar;
        title(sprintf('neuron %d', k+1));
        axis equal off tight; hold on;
        plot(c,r, 'om');
        subplot(333);
        imagesc(temp, [min_corr, 1]);
        axis equal off tight;
        title('corr. with neighbours');
        subplot(3,3,4:6); cla;
        plot(y0); title('activity in the center');
        subplot(3,3,7:9); cla;
        if ~save_avi; pause; end
    end
    peak_ratio(ind_p) = 0;  % no longer visit this pixel any more
    stats=regionprops(active_pixel,'MinorAxisLength');
    %% save neuron
    %   nonzero area
    data = Y_box(active_pixel(:), :);
    ind_active = ind_nhood(active_pixel(:));  %indices of active pixels within the whole frame
    %peak_ratio(ind_nhood(ind_peak)) = 0;    % the small area near the peak is not able to initialize neuron anymore
    
    
    
    
    
    % do a rank-1 matrix factorization in this small area
    [ai, ci] = finetune2d(data, y0, maxIter);
    %     data(data<0) = 0;
    %     ai = (data*y0')/(y0*y0');
    %     ci = y0;
    if sum(ai)==0
         peak_ratio(ind_peak)=0;
         if exist('total_fail','var')&total_fail>20
             break
         else
             if exist('total_fail')
                 total_fail=total_fail+1;
             else
                 total_fail=1;
             end
             
            continue
         end
    else
        total_fail=0;
    end
    temp_a=zeros(size(temp_act));
    temp_a(active_pixel)=ai;
   orig_a=temp_a;
    
    temp_a=fill_in_footprint(temp_a,2,10);
    temp_a(temp_a<.1*max(max(temp_a)))=0;
    
%     temp_comp=bwconncomp(temp_a>0);
%     temp_comp_size=cellfun(@length,temp_comp.PixelIdxList);
%     del_ind=find(temp_comp_size<max(temp_comp_size));
%     for i=1:length(del_ind);
%         temp_a(temp_comp.PixelIdxList{del_ind(i)})=0;
%     end
    
    temp_a=temp_a.*(temp_act>0);
    max_ai=max(max(ai));  
    smooth_ai=imgaussfilt(temp_a)*max_ai/max(max(temp_a));
    
    ai=smooth_ai;
    %ai=temp_a;
    temp_stats=regionprops(ai,'MinorAxisLength');
    stats.MinorAxisLength=min(stats.MinorAxisLength,temp_stats.MinorAxisLength);
    temp_center=calculateCentroid(ai,size(temp_act));
%     try
%     [A1_comp,A2_comp]=construct_comparison_footprint_ellipse(ai,temp_center,size(temp_act));
%         %[A1_comp,A2_comp]=construct_comparison_footprint_gaussian(centroid,cov,data_shape);
%      
%   
%  
%      JS1=JSDiv(reshape(ai,1,[]),reshape(A1_comp,1,[]));
%      JS2=JSDiv(reshape(ai,1,[]),reshape(A2_comp,1,[]));
%      
%      JS=min(JS1,JS2);
%     catch
%         JS=2;
%     end
    ai=reshape(ai,[],1);
%   JS_temp(end+1)=JS;
%   max_dist_temp(end+1)=min(sum(abs(ai/sum(ai)-A1_comp(:)/sum(A1_comp(:)))),sum(abs(ai/sum(ai)-A2_comp(:)/sum(A2_comp(:)))));
%   
    
%    
%     close all
% %     imagesc(temp_act)
% %     figure()
% %     imagesc(temp_act.*active_pixel);
% %     figure()
%     imagesc(reshape(ai,size(temp_act)))
%     keep=input('Keep neuron y/n','s');
%     if isequal(keep,'n')
%         keep_ind(end+1)=1;
%     else
%         keep_ind(end+1)=0;
%     end
   
    JS=0;
    
    if max_v>=max_thresh&Cn(ind_p)>=min_corr&max_v/(min_corr)>=min_snr&norm(ai)>0&tmp_v>=min_pixel&stats.MinorAxisLength>(gSig*1.5)&JS<.0525
     
        
    k=k+1;
    Ain(ind_nhood, k) = ai;
    Cin(k, :) = ci;
    
    center(k, :) = [r, c];
   
    if mod(k, 10)==0
        fprintf('%d/%d neurons have been detected\n', k, K);
    end
    
    
   
   
    fprint_center=round(calculateCentroid(ai,size(temp_act)));
    
    rnew=r+(size(temp_act,1)-1)/2-fprint_center(1);
    cnew=c+(size(temp_act,2)-1)/2-fprint_center(2);
    if rnew>0&rnew<d1
        r=rnew;
    end
    if cnew>0&cnew<d2
        c=cnew;
    end
  
    
    
    HY(ind_nhood, :) = HY(ind_nhood,:)-reshape(ai,[],1)*ci;
    end
    
    if debug_on
        subplot(331);
        plot(c, r, '.r');
        subplot(332);
        plot(c,r, 'or');
        subplot(333);
        temp = zeros(nr, nc); temp(active_pixel) = ai;
        imagesc(temp);
        axis equal off tight;
        title('spatial component');
        subplot(3,3,7:9); cla;
        plot(ci); title('temporal component');
        if save_avi; avi_file.writeVideo(getframe(gcf)); else pause; end
    end
    
    
    if k==K;   break; end
    
    %% udpate peak_ratio and correlation image
    r=round(r);
    c=round(c);
    rsub = (max(1, -pSiz+r):min(d1, pSiz+r)) ;
    csub = (max(1, -pSiz+c):min(d2, pSiz+c));
    [cind, rind] = meshgrid(csub, rsub);
    cind=cind(:);
    rind=rind(:);
    del_ind=find(pdist2([r,c],[rind,cind])>pSiz);
    ind_peak = sub2ind([d1, d2], rind, cind);
    ind_peak(del_ind)=[];
   
    %tmp_old = peak_ratio(ind_active);
    %tmp_new = max(Y(ind_active, :), [], 2)./Y_std(ind_active);
    %tmp_new=Y_std(ind_active);
    %temp = zeros(nr, nc);
    %temp(active_pixel) = max(0, tmp_old-tmp_new); % after each iteration, the peak ratio can not be increased
    %peak_ratio(ind_nhood) = max(0, peak_ratio(ind_nhood) - reshape(imfilter(temp, psf), [], 1)); % update peak_ratio, results are smoothed
    peak_ratio(ind_active)=std(HY(ind_active,:),[],2);
    peak_ratio(ind_peak)=0;
    Cn(ind_nhood) = correlation_image(full(HY(ind_nhood, :)), sz, nr, nc,[],[],false)-reshape(Cb(ind_nhood), nr, nc,[]);  % update local correlation

end
for i=1:k
    center(i,:) = calculateCentroid(Ain(:,i),d1,d2);
end
Ain = sparse(Ain(:, 1:k));
Cin = Cin(1:k, :);
Cin(Cin<0) = 0;
if save_avi; avi_file.close(); end
res = bsxfun(@plus, Y, Y_median);

%% clear data matrix from local memory (avoid out-of-memory in nnmf)
clear Y

%% initialize background
tsub = max(1, round(T/1000));
[bin, f] = nnmf(max(res(:, 1:tsub:T), 0), nb);
fin = imresize(f, [nb, T]);
fin = HALS_temporal(max(res, 0), bin, fin, maxIter);
bin = HALS_spatial(max(res, 0), bin, fin, [], maxIter);
end

function [ai, ci] = finetune2d(data, ci, nIter)
%do matrix factorization given the model data = ai*ci, where ai>=0
%
%Input:
%   data:   d x T matrix, small patch containing one neuron
%   ci:     initial value for trace
%   nIter  number of coordinate descent steps
%
%Output:
%   ai  M x N matrix, result of the fine-tuned neuron shape
%   ci  1 x T matrix, result of the neuron
%% copied from greedyROI.m

if ~exist('nIter', 'var'), nIter = 1; end
data(data<0)= 0;
%do block coordinate descent
for iter = 1:nIter,
    %update basis
    ai = max(0, (data*ci')/(ci*ci'));
    norm_ai = norm(ai, 2);
    if norm_ai==0; break;     end
    ai = ai/norm_ai;
    ci =  (ai'*data);
    %     ci(ci<0) = 0;
end
temp = (median(ci)-2*std(ci));
ci(ci<temp) = temp;
end
