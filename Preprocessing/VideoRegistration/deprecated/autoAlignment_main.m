function moving_proj_temp=autoAlignment_adj_Steve(fixed_index)
%Modifies vid_files in current folder to the index of the file indicated by fixed_index

%For example, use this code to consecutively align videos in a folder, or align all videos to a baseline.




%n -no, y - yes, m - manual intervention

%Extract file names from directory
vid_files=dir;
vid_files={vid_files.name};
vid_files(1:2)=[];
lower_vids=lower(vid_files);
[~,ind]=sort(lower_vids);
vid_files=vid_files(ind);
vids={};

for i=1:length(vid_files)
    if isfile(vid_files{i})&~isequal(vid_files{i},'.dir.mat')
        vids{end+1}=vid_files{i};
    end
end
%Construct templates
construct_correlation_template_main();
templates=dir('./templates');
templates={templates.name};
projection_paths={};
for i=1:length(templates)
    if isfile(['./templates/',templates{i}])&&~isequal(templates{i},'.dir.mat')
    projection_paths{end+1}=['./templates/',templates{i}];
    end
end


vid_paths=vids;


close all
if ~exist('fixed_index','var')||isempty(fixed_index)
    fixed_index=length(projection_paths);
end
for i=1:length(vid_paths)
    Y=load(vid_paths{i});
    try
    vids{i}=Y.Y;
    catch
        vids{i}=Y.current;
    end
    
    
end
for i=1:length(projection_paths)
    project=struct2cell(load(projection_paths{i}));
    projections{i}=project{1};
end


aligned={};
aligned{fixed_index}=vids{fixed_index};
nonempty=1;
while  nonempty<length(vid_paths)
    while true
        [~,indices]=number_nonempty(aligned);
        indices_string="";
        for i=1:length(indices)
            indices_string=strcat(indices_string,' ',string(indices(i)));
        end
	%switch these if you want to manually select the video used as reference
        %base_selection=input(strcat('select video index to be used as base, ',indices_string,': '),'s');
        base_selection=num2str(fixed_index);
        try
            base_selection=str2num(base_selection);
            if any(indices==base_selection)
                break
            end
        end
    end
    fixed=double(aligned{base_selection});
    unaligned=setdiff(1:length(vid_paths),indices);
%     while true
%        
%         indices_string="";
%         for i=1:length(unaligned)
%             indices_string=strcat(indices_string,' ',string(unaligned(i)));
%         end
%         alter_selection=input(strcat('select video index to alter, ',indices_string,': '),'s');
%         try
%             alter_selection=str2num(alter_selection);
%             if any(unaligned==alter_selection)
%                 break
%             end
%         end
%     end
    for q=unaligned
        alter_selection=q;
    moving=double(vids{alter_selection});
    
    
    
    
    
    
    %Attempt to automatically register recordings
 
    fixed_proj=projections{base_selection};
    moving_proj=projections{alter_selection};
    fixed_proj(fixed_proj<.75)=0;
    moving_proj(moving_proj<.75)=0;
    registration1=registration2d(fixed_proj,moving_proj,'transformationModel','translation');
    moving_proj_temp=imtranslate(moving_proj,-1*[registration1.transformationMatrix(1,3), registration1.transformationMatrix(2,3)],'FillValues',0);
    registration2=registration2d(fixed_proj,moving_proj_temp,'transformationModel','non-rigid');
    
    registration3=[];
    moving_proj_temp=deformation(moving_proj_temp,registration2.displacementField...
        ,registration2.interpolation);
    
    
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
    if isequal(keep,'m')
        %Manually select features from both templates for registration
        
        [fixed_mask,moving_mask]=manual_ROI_selection(fixed_proj,moving_proj);
        for i=1:length(fixed_mask)
            s=regionprops(fixed_mask{i},'centroid');
            centroid_1(i,:)=s.Centroid;
            s=regionprops(moving_mask{i},'centroid');
            centroid_2(i,:)=s.Centroid;
        end
        diff=centroid_2-centroid_1;
        diff=mean(diff,1);
        
        moving_proj_temp=imtranslate(moving_proj,-1*diff);
        
        
        registration1=[];
        registration2=[];
        

        registration3=registration2d(fixed_proj,moving_proj_temp,'transformationModel','non-rigid');
        moving_proj_temp=deformation(moving_proj_temp,registration3.displacementField...
           ,registration3.interpolation);
        figure('name','moving','Position', [10 10 200 200])
        imagesc(moving_proj_temp)
        colormap gray
        daspect([1,1,1])
        figure('name','fixed','Position', [10 10 200 200])
        imagesc(fixed_proj)
        colormap gray
        daspect([1,1,1])
        keep=input('Is registration acceptable? y/n/m ','s');
        %keep='y';
    end
    
    
    
    
    
    if isequal(lower(keep),'y')
        if exist('diff','var');
            parfor k=1:size(moving,3);
                moving(:,:,k)=imtranslate(moving(:,:,k),-1*diff);
           
            
            if ~isempty(registration3)
             moving(:,:,k) = uint8(deformation(double(moving(:,:,k)),...
                registration3.displacementField,registration3.interpolation));  
            end
            end
            clear diff
        end
        if ~isempty(registration1)
        parfor k=1:size(moving,3)
            moving(:,:,k) = imtranslate(double(moving(:,:,k)),-1*[registration1.transformationMatrix(1,3), registration1.transformationMatrix(2,3)],'FillValues',0);
   
            
            moving(:,:,k)=uint8(deformation(double(moving(:,:,k)),...
                registration2.displacementField,registration2.interpolation));
            
        end
        end
        projections{alter_selection}=moving_proj_temp;
  
        disp('registration accepted')
        aligned{alter_selection}=moving;
  
    end
    
    %saver=input('save current aligned files, and end session? y/n ','s');
    saver='n';
    if isequal(saver,'y')
        saved_files={};
        for i=1:length(aligned)
            Y=uint8(aligned{i});
            if ~isempty(Y)
                Ysiz=size(Y);
                save(vid_paths{i},'Y','Ysiz','-v7.3');
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
    save(vid_paths{i},'Y','Ysiz','-v7.3');
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

