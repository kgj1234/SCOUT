function [a,b]=argmax_2d(A);
[M,I]=max(reshape(A,1,[]));
[a,b]=ind2sub([size(A,1),size(A,2)],I);
