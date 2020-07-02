function []=autoAlignmentAdj(video1_path,video2_path)
%For memory intensive situations, modifies video 2 in place to match video
%1. 
close all
[filepath,name,ext]= fileparts(video1_path);
        if isequal(ext,'.tif')
            fixed=double(loadtiff(video1_path));
        else
            fixed=load(video1_path);
            %moving=double(moving.fixed);
            fixed=double(fixed.Y);
        end
        [filepath,name,ext]= fileparts(video2_path);
        if isequal(ext,'.tif')
            moving=double(loadtiff(video2_path));
        else
            moving=load(video2_path);
            %moving=double(moving.fixed);
            moving=double(moving.Y);
        end
        
        %Remove this after finishing mouse 1
        %moving = imresize(moving, [240 450]);
        %moving=moving(:,38:end-37,:);
        
       light=[];
        for k=1:size(fixed,3)
            light(k)=sum(fixed(:,:,k),'all');
        end
        prc=prctile(light,80);
        indices=find(light<prc);
        
        fixed_proj=double(max(fixed(:,:,indices),[],3));
        light=[];
        for k=1:size(moving,3)
            light(k)=sum(moving(:,:,k),'all');
        end
        prc=prctile(light,80);
        indices=find(light<prc);
        
        moving_proj=max(moving(:,:,indices),[],3);
        
        moving_proj = imsharpen(medfilt2(moving_proj,[3 3]));
        fixed_proj = imsharpen(medfilt2(fixed_proj,[3 3]));
        
        
    tform=matlab_image_registration(fixed_proj,moving_proj);

    parfor k=1:size(moving,3)
        moving(:,:,k) = imwarp(moving(:,:,k),tform);
    
    end
     
       light=[];
        for k=1:size(fixed,3)
            light(k)=sum(fixed(:,:,k),'all');
        end
        prc=prctile(light,80);
        indices=find(light<prc);
        
        fixed_proj=double(max(fixed(:,:,indices),[],3));
        light=[];
        for k=1:size(moving,3)
            light(k)=sum(moving(:,:,k),'all');
        end
        prc=prctile(light,80);
        indices=find(light<prc);
        
        moving_proj=max(moving(:,:,indices),[],3);
        
        moving_proj = imsharpen(medfilt2(moving_proj,[3 3]));
        fixed_proj = imsharpen(medfilt2(fixed_proj,[3 3]));
%     
%      figure('name','moving','Position', [10 10 800 600])
%         imagesc(moving_proj)
%         colormap gray
%         daspect([1,1,1])
%         figure('name','fixed','Position', [10 10 800 600])
%         imagesc(fixed_proj)
%         colormap gray
%         daspect([1,1,1])
%         
%         %m denotes manual feature selection
%         keep=input('Is registration acceptable? y/n ','s');
        keep='n';
if isequal(keep,'n')
        
          
        tform=matlab_image_registration(fixed_proj,moving_proj);
        moving_proj_temp=imwarp(moving_proj,tform);
    



        
        figure('name','moving','Position', [10 10 800 600])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 800 600])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        
        %m denotes manual feature selection
        keep=input('Is registration acceptable? y/n/m ','s');
        %keep='y';
        while isequal(keep,'m')
        
            
            [fixed_mask,moving_mask]=manual_ROI_selection(fixed_proj,moving_proj);
            fixed_proj_temp=max(double(fixed_proj),max(max(fixed_proj))*double(fixed_mask));
            moving_proj_temp=max(moving_proj,max(max(moving_proj))*double(moving_mask));
            
       
            registration=registration2d(fixed_proj_temp,moving_proj_temp);
            moving_proj_im=deformation(moving_proj,registration.displacementField...
                ,registration.interpolation);
            figure('name','moving','Position', [10 10 800 600])
            imagesc(moving_proj_im)
            colormap gray
            daspect([1,1,1])
            figure('name','fixed','Position', [10 10 800 600])
            imagesc(fixed_proj)
            colormap gray
            daspect([1,1,1])
            keep=input('Is registration acceptable? y/n/m ','s');
        end





if isequal(lower(keep),'y')
   parfor k=1:size(moving,3)
        moving(:,:,k) = imwarp(moving(:,:,k),tform);
    
    end
    
    Y=uint8(moving);
    Ysiz=size(Y);
    save(video2_path,'Y','Ysiz','-v7.3')
end

else
    Y=uint8(moving);
    Ysiz=size(Y);
    save(video2_path,'Y','Ysiz','-v7.3')
end
 close all