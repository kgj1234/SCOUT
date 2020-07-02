function video_registration_main(use_non_rigid,base_index,projection_type,automatic,projection_paths)
%Modifies vid_files listed in current folder to match the file at index base_index in vid_path

%For example, use this code to consecutively align videos in a folder, or align all videos to a baseline.

%n -no, y - yes, m - manual intervention

%projection paths is an optional input indicating where previously extracted recording templates
%are stored. These should be stored as .mat files

%projection_type indicates method to create templates (if projection paths
%is not provided. Options 'max','correlation'

%use_non_rigid- booleans indicating whether to apply non-rigid
%transformations

close all
%Identify files in folder with extensions possibly indicating video files
if ~exist('use_non_rigid','var') || isempty(use_non_rigid)
    use_non_rigid=false;
end
if ~exist('projection_type','var')||isempty(projection_type)
    projection_type='max';
end

if ~exist('base_index','var')||isempty(base_index)
    base_index=1;
end
if ~exist('automatic','var')||isempty(automatic);
    automatic=false;
end


vid_paths=dir;

vid_paths={vid_paths.name};
for i=1:length(vid_paths)
    [~,name,ext]=fileparts(vid_paths{i});
    if (~isequal(ext,'.mat') && ~isequal(ext,'.avi'))||isequal(name,'.dir')||isequal(name,'dir')
        del_ind(i)=1;
    end
end
vid_paths(find(del_ind))=[];
disp(vid_paths)



%Load video files
for i=1:length(vid_paths)
    [~,~,ext]=fileparts(vid_paths{i});
    if isequal(ext,'.mat')
        Y=struct2cell(load(vid_paths{i}));
        vids{i}=Y{1};
    else
        v=VideoReader(vid_paths{i});
        vids{i}=v.read();
    end
    if length(size(vids{i}))==4
          vids{i}=squeeze(max(vids{i},[],3));
    end
end

%Load projections if available
if ~exist('projection_paths','var')||isempty(projection_paths)
    projections={};
else
    for i=1:length(projection_paths)
        projection_paths=dir(projection_paths);
        projection_paths=projection_paths.name;
        projections={};
        for k=1:length(projection_paths)
            [path,name,ext]=fileparts(projection_paths{k});
            if isequal(ext,'.mat')
                try
                    project=struct2cell(load(projection_paths{k}));
                    projections{end+1}=project{1};
                end
            end
        end
       
    end
    if length(projections)~=length(vids)
        projections={};
    end
end
if length(projections)==0
    if isequal(projection_type,'max')
        for i=1:length(vid_paths)
            [Ydt, X, R] = detrend_data(reshape(double(vids{i}),[],size(vids{i},3)),4);
            Ydt=reshape(Ydt,size(vids{i},1),size(vids{i},2),[]);
            projections{i}=max(Ydt,[],3);
        end
    else
        projections=construct_correlation_template_main();
    end
end



aligned={};
aligned{base_index}=vids{base_index};
nonempty=1;
while  nonempty<length(vid_paths)
    while true
        [~,indices]=number_nonempty(aligned);
        indices_string='';
        for i=1:length(indices)
            indices_string=strcat(indices_string,' ',num2str(indices(i)));
        end
        if automatic
            base_selection=base_index;
        else    
            base_selection=input(strcat('select video index to be used as base, ',indices_string,': '),'s');
        end
        try
            if ischar(base_selection)
                base_selection=str2num(base_selection);
            end
            if any(indices==base_selection)
                break
            end
        end
    end
    fixed=double(aligned{base_selection});
    unaligned=setdiff(1:length(vid_paths),indices);
    while true
       
        indices_string='';
        for i=1:length(unaligned)
            indices_string=strcat(indices_string,' ',num2str(unaligned(i)));
        end
        if automatic
            alter_selection=unaligned(1);
        else
            alter_selection=input(strcat('select video index to alter, ',indices_string,': '),'s');
        end
        try
            if ischar(alter_selection)
                alter_selection=str2num(alter_selection);
            end
            if any(unaligned==alter_selection)
                break
            end
        end
    end
    moving=double(vids{alter_selection});
    
    fixed_proj=double(projections{base_selection});
    moving_proj=double(projections{alter_selection});
    if isequal(projection_type,'correlation')
        fixed_proj(fixed_proj<.15)=0;
        moving_proj(moving_proj<.15)=0;
    end
    try
        R=imref2d(size(fixed_proj));
        [optimizer, metric] = imregconfig('multimodal');
        tform=imregtform(moving_proj,fixed_proj,'translation',optimizer,metric);
        moving_reg=imwarp(moving_proj,tform,'OutputView',R);
        tform1=imregtform(moving_reg,fixed_proj,'affine',optimizer,metric);
        moving_reg1=imwarp(moving_reg,tform1,'OutputView',R);
        
    catch
        registration=registration2d(fixed_proj,moving_proj,'transformationModel','translation');
        moving_reg=registration.deformed;
        registration1=registration2d(fixed_proj,moving_reg,'transformationModel','affine');
        moving_reg1=registration1.deformed;
    end
    if use_non_rigid
        registration2=registration2d(fixed_proj,moving_reg1,'transformationModel','non-rigid');
        moving_reg_nonrigid=registration2.deformed;
        moving_proj_temp=moving_reg_nonrigid;
    else
        moving_proj_temp=moving_reg1;
    end
    
   
    
    
    figure('name','moving','Position', [10 10 200 200])
    imagesc(moving_proj_temp)
    colormap gray
    daspect([1,1,1])
    figure('name','fixed','Position', [10 10 200 200])
    imagesc(fixed_proj)
    colormap gray
    daspect([1,1,1])
    
    %m denotes manual feature selection
    if automatic
        keep='y';
    else
        keep=input('Is registration acceptable? y/n/m ','s');
    end
 
    while isequal(keep,'m')
        
       
        [fixed_mask,moving_mask]=manual_ROI_selection(fixed_proj,moving_proj);
        for i=1:length(fixed_mask)
            s=regionprops(fixed_mask{i},'centroid');
            centroid_1(i,:)=s.Centroid;
            s=regionprops(moving_mask{i},'centroid');
            centroid_2(i,:)=s.Centroid;
        end
        diff=centroid_2-centroid_1;
        diff=mean(diff,1);
        
        moving_proj_new=imtranslate(moving_proj,-1*diff);
         try
            R=imref2d(size(fixed_proj));
            [optimizer, metric] = imregconfig('multimodal');
            tform=imregtform(moving_proj_new,fixed_proj,'translation',optimizer,metric);
            moving_reg=imwarp(moving_proj_new,tform,'OutputView',R);
            tform1=imregtform(moving_reg,fixed_proj,'affine',optimizer,metric);
            moving_reg1=imwarp(moving_reg,tform1,'OutputView',R);

        catch
            registration=registration2d(fixed_proj,moving_proj_new,'transformationModel','translation');
            moving_reg=registration.deformed;
            registration1=registration2d(fixed_proj,moving_reg,'transformationModel','affine');
            moving_reg1=registration1.deformed;
        end
        if use_non_rigid
            registration2=registration2d(fixed_proj,moving_reg1,'transformationModel','non-rigid');
            moving_reg_nonrigid=registration2.deformed;
            moving_proj_temp=moving_reg_nonrigid;
        else
            moving_proj_temp=moving_reg1;
        end
   
        
        figure('name','moving','Position', [10 10 200 200])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 200 200])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        keep=input('Is registration acceptable? y/n/m ','s');
    end
    
    
    
    
    
    if isequal(lower(keep),'y')
        if exist('diff','var');
            parfor k=1:size(moving,3);
                moving(:,:,k)=imtranslate(moving(:,:,k),-1*diff);
            end
            clear diff
        end
        
        
            if exist('tform','var')
                parfor k=1:size(moving,3)
                    moving(:,:,k)=imwarp(moving(:,:,k),tform,'OutputView',R);
                    moving(:,:,k)=imwarp(moving(:,:,k),tform1,'OutputView',R);
                end
            else
                parfor k=1:size(moving,3)
                moving(:,:,k) = deformation(double(moving(:,:,k)),...
                registration.displacementField,registration.interpolation);
                moving(:,:,k) = deformation(double(moving(:,:,k)),...
                registration1.displacementField,registration1.interpolation);
                end
            end
            if use_non_rigid
                parfor k=1:size(moving,3)
                moving(:,:,k)=deformation(double(moving(:,:,k)),...
                registration2.displacementField,registration2.interpolation);
                end
            end
        
        moving=uint8(moving);
        projections{alter_selection}=moving_proj_temp;
  
        disp('registration accepted')
        aligned{alter_selection}=moving;
  
    end
    if automatic
        saver='n';
    else
        saver=input('save current aligned files, and end session? y/n ','s');
    end
    if isequal(saver,'y')
        saved_files={};
        for i=1:length(aligned)
            Y=uint8(aligned{i});
            if ~isempty(Y)
                Ysiz=size(Y);
                [path,name,ext]=fileparts(vid_paths{i});
                name=[name,'_registered'];
                save(fullfile(path,name),'Y','Ysiz','-v7.3');
                try
                template=projections{i};
                save(projection_paths{i},'template')
                end
                saved_files{i}=vid_paths{i};
            end
        end
        disp('saved files')
        disp(saved_files)
        return
    end
    
    [nonempty,indices]=number_nonempty(aligned);
    close all
end
for i=1:length(projections)
    figure()
    imagesc(projections{i});
    colormap gray
    daspect([1,1,1])
end



saved_files={};
for i=1:length(aligned)
    Y=uint8(aligned{i});
    Ysiz=size(Y);
    [path,name,ext]=fileparts(vid_paths{i});
    name=[name,'_registered'];
    save(fullfile(path,name),'Y','Ysiz','-v7.3');
    saved_files{i}=vid_paths{i};
end
try
for i=1:length(aligned)
    template=projections{i};
    save(projection_paths{i},'template')
end
end



disp('saved files')
disp(saved_files)




        
        
        