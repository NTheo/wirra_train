%% Load the data
display = false;
load_data;

if display
    display_graph;
end

%% Initialization of the problem

n_iter   = 1;
exp_cost = 1;

disp('Kmeans ...');
init_kmeans;

for i=1:n_iter
   fprintf('E-step iter %d out of %d \n', i, n_iter);
   e_step;
   fprintf('M-step iter %d out of %d \n', i, n_iter);
   m_step;
end


