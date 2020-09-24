function nam_mat=convert_recording(nam)

    % use pre-specified file 
    if exist(nam, 'file')
        [dir_nm, file_nm, file_type] = fileparts(nam);
    else
        nam_mat=[];
        return
    end


%% convert the data to mat file
if isempty(dir_nm)
    dir_nm='.';
end
nam_mat = [dir_nm, filesep, file_nm, '.mat'];
if strcmpi(file_type, '.mat')
    %fprintf('The selected file is *.mat file\n');

    vars=who('-file',nam);
    m=matfile(nam);
    for q=1:length(vars)
        if length(size(m,vars{q}))>3
            Y=load(nam,vars{q});
            Y=getfield(Y,vars{q});
            Y=squeeze(max(Y,[],3));
            Ysiz=size(Y);
            save([dir_nm, filesep, file_nm, '_projection.mat'],'Y','Ysiz','-v7.3')
            nam_mat=[dir_nm, filesep, file_nm, '_projection.mat'];
            break
        end
        
    end
            
        
elseif  exist(nam_mat, 'file')
    % the selected file has been converted to *.mat file already
    %fprintf('The selected file has been replaced with its *.mat version.\n');
elseif or(strcmpi(file_type, '.tif'), strcmpi(file_type, '.tiff'))
    % convert
    tic;
    fprintf('converting the selected file to *.mat version...\n');
    nam_mat = tif2mat(nam);
    %fprintf('Time cost in converting data to *.mat file:     %.2f seconds\n', toc);
elseif strcmpi(file_type, '.avi')
    % convert
    tic;
    fprintf('converting the selected file to *.mat version...\n');
    v=VideoReader(nam);
    Y=v.read;
    Ysiz=size(Y);
    if length(Ysiz)>3
        Y=squeeze(max(Y,[],3));
        Ysiz=size(Y);
    end
    save([dir_nm,filesep,file_nm],'Y','Ysiz','-v7.3')
    %fprintf('Time cost in converting data to *.mat file:     %.2f seconds\n', toc);

else
      nam_mat=[];
      disp('File type not supported or file is not video file')
end

