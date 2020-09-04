function [path_name, file_base, file_fmt] = data_info
% Select datasets to process
%   Jinghao Lu 01/12/2016

%     [file_name_tmp, path_name] = uigetfile({'*.tif'; '*.tiff'; '*.avi'}, 'Select coordinates file', 'MultiSelect', 'on');
    [file_name_tmp, path_name] = uigetfile('*', 'Select imaging file', 'MultiSelect', 'on');
    if ~iscell(file_name_tmp)
        file_name{1} = file_name_tmp;
    else
        file_name = file_name_tmp;
    end
    %This is a hack for when the avi files don't have correct header info,
    %not good as it requires loading full video at the same time.
    [~,~,temp]=fileparts(file_name{1});
    if isequal(temp,'.avi')
        v=VideoReader(fullfile(path_name,file_name{1}));
        Y=v.read();
        [~,name,ext]=fileparts(file_name{1});
        save(fullfile(path_name,[name,'.mat']),'Y','-v7.3');
        file_name{1}=[name,'.mat'];
    end
    
    
    file_base = cell(1, length(file_name));
    file_fmt = cell(1, length(file_name));
    for i = 1: length(file_name)
        %%% first find out whether it is Inscopix or UCLA %%%
        if contains(file_name{i}, '.avi')
            file_fmt{i} = 'avi';
            ids = regexp(file_name{i}, '\d');
            ids = ids(end);
            file_base{i} = file_name{i}(1: ids - 1);
        elseif contains(file_name{i}, '.tiff')
            file_fmt{i} = 'tiff';
            file_temp1 = find(file_name{i} == '-', 1, 'last');
            file_temp2 = find(file_name{i} == '.');
            if ~isempty(file_temp1)
                file_base{i} = file_name{i}(1: file_temp1 - 1);
            else
                file_base{i} = file_name{i}(1: file_temp2 - 1);
            end
        elseif contains(file_name{i}, '.tif')
            file_fmt{i} = 'tif';
            file_temp1 = find(file_name{i} == '-', 1, 'last');
            file_temp2 = find(file_name{i} == '.');
            if ~isempty(file_temp1)
                file_base{i} = file_name{i}(1: file_temp1 - 1);
            else
                file_base{i} = file_name{i}(1: file_temp2 - 1);
            end
        elseif contains(file_name{i}, '.mat')
            file_fmt{i} = 'mat';
            file_temp1 = find(file_name{i} == '-', 1, 'last');
            file_temp2 = find(file_name{i} == '.');
            if ~isempty(file_temp1)
                file_base{i} = file_name{i}(1: file_temp1 - 1);
            else
                file_base{i} = file_name{i}(1: file_temp2 - 1);
            end
        end
    end
end