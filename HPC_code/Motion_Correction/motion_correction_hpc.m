function motion_correction_hpc()

data=txt_parser('motion_correction_options.txt');

for k=1:length(data)
    try
        eval(data{k});
    end
end


for k=1:length(filename)
    if background_subtract
        m=background_subtraction(filename{k});
        Yfilter=m.reg;
        Yfilter=uint8(Yfilter/max(Yfilter(:))*255);
        Y=uint8(m.orig*255);
        Y=runrigid3(Yfilter,Y);
        Ysiz=size(Y);
        if save_file
            
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
