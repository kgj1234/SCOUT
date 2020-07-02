function []=save_temp_file_single(base_dir,vid_files)


if ~isfile([base_dir,'temp/neuron','.mat'])
    Y1=[];
    for j=1:length(vid_files)
        load(fullfile(base_dir,vid_files{j}));
        Y1=cat(3,Y1,Y);
    end
    
    Y=Y1;
    Ysiz=size(Y);
    
    
    if ~isfile([base_dir,'temp/neuron','.mat'])
        save([base_dir,'/temp/neuron'],'Y','Ysiz','-v7.3')
    end
    clear Y
end