%% Load the data
display       = false;
finetune_init = false;
load_data;

if display
    display_graph;
end

%% Initialization of the problem

n_iter   = 1;
exp_cost = 0;

disp('Kmeans ...');
init_kmeans;

if finetune_init
    for i=1:n_iter
       fprintf('E-step iter %d out of %d \n', i, n_iter);
       e_step;
       fprintf('M-step iter %d out of %d \n', i, n_iter);
       m_step;
    end
end

if display
   display_cluster 
end

%% Find solution for the problem

bring_cars_to_cluster;
solve_subproblems;
