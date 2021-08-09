function aligned=construct_greedy_alignments(dimensions,distance_matrix)
n1=dimensions(1);
n2=dimensions(2);
%distance_matrix=distance_matrix(1:n1,n1+1:end);
aligned=[];

while sum(distance_matrix,'all')>0
    [a,b]=argmax_2d(distance_matrix);
    aligned(end+1,1)=a;
    aligned(end,2)=b;
    distance_matrix(a,:)=0;
    distance_matrix(:,b)=0;
end
aligned(:,2)=aligned(:,2)+n1;