function  [merged_ROIs, newIDs] = quickMerge(obj, merge_thr,gSiz,correlation_method)


%% merge neurons based on simple spatial and temporal correlation
% input:
%   merge_thr: 1X3 vector, threshold for three metrics {'C', 'S', 'A'}, it merge neurons based
%   on correlations of spatial shapes ('A'),  calcium traces ('C') and  spike counts ('S').
%   gSiz: maximal neuron footprint diameter
%   correlation_method: 'spike_train','normalized_fluorescence','pearson'
% output:
%   merged_ROIs: cell arrarys, each element contains indices of merged
%   components
%   newIDs: vector, each element is the new index of the merged neurons

%% Author: Pengcheng Zhou, Carnegie Mellon University, Kevin Johnston, University of California, Irvine.
%  The basic idea is proposed by Eftychios A. Pnevmatikakis: high temporal
%  correlation + spatial overlap
%  reference: Pnevmatikakis et.al.(2016). Simultaneous Denoising, Deconvolution, and Demixing of Calcium Imaging Data. Neuron

%% variables & parameters


if ~exist('correlation_method','var')||isempty(correlation_method)
    correlation_method='spike_train';
end
if ~exist('gSiz','var')||isempty(gSiz);
    gSiz=32;
end
if ~exist('dist_method','var')||isempty(dist_method)
    dist_method='overlap';
end
A = obj.A;          % spatial components
if isempty(obj.C_raw)
    obj.C_raw = obj.C;
end
C_raw = obj.C_raw;
C = obj.C;

if ~exist('merge_thr', 'var') || isempty(merge_thr) || numel(merge_thr)~=3
    merge_thr = [.6, 0.7, -1];
end
A_thr = merge_thr(1);
C_thr = merge_thr(2);
S_thr = merge_thr(3);
[K, ~] = size(C);   % number of neurons
deconv_options_0 = obj.options.deconv_options;

%% find neuron pairs to merge
% compute spatial correlation
% temp = bsxfun(@times, A, 1./sum(A.^2,1));
obj.updateCentroid();
if isequal(dist_method,'overlap')
    temp = bsxfun(@times, A>0, 1./sqrt(sum(A>0)));
    A_overlap = temp'*temp;
else
    
    distance=compute_pairwise_distance(neuron,neuron,d1,d2,'centroid_dist');
end
% compute temporal correlation
if ~exist('X', 'var')|| isempty(X)
    X = 'C';
end

S = obj.S;
if isempty(S) || (size(S, 1)~=size(obj.C, 1))
    try
        S = diff(obj.C_raw, 1, 2);
    catch
        S = diff(obj.C, 1, 2);
    end
    S(:, end+1) = 0;
    
       S(bsxfun(@lt, S, 2*get_noise_fft(S))) = 0;
end
S_corr = corr(S') - eye(size(S,1));


if isequal(correlation_method,'spike_train')
    try
        C_corr=spike_train_correlation(obj,obj,[.5,.5],gSiz);
        temp=corr(obj.C',obj.C');
        C_corr=max(C_corr,temp);
    catch
        C_corr=corr(obj.C',obj.C');
    end
elseif isequal(correlation_method,'normalized_fluorescence')
    try
        C_corr=CNMFE_correlations(obj,ob,[.05],gSiz);
    catch
        C_corr=corr(obj.C',obj.C');
    
    end
else
   C_corr=corr(obj.C',obj.C');
end
%

C_corr=C_corr-eye(size(C_corr));
A_overlap=A_overlap-eye(size(A_overlap));
%% using merging criterion to detect paired neurons
if isequal(dist_method,'overlap')
    
    flag_merge = (A_overlap>A_thr)&(C_corr>C_thr)&(S_corr>=S_thr);
else
    flag_merge = (distance<A_thr)&(C_corr>C_thr)&(S_corr>=S_thr);
end
if length(merge_thr)>3
    max_decay_diff = merge_thr(4); 
     taud = zeros(K, 1);
     for m=1:K
         temp = ar2exp(obj.P.kernel_pars(m));
         taud(m) = temp(1);
     end
     decay_diff = abs(bsxfun(@minus, taud, taud'));
     flag_merge = flag_merge & (decay_diff<max_decay_diff); 
end
for i=1:size(flag_merge,1);
    if sum(flag_merge(i,:))>1
        
        
        while true
            ind=[i,find(flag_merge(i,:)>0)];
            if length(ind)==1
                break
            end
            correlation=C_corr(ind,ind);
            [a,b]=argmax_2d(correlation);
            if norm(obj.centroid(ind(a),:)-obj.centroid(ind(b),:))<gSiz
                ind=setdiff(ind,[ind(a),ind(b)]);
                flag_merge(i,ind)=0;
                flag_merge(ind,i)=0;
                break
            else
                flag_merge(ind(a),ind(b))=0;
                flag_merge(ind(b),ind(a))=0;
            end
        end 
    end
end
[l,c] = graph_connected_comp(sparse(flag_merge));     % extract connected components

MC = bsxfun(@eq, reshape(l, [],1), 1:c);
MC(:, sum(MC,1)==1) = [];
if isempty(MC)
    fprintf('All pairs of neurons are below the merging criterion!\n\n');
    merged_ROIs = [];
    newIDs = [];
    return;
else
   % MC=maximal_connected_components(obj,MC,1.5*gSiz,C_corr,merge_thr);
    
    fprintf('%d neurons will be merged into %d new neurons\n\n', sum(MC(:)), size(MC,2));
end

% %% start merging
[nr, n2merge] = size(MC);
ind_del = false(nr, 1 );    % indicator of deleting corresponding neurons
merged_ROIs = cell(n2merge,1);
newIDs = zeros(nr, 1);
for m=1:n2merge
    IDs = find(MC(:, m));   % IDs of neurons within this cluster
    merged_ROIs{m} = IDs;
    if norm(obj.centroid(IDs(1),:)-obj.centroid(IDs(2),:))>gSiz
        continue;
    end
    
    
       % determine searching area
    active_pixel = (sum(A(:,IDs), 2)>0);
    
    % update spatial/temporal components of the merged neuron
    try
    data = A(active_pixel, IDs)*C_raw(IDs, :);
    ci = C_raw(IDs(1), :);
    catch
        data = A(active_pixel, IDs)*obj.C(IDs, :); 
        ci=obj.C(IDs(1),:);
    end
    for miter=1:10
        ai = data*ci'/(ci*ci');
        ci = ai'*data/(ai'*ai);
    end
    % normalize ci
    sn = get_noise_fft(ci);
    obj.A(active_pixel, IDs(1)) = ai*sn;
    try
    obj.C_raw(IDs(1), :) = ci/sn;
    end
    %     [obj.C(IDs(1), :), obj.S(IDs(1), :), tmp_kernel] = deconvCa(ci, obj.kernel, 3, true, false);
    try
        [obj.C(IDs(1), :), obj.S(IDs(1),:), deconv_options] = deconvolveCa(ci, deconv_options_0);
        try
        obj.P.kernel_pars(IDs(1), :) = deconv_options.pars;
        end
        newIDs(IDs(1)) = IDs(1);
        % remove merged elements
        ind_del(IDs(2:end)) = true;
    catch
        ind_del(IDs) = true;
    end
    try
        obj.probabilities(IDs(1))=max(obj.probabilities(IDs));
    end
end
newIDs(ind_del) = [];
newIDs = find(newIDs);

% remove merged neurons and update obj
obj.delete(ind_del);
% obj.A(:, ind_del) = [];
% obj.C_raw(ind_del, :) = [];
% obj.C(ind_del, :) = [];
% obj.S(ind_del, :) = [];
% obj.P.kernel_pars(ind_del, :) = [];
