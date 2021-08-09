function Y=interpolate_nan(Y);
for i=1:size(Y,2)
    nan_ind=[find(isnan(Y(:,i)));find(isinf(Y(:,i)))];
    if length(nan_ind)>0
    try
    val_ind=setdiff(1:size(Y,1),nan_ind);
    Y(nan_ind,i)=interp1(val_ind,Y(val_ind,i),nan_ind);
    end
    Y(isnan(Y(:,i)),i)=0;
    Y(isinf(Y(:,i)),i)=0;
    end
end