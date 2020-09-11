function individual_extraction_hpc()


data=txt_parser('individual_extraction_options.txt');

for k=1:length(data)
    
        eval(data{k});
   
end
filename=filename;
gSiz=gSiz;
data_type=data_type;
max_neurons=max_neurons;
min_corr=min_corr;
corr_noise=corr_noise;
indices=indices;
min_pnr=min_pnr;
disp(JS)
JS=JS;

parfor k=1:length(filename)
	
	neurons{k}=individual_extraction_main(filename{k},gSiz,data_type,max_neurons,min_corr,corr_noise,indices,min_pnr,JS);
end
for k=1:length(filename)
	[path,name,ext]=fileparts(filename{k})
	neuron=neurons{k}
	save(fullfile(path,[name,'_extracted_data']),'neuron') %Change save location here
end
