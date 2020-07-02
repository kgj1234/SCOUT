function align_via_CNMF_E(vid1,vid2)
Y{1}=matfile(['./',vid1]);
Y{2}=matfile(['./',vid2]);
vids={vid1,vid2};
parfor i=1:2
proj{i}=extract_background_CNMF_E(['./',vids{i}],Y{i}.Ysiz,[],15);
end

fixed_proj=reshape(proj{1},Y{1}.Ysiz(1,1),Y{1}.Ysiz(1,2),[]);


moving_proj=reshape(proj{2},Y{2}.Ysiz(1,1),Y{2}.Ysiz(1,2),[]);

fixed_proj=max(fixed_proj,[],3);
moving_proj=max(moving_proj,[],3);
[filepath,name,ext]= fileparts(vid1);
        if isequal(ext,'.tif')
            fixed=double(loadtiff(vid1));
        else
            fixed=load(vid1);
            %moving=double(moving.fixed);
            fixed=double(fixed.Y);
        end
        [filepath,name,ext]= fileparts(vid2);
        if isequal(ext,'.tif')
            moving=double(loadtiff(vid2));
        else
            moving=load(vid2);
            %moving=double(moving.fixed);
            moving=double(moving.Y);
        end

        registration=registration2d(fixed_proj,moving_proj);



        moving_proj_temp=deformation(moving_proj,registration.displacementField...
                ,registration.interpolation);
        
        
        figure('name','moving','Position', [10 60 200 200])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 60 200 200])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        
        keep=input('Is registration acceptable? y/n ','s');
        
if isequal(lower(keep),'y')
   
    parfor k=1:size(moving,3)
        moving(:,:,k) = uint8(deformation(double(moving(:,:,k)),...
        registration.displacementField,registration.interpolation));
    
    end
    
    
    Y=moving;
    Ysiz=size(Y);
    save(vid2,'Y','Ysiz','-v7.3')
end
