function BatchEndoscopeWrapper_HPC()

data=txt_parser('BatchEndoscopeWrapper_options.txt');
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

BatchEndoscopeWrapper(base_dir,vids_per_batch,overlap_per_batch,data_type,threads,extraction_options,cell_tracking_options);