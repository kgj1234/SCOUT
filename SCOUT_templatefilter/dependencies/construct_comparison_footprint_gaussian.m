function [A1_comp,A2_comp]=construct_comparison_footprint_gaussian(A1)
% Construct gaussian comparison footprint
% inputs

% A1 (matrix) proposed footprint

%ouputs

% A1_comp, A2_comp (matrix) gaussian comparison footprints

%%Author Kevin Johnston

%%



data_shape=size(A1);
%Construct Parameters
[centroid,covariance]=calculateCentroid_and_Covariance(A1,data_shape(1),data_shape(2));
%Construct Gaussian Footprints               
[X,Y]=meshgrid(1:data_shape(2),1:data_shape(1));
X=reshape(X,[],1);
Y=reshape(Y,[],1);
Z=mvnpdf([X,Y],centroid,covariance);
A1_comp=reshape(Z,data_shape(1),data_shape(2));
A2_comp=A1_comp;

