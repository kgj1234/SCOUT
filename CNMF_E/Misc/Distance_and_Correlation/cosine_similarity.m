function distance=cosine_similarity(A1,A2)
A1=A1./sqrt(sum(A1.^2,1));
A2=A2./sqrt(sum(A2.^2,1));

for i=1:size(A1,2)
    for j=1:size(A2,2)
        distance(i,j)=(A1(:,i)'*A2(:,j));
    end
end

