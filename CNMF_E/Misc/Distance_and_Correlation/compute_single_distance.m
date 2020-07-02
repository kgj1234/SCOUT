function distance=compute_single_distance(neuron1,neuron2,height,width,index1,index2,dist_method)
if ~exist('dist_method','var')||isempty(dist_method);
    dist_method=overlap;
end

if isequal(dist_method,'overlap')
    temp = bsxfun(@times, neuron1.A(:,index1)>0, 1./sqrt(sum(neuron1.A(:,index1)>0)));
    temp1=bsxfun(@times, neuron2.A(:,index2)>0, 1./sqrt(sum(neuron2.A(:,index2)>0)));
    distance=temp'*temp1;
    distance=1-distance;
elseif isequal(dist_method,'centroid_dist')
    distance=norm(neuron1.centroid(index1,:)-neuron2.centroid(index2,:));
elseif isequal(dist_method,'KL')
    distance=spatial_overlap_via_bivariate_gaussian(neuron1.A(:,index1),neuron2.A(:,index2),height,width);
    
end