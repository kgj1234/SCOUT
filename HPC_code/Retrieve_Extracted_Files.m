%Load workspace corresponding to extraction prior to running


%% Check to see if extraction completed
%Check if extraction has finished, if so, move data back to local server
ssh2_conn=ssh2_config(Hostname,Username,Password);
ssh2_conn=ssh2_command(ssh2_conn,'qstat -u kgjohnst');
job_running=false;
for k=1:length(ssh2_conn.command_result)
    if length(strfind(ssh2_conn.command_result{k},num2str(job_num)))>0
        job_running=true;
    end
end

%Retrieve log files
failed=true;
try
    ssh2_conn=scp_get(ssh2_conn,{['batchendoscope.o',num2str(job_num)],...
    ['batchendoscope.e',num2str(job_num)]},'.','~/');
    
    data=txt_parser(['./','batchendoscope.e',num2str(job_num)]);
    for k=1:length(data)
        if findstr(data{k},'Job completed successfully')
            failed=false;
            break
        end
        
    end
    
end

%Find out if extraction completed successfully
cmd=['find ',Host_folder,' -name', ' "SCOUT_neuron.mat"'];
ssh2_conn=ssh2_command(ssh2_conn,cmd);
if length(ssh2_conn.command_result{1})>0
    failed=false;
end

if ~job_running
    if failed
        disp('Extraction Appears to have failed')
        retry=input('Attempt re-extraction? y/n: ','s');
        retrieve_anyway=input('Retrieve files anyway? y/n:','s');
        if isequal(retry,'y')
            ssh2_conn=scp_put(ssh2_conn,opt_path{end},Host_folder,loc_path);
            edit_sh_file([loc_path,'full_pipeline_hpc.sh'],Host_folder);
            ssh2_conn=scp_put(ssh2_conn,'full_pipeline_hpc.sh',host_path,loc_path);
            
            ssh2_conn=ssh2_command(ssh2_conn,['test -f ',[host_path,'full_pipeline_hpc'],' && echo "exists"']);

            if ~isempty(ssh2_conn.command_result{1})
                %Submit job
                cmd=['qsub ', [host_path,'full_pipeline_hpc.sh']];
                ssh2_conn=ssh2_command(ssh2_conn,cmd);
            else
                
                %Compile and run analysis code, this can take up to 30 minutes
                cmd=['bash ',[host_path,'compile_full_pipeline.sh']];
                ssh2_conn=ssh2_command(ssh2_conn,cmd);
            end
        end
    end
   if ~failed | (exist('retrieve_anyway','var')&isequal(retrieve_anyway,'y'))
        if ~failed
            disp('Extraction Succeeded')
        end
        try
            ext_path=regexp(extraction_folder,filesep,'split');
            for k=length(ext_path):-1:1
                if isempty(ext_path{k})
                    ext_path(k)=[];
                end
            end
            ext_path1='';
            if isunix
                ext_path1='/';
            end
            for k=1:length(ext_path)
                if ~isempty(ext_path{k});
                    
                    ext_path1=[ext_path1,ext_path{k},filesep];
                end
            end
            
            %Move data to local machine (This has to be run on the system to
            %retrieve folders recursively
            cmd=['find ',Host_folder,' -name', ' "motion_corrected"'];
            ssh2_conn=ssh2_command(ssh2_conn,cmd);
            if ~isempty(ssh2_conn.command_result{1})
                Host_folder=[Host_folder,'/motion_corrected'];
                if ispc %Requires putty
                    cmd=['pscp -P 22 -r ',Username,'@',Hostname,':',Host_folder,' ', ext_path1];
                else
                    cmd=['scp -r ',Username,'@',Hostname,':',Host_folder,' ', ext_path1];
                end
            else
                cmd=['find ',Host_folder,' -name', ' "extraction_1"'];
                ssh2_conn=ssh2_command(ssh2_conn,cmd);
                if ~isempty(ssh2_conn.command_result{1})
                    Host_folder=[Host_folder,'/extraction_1'];
                    if ispc %Requires putty
                        cmd=['pscp -P 22 -r ',Username,'@',Hostname,':',Host_folder,' ', ext_path1];
                    else
                        cmd=['scp -r ',Username,'@',Hostname,':',Host_folder,' ', ext_path1];
                    end
                else
                    error('Motion correction and extraction failed')
                end
            end
            system(cmd);
            delete_files=input('Delete files on remote computer (Make sure file download is complete and files are in the correct location)? y/n','s');
            if isequal(delete_files,'y')
                cmd=['rm -r ', Host_folder];
            
                ssh2_conn=ssh2_command(ssh2_conn,cmd);
            end
            
        end
    end
else
    disp('Code is still running')
    
end

ssh2_conn = ssh2_close(ssh2_conn);


