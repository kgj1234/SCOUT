function [m, xfall, sxall, syall] = inter_section(m, sttn, se, pixs, scl, sigma_x, sigma_f, sigma_d, maskc)
% register frames across stable sections
%   Jinghao Lu, 02/02/2018
    
    [pixh, pixw, nf] = size(m, 'reg');
    if nargin < 4 || isempty(pixs)
        pixs = min(pixh, pixw);
    end
    
    if nargin < 5 || isempty(scl)
        defpar = default_parameters;
        scl = defpar.mc_scl;
    end
    
    if nargin < 6 || isempty(sigma_x)
        defpar = default_parameters;
        sigma_x = defpar.mc_sigma_x;
    end
    
    if nargin < 7 || isempty(sigma_f)
        defpar = default_parameters;
        sigma_f = defpar.mc_sigma_f;
    end
    
    if nargin < 8 || isempty(sigma_d)
        defpar = default_parameters;
        sigma_d = defpar.mc_sigma_d;
    end
    
    if nargin < 9 || isempty(maskc)
        maskc = true(pixh, pixw);
    end
    
    %% prepare inter-section data %%
    if ~any(sttn == 1)
        sttnn = [1; sttn(2: end)];
    else
        sttnn = sttn;
    end
    stpnn = unique([sttn(2: end) - 1; nf]);
    flag = true;

    %% LK-LogDemons hierarchical registration %%
    %%% initial data prep %%%
    nn = length(sttnn);
    nnt = nn;
    istep = 5;
    nl = ceil(nnt / istep);
    regallt = zeros(pixh, pixw, nnt);
    regallt_orig=zeros(pixh,pixw,nnt);
    parfor i = 1: nnt
        mm = m;
        tmp = mm.reg(1: pixh, 1: pixw, sttnn(i): stpnn(i));
        tmp1=mm.orig(1:pixh,1:pixw,sttnn(i):stpnn(i));
        
        regallt(:, :, i) = ref_select(tmp);
        regallt_orig(:,:,i)=ref_select(tmp1)
    end
    
    regpara = cell(1, nl);
    regpara_orig = cell(1,nl);
    for i = 1: nl
        idt = istep * (i - 1) + 1: min(nnt, istep * i);
        regpara{i} = regallt(:, :, idt);
        regpara_orig{i}=regallt_orig(:,:,idt);
        
    end
    
    clear regallt
    disp('Done data prep')
    
    %%% initialization %%%
    ub = 0;
    nntt = nn;
    while nntt > 1
        nntt = nntt / istep;
        ub = ub + 1;
    end
    sx = cell(1, ub);
    sy = cell(1, ub);
    xf = cell(1, ub);
    id = cell(1, ub);
    p0 = [0; 0];
    
    %%% main loop %%%
    for ii = 1: ub
        sxx = cell(1, nl);
        syy = cell(1, nl);
        xff = cell(1, nl);
        idxx = cell(1, nl);
        parfor i = 1: nl
            nn=length(sttnn);
            idt = istep * (i - 1) + 1: min(nn, istep * i);
            tmp = regpara{i};
            tmp1 =regpara_orig{i};
            %%% register: lk_logdemons_unit %%%
            [tmp, xft, sxxt, syyt,PNs,p1] = lk_logdemons_unit(tmp, se, pixs, scl, sigma_x, sigma_f, sigma_d, flag, maskc);
            nn = size(tmp,3);
            for j = 1: nn - 1
                tmp1(:, :, j + 1) = lk2_warp(tmp1(:, :, j + 1), PNs(:, j), p1);

            end
            %%% update results %%%
            regpara{i} = tmp;
            regpara_orig{i}=tmp1;
            
            xff{i} = xft;
            sxx{i} = sxxt;
            syy{i} = syyt;
            idxx{i} = idt;
            tmp = [];
            sxxt = [];
            syyt = [];
%             disp(num2str(i))
        end
        
        %%% update variables %%%
        xf{ii} = xff;
        sx{ii} = sxx;
        sy{ii} = syy;
        id{ii} = idxx;
        
        %%% prepare next round data %%%
        nnt = nl;
        nl = ceil(nnt / istep);
        regparat = cell(1, nl);
        regparat_orig=cell(1,nl);
    
        for i = 1: nl
            idt = istep * (i - 1) + 1: min(nnt, istep * i);
            regparat{i} = zeros(pixh, pixw, length(idt));
            regparat_orig{i}=zeros(pixh,pixw,length(idt));
            
            for j = 1: length(idt)
                tmp = regpara{idt(j)};
                regparat{i}(:, :, j) = max(tmp, [], 3);
                
                tmp1=regpara_orig{idt(j)};
                regparat_orig{i}(:,:,j)=max(tmp1,[],3);
                
            end
        end
        regpara = regparat;
        regpara_orig=regparat_orig;
        
        disp(['Done loop #', num2str(ii), '/', num2str(ub)])
    end
    
    %%% register preparation %%%
    xfall = cell(1, nn);
    sxall = cell(1, nn);
    syall = cell(1, nn);
    count = 0;
    for i = 1: length(xf)
        for j = 1: length(xf{i})
            idt = id{i}{j};
            for k = 1: length(idt)
                idc = istep ^ (i - 1) * (idt(k) - 1) + 1: min(nn, istep ^ (i - 1) * idt(k));
                for ii = 1: length(idc)
                    xfall{idc(ii)} = [xfall{idc(ii)}, xf{i}{j}(k)];
                    sxall{idc(ii)} = [sxall{idc(ii)}, sx{i}{j}(k)];
                    syall{idc(ii)} = [syall{idc(ii)}, sy{i}{j}(k)];
                    for kk = 1: length(sx{i}{j}{k})
                        count = count + size(sx{i}{j}{k}{kk}, 3);
                    end
                end
            end
        end
    end
        
    %% warp frames %%
    %%% compute batch %%%
    df = stpnn - sttnn + 1;
    dfc = cumsum(df);
    nff = dfc(end);
    ttype = class(m.reg(1, 1, 1));
    stype = parse_type(ttype);
%     nsize = pixh * pixw * nff * stype * 8; %%% heuristic size of algorithm %%%
    nsize = pixh * pixw * count * stype * 16; %%% heuristic size of algorithm %%%
    nbatch = batch_compute(nsize);
    ebatch = round(nff / nbatch);
    
    i = 1;
    idbatch = zeros(1, nbatch);
    while dfc(end) > 0
        idtmp = find(dfc <= ebatch, 1, 'last');
        idbatch(i) = idtmp;
        dfc = dfc - dfc(idtmp);
        i = i + 1;
    end
    nbatch = i - 1;
    idbatch = [0, idbatch];
    
    %%% warp all frames %%%
    for i = 1: nbatch
        %%%% parallel and batch data prepare %%%
        Yuse = cell(1, idbatch(i + 1) - idbatch(i));
        Yuse_orig=cell(1,idbatch(i+1)-idbatch(i));
        for ii = idbatch(i) + 1: idbatch(i + 1)
            Yuse{ii - idbatch(i)} = m.reg(1: pixh, 1: pixw, sttnn(ii): stpnn(ii));
            Yuse_orig{ii-idbatch(i)}=m.orig(1:pixh,1:pixw,sttnn(ii):stpnn(ii));
        end
        
        %%%% warp main %%%%
        stof = idbatch(i);
        nY = length(Yuse);
        parfor ip = 1: nY
            regt = Yuse{ip};
            regt_a=Yuse_orig{ip};
            if ~isempty(xfall{ip + stof})
                for j = 1: length(xfall{ip + stof})
                    for k = 1: size(regt, 3)
                        regt(:, :, k) = lk2_warp(regt(:, :, k), xfall{ip + stof}{j}, p0);
                        regt_a(:,:,k)=lk2_warp(regt_a(:,:,k), xfall{ip+stof}{j},p0);
                        
                        for ii = 1: length(sxall{ip + stof}{j})
                            regt(:, :, k) = iminterpolate(regt(:, :, k), sxall{ip + stof}{j}{ii}, syall{ip + stof}{j}{ii});
                            regt(:, :, k) = regt(:, :, k) - imopen(regt(:, :, k), strel('disk', se));
                            regt_a(:,:,k)= iminterpolate(regt_a(:, :, k), sxall{ip + stof}{j}{ii}, syall{ip + stof}{j}{ii});
                            
                            
                        end
                    end
                end
            end
            Yuse{ip} = regt;
            Yuse_orig{ip}=regt_a;
            regt = [];
            regt_a=[];
        end
        
        %%%% data update %%%%
        for ii = idbatch(i) + 1: idbatch(i + 1)
            m.reg(1: pixh, 1: pixw, sttnn(ii): stpnn(ii)) = Yuse{ii - idbatch(i)};
            m.orig(1:pixh,1:pixw,sttnn(ii):stpnn(ii))=Yuse_orig{ii-idbatch(i)};
        end
    end
end