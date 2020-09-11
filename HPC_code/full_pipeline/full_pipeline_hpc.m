function full_pipeline_hpc()

data=txt_parser('~/SCOUT/HPC_code/full_pipeline/full_pipeline_options.txt');

for k=1:length(data)
    try
        eval(data{k});
    end
end
cd(base_dir);
vids=dir;
filename={vids.name};
filename(1:2)=[];

for k=1:length(filename)
    try
    if background_subtract
        m=background_subtraction(filename{k});
	Yfilter=m.reg;
        Yfilter=uint8(Yfilter/max(Yfilter(:))*255);
        Y=uint8(m.orig*255);
        Y=runrigid3(Yfilter,Y);
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
if register_sessions
    video_registration_main(true,1,'correlation',true);
    
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

BatchEndoscopeWrapper('./',vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options);
