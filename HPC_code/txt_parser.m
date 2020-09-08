function data=txt_parser(filename)
data={};
fid = fopen(filename);
tline = fgetl(fid);
while ischar(tline)
    data{end+1}=tline;
    tline = fgetl(fid);
end
fclose(fid);