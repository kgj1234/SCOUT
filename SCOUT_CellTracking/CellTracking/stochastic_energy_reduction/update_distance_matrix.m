function distance_matrix=update_distance_matrix(distance_matrix,permutation,best_aligned)
distance_matrix1=full(distance_matrix);
distance_matrix=full(distance_matrix);

for i=1:size(permutation,2)
    if sum(permutation(:,i)==0)==0
        [M1,I1]=max(distance_matrix(permutation(1,i),:));
        [M2,I2]=max(distance_matrix(permutation(2,i),:));
        distance_matrix1(permutation(2,i),I2)=M1;
    end
end

for i=1:size(best_aligned,1)
    ind=find(distance_matrix1(best_aligned(i,1),:)>distance_matrix1(best_aligned(i,1),best_aligned(i,2)));
    distance_matrix1(best_aligned(i,1),ind)=distance_matrix1(best_aligned(i,1),best_aligned(i,2))-.01;
   ind=find(distance_matrix1(:,best_aligned(i,2))>distance_matrix1(best_aligned(i,1),best_aligned(i,2)));
   distance_matrix1(ind,best_aligned(i,2))=distance_matrix1(best_aligned(i,1),best_aligned(i,2))-.01;
end
distance_matrix=distance_matrix1;
