function [dist,mass_rem]=KLDiv(P,Q,div)
if ~exist('div','var')||isempty(div)
    div='JS';
end

P=reshape(P,[],1);
Q=reshape(Q,[],1);
%P(P<.2*max(max(P)))=0;
%Q(Q<.2*max(max(Q)))=0;
P=P/sum(sum(P));
Q=Q/sum(sum(Q));


if isequal(div,'KL')
    
%Find mutual support
 supp_P=find(P>0);
 supp_Q=find(Q>0);
 inter=intersect(supp_P,supp_Q);
 out=setdiff(1:size(P,1)*size(P,2),inter);

 %if sum(Q(out))>.1
 %disp(horzcat('warning: removed mass Q', num2str(sum(Q(out)))));
% end
% if sum(P(out))>.1
%     disp(horzcat('warning: removed mass P', num2str(sum(P(out)))));
% end
mass_rem=max(sum(Q(out)),sum(P(out)));
P(out)=0;
Q(out)=0;
P=P/sum(sum(P));
Q=Q/sum(sum(Q));
    dist=0;

for i=squeeze(inter')
    dist=dist+P(i)*log2(P(i)/Q(i))+Q(i)*log2(Q(i)/P(i));
end
dist=dist/2;
end


%    dist=0;

if isequal(div,'JS')
M=.5*(P+Q);
ind=P>0;
ind1=Q>0;
dist=sum(P(ind).*log2(P(ind)./M(ind)))+sum(Q(ind1).*log2(Q(ind1)./M(ind1)));
dist=dist/2;
mass_rem=0;
end


