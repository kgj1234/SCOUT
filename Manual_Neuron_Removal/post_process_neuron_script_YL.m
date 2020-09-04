clear all 
filename='W:\2p data backup\yongjun\01142020\PVAi163-150\PVAi163-150_000_000_cell_data.mat';  %Insert filename for neuronsIndividuals
load(filename,'neuronsIndividuals')


del_index_spatial={};
del_index_manual={};
del_index={};
for i=1:length(neuronsIndividuals)
%     neuronIndividuals{i}=spatial_delete_main(neuronsIndividuals{i},80);
    [neuronIndividuals{i},del_index_spatial{i}]=spatial_delete_main(neuronsIndividuals{i},80);
    
    close all
%     neuronIndividuals{i}=manual_deletion_main(neuronsIndividuals{i},8);
    [neuronIndividuals_chekd{i},del_index_manual{i}]=manual_deletion_main(neuronIndividuals{i},8);
    close all
    del_index{i}=[del_index_spatial{i},correct_indices(del_index_manual{i},del_index_spatial{i})];
    clear del_index_spatial del_index_manual
end

[path,name,ext]=fileparts(filename);
save(fullfile(path,[name,'_processed.mat']),'neuronIndividuals_chekd','del_index','-v7.3')
