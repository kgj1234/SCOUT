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
x=round(MajorAxisLength/2*cos(Orientation*pi/180));
y=round(MajorAxisLength/2*sin(Orientation*pi/180));
edge_vec=centroid+[x,y];
x_coord=double([centroid(1),edge_vec(1)]);
y_coord=double([centroid(2),edge_vec(2)]);
c = improfile(double(A1),x_coord,y_coord);


edge_vec=centroid-[x,y];
x_coord=double([centroid(1),edge_vec(1)]);
y_coord=double([centroid(2),edge_vec(2)]);
c1 = improfile(double(A1),x_coord,y_coord);

total=sum(c==0);
total1=sum(c1==0);
c(c==0)=[];
c1(c1==0)=[];


c(isnan(c))=[];
c1(isnan(c1))=[];

c=c/max(c);
c1=c1/max(c1);


c1=c1';
c=c';


min_length=min([length(c),length(c1)]);
difference=c1(1:min_length)-c(1:min_length);
% RMSE=sqrt(1/length(difference)*sum(difference.^2));
% if RMSE>.13
%     A1_comp=zeros(size(A1));
%     A2_comp=zeros(size(A2));
%     return
% end

c(1:min_length)=(c(1:min_length)+c1(1:min_length))/2;
c1(1:min_length)=c(1:min_length);
if length(c1)>length(c)
    c=c1;
end

if max([total,total1])>0
    c=[c,0];
end


x=linspace(0,1,length(c));
error=[nan,nan];
%x=x(1:end-1);
%c=c(1:end-1);
warning('off','all')

%Fit fractional exponential model

init_vals=2.2:-.2:.8;
for i=1:length(init_vals)
    try
        modelfun{2}=@(b,x) b(3)*(1-x).^(1/b(1))+(1-b(3))*(1-x.^2).^(1/b(2));
        [beta{2},R2]=nlinfit(x,c,modelfun{2},[init_vals(i),init_vals(i),.5]);

    end

    if exist('beta','var')
        vals=modelfun{2}(beta{2},x);
        break
    end
end
if ~exist('beta','var')

    try
         modelfun{2}=@(b,x) (1-x).^(1/b(1));
        [beta{2},R2]=nlinfit(x,c,modelfun{2},init_vals(i));

    end
end






warning('on','all')
% if ~isempty(R1)&&~isempty(R2)
%     [~,I]=min([mean(abs(R1)),mean(abs(R2))]);
% elseif isempty(R1)
%     I=1;
% else
%     I=2;
%     
% end
I=2;
beta=beta{I};
modelfun=modelfun{I};



%Construct Comparisons

A1_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),modelfun,beta,Orientation*pi/180,centroid,data_shape);

A2_comp=plot_ellipse((MajorAxisLength/2),(MinorAxisLength/2),modelfun,beta,Orientation*pi/180+pi/2,centroid,data_shape);
