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
try
    ssh2_conn=scp_get(ssh2_conn,{['batchendoscope.o',num2str(job_num)],...
    ['batchendoscope.e',num2str(job_num)]},'.','~/');
end

%Find out if extraction completed successfully
cmd=['find ',Host_folder,' -name', ' "SCOUT_neuron.mat"'];
ssh2_conn=ssh2_command(ssh2_conn,cmd);
if length(ssh2_conn.command_result{1})==0
    failed=true;
else
    failed=false;
end

if ~job_running
    if failed
        disp('Extraction Failed')
        retry=input('Attempt re-extraction? y/n: ','s');
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
        
    else
        disp('Extraction Succeeded')
        try
            ext_path=regexp(extraction_folder,filesep,'split');
            ext_path1='';
            if isunix
                ext_path1='/';
            end
            for k=1:length(ext_path)-1
                if ~isempty(ext_path{k});
                    
                    ext_path1=[ext_path1,ext_path{k},filesep];
                end
            end
            %Delete reg.mat and frame_all.mat files
            ssh2_conn=ssh2_command(ssh2_conn,['rm ',Host_folder,'/*reg.mat']);
            ssh2_conn=ssh2_command(ssh2_conn,['rm ',Host_folder,'/*frame_all.mat']);
            
            %Move data to local machine (This has to be run on the system to
            %retrieve folders recursively
            if ispc %Requires putty
                cmd=['pscp -P 22 -r ',Username,'@',Hostname,':',Host_folder,' ', ext_path1];
            else
                cmd=['scp -r ',Username,'@',Hostname,':',Host_folder,' ', ext_path1];
            end
            system(cmd);
            
            cmd=['rm -r ', Host_folder];
            
            ssh2_conn=ssh2_command(ssh2_conn,cmd);
            
        end
    end
else
    disp('Code is still running')
    
end

ssh2_conn = ssh2_close(ssh2_conn);


