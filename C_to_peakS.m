function nS=C_to_peakS(nC)

nS=[];
for i=1:size(nC,1)
    t=nC(i,:);
    [pks,loc]=findpeaks(t);
    t=t*0;
    t(loc)=pks;
    nS(i,:)=t;
end