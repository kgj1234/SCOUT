function []=autoAlignmentDirectory(drcty)
%drcty-string, directory path containing files
close all
direc=dir(drcty);
total_files={direc.name};
total_files=total_files(3:end);
exists=false;
for i=1:length(total_files);
    if isequal(total_files{i},'higherdirectory');
        exists=true;
        break
    end
end
if exists==false
    mkdir('higherdirectory')
end



f= dir(drcty); 
total_files={f.name};
vid_files={};
for i=1:length(total_files)
    [filepath,name,ext]= fileparts(total_files{i});
    if isequal(ext,'.tif')||isequal(ext,'.mat')
        vid_files{end+1}=horzcat(name,ext);
    end
end

vid_files=sort(vid_files);
%Check to make sure filenames are in the correct order

i=1;


while i<length(vid_files)-1
    [filepath,name,ext]= fileparts(vid_files{i});
    if isequal(ext,'.tif')
        fixed=loadtiff(vid_files{i});
        
    else
        fixed=load(vid_files{i});
        %Edit this 
        %fixed=fixed.fixed;
        fixed=fixed.Y;
    end
   
    for j=i+1:min(length(vid_files),i+5)
        [filepath,name,ext]= fileparts(vid_files{j});
        if isequal(ext,'.tif')
            moving=double(loadtiff(vid_files{j}));
        else
            moving=load(vid_files{j});
            %moving=double(moving.fixed);
            moving=double(moving.Y);
        end
        light=[];
        for k=1:size(fixed,3)
            light(k)=sum(fixed(:,:,k),'all');
        end
        prc=prctile(light,75);
        indices=find(light<prc);
        
        fixed_proj=double(max(fixed(:,:,indices),[],3));
        light=[];
        for k=1:size(fixed,3)
            light(k)=sum(moving(:,:,k),'all');
        end
        prc=prctile(light,75);
        indices=find(light<prc);
        
        moving_proj=max(moving(:,:,indices),[],3);
        
       
        registration=registration2d(fixed_proj,moving_proj);
        moving_proj_temp=deformation(moving_proj,registration.displacementField...
                ,registration.interpolation);
        figure('name','moving','Position', [10 10 900 600])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 900 600])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        
        %m denotes manual feature selection
        keep=input('Is registration acceptable? y/n/m ','s');
        %keep='y';
        while isequal(keep,'m')
        
            close all
            [fixed_mask,moving_mask]=manual_ROI_selection(fixed_proj,moving_proj);
            fixed_proj_temp=max(double(fixed_proj),max(max(fixed_proj))*double(fixed_mask));
            moving_proj_temp=max(moving_proj,max(max(moving_proj))*double(moving_mask));
            
       
            registration=registration2d(fixed_proj_temp,moving_proj_temp);
            moving_proj_im=deformation(moving_proj_temp,registration.displacementField...
                ,registration.interpolation);
            figure('name','moving','Position', [10 10 900 600])
            imagesc(moving_proj_im)
            colormap gray
            daspect([1,1,1])
            figure('name','fixed','Position', [10 10 900 600])
            imagesc(fixed_proj)
            colormap gray
            daspect([1,1,1])
            keep=input('Is registration acceptable? y/n/m ','s');
        end
        
        if isequal(lower(keep),'y')
            close all
            parfor k=1:size(moving,3)
                moving(:,:,k) = deformation(moving(:,:,k),...
                registration.displacementField,registration.interpolation);
            end
            moving=uint8(moving);
            fixed(:,:,size(fixed,3)+1:size(fixed,3)+size(moving,3))=moving;
            if j==i+6||j==length(vid_files)
                [filepath,name,ext]= fileparts(vid_files{i}) ;
                [filepath1,name1,ext1]= fileparts(vid_files{j}) ;
                Y=fixed;
                Ysiz=size(Y);
                save(horzcat('./higherdirectory/',name,'_',name1),'Y','Ysiz','-v7.3');
                i=j-1;
            end
        else
            [filepath,name,ext]= fileparts(vid_files{i}); 
            [filepath1,name1,ext1]= fileparts(vid_files{j-1}); 
            Y=fixed;
            Ysiz=size(Y);
            save(horzcat('./higherdirectory/',name,'_',name1),'Y','Ysiz','-v7.3');
            i=j-1;
            break
        end
    end
end
    