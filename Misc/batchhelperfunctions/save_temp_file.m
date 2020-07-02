function []=save_temp_file(base_dir,vid_files,index,overlap)


if ~isfile([base_dir,'temp/neuron',num2str(index),'.mat'])
    Y1=[];
    for j=1:length(vid_files)
        load(fullfile(base_dir,vid_files{j}));
        Y1=cat(3,Y1,Y);
    end
    
    Y=cat(3,Y1,Y1(:,:,1:overlap+1));
    clear Y1
    Ysiz=size(Y);
    
    
    if ~isfile([base_dir,'temp/neuron',num2str(index),'.mat'])
        save([base_dir,'/temp/neuron',num2str(index)],'Y','Ysiz','-v7.3')
    end
    clear Y
end