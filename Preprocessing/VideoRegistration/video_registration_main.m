function video_registration_main(use_non_rigid,base_index,projection_type,automatic,projection_dir,data_type)
%Modifies vid_files listed in current folder to match the file at index base_index in vid_path

%For example, use this code to consecutively align videos in a folder, or align all videos to a baseline.

%n -no, y - yes, m - manual intervention

%projection paths is an optional input indicating where previously extracted recording templates
%are stored. These should be stored as .mat files

%projection_type indicates method to create templates (if projection paths
%is not provided. Options 'max','correlation'

%use_non_rigid- booleans indicating whether to apply non-rigid
%transformations

%automated (bool) indicates whether to auto accept registration

%data_type (str) '1p' or '2p'

%%Author Kevin Johnston

%%

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
if ~exist('data_type','var')||isempty(data_type)
    data_type='1p';
end
registration_methods={'translation','affine'};
if use_non_rigid
    registration_methods{end+1}='non-rigid';
end

vid_paths=dir;

vid_paths={vid_paths.name};
for i=1:length(vid_paths)
    [~,name,ext]=fileparts(vid_paths{i});
    if (~isequal(ext,'.mat') && ~isequal(ext,'.avi'))||isequal(name,'.dir')||isequal(ext,'.m')
        del_ind(i)=1;
    end
end
vid_paths(find(del_ind))=[];
disp(vid_paths)



%Load video files
for i=1:length(vid_paths)
    [path,name,ext]=fileparts(vid_paths{i});
    if isequal(ext,'.mat')
        Y=struct2cell(load(vid_paths{i}));
        vids{i}=Y{1};
    elseif isequal(ext,'.avi')
        v=VideoReader(vid_paths{i});
        vids{i}=v.read();
    else
        error('Video filetype not supported')
    end
    if length(size(vids{i}))==4
          vids{i}=squeeze(max(vids{i},[],3));
          Y=vids{i};
          Ysiz=size(Y);
          save(fullfile(path,[name,'.mat']),'Y','Ysiz','-v7.3')
          vid_paths{i}=fullfile(path,[name,'.mat']);
          
    end
end

%Load projections if available
if ~exist('projection_dir','var')||isempty(projection_dir)
    projections={};
else
        projection_paths=dir(projection_dir);
        projection_paths={projection_paths.name};
        proj_lower=lower(projection_paths);
        [~,ind]=sort_nat(proj_lower);
        projection_paths=projection_paths(ind);
        
        
        projections={};
        for k=1:length(projection_paths)
            [path,name,ext]=fileparts(projection_paths{k});
            path=projection_dir;
            if isequal(ext,'.mat')&~isequal(projection_paths{k},'.dir.mat')
                try
                    project=struct2cell(load(fullfile(path,projection_paths{k})));
                    projections{end+1}=project{1};
                end
            end
        end
       
    
    if length(projections)~=length(vids)
        projections={};
    end
end
if length(projections)==0
    if isequal(projection_type,'max')
        
        vids_lower=lower(vid_paths);
        [~,ind]=sort_nat(vids_lower);
        vid_paths=vid_paths(ind);
        for i=1:length(vid_paths)
            
            [Ydt, ~,~] = detrend_data(reshape(double(vids{i}),[],size(vids{i},3)),4);
            Ydt=reshape(Ydt,size(vids{i},1),size(vids{i},2),[]);
            
            projections{i}=double(max(Ydt,[],3));
            Ydt=[];
           
        end
    else
        
        projections=construct_correlation_template_main(data_type,vid_paths);
    end
end

mkdir registered
cd registered

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
%     if isequal(projection_type,'correlation')
%         fixed_proj(fixed_proj<.08)=0;
%         moving_proj(moving_proj<.08)=0;
%     end
    [moving_proj_temp,registrations]=register_projections(moving_proj,fixed_proj,registration_methods);
    
   
    
    
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
    iter=1;
    while isequal(keep,'m')
        registrations={};
        
%         [fixed_mask,moving_mask]=manual_ROI_selection(fixed_proj,moving_proj);
%         try
%         for i=1:length(fixed_mask)
%             s=regionprops(fixed_mask{i},'centroid');
%             centroid_1(i,:)=s.Centroid;
%             s=regionprops(moving_mask{i},'centroid');
%             centroid_2(i,:)=s.Centroid;
%         end
%         diff=centroid_2-centroid_1;
%         diff=mean(diff,1);
%         catch
%             diff=[0,0];
%         end
%         moving_proj_new=imtranslate(moving_proj,-1*diff);
%         reg1=affine2d;
%         reg1.T=[1,0,0;0,1,0;-1*diff(1),-1*diff(2),1];
%         reg1={reg1};
        close all
        figure('Name','Moving')
        imagesc(moving_proj)
        colormap gray
        figure('Name','Fixed')
        imagesc(fixed_proj)
        colormap gray
        [mp,fp] = cpselect(moving_proj,fixed_proj,'Wait',true);
        reg1{1}=fitgeotrans(mp,fp,'projective');
        R=imref2d(size(fixed_proj));
        moving_proj_new=imwarp(moving_proj,reg1{1},'OutputView',R);
 
        if use_non_rigid
            
            [moving_proj_temp,registrations]=register_projections(moving_proj_new,fixed_proj,{'non-rigid'});
        else
            [moving_proj_temp,registrations]=register_projections(moving_proj_new,fixed_proj,registration_methods);
        end
   
        figure('Name','moving_proj_new')
        imagesc(moving_proj_new)
        colormap gray
        
        figure('Name','moving_proj_refined')
        imagesc(moving_proj_temp)
        colormap gray
        
        keep_refine=input('Keep refined? y/n ','s');
        if isequal(keep_refine,'y')
            for k=1:length(registrations)
                reg1{end+1}=registrations{k};
            end
            registrations=reg1;
        else
            moving_proj_temp=moving_proj_new;
            registrations=reg1;
        end
        close all
        
        figure('name','moving','Position', [10 10 200 200])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 200 200])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        keep=input('Is registration acceptable? y/n/m ','s');
        iter=iter+1;
    end
    
    
    
    
    
     if isequal(lower(keep),'y')
        R=imref2d(size(fixed_proj));
        parfor k=1:size(moving,3)
            for p=1:length(registrations)
                if isequal(class(registrations{p}),'affine2d')||isequal(class(registrations{p}),'projective2d')
                    moving(:,:,k)=imwarp(double(moving(:,:,k)),registrations{p},'OutputView',R);
                else
                    moving(:,:,k)=deformation(double(moving(:,:,k)),...
                        registrations{p}.displacementField,registrations{p}.interpolation);
                end
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
                %name=[name,'_registered'];
                save(fullfile(path,name),'Y','Ysiz','-v7.3');
                
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
    %name=[name,'_registered'];
    save(fullfile(path,name),'Y','Ysiz','-v7.3');
    saved_files{i}=vid_paths{i};
end



disp('saved files')
disp(saved_files)




        
        
        