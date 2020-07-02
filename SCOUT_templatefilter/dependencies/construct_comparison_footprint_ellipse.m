function [A1_comp,A2_comp]=construct_comparison_footprint_ellipse(A1)
% Function construction elliptic comparison to inputted footprint A1
%inputs
    %A1: (image matrix) proposed footprint
%outputs
    %A1_comp,A2_comp (image matrix) closest elliptic comparisons
%%Author Kevin Johnston

%%

data_shape=size(A1);

%Extract parameters
[centroid,cov]=calculateCentroid_and_Covariance(A1,data_shape(1),data_shape(2));


bw=A1>0;
CC=bwconncomp(bw);
stats=CC.PixelIdxList;
curr_rem_ind=[];
num_elements=[];
for l=1:length(stats)
    num_elements(l)=length(stats{l});
end
for l=1:length(stats)
    if length(stats{l})~=max(num_elements)
        curr_rem_ind=[curr_rem_ind;stats{l}];
    end
end
A2=A1;
A2(curr_rem_ind)=0;
bw=A2>0;
stats= regionprops(full(bw),'MajorAxisLength','MinorAxisLength','Orientation');
MajorAxisLength=stats.MajorAxisLength;

MinorAxisLength=stats.MinorAxisLength;

Orientation=stats.Orientation;

%Estimate appropriate power to use for signal decrease from centroid
x=round(MajorAxisLength*cos(Orientation*pi/180));
y=round(MajorAxisLength*sin(Orientation*pi/180));
edge_vec=centroid+[x,y];
x_coord=double([centroid(1),edge_vec(1)]);
y_coord=double([centroid(2),edge_vec(2)]);
c = improfile(double(A1),x_coord,y_coord);

c=c/max(c);
c(c==0)=[];
c(isnan(c))=[];
c=c';
c=[c,0];
x=linspace(0,1,length(c));
error=[nan,nan];
x=x(1:end-1);
c=c(1:end-1);
warning('off','all')

%Fit fractional exponential model
init_vals=2.2:-.2:.8;
for i=1:length(init_vals)
    try
        modelfun{2}=@(b,x) (1-x).^(1/b(1));
        beta{2}=nlinfit(x,c,modelfun{2},[2.2]);
    end
    if exist('beta','var')
        vals=modelfun{2}(beta{2},x);
        break
    end
end

warning('on','all')

I=2;
beta=beta{I};
modelfun=modelfun{I};



%Construct Comparisons
A1_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),modelfun,beta,Orientation*pi/180,centroid,data_shape);
A2_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),modelfun,beta,Orientation*pi/180+pi/2,centroid,data_shape);
