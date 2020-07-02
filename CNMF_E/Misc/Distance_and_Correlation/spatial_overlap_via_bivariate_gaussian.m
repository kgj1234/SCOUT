function KL=spatial_overlap_via_bivariate_gaussian(A1,A2,height,width)

[centroid1,covariance1]=calculateCentroid_and_Covariance(A1,height,width);
[centroid2,covariance2]=calculateCentroid_and_Covariance(A2,height,width);
warning('off','all')

KL=1/2*(trace((covariance2)\covariance1)+(centroid2-centroid1)*((covariance2)\(centroid2-centroid1)')-2+log(det(covariance2)/det(covariance1)));
warning('on','all')
