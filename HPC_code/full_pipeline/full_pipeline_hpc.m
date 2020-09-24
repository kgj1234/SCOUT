<<<<<<< HEAD
function full_pipeline_hpc(base_dir)

try
    data=txt_parser(fullfile(base_dir,'full_pipeline_options.txt'));

    disp('Detected options folder in base directory')
catch
    data=txt_parser('~/SCOUT/HPC_code/full_pipeline/full_pipeline_options.txt');
    disp('Using default options')
end
=======
function full_pipeline_hpc()

data=txt_parser('~/SCOUT/HPC_code/full_pipeline/full_pipeline_options.txt');
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa

for k=1:length(data)
    try
        eval(data{k});
    end
end
<<<<<<< HEAD
parpool(min(12,threads));

cd(base_dir);


if motion_correct
=======
cd(base_dir);
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
vids=dir;
filename={vids.name};
filename(1:2)=[];

for k=1:length(filename)
    try
<<<<<<< HEAD
    	VI=who('-file',filename{k});
    catch
        VI={};
    end
    if ismember('Y',VI)|ismember('Mr',VI);
    if background_subtract
	iter=1;
	while iter<10
            try
                m=background_subtraction(filename{k},true);
                break
            catch ME 
                disp(ME)
            	iter=iter+1;
            end
	end
	
	Yfilter=m.reg;
        Yfilter=uint8(Yfilter/max(Yfilter(:))*255);
        Y=uint8(m.orig*255);
	if from_filtered
            Y=runrigid3(Yfilter,Yfilter);
	else
	    Y=runrigid3(Yfilter,Y);
	end
=======
    if background_subtract
        m=background_subtraction(filename{k});
	Yfilter=m.reg;
        Yfilter=uint8(Yfilter/max(Yfilter(:))*255);
        Y=uint8(m.orig*255);
        Y=runrigid3(Yfilter,Y);
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
        if save_file
            Ysiz=size(Y);
            [path,name,ext]=fileparts(filename{k});
            mkdir(fullfile(path,'motion_corrected'))
            if ~isempty(path)
                save(fullfile(path,'motion_corrected',[name,'_motion_corrected','.mat']),'Y','Ysiz','-v7.3')
            else
                save(fullfile('.','motion_corrected',[name,'_motion_corrected','.mat']),'Y','Ysiz','-v7.3')
            end
        end
    else
        runrigid2(filename{k},conv_uint8,save_file);
    end
    end
end
cd motion_corrected
<<<<<<< HEAD
end


if register_sessions
    video_registration_main(true,1,'max',true);
=======
if register_sessions
    video_registration_main(true,1,'correlation',true);
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
    
end


extraction_options_struct=struct;
for k=1:length(extraction_options)/2
    extraction_options_struct=setfield(extraction_options_struct,...
        extraction_options{2*k-1},extraction_options{2*k});
end
extraction_options=extraction_options_struct;

cell_tracking_options_struct=struct;
for k=1:length(cell_tracking_options)/2
    if length(cell_tracking_options{2*k})>1 & isequal(class(cell_tracking_options{2*k}),'cell')
        temp={};
        for j=1:length(cell_tracking_options{2*k})
            temp{end+1}=cell_tracking_options{2*k}{j};
        end
        cell_tracking_options_struct=setfield(cell_tracking_options_struct,...
            cell_tracking_options{2*k-1},temp);
    else
        cell_tracking_options_struct=setfield(cell_tracking_options_struct,...
            cell_tracking_options{2*k-1},cell_tracking_options{2*k});
    end
end
cell_tracking_options=cell_tracking_options_struct;
<<<<<<< HEAD
try
    rmdir('./extraction_1','s')
end

if extract_videos
    BatchEndoscopeWrapper('./',vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options);
end
delete(gcp('nocreate'))
error('Job completed successfully')
end
=======

BatchEndoscopeWrapper('./',vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options);
>>>>>>> 1b79ac8f015244c3f87d381b6f04f384c54ab5aa
