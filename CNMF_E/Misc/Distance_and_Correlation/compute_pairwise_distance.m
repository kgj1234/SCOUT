function distance=compute_pairwise_distance(neuron1,neuron2,height,width,dist_method)

if ~exist('dist_method','var')||isempty(dist_method)
    dist_method='overlap';
end

if isequal(dist_method,'overlap')
    temp = bsxfun(@times, neuron1.A>0, 1./sqrt(sum(neuron1.A>0)));
    temp1=bsxfun(@times, neuron2.A>0, 1./sqrt(sum(neuron2.A>0)));
    distance=temp'*temp1;
    distance=1-distance;
elseif isequal(dist_method,'centroid_dist')
    for i=1:size(neuron1.A,2)
        for j=1:size(neuron2.A,2)
            distance(i,j)=norm(neuron1.centroid(i,:)-neuron2.centroid(j,:));
        end
    end
elseif isequal(dist_method,'KL')
    distance=zeros(size(neuron1.A,2),size(neuron2.A,2));
    parfor i=1:size(neuron1.A,2)*size(neuron2.A,2)
        [a,b]=ind2sub([size(neuron1.A,2),size(neuron2.A,2)],i);
        [distance(i),~]=KLDiv(reshape(neuron1.A(:,a),height,width),reshape(neuron2.A(:,b),height,width));
        
    end
end