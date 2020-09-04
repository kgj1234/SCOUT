clear all 
filename='MD-PV671-P32_000_000_cell_data.mat';  %Insert filename for neuronsIndividuals
load(filename,'neuronsIndividuals')



for i=1:length(neuronsIndividuals)
    neuronIndividuals{i}=spatial_delete_main(neuronsIndividuals{i},80)  
    close all
    neuronIndividuals{i}=manual_deletion_main(neuronsIndividuals{i},8)
    close all
end

[path,name,ext]=fileparts(filename);
save(fullfile(path,[name,'_processed.mat']),'neuronsIndividuals','-v7.3')
