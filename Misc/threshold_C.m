function neuron=threshold_C(neuron)
%Takes in sources2D object
neuron.C_thresh=zeros(size(neuron.C));
neuron.S_thresh=zeros(size(neuron.S));
for i=1:size(neuron.C,1)
 C{i}=neuron.C(i,:);
   S{i}=neuron.S(i,:);
end

parfor i=1:size(neuron.C,1)
    if max(C{i})>eps
        C1=C{i};
        %thresh=std(C1(C1>0));
        %Threshold for retaining spikes
        thresh=.2*max(C1);
        [~,peaks]=findpeaks(C1);
        decay=[];
        for q=length(peaks):-1:1
            try
            val=C1(peaks(q):peaks(q)+20);
            if sum(val==sort(val,'descend'))==21
            
            f=fit((1:21)',val','exp1');
            decay=[f.b,decay];
            else
peaks(q)=[];
end


end

        end

        rem_ind=peaks(find(C1(peaks)<thresh));
        x=0:length(C1)-1;
        
        
        for k=1:length(rem_ind)
            y=exp(decay(k)*x);
           C1(rem_ind(k):end)=C1(rem_ind(k):end)-C1(rem_ind(k))*y(1:length(C1)-rem_ind(k)+1);
        end
        
        S_thresh=neuron.S(i,:);
        ind=S_thresh>0&C1==0;
        S_thresh(ind)=0;
        %Percentile for normalizing neuron S
        small_peak_prc=prctile(S_thresh(S_thresh>0),25);
        small_peak=mean(S_thresh(S_thresh>0&S_thresh<small_peak_prc));
        small_peak=small_peak_prc;
        if isnan(small_peak)
            small_peak=min(S_thresh(S_thresh>0));
            if isempty(small_peak)||small_peak==0
                small_peak=1;
            end
        end
        S_thresh=S_thresh/small_peak;
        S_thresh=int8(S_thresh);
             
        S_thresh=double(S_thresh);
        small_C=prctile(C1(S_thresh>0),25);
        
        
   
        
        C{i}=C1/small_C;
        S{i}=S_thresh;
    end
end

for i=1:length(S)
neuron.S_thresh(i,:)=S{i};
neuron.C_thresh(i,:)=C{i};
end
neuron.C_thresh(neuron.C_thresh<0)=0;
