function []=Concatenated_Extraction_Cell_Tracking(vid_files,base_dir,batch_sizes,data_type,overlap_per_batch,threads,extraction_options,cell_tracking_options);
global_extraction_parameters.vid_files=vid_files;
global_extraction_parameters.base_dir=base_dir;
global_extraction_parameters.batch_sizes=batch_sizes;
global_extraction_parameters.data_type=data_type;
global_extraction_parameters.overlap_per_batch=overlap_per_batch;
global_extraction_parameters.threads=threads;
cd(base_dir)
folders=dir;
is_dir=cell2mat({folders.isdir});
folders={folders.name};
folders=folders(is_dir);
for i=length(folders):-1:1
    if length(strfind(folders{i},'extraction_'))==0
        folders(i)=[];
    end
end

if length(folders)==0
    mkdir('extraction_1')
    cd('extraction_1')
else
    disp('Previous Extractions Available, selecting a previous extraction will overwrite extraction parameters')
    while true
        try
            if length(folders)==1
                select_extraction=input(['Enter 1 to continue previous extraction',...
                ', or input ' num2str(length(folders)+1) ' for new extraction. Input should be an integer: ']);
            else
                
                select_extraction=input(['Input an extraction between ',num2str(1), ' and ' num2str(length(folders)),...
                ', or input ' num2str(length(folders)+1) ' for new extraction. Input should be an integer: ']);
            end
            break
        catch
            disp('Input should be an integer')
        end
    end
    if select_extraction<=length(folders)
        cd(['extraction_',num2str(select_extraction)])
        try
            load(fullfile('.','global_extraction_parameters'),'global_extraction_parameters')
            load(fullfile('.','extraction_options'),'extraction_options')
            load(fullfile('.','cell_tracking_options'),'cell_tracking_options')
        end
    else
        mkdir(['extraction_',num2str(length(folders)+1)])
        cd(['extraction_',num2str(length(folders)+1)])
    end
    
end
try
    cell_tracking_options=rmfield(cell_tracking_options','links');
end

save('global_extraction_parameters','global_extraction_parameters')
save('extraction_options','extraction_options')
save('cell_tracking_options','cell_tracking_options')



if ~isfolder('extraction_recordings')
    mkdir('extraction_recordings')
    cd('extraction_recordings')
    for k=1:length(vid_files)
        Y1=[];
        for j=1:length(vid_files{k});
            try
                load(fullfile('../','../',vid_files{k}{j}),'Y')
            catch
                error(['Incorrect File Format for', vid_files{k}{j}])
            end
            Y1=cat(3,Y1,Y);
        end
        Y=Y1;
        Ysiz=size(Y);
        save(['concatenated_video',num2str(k)],'Y','Ysiz','-v7.3');
        
    end
    cd ../
end
Y=[];
Y1=[];

try 
    load(fullfile('.','neurons'));
catch
    neurons=cell(1,length(vid_files));
end

if ~(exist(fullfile('.','log.txt'), 'file') == 2)
    %initialize log file
    log = fopen( fullfile('.','log.txt'), 'wt' );
    fclose(log);
end


 
        


tic


total_empty=0;
for i=1:length(neurons)
    if isempty(neurons{i})
        total_empty=total_empty+1;
    end
end
extract_iter=1;
if isfield(global_extraction_parameters,'threads')
    delete(gcp('nocreate'))
    parpool(global_extraction_parameters.threads);
end

while total_empty>0 & extract_iter<=3
    parfor i=1:length(neurons)
        if isempty(neurons{i})
            try
                    disp(strcat('batch',num2str(i),'initialization'))
                    if isequal(data_type,'1p')
                        neurons{i}=full_demo_endoscope(fullfile('.','extraction_recordings',['concatenated_video',num2str(i),'.mat']),extraction_options);
                    elseif isequal(data_type,'2p')
                        neurons{i}=full_demo_endoscope_2p(fullfile('.','extraction_recordings',['concatenated_video',num2str(i),'.mat']),extraction_options);
                    end
                    log = fopen( 'log.txt', 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'successful\n']);
                    fclose(log);
                catch ME
                    
                    msgText = getReport(ME);
                    log = fopen( 'log.txt', 'a' );
                    fprintf(log,['extraction of recording', num2str(i), 'unsuccessful\n ',msgText,'\n']);
                    
                    fclose(log);
                end
        end
    end
    total_empty=0;
    for i=1:length(neurons)
        if isempty(neurons{i})
            total_empty=total_empty+1;
        end
    end
    extract_iter=extract_iter+1;
    save('neurons','neurons','-v7.3');
end
save('neurons','neurons','-v7.3')
if total_empty>0
    error('Not all recording extracted')
end


if isequal(data_type,'1p')
for i=1:length(neurons)
    neurons{i}.MergeNeighbors([2,15]);

end
end

if cell_tracking_options.overlap>0
    neuron=Combine_Full_Experiment(neurons,global_extraction_parameters,cell_tracking_options);
else
    neuron=cellTracking_SCOUT(neurons,'links',[],'cell_tracking_options',cell_tracking_options);
end

save('neuron_SCOUT','neuron','-v7.3')

toc
