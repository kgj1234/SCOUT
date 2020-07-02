function [neuron,mse]=register_neurons_ind(neuron,base_template,base_template_norm,template,template_norm,normalize,registration_method)
if normalize
    template=template_norm;
    base_template=base_template_norm;
end

R=imref2d(neuron.imageSize);

try
            [optimizer, metric] = imregconfig('multimodal');
            if ~isequal(registration_method,'non-rigid')
                tform1=imregtform(template,base_template,registration_method,optimizer,metric);
                template=imwarp(template,tform1,'OutputView',R);
                registration2=[];
                template_norm=imwarp(template_norm,tform1,'OutputView',R);
                mse1=MSE_registration_metric(template_norm,base_template_norm);
            else
                tform1=imregtform(template,base_template,'affine',optimizer,metric);
                template=imwarp(template,tform1,'OutputView',R);
                template_norm=imwarp(template_norm,tform1,'OutputView',R);
                
                registration2=registration2d(base_template,template,'transformationModel',registration_method);
                template=deformation(template,registration2.displacementField,registration2.interpolation);
                template_norm=deformation(template_norm,registration2.displacementField,registration2.interpolation);
                
                mse1=MSE_registration_metric(template_norm,base_template_norm);
            end
catch
    mse1=[];
end
try
     registration1=registration2d(base_template,template,'transformationModel','translation');
     template=imtranslate(template,-1*[registration1.transformationMatrix(1,3), registration1.transformationMatrix(2,3)],'FillValues',0);
     template_norm=imtranslate(template_norm,-1*[registration1.transformationMatrix(1,3), registration1.transformationMatrix(2,3)],'FillValues',0);
     
     
     registration2=registration2d(base_template,template,'transformationModel',registration_method);
     template=deformation(template,registration2.displacementField,registration2.interpolation);
     template_norm=deformation(template_norm,registration2.displacementField,registration2.interpolation);
     mse2=MSE_registration_metric(template_norm,base_template_norm);
catch
    mse2=[];
end
if isempty(mse2)&~isempty(mse1)
    mse2=mse1*2;
elseif isempty(mse1)&~isempty(mse2)
    mse1=mse2*2;
elseif isempty(mse1)&isempty(mse2)
    warning('Registration Failed')
    mse=0;
    return
end

if mse1<=mse2
   
    mse=mse1;
    temp_A=reshape(neuron.A,neuron.imageSize(1),neuron.imageSize(2),[]);
    parfor j=1:size(neuron.A,2)
        temp_A(:,:,j)=imwarp(temp_A(:,:,j),tform1,'OutputView',R);
        if isequal(registration_method,'non-rigid')

            temp_A(:,:,j)=deformation(temp_A(:,:,j),registration2.displacementField,registration2.interpolation);
        end
    end   
elseif mse2<mse1
    


    mse=mse2;
  
    registration1=registration2d(base_template,template,'transformationModel','translation');
    template=imtranslate(template,-1*[registration1.transformationMatrix(1,3), registration1.transformationMatrix(2,3)],'FillValues',0);
    registration2=registration2d(base_template,template,'transformationModel',registration_method);
    template=deformation(template,registration2.displacementField,registration2.interpolation);

    temp_A=reshape(neuron.A,neuron.imageSize(1),neuron.imageSize(2),[]);
    parfor j=1:size(neuron.A,2)
        temp_A(:,:,j)=imtranslate(temp_A(:,:,j),-1*[registration1.transformationMatrix(1,3), registration1.transformationMatrix(2,3)],'FillValues',0);
        temp_A(:,:,j)=deformation(temp_A(:,:,j),registration2.displacementField,registration2.interpolation);
    end
end
neuron.A=reshape(temp_A,neuron.imageSize(1)*neuron.imageSize(2),[]);
neuron.A(neuron.A<10^(-6))=0;
