global data Ysiz d1 d2 numFrame; 

%% select file 
if ~exist('nam', 'var') || isempty(nam)
    % choose files manually 
    try
        load .dir.mat; %load previous path
    catch
        dir_nm = [cd(), filesep]; %use the current path
    end
    [file_nm, dir_nm] = uigetfile(fullfile(dir_nm, '*.tif;*.mat;*.h5'));
    nam = [dir_nm, file_nm];  % full name of the data file
    [dir_nm, file_nm, file_type] = fileparts(nam);
else
    % use pre-specified file 
    if exist(nam, 'file')
        [dir_nm, file_nm, file_type] = fileparts(nam);
    else
        dir_nm = 0; 
    end
end
if dir_nm~=0
    save .dir.mat dir_nm;
else
    fprintf('no file was selected. STOP!\n');
    return;
end

%% convert the data to mat file
nam_mat = [dir_nm, filesep, file_nm, '.mat'];
if strcmpi(file_type, '.mat')
    fprintf('The selected file is *.mat file\n');
elseif  exist(nam_mat, 'file')
    % the selected file has been converted to *.mat file already
    fprintf('The selected file has been replaced with its *.mat version.\n');
elseif or(strcmpi(file_type, '.tif'), strcmpi(file_type, '.tiff'))
    % convert
    tic;
    fprintf('converting the selected file to *.mat version...\n');
    nam_mat = tif2mat(nam);
    fprintf('Time cost in converting data to *.mat file:     %.2f seconds\n', toc);
elseif strcmpi(file_type, '.avi')
    % convert
    tic;
    fprintf('converting the selected file to *.mat version...\n');
    v=VideoReader(nam);
    Y=v.read;
    
    Ysiz=size(Y);
    if length(Ysiz)>3
        Y=max(squeeze(Y,[],3));
        Ysiz=size(Y);
        disp('Video is in full color, using max projection to convert to grayscale')
    end
    save(file_nm,'Y','Ysiz','-v7.3')
    fprintf('Time cost in converting data to *.mat file:     %.2f seconds\n', toc);
elseif or(strcmpi(file_type, '.h5'), strcmpi(file_type, '.hdf5'))
    fprintf('the selected file is hdf5 file\n'); 
    temp = h5info(nam);
    dataset_nam = ['/', temp.Datasets.Name];
    dataset_info = h5info(nam, dataset_nam);
    dims = dataset_info.Dataspace.Size;
    ndims = length(dims);
    d1 = dims(2); 
    d2 = dims(3); 
    numFrame = dims(end);
    Ysiz = [d1, d2, numFrame]; 
    fprintf('\nThe data has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1, d2, numFrame, prod(Ysiz)*8/(2^30));
    return; 
else
    fprintf('The selected file type was not supported yet! email me to get support (zhoupc1988@gmail.com)\n');
    return;
end

%% information of the data
while true
    try
        data = matfile(nam_mat);
        break
    catch ME
        'data saving, will try again in 2 minutes'
        pause(120)
    end
end
if ~isempty(indices)
    data_shape=size(data,'Y');
    Ysiz = [data_shape(1),data_shape(2),indices(2)-indices(1)+1];
else
    try
        Ysiz=data.Ysiz;
    catch
        vals=whos(data);
        Ysiz=vals.size;
    end
end
d1 = Ysiz(1);   %height
d2 = Ysiz(2);   %width
numFrame = Ysiz(3);    %total number of frames

fprintf('\nThe data has been mapped to RAM. It has %d X %d pixels X %d frames. \nLoading all data requires %.2f GB RAM\n\n', d1, d2, numFrame, prod(Ysiz)*8/(2^30));