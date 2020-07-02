function Num=extract_numeric(A)
%Luffy on matlab answers
Num=regexp(A,'[0-9]','match');
if length(Num)>1
    Num=horzcat(Num{:});
else
    Num=Num{1};
end

Num=str2num(Num);