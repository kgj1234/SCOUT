function del_ind=identify_spatial_irregularities(neuron,indices)
close all
bad_ind=[];
good_ind=indices(1):indices(2);

while true
    colorschema=zeros(neuron.imageSize(1),neuron.imageSize(2),3);
    try
    colorschema(:,:,2)=max(reshape(neuron.A(:,good_ind),...
        neuron.imageSize(1),neuron.imageSize(2),[]),[],3);
    end
    try
    colorschema(:,:,1)=max(reshape(neuron.A(:,bad_ind),...
        neuron.imageSize(1),neuron.imageSize(2),[]),[],3);
    end
    colorschema=colorschema/max(max(max(colorschema)));
    
    imagesc(colorschema)
    try
        roi=getPosition(imrect);
    catch
        break
    end
    
    if sum(roi(3:end))==0
        dist=pdist2(neuron.centroid,roi(2:-1:1));
        [m,val]=min(dist);
        tot_pix=sum(neuron.A(:,val)>0);
        min_dist=1.5*sqrt(tot_pix);
        if m<min_dist
            if any(bad_ind==val);
                good_ind=[good_ind,val];
                bad_ind=setdiff(bad_ind,good_ind);
            else
                bad_ind=[bad_ind,val];
                good_ind=setdiff(good_ind,bad_ind);
            end
        end
    else
        percent=fraction_pixels_rectangle(roi,neuron,indices);
        bad_ind=[bad_ind,find(percent>.5)];
        good_ind=setdiff(good_ind,bad_ind);
    end
    
        
    
end

del_ind=bad_ind;

    