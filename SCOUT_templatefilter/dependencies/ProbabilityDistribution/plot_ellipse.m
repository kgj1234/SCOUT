function A=plot_ellipse(xwidth,ywidth,modelfun,beta,angle,centroid,data_shape)
% construct elliptical comparison given parameters
% inputs

%xwidth (int) xwidth of ellipse
%ywidth (int) ywidth of ellipse
% modelfun (function) function model for signal decrease from origin
% beta: function parameters
% angle: (float) angle (in radians) footprint makes with the x-axis
% centroid: (vector) centroid of footprint
% data_shape (vector) size of inputted footprint

%outputs
%A (matrix) commparison footprint

%%Author Kevin Johnston

%%




[t,r] = meshgrid(linspace(0,2*pi,361),linspace(0,max(xwidth,ywidth),ceil(2*max(xwidth,ywidth))));

%Construct image by drawing radial lines from centroid
Z=plot_by_angle(xwidth,ywidth,r,t,angle,modelfun,beta);
Z(abs(imag(Z))>0)=0;


[X,Y]=pol2cart(t,r);
X=round(X);
Y=round(Y);



%Trim edges to prevent exceeding the size of the recording
X=reshape(X,1,[])+round(centroid(1));
Y=reshape(Y,1,[])+round(centroid(2));
X(X>data_shape(2))=data_shape(2);
X(X<1)=1;
Y(Y>data_shape(1))=data_shape(1);
Y(Y<1)=1;
A=zeros(data_shape);
ind=sub2ind(data_shape,Y,X);
for i=1:length(ind)
    if ind(i)<=0
        ind=sub2ind(data_shape,round(centroid(1)),round(centroid(2)));
    end
        
    same_index=ind==ind(i);
    Z(same_index)=max(Z(same_index));
end

%Construct comparison footprint and normalize
A(ind)=Z;
A=A/sum(sum(A));


