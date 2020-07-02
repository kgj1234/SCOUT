function neuron=smooth_spatial(neuron,gSizMin)

data_shape=neuron.imageSize;
for i=1:size(neuron.A,2)
    A{i}=neuron.A(:,i);
end

sigma=(gSizMin-1)/6;
h=fspecial('gaussian',[gSizMin,gSizMin],sigma);
for i=1:length(A)
    
    A1=A{i};
    
    A1=reshape(A1,data_shape(1),data_shape(2));
    
    A1=imfilter(A1,h);
    
    
    
   
   
A{i}=A1;    
end
neuron.A=[];
for i=1:length(A)
    neuron.A=[neuron.A,reshape(A{i},data_shape(1)*data_shape(2),1)];
end


