function []=Concatenated_Extraction_Cell_Tracking(vid_files,base_dir,batch_sizes,data_type,extraction_options,cell_tracking_options);
global_extraction_parameters.vid_files=vid_files;
global_extraction_parameters.base_dir=base_dir;
global_extraction_parameters.batch_sizes=batch_sizes;
global_extraction_parameters.data_type=data_type;


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
    cell_tracking_opttions=rmfield(cell_tracking_options,'links');
end
save('global_extraction_parameters','global_extraction_parameters','-v7.3')
save('extraction_options','extraction_options','-v7.3')
save('cell_tracking_options','cell_tracking_options','-v7.3')



if ~isfolder('connecting_recordings')
    mkdir('connecting_recordings')
    cd('connecting_recordings')
    for k=1:length(vid_files)-1
        try
        load(fullfile('..','..',vid_files{k}{1}),'Y');
        Y1=Y(:,:,end-cell_tracking_options.overlap+1:end);
        load(fullfile('..','..',vid_files{k+1}{1}),'Y');
        Y1=cat(3,Y1,Y(:,:,1:cell_tracking_options.overlap+1));
        catch
            error('Error loading files')
        end
        Y=Y1;
        Ysiz=size(Y);
        save(['connecting_recording',num2str(k)],'Y','Ysiz','-v7.3');
    end
    cd ../
end

try 
    load(fullfile('.','neurons'));
catch
    neurons=cell(1,length(vid_files));
end

try
    load(fullfile('.','links'));
catch
    links=cell(1,length(vid_files)-1);
end
if cell_tracking_options.overlap==0
    links=[];
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
while total_empty>0 & extract_iter<=3
    for i=1:length(vid_files)+length(links)
            if i<=length(vid_files)&isempty(neurons{i})
                try
                    disp(strcat('session',num2str(i),'initialization'))
                    if isequal(data_type,'1p')
                        
                        neurons{i}=full_demo_endoscope(fullfile('..',vid_files{i}{1}),extraction_options);
                    elseif isequal(data_type,'2p')
                        neurons{i}=full_demo_endoscope_2p(fullfile('..',vid_files{i}{1}),extraction_options);
                    else
                        error('invalid datatype')
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
            elseif i>length(vid_files) &isempty(links{i-length(neurons)})
                 try
                    disp(strcat('session',num2str(i),'initialization'))
                    if isequal(data_type,'1p')
                        
                        links{i-length(neurons)}=full_demo_endoscope(fullfile('connecting_recordings',...
                            ['connecting_recording',num2str(i-length(neurons))]),extraction_options);
                    elseif isequal(data_type,'2p')
                        links{i-length(neurons)}=full_demo_endoscope_2p(fullfile('connecting_recordings',...
                            ['connecting_recording',num2str(i-length(neurons))]),extraction_options);
                    else
                        error('invalid datatype')
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
    extract_iter=extract_iter+1;
    total_empty=0;
    for i=1:length(neurons)
        if isempty(neurons{i})
            total_empty=total_empty+1;
        end
    end
    for i=1:length(links)
        if isempty(links{i})
            total_empty=total_empty+1;
        end
    end
    
    save('neurons','neurons','-v7.3')
    save('links','links','-v7.3')
end
save('neurons','neurons','-v7.3')
save('links','links','-v7.3')

%Optional extra merging on links
if isequal(data_type,'1p')
for i=1:length(links)
    links{i}.MergeNeighbors([2,15]);
    links{i}.remove_false_positives(false,true);
end
end


if total_empty>0
    error('Not all recordings extracted')
end

cell_tracking_options.links=links;
neuron=cellTracking_SCOUT(neurons,'cell_tracking_options',cell_tracking_options);

save('SCOUT_neuron','neuron')

toc
