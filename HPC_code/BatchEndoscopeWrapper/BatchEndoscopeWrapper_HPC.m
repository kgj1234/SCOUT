function BatchEndoscopeWrapper_HPC()

<<<<<<< HEAD
data=txt_parser('~/SCOUT/HPC_code/BatchEndoscopeWrapper/BatchEndoscopeWrapper_Options.txt');
=======
data=txt_parser('BatchEndoscopeWrapper_options.txt');
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2
for k=1:length(data)
    try
        eval(data{k});
    end
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
BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options);
=======
BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options);
>>>>>>> 4a675d56d800eaf546e62ea1fa2ceccc319852d2
