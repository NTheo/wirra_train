% input v index of one vertex
% output dists : distances of all vertex to this vertex
% futur output: gdist_vertex
c            = 1;
distances    = +inf*ones(size(coords,2),1);
finished     = boolean(zeros(size(coords,2),1));
distances(v) = 0;

while(c<size(coords,2))
    distances_tmp           =distances;
    distances_tmp(finished) =inf;
    [~,v1]                  = min(distances_tmp);
	neighbours              = find(M(v1,:)>0);
    for ne=neighbours
        distances(ne) = min(distances(ne),distances(v1)+M(v1,ne));
    end
    finished(v1) = 1;
    c            = c+1;
end
finished(v1) = 1;
