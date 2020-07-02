function correlations=spike_train_correlation(neuron1,neuron2,weights,max_dist)
%uses spike train to calculate correlation as described in the paper




%Calculate kernel width for neuron1
neuron1.updateCentroid();
neuron2.updateCentroid();

S1=neuron1.S;
S1=S1>0;

sigma1=zeros(size(S1,1),1);
scale1=zeros(size(S1,1),1);
width1=zeros(size(S1,1),1);
for i=1:length(sigma1)
    try
    spike_times=find(S1(i,:));
    delays=diff(spike_times);
    delays(delays<4)=[];
    width1(i)=prctile(delays,5);
    possible_widths=0:width1(i)/100:2*width1(i);
    percentiles=abs(expinv(.9,possible_widths)-width1(i));
    percentiles(isnan(percentiles))=[];
    [~,I]=min(percentiles);
    sigma1(i)=possible_widths(I);
    scale1(i)=1/exppdf(0,sigma1(i));
    catch
        sigma1(i)=0;
        scale1(i)=0;
    end
end

% Calculate kernel width for neuron2

S2=neuron2.S;
S2=S2>0;
sigma2=zeros(size(S2,1),1);
scale2=zeros(size(S2,1),1);
width2=zeros(size(S2,1),1);
for i=1:length(sigma2)
    try
     spike_times=find(S2(i,:));
    delays=diff(spike_times);
    delays(delays<4)=[];
    width2(i)=prctile(delays,5);
    possible_widths=0:width2(i)/100:2*width2(i);
    percentiles=abs(expinv(.9,possible_widths)-width2(i));
    percentiles(isnan(percentiles))=[];
    [~,I]=min(percentiles);
    sigma2(i)=possible_widths(I);
    scale2(i)=1/exppdf(0,sigma2(i));
    catch
        sigma2(i)=0;
        scale2(i)=0;
    end
end
correlations=zeros(length(sigma1)*length(sigma2),1);
for k=1:length(sigma1)*length(sigma2)
   
    [i,j]=ind2sub([length(sigma1),length(sigma2)],k);
    if norm(neuron1.centroid(i,:)-neuron2.centroid(j,:))<max_dist&scale1(i)>0&scale2(j)>0
    ind1=find(S1(i,:));
    ind2=find(S2(j,:));
    total1=0;
    total_corr1=0;
    for l=1:length(ind1)
        [M,I]=min(abs(ind2-ind1(l)));
        if abs(ind1(l)-ind2(I))<width1(i)
            total1=total1+1;
            if exppdf(abs(ind1(l)-ind2(I)),sigma1(i))*scale1(i)<.5
                total_corr1=total_corr1-(1-exppdf(abs(ind1(l)-ind2(I)),sigma1(i))*scale1(i));
            else
                 total_corr1=total_corr1+exppdf(abs(ind1(l)-ind2(I)),sigma1(i))*scale1(i);
            end
        end
    end
    total_corr1=total_corr1/total1;
    total2=0;
    total_corr2=0;
    for l=1:length(ind2)
        [M,I]=min(abs(ind1-ind2(l)));
        if abs(ind2(l)-ind1(I))<width2(j)
            total2=total2+1;
            if exppdf(abs(ind2(l)-ind1(I)),sigma2(j))*scale2(j)<.5
                total_corr2=total_corr2-(1-exppdf(abs(ind2(l)-ind1(I)),sigma2(j))*scale2(j));
            else
                total_corr2=total_corr2+exppdf(abs(ind2(l)-ind1(I)),sigma2(j))*scale2(j);
            end
        end
    end
    total_corr2=total_corr2/total2;
    correlations(k)=weights(1)*((total_corr2+total_corr1)/2)+weights(2)*((total2/length(ind2)+total1/length(ind1))/2)-weights(2)*(((length(ind2)-total2)/length(ind2)+(length(ind1)-total1)/length(ind1))/2);
    end
end
correlations=reshape(correlations,[length(sigma1),length(sigma2)]);

    
'hi';

