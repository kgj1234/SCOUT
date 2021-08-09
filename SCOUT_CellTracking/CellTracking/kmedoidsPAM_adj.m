function cellout = kmedoidsPAM_adj(rep,S,X,k,distObj,initialize,maxIterations,xDist,display,usePool)
%kmedoidsSmallPAM - an iterative algorithm to find perform k-medoids partional
%clustering
%
% kmedoidsSmallPAM implements a version of the algorithm described in [1].
%
% Usage:
%
% cellout = kmedoidsSmallPrecalculated(rep,S,X,k,distance,initialize,maxIterations,xDist,display,usePool)
%
% where, rep is the replicate number S is the random stream or an empty
% array X is the array of data supplied to kmedoids k is the number of
% clusters sought distance is an string or function handle than can be
% accepted by pdist2 initialize is a function handle to an initialization
% function set in kmedoids maxIterations is an integer greater than 0 xDist
% is an upper triangular array of pairwise distances between the rows of X
% display is an integer set from the display options in kmedoids usePool is
% a bool indicating whether a parallel pool should be used
%
% cellout is a cell returned in the format required by
% internal.stats.smartForReduce
%
% kmedoidsSmallPAM should not be called directly by users. It
% will likely change in a future release of MATLAB.

% References:
% [1] Kaufman, Leonard, and Peter J. Rousseeuw. Finding groups in data: an 
% introduction to cluster analysis. Vol. 344. Wiley. com, 2009.

% Copyright MathWorks 2014-2016 

if isempty(S)
    S = RandStream.getGlobalStream;
end

%distFun = @(varargin) internal.stats.kmedoidsDistFun(varargin{:},distance);

if display > 1 % 'iter'
    if usePool
        dispfmt = '%6d\t%8d\t%8d\t%12g\n';
        labindx = internal.stats.parallel.workerGetValue('workerID');
    else
        dispfmt = '%6d\t%8d\t%12g\n';
    end
end

cellout = cell(8,1); % cellout{1} = total sum of distances
                     % cellout{2} = replicate number
                     % cellout{3} = sum of distance for each cluster
                     % cellout{4} = iteration
                     % cellout{5} = idx;
                     % cellout{6} = Medoids
                     % cellout{7} = Distance

[~, medoidIndex,assign] = initialize(X,k,S,rep);
n = size(xDist,1);
if isempty(assign)
    [~,assign] = min(xDist(:,medoidIndex),[],2);
end
if length(unique(assign))~=k
    ind=randperm(length(assign),k);
    assign(ind)=1:k;
end
gain=zeros(1,k);
gaini=zeros(k,n-k);
swapgain=zeros(k,n);
for kter = 1:maxIterations
    nochange = false;
    
        


    if k==1
        gaint = mean(xDist,'all');
    else
        for j=1:k
            group_mem(j)=sum(assign==j);
        end
        

        for j=1:k
            for l=1:n
                if assign(l)~=j
                    shiftgain(j,l)=(-NaN20(mean(xDist(l,(assign==assign(l)&((1:n)'~=l))),'all'))+...
                    NaN20(mean(xDist(l,assign==j),'all')))+...
                    0.2*(group_mem(assign(l))-group_mem(j))/max(group_mem);
                else
                    shiftgain(j,l)=inf;
                end
                
            end
        end
        for j=1:n
            for l=1:n
                if assign(l)~=assign(j)&l>j
                    swapgain(j,l)=-NaN20(mean(xDist(j,(assign==assign(j)&((1:n)'~=j))),'all'))+...
                        NaN20(mean(xDist(j,(assign==assign(l)&((1:n)'~=l))),'all'))+...
                        -NaN20(mean(xDist(l,(assign==assign(l)&((1:n)'~=l))),'all'))+...
                        NaN20(mean(xDist(l,(assign==assign(j)&((1:n)'~=j))),'all'));
                else
                    swapgain(j,l)=inf;
                end
            end
        end
        
                    
        while true
            [M,I]=argmin_2d(shiftgain);
            if length(assign==assign(I(2)))==1 &~isinf(M)
                shiftgain(I(1),I(2))=inf;
            else
                break
            end
        end
        [M1,I1]=argmin_2d(swapgain);
        [M2,I2]=argmin_2d(shiftgain);
        
        if min(M1,M2)>=0

            nochange=true;
        
        elseif M1<M2
            val1=assign(I1(1));
            val2=assign(I1(2));
            assign(I1(1))=val2;
            assign(I1(2))=val1;
        else
            assign(I2(2))=I2(1);
        end
            
    end
            
    
    
    
    
    if nochange
        break
    end
    
end

for j=1:k
    try
    nodes=find(assign==j);
    [M,I]=min(mean(X(assign==j,assign==j),2));
    medoidIndex(j)=nodes(I);
    catch
        'hi'
    end
end

[m,h] = min(xDist(:,medoidIndex),[],2);
cellout{1} = sum(m);
cellout{2} = rep;
cellout{4} = kter;
cellout{5} = assign;
cellout{6} = medoidIndex;
cellout{7} = X(medoidIndex,:);
cellout{3} = accumarray(h,min(cellout{7},[],1),[k,1]);
cellout{8} = medoidIndex;

return