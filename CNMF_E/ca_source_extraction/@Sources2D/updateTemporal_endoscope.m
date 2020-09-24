function [C_offset] = updateTemporal_endoscope(obj, Y, allow_deletion)

%% run HALS by fixating all spatial components
% input:
%   Y:  d*T, fluorescence data
%   allow_deletion: boolean, allow deletion (default: true)
% output:
%   C_raw: K*T, temporal components without being deconvolved

% Author: Pengcheng Zhou, Carnegie Mellon University, adapted from Johannes

% options
maxIter = obj.options.maxIter;
deconv_options_0 = obj.options.deconv_options;

if ~exist('allow_deletion', 'var')
    allow_deletion = true;
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
    
if sum(isnan(Y(:)))>0||sum(isinf(Y(:)))>0
	disp('bad values Y')
<<<<<<< HEAD
    Y(isnan(Y(:)|isinf(Y(:))))=0;
end
if sum(isnan(obj.A(:)))>0||sum(isinf(obj.A(:)))>0
	disp('bad values A')
    obj.A(isnan(obj.A(:))|isinf(obj.A(:)))=0;
end
if sum(isnan(obj.C(:)))>0||sum(isinf(obj.C(:)))>0
	disp('bad values C')
    obj.C(isnan(obj.C(:))|isinf(obj.C(:)))=0;
=======
end
if sum(isnan(obj.A(:)))>0||sum(isinf(obj.A(:)))>0
	disp('bad values A')
end
if sum(isnan(obj.C(:)))>0||sum(isinf(obj.C(:)))>0
	disp('bad values C')
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
end


%% initialization
A = obj.A;
K = size(A, 2);     % number of components
C = obj.C;
C_raw = zeros(size(C));
C_offset = zeros(K, 1);
S = zeros(size(C));
A = full(A);
U = A'*Y;
V = A'*A;
U(isnan(U(:))|isinf(U(:)))=0;
V(isnan(V(:))|isinf(V(:)))=0;

aa = diag(V);   % squares of l2 norm all all components
sn =  zeros(1, K);
smin = zeros(1,K);
% kernel = obj.kernel;
kernel_pars = cell(K,1);
%% updating


ind_del = aa<10^(-7);
aa(aa<10^(-7))=10^(-7);
disp(find(ind_del))
for miter=1:maxIter
    for k=1:K
        
        if ind_del(k)
            continue;
        end
        temp = C(k, :) + (U(k, :)-V(k, :)*C)/aa(k);
        %remove baseline and estimate noise level
        if sum(isnan(temp)|isinf(temp))>0
            disp('bad temp')
            temp(isnan(temp))=0;
            C_raw(k, :) = C_raw(k, :)*0;
            C(k,:) = C(k, :)*0;
            S(k, :) = S(k, :)*0;
            ind_del(k) = true;
            kernel_pars{k}=1;
            sn(k)=1;
            smin(k) = deconv_options.smin;
            continue;
        end
        
        [b_hist, sn_hist] = estimate_baseline_noise(temp);
        b = mean(temp(temp<median(temp)));
        sn_psd = GetSn(temp);
<<<<<<< HEAD
        if sum(isnan(sn_psd(:)))>0|sum(isinf(sn_psd(:)))>0|isnan(b_hist)|isnan(sn_hist)
            disp('sn bad')
            smin(k) = deconv_options.smin;
            C_raw(k, :) = C_raw(k, :)*0;
            C(k,:) = C(k, :)*0;
            S(k, :) = S(k, :)*0;
            ind_del(k) = true;
            kernel_pars{k}=1;
            sn(k)=1;
            continue;
        end
=======
	if sum(isnan(sn_psd(:)))>0||sum(isinf(sn_psd(:)))>0
		disp('sn bad')
	end
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
        if sn_psd<sn_hist
            tmp_sn = sn_psd;
        else
            tmp_sn = sn_hist;
            b = b_hist;
        end
        
        temp = temp -b;
        sn(k) = tmp_sn;
        if sn(k)==0
            
            smin(k) = deconv_options.smin;
            C_raw(k, :) = C_raw(k, :)*0;
            C(k,:) = C(k, :)*0;
            S(k, :) = S(k, :)*0;
            ind_del(k) = true;
            kernel_pars{k}=1;
            sn(k)=1;
            continue;
        end
        % deconvolution
        if obj.options.deconv_flag
            [ck, sk, deconv_options]= deconvolveCa(temp, deconv_options_0, 'maxIter', 2, 'sn', tmp_sn);
            smin(k) = deconv_options.smin;
            kernel_pars{k} = reshape(deconv_options.pars, 1, []);
            temp = temp - deconv_options.b; 
        else
            ck = max(0, temp);
        end
        if sum(isnan(ck))>0|isnan(sk)|sk==0
            smin(k) = deconv_options.smin;
            C_raw(k, :) = C_raw(k, :)*0;
            C(k,:) = C(k, :)*0;
            S(k, :) = S(k, :)*0;
            ind_del(k) = true;
            kernel_pars{k}=1;
            sn(k)=1;
            continue;
        end
        % save convolution kernels and deconvolution results
        C(k, :) = ck;
        
        if sum(ck(2:end))==0
            ind_del(k) = true;
        end
        % save the spike count in the last iteration
        if miter==maxIter
            if obj.options.deconv_flag
                S(k, :) = sk;
            end
            C_raw(k, :) = temp;
        end
    end
end
sn(isnan(sn)|(sn==0))=1;
obj.A = bsxfun(@times, A, sn);
obj.C = bsxfun(@times, C, 1./sn');
obj.C_raw = bsxfun(@times, C_raw, 1./sn');
obj.S = bsxfun(@times, S, 1./sn');
obj.P.kernel_pars =cell2mat( kernel_pars);
obj.P.smin = smin/sn;
obj.P.sn_neuron = sn;
if allow_deletion
    obj.delete(ind_del);
end
obj.A(isnan(obj.A(:))|isinf(obj.A(:)))=0;
obj.C(isnan(obj.C(:))|isinf(obj.C(:)))=0;
obj.C_raw(isnan(obj.C_raw(:))|isinf(obj.C_raw(:)))=0;
obj.S(isnan(obj.S(:))|isinf(obj.S(:)))=0;

obj.P.sn_neuron(isnan(obj.P.sn_neuron)|obj.P.sn_neuron==0)=mean(obj.P.sn_neuron(obj.P.sn_neuron>0&~isnan(obj.P.sn_neuron)));
obj.P.kernel_pars(isnan(obj.P.kernel_pars))=1;
