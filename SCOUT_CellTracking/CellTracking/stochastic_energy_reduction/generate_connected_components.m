function [components,total_conn]=generate_connected_components(distance_matrix)
distance_matrix(distance_matrix>0)=1;
[components,c] = graph_connected_comp(sparse(distance_matrix));
for i=1:max(components)
    total_conn(i)=sum(components==i);
    
end
