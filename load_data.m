f = fopen('paris_54000.txt');
header = fscanf(f, '%d %d %d %d %d', [1 5]);
n_vertices = header(1); n_edges = header(2); T = header(3); n_cars = header(4); v_0 = header(5);
coords = fscanf(f, '%f %f', [2 n_vertices]);
edges = fscanf(f, '%d %d %d %d %d', [5 n_edges]);
fclose(f);

M=sparse(edges(1,:)+1,edges(2,:)+1,(edges(3,:)==1).*edges(4,:));
M=M+sparse(edges(1,:)+1,edges(2,:)+1,(edges(3,:)==2).*edges(4,:));
M=M+sparse(edges(2,:)+1,edges(1,:)+1,(edges(3,:)==2).*edges(4,:));
vertices_first  = coords(:, edges(1,:)+1)';
vertices_second = coords(:, edges(2,:)+1)';

orientations    = edges(3, :);

