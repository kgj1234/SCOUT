function updateSpatial_endoscope(obj, Y, num, method)
%% udpate spatial components

%% inputs:
%   Y: d X T matrix, data
%   num: scalar. If method=='hals', then num is the number of iterations to
%       update A; If method=='nnls', then num is the maximum number of neurons
%       overlapping at one pixel
%   method: method for updating the spatial components {'hals', 'nnls'}.
%       default: 'nnls'

%% Author: Pengcheng Zhou, Carnegie Mellon University.

%% input parameters number of iterations
if ~exist('method', 'var')||isempty(method)
    method = 'nnls';
end
if ~exist('num', 'var')||isempty(num)
    if strcmpi(method, 'nnls')
        num=5;
    else
        num = 10;
    end
end


for i=1:size(Y,2)
    nan_ind=[find(isnan(Y(:,i)));find(isinf(Y(:,i)))];
    if length(nan_ind)>0
    
    val_ind=setdiff(1:size(Y,1),nan_ind);
    Y(nan_ind,i)=interp1(val_ind,Y(val_ind,i),nan_ind);
    Y(isnan(Y(:,i)),i)=0;
    Y(isinf(Y(:,i)),i)=0;
    end
end
for i=1:size(obj.C,1)
    nan_ind=[find(isnan(obj.C(i,:))),find(isinf(obj.C(i,:)))];
    if length(nan_ind)>0
    try
    val_ind=setdiff(1:size(obj.C,2),nan_ind);
	val_ind
	nan_ind
	obj.C(i,:)
	size(obj.C)
    obj.C(i,nan_ind)=interp1(val_ind,obj.C(i,val_ind),nan_ind);
    end
    obj.C(i,isnan(obj.C(i,:)))=0;
    obj.C(i,isinf(obj.C(i,:)))=0;
    end
end


if sum(isnan(Y(:)))>0||sum(isinf(Y(:)))>0
        disp('bad values Y')
end
if sum(isnan(obj.A(:)))>0||sum(isinf(obj.A(:)))>0
        disp('bad values A')
end
if sum(isnan(obj.C(:)))>0||sum(isinf(obj.C(:)))>0
	disp('bad values C')
end



%% determine the search locations
search_method = obj.options.search_method;
params = obj.options;
if strcmpi(search_method, 'dilate')
    obj.options.se = [];
end
IND = logical(determine_search_location(obj.A, search_method, params));

%% estimate the noise
if and(strcmpi(method, 'hals_thresh') || strcmpi(method, 'nnls_thresh'), isempty(obj.P.sn))
    %% estimate the noise for all pixels
    b0 =zeros(size(obj.A,1), 1);
    sn = b0;
    parfor m=1:size(obj.A,1)
        [b0(m), sn(m)] = estimate_baseline_noise(Y(m, :));
    end
    if sum(isnan(b0))>0 || sum(isinf(b0))>0
	disp('bad b0')
    end
    Y = bsxfun(@minus, Y, b0);
    obj.P.sn = sn; 
end

%% update spatial components
if strcmpi(method, 'hals')
    obj.A = HALS_spatial(Y, obj.A, obj.C, IND, num);
elseif strcmpi(method, 'hals_thresh')
    obj.A = HALS_spatial_threshold(Y, obj.A, obj.C, IND, num, obj.P.sn); 
elseif strcmpi(method, 'lars')
     if ~isfield(obj.P, 'mis_entries')
         obj.P.mis_entries = sparse(isnan(Y)); 
     end 
     [obj.A, obj.C] = update_spatial_components_nb(Y,obj.C,obj.A, obj.P, obj.options); 
elseif strcmpi(method, 'nnls_thresh')&&(~isempty(IND_thresh)) 
    obj.A = nnls_spatial_thresh(Y, obj.A, obj.C, IND, num, obj.P.sn); 
else
    obj.A = nnls_spatial(Y, obj.A, obj.C, IND, num);
end

%% thresholding the minimum number of neurons
obj.delete(sum(obj.A>0, 1)<=obj.options.min_pixel);

end
