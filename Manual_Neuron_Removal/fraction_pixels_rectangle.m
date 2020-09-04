function fraction=fraction_pixels_rectangle(roi,neuron,indices)
poss_ind=find(neuron.centroid(:,2)>roi(1)&neuron.centroid(:,2)<roi(1)+roi(3)...
    &neuron.centroid(:,1)>roi(2)&neuron.centroid(:,1)<roi(2)+roi(4));
temp_roi(1)=roi(2);
temp_roi(2)=roi(1);
temp_roi(3)=roi(4);
temp_roi(4)=roi(3);

poss_ind(poss_ind<indices(1))=[];
poss_ind(poss_ind>indices(2))=[];

roi=round(temp_roi);
mask=zeros(neuron.imageSize(1),neuron.imageSize(2));
mask(roi(1):roi(1)+roi(3),roi(2):roi(2)+roi(4))=1;

for k=1:length(poss_ind);
    temp=reshape(neuron.A(:,poss_ind(k)),neuron.imageSize(1),neuron.imageSize(2));
    temp=temp.*mask;
    fraction(poss_ind(k))=sum(sum(temp>0))/sum(sum(neuron.A(:,poss_ind(k))>0));
end

    