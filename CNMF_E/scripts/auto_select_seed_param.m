function [min_pnr,min_corr]=auto_select_seed_param(Cn,PNR,thresh);
if ~exist('thresh','var')
    thresh=.4;
end

init_corr=.9;
init_pnr=20;
min_corr=.02;
min_pnr=2;
curr_corr=init_corr;
curr_pnr=init_pnr;


total_avail=sum(Cn(:)>min_corr&PNR(:)>min_pnr&Cn(:).*PNR(:)>min_corr*min_pnr);

while sum(Cn(:)>curr_corr&PNR(:)>curr_pnr&Cn(:).*PNR(:)>curr_corr*curr_pnr)<thresh*total_avail;
    [M,I]=min([sum(Cn(:)>curr_corr),sum(PNR(:)>curr_pnr)]);
    if I==1
        curr_corr=curr_corr-.02;
    else
        curr_pnr=curr_pnr-.1;
    end
end
min_pnr=curr_pnr;
min_corr=curr_corr;
