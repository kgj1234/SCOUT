function moving_proj_temp=autoAlignment(video1_path,video2_path)
%Modifies video 2 in place to match video
%1. 

%For example, use this code to consecutively align videos in a folder, or align all videos to a baseline.

%n -no, y - yes, m - manual intervention
close all
[filepath,name,ext]= fileparts(video1_path);
        if isequal(ext,'.tif')
            fixed=double(loadtiff(video1_path));
        else
            fixed=load(video1_path);
            %moving=double(moving.fixed);
            try
            fixed=double(fixed.Y);
            catch
                fixed=double(fixed.current);
            end
        end
        [filepath,name,ext]= fileparts(video2_path);
        if isequal(ext,'.tif')
            moving=double(loadtiff(video2_path));
        else
            
            moving=load(video2_path);
            %moving=double(moving.fixed);
            try
                moving=double(moving.Y);
            catch
                moving=double(moving.current);
            end
        end
        
        %Remove this after finishing mouse 1
        %moving = imresize(moving, [220 420]);
        %moving=moving(:,38:end-37,:);
        
       light=[];
     
       fix_back=zeros(size(fixed));
        parfor k=1:size(fixed,3)
   
            %fix_back(:,:,k)=medfilt2(remove_template_background(fixed(:,:,k)));
            fix_back(:,:,k)=fixed(:,:,k);
            light(k)=sum(fixed(:,:,k),'all');
        end
        prc=prctile(light,60);
        indices=find(light<prc);
        
        %fixed_proj1=double(std(fixed(:,:,indices),[],3));
        %fixed_proj2=double(max(fixed(:,:,indices),[],3));
        %fixed_proj=(fixed_proj1+fixed_proj2)/2;
        %fixed_proj=fixed_proj1;
        fixed_proj1=std(fix_back(:,:,indices),[],3);
        fixed_proj2=max(fix_back(:,:,indices),[],3);
        fixed_proj=(fixed_proj1*max(fixed_proj2,[],'all')/max(fixed_proj1,[],'all')+fixed_proj2)/2;
        fixed_proj(fixed_proj<=2)=max(fixed_proj,[],'all');
        light=[];
        mov_back=zeros(size(moving));
        parfor k=1:size(moving,3)
            %mov_back(:,:,k)=medfilt2(remove_template_background(moving(:,:,k)));
            mov_back(:,:,k)=moving(:,:,k);
            light(k)=sum(moving(:,:,k),'all');
        end
        prc=prctile(light,60);
        indices=find(light<prc);
        
        %moving_proj1=std(moving(:,:,indices),[],3);
        %moving_proj2=max(moving(:,:,indices),[],3);
        %moving_proj=(moving_proj1+moving_proj2)/2;
        %moving_proj=moving_proj1;
        moving_proj1=std(mov_back(:,:,indices),[],3);
        moving_proj2=max(mov_back(:,:,indices),[],3);
        moving_proj=(moving_proj1*max(moving_proj2,[],'all')/max(moving_proj1,[],'all')+moving_proj2)/2;
        moving_proj(moving_proj<=2)=max(moving_proj,[],'all');
         %moving_proj = adapthisteq(imsharpen(moving_proj)/255);
         %fixed_proj = adapthisteq(imsharpen(fixed_proj)/255);
         %moving_proj=imhistmatch(moving_proj,fixed_proj);
         %moving_proj=remove_template_background(moving_proj);
         %fixed_proj=remove_template_background(fixed_proj);
registration=registration2d(fixed_proj,moving_proj,'transformationModel' , 'translation');
    tic
    parfor k=1:size(moving,3)
        moving(:,:,k) = uint8(deformation(double(moving(:,:,k)),...
        registration.displacementField,registration.interpolation));
    
    end
    toc
     
       light=[];
       fix_back=zeros(size(fixed));
        parfor k=1:size(fixed,3)
            %fix_back(:,:,k)=medfilt2(remove_template_background(fixed(:,:,k)));
            fix_back(:,:,k)=fixed(:,:,k);
            light(k)=sum(fixed(:,:,k),'all');
        end
         prc=prctile(light,60);
         indices=find(light<prc);
%         
%         fixed_proj1=double(std(fixed(:,:,indices),[],3));
%         fixed_proj2=double(max(fixed(:,:,indices),[],3));
%         fixed_proj=(fixed_proj1+fixed_proj2)/2;
        %fixed_proj=fixed_proj1;
        %fixed_proj1=std(fix_back(:,:,indices),[],3);
        %fixed_proj2=max(fix_back(:,:,indices),[],3);
        %fixed_proj=(fixed_proj1+fixed_proj2)/2;
        fixed_proj=max(fix_back(:,:,indices),[],3);
        
        
        light=[];
        mov_back=zeros(size(moving));
        parfor k=1:size(moving,3)
            %mov_back(:,:,k)=medfilt2(remove_template_background(moving(:,:,k)));
            mov_back(:,:,k)=moving(:,:,k);
            light(k)=sum(moving(:,:,k),'all');
        end
        prc=prctile(light,60);
         indices=find(light<prc);
%         
%         moving_proj1=std(moving(:,:,indices),[],3);
%         
%         moving_proj2=max(moving(:,:,indices),[],3);
%         moving_proj=(moving_proj1+moving_proj2)/2;
        %moving_proj=moving_proj1;
        %fixed_proj=imsharpen(fixed_proj);
        %moving_proj=imsharpen(moving_proj);
        %moving_proj1=std(mov_back(:,:,indices),[],3);
        %moving_proj2=max(mov_back(:,:,indices),[],3);
        %moving_proj=(moving_proj1+moving_proj2)/2;
        %  moving_proj=remove_template_background(moving_proj);
         %fixed_proj=remove_template_background(fixed_proj);
        %moving_proj = adapthisteq(imsharpen(moving_proj)/255);
        %fixed_proj = adapthisteq(imsharpen(fixed_proj)/255);
        %moving_proj=imhistmatch(moving_proj,fixed_proj);
        moving_proj=max(mov_back(:,:,indices),[],3);
        %moving_proj=imcomplement(moving_proj);
        figure('name','moving','Position', [10 60 200 200])
        imagesc(moving_proj)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 200 200])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        
        %m denotes manual feature selection
        keep=input('Is registration acceptable? y/n ','s');
        keep='n';
        
if isequal(keep,'n')
        
        %h=imrect();
        %mask=createMask(h);
        fixed_proj=double(mask).*fixed_proj;
        moving_proj=double(mask).*moving_proj;
        registration=registration2d(fixed_proj,moving_proj);



        moving_proj_temp=deformation(moving_proj,registration.displacementField...
                ,registration.interpolation);
        
        
        figure('name','moving','Position', [10 10 200 200])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 200 200])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        
        %m denotes manual feature selection
        keep=input('Is registration acceptable? y/n/m ','s');
        %keep='y';
        while isequal(keep,'m')
        
            
            [fixed_mask,moving_mask]=manual_ROI_selection(fixed_proj,moving_proj);
            fixed_proj_temp=fixed_proj;
            moving_proj_temp=moving_proj;
            
            for i=1:length(fixed_mask)
                fixed_proj1=fixed_proj.*double(fixed_mask{i});
                moving_proj1=moving_proj.*double(moving_mask{i});
                fixed_proj1=imadjust(fixed_proj1(fixed_mask{i})/255,[min(fixed_proj1,[],'all')/255,max(fixed_proj1,[],'all')/255],[0,max(fixed_proj,[],'all')/255]);
                moving_proj1=imadjust(moving_proj1(moving_mask{i})/255,[min(moving_proj1,[],'all')/255,max(moving_proj1,[],'all')/255],[0,max(moving_proj,[],'all')/255]);
                prc=prctile(fixed_proj1,20);
                fixed_proj1(fixed_proj1<prc)=0;
                
                prc=prctile(moving_proj1,20);
                moving_proj1(moving_proj1<prc)=0;
                
                fixed_proj_temp(fixed_mask{i})=max(max(fixed_proj_temp))-255*fixed_proj1;
                moving_proj_temp(moving_mask{i})=max(max(moving_proj_temp))-255*moving_proj1;
            end
            %fixed_proj_temp=max(double(fixed_proj),max(max(fixed_proj))*double(fixed_mask));
            %moving_proj_temp=max(moving_proj,max(max(moving_proj))*double(moving_mask));
            
       
            registration=registration2d(fixed_proj_temp,moving_proj_temp,'transformationModel' , 'translation');
            moving_proj_im=deformation(moving_proj,registration.displacementField...
                ,registration.interpolation);
            figure('name','moving','Position', [10 10 200 200])
            imagesc(moving_proj_im)
            colormap gray
            daspect([1,1,1])
            figure('name','fixed','Position', [10 10 200 200])
            imagesc(fixed_proj)
            colormap gray
            daspect([1,1,1])
            keep=input('Is registration acceptable? y/n/m ','s');
        end





if isequal(lower(keep),'y')
       tic
    parfor k=1:size(moving,3)
        moving(:,:,k) = uint8(deformation(double(moving(:,:,k)),...
        registration.displacementField,registration.interpolation));
    
    end
    
    toc
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
