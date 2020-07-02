function mse=MSE_registration_metric(im1,im2);

avg=(im1+im2)/2;
mss=1/2*((im1-avg).^2+(im2-avg).^2);
mse=sqrt(1/(size(im1,1)*size(im1,2))*sum(mss(:)));













