function template=construct_template(video);

warning('off','all')
for i=1:size(video,3);
    rgb=video(:,:,i);
    
   
    
    [centers,radii] = imfindcircles(rgb,[3 12],'Sensitivity',0.87);
    
    if length(centers)>=1
        rgb=remove_template_background(rgb);
        
         prc=prctile(reshape(rgb,1,[]),99.5);
         rgb(rgb<prc)=0;
         [centers,radii] = imfindcircles(rgb,[3 12],'Sensitivity',0.92);
         %radii=radii*1.5;
         radii=radii*2/3;
        frame_circ(i)=1;
        try
        temp_mask=double(createCirclesMask(rgb,centers,radii));
        temp_mask=imgaussfilt(temp_mask,max(radii)/3);
        rgb=uint8(rgb.*temp_mask);
        
        video(:,:,i)=rgb;
        catch
            video(:,:,i)=0;
        end
            
    end
end
warning('on','all')
frame_circ=find(frame_circ);
visible_circles=video(:,:,frame_circ);

template=max(visible_circles,[],3);
mean_template=std(video,[],3);
template=template+.5*max(template,[],'all')*mean_template/max(mean_template,[],'all');
template=255*template/max(template,[],'all');


end
  