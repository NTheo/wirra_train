
cols = {'r','g','b','c','m','y','k', [0.5 0.5 0.5]};
figure;
hold on;
for i = 1:n_cars
    selected = (idxs == i);
    plot([vertices_first(selected,2) vertices_second(selected,2)]',[vertices_first(selected,1) vertices_second(selected,1)]','Color',cols{i});
%     pause;
end
hold off;
