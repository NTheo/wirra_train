classdef VectorizedGraph2 < handle
% VectorizedGraph is a graph structure using a vectorized format to speed
% up computations
% By default this structure works for oriented edges. If your structure is
% unoriented some values and operations might be redondant
% Each oriented is indexededges is formed of two indexes, corresponding to the origin and
% destination nodes
%
%
%FIELDS : 
%   Graph structure with fields:
%
%   PUBLIC:
%   numberOfNodes - the number of nodes.
%   numberOfEdges - the number of edges.
%   edgesValues   - value defined on each edges
%   edgeWeights   - weights on each edges
%   nodeValues    - value defined on each node
%   nodeWeights1  - weight on each node
%   nodeWeights2  - another field for the nodes
%   hasNeighbors  - boolean value indicating wetehr or not the edge has at
%                   least one neighbor
%
%   PRIVATE
%   nodeToEdge    - for each node the smallest index of the edges leaving 
%                   the node. Those index are contiguous. From a node n 
%                   leaves edges with index nodeToEdge(n) to nodeToEdge(n+1)-1.
%   nodeToEdge    - similar but only for node that have at least one
%                   neighbor
%   edgeToNode    - for each edge the node index of the origin node of the
%                   edge.
%   edgeToNoder   - for each edge the node index of the destination node of the
%                   edge.
%   sentToReceive - for each edge the edge index of the reversed edge.
%   edgeWeight     = the vectorized edgeweight array
%
%METHODS :
%   VectorizedGraph(neighbors,edgeWeights)
%       the constructor
%       %SYNTAX :
%           vg = VectorizedGraph(neighbors)
%           vg = VectorizedGraph(neighbors,edgeWeight)
%       %INPUTS :
%           - neighbors  : a cell of size N the number of nodes, listing the 
%                          neighbors of the node
%           - edgeWeight : for edge-weighted graphs, a cell of size N with the weight 
%                          of each edge in the same order they are presented in neighbors.
%                          defaults is 1 for all edges
%       %OUTPUT :
%           - vg : the vectorized graph structure
%
%   vg.setNodeValues(X)
%       set the field nodeValues
%
%   vg.setEdgeValues(Z)
%       set the field edgeValues
%
%   vg.setNodeWeight1(X)
%       set the field nodeWeight1
%
%   vg.setNodeWeight2(X)
%       set the field nodeWeight2
%
%   grad = vg.gradient(X, weight)
%       compute the graph-gradient of the node field X
%        %SYNTAX :
%        grad = vg.gradient
%        grad = vg.gradient(X)
%        grad = vg.gradient(X, withWeights)
%        grad = vg.gradient(X, withWeights, weights)
%        %INPUTS :
%           - X           : field defined on each nodes. 
%                           Default value : nodeValues
%           - withWeights : boolean value indicating wether or not to
%                           weight the gradient with edgeWeight.
%                           Default value is 0
%           - weights     : define custom weights to weight the gradient
%                           weights must be of size numberOfEdges
%                           Default value is edgeWeight
%        %OUTPUTS :
%           - grad : the graph gradient of X 
%                    on each edge e = (n1->n2) : grad(e) = X(n1)-X(n2)
%
%   X    = vg.sumOnNodes(Z,weight)
%       compute the sum on each nodes of the edge field Z
%        %SYNTAX :
%        X = vg.sumOnNodes
%        X = vg.sumOnNodes(Z)
%        X = vg.sumOnNodes(Z, withWeights)
%        X = vg.sumOnNodes(Z, withWeights, weights)
%        %INPUTS :
%           - Z           : field defined on each edges
%                           Default value : edgeValues
%           - withWeights : boolean value indicating wether or not to
%                           weight the sum with edgeWeight. 
%                           Default value is 0
%           - weights     : define custom weights to weight the sum
%                           Default value is edgeWeight
%        %OUTPUT :
%           - X : the sum of Z for all edges starting on a node
%                 for node n, origin of edges set (e1,e2,e3)
%                 X = Z(e1)+Z(e2)+Z(e3)
%
%   X    = vg.prodOnNodes(obj,Z)
%       compute the product on each nodes of the edge field Z
%        %SYNTAX :
%        X = vg.prodOnNodes
%        X = vg.prodOnNodes(Z)
%        %INPUT :
%           - Z : field defined on each edges
%                 Default value : edgeValues
%        %OUTPUT :
%           - X : the product of Z for all edges starting on a node
%                 for node n, origin of edges set (e1,e2,e3) :
%                 X = Z(e1)*Z(e2)*Z(e3)
%
%   Z    = vg.split(X)
%        create an edge field Z which value is the value of X at origin
%        node
%        %SYNTAX :
%        X = vg.split
%        X = vg.split(X)
%        %INPUT :
%           - X : field defined on each nodes
%                 Default value : nodeValues
%        %OUTPUT :
%           - Z : edges field with value X at the origin.
%                 for edge e = (n1->n2) : Z(e) = X(n1)
%                 
%   Zr   = vg.reverse(obj,Z)
%        reverse an edge field Z
%        %SYNTAX :
%        Zr = vg.split
%        Zr = vg.split(Z)
%        %INPUT :
%           - Z : field defined on each edges
%                 Default value : edgeValues
%        %OUTPUT :
%           - Zr : reverse edges field
%                 for edge e = (n1->n2) and er = (n2->n1) : Zr(e) = Z(e)

%
%Author : Loic Landrieu
%   Janvier 2015    
    properties
        numberOfNodes
        numberOfEdges
        edgeWeights
        nodeValues
        nodeWeights1
        nodeWeights2
        hasNeighbors
    end
    properties (GetAccess = private)
        edge2node
        edge2noder
        node2edge
        node2edgeNei
        sent2receive
        hasWeight
    end
    methods
        %==================================================================
        %======================CONSTRUCTOR=================================
        %==================================================================
        function obj = VectorizedGraph2(neighbors,edgeWeights)
            %the constructor
            if (nargin<1)
                error('Graph needs neighbors fields');
            end
            if (size(neighbors,2)>size(neighbors,1))
                neighbors = neighbors';
            end
            obj.numberOfNodes  = numel(neighbors);
            if (nargin==2)
                obj.hasWeight = true;
                if (size(edgeWeights,2)>size(edgeWeights,1))
                    edgeWeights = edgeWeights';
                end
                if ((size(edgeWeights,1)~=obj.numberOfNodes))
                    error('neighbors and weights must be of the same size');
                end
            else
                obj.hasWeight = false;
            end 
            %-------------CONSTRUCTING THE EDGES INDEX---------------------------------
            numberOfEdgesE     = 10 * obj.numberOfNodes;
                %we first need to go through all edges to assign indexes
            numberOfEdges  = 1;
            numberOfNeigh      = nan(obj.numberOfNodes, 1); %number of neighbors
                %for each node the edge index of the first edge leaving the node. From 
                %a node n leaves edges with index nodeToEdge(n) to nodeToEdge(n+1)-1.
            node2edge      = nan(obj.numberOfNodes, 1);
                %for each edge the node index of the origin node of the edge.
            edge2node      = NaN(numberOfEdgesE,1);
            tic;
            reverseStr = '';
            fprintf('1/2 Constructing edges index   : ');
            for node = 1 : obj.numberOfNodes
                    %for each node we create numberOfNeigh new edges index 
                    %of all the edges that leaves this nodes.
                    %numberOfEfge - 1 is the index of the last edge index
                    %assigned
                numberOfNeigh(node) = numel(neighbors{node});    
                if (numberOfNeigh(node)==0)
                    continue;
                end
                node2edge(node)    = numberOfEdges;
                    %we update numberOfEdges
                numberOfEdges      = numberOfEdges ...
                                   + numberOfNeigh(node);
                    %all the edges are leaving node
                edge2node(node2edge(node):(node2edge(node)...
                                   + numberOfNeigh(node)-1))...
                                   = node;
                if (numberOfEdges>0.9*numberOfEdgesE)
                    edgeToNode2 = nan(numberOfEdgesE * 2,1);
                    edgeToNode2(1:numberOfEdgesE) = edge2node;
                    edge2node = edgeToNode2;
                    clear('edgeToNode2');
                    numberOfEdgesE = 2 * edgeToNodeE;
                end
                %-------------TIME BOX-------------------------------------
                if (mod(node,50000)==0)
                ratio         = (node)/(obj.numberOfNodes);
                remainingTime = toc * (1 - ratio) / ratio;
                msg = sprintf('%3.0f %%%% => Xp : %d / %d, Reamining time = %s\n'...
                    ,ceil(100 * ratio) ,node,obj.numberOfNodes,...
                obj.formatTime(remainingTime));
                fprintf([reverseStr,msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
                end
                %----------------------------------------------------------               
            end
            numberOfEdges    = numberOfEdges - 1; 
            edge2node        = edge2node(1:numberOfEdges);
            sent2receive     = NaN(1, numberOfEdges); %index of the reversed edge.
            if (obj.hasWeight)
            	edgeWeightArray  = NaN(1, numberOfEdges);            
            end
            tic;
            reverseStr = '';
            fprintf('2/2 Vectorizing edge structure : ');
            %-------------CONSTRUCTING THE EDGES INDEX---------------------------------
            for node = 1 : obj.numberOfNodes
                if (numberOfNeigh(node)==0)
                    continue;
                end
                if (obj.hasWeight)
                    %we store the edge weight in the order we met them
                    edgeWeightArray(node2edge(node):(node2edge(node)  ...
                    + numberOfNeigh(node) - 1)) = edgeWeights{node};
                end
                    %the cumulative sum of the number of neigbors of each neighbor
                lengthArray = cumsum([0,cellfun(@length...
                            ,{neighbors{neighbors{node}}})]);
                lengthArray = lengthArray(1:(end-1));
        %
                %compute the index of the reverses edges
                sent2receive(node2edge(node):(node2edge(node)...
                    + numberOfNeigh(node) - 1)) ...
                    = node2edge(neighbors{node})' ...
                    + find(([neighbors{neighbors{node}}]==node)) ...
                    - lengthArray - 1;
                %-------------TIME BOX-------------------------------------
                if (mod(node,10000)==0)
                ratio         = (node)/(obj.numberOfNodes);
                remainingTime = toc * (1 - ratio) / ratio;
                msg = sprintf('%3.0f %%%% => Xp : %d / %d, Reamining time = %s\n'...
                  ,ceil(100 * ratio) ,node,obj.numberOfNodes,...
                  obj.formatTime(remainingTime));
                fprintf([reverseStr,msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg)-1);
                end
                %----------------------------------------------------------     
            end
        obj.numberOfEdges = numberOfEdges;
        obj.edgeWeights   = edgeWeightArray';
        obj.edge2node     = edge2node;
        obj.edge2noder    = edge2node(sent2receive);
        obj.node2edge     = node2edge;
        obj.sent2receive  = sent2receive;
        obj.hasNeighbors  = ~isnan(node2edge); %the nodes that have at least 1 neighbor
        obj.node2edgeNei  = node2edge(obj.hasNeighbors);
        end
        %==================================================================
        %========================SETTING VALUES============================
        %==================================================================
        function obj = setNodeValues(obj,X)
            if (numel(X)~=obj.numberOfNodes)
                error('input must be of size NumberOfNodes');  
            end
            obj.nodeValues = X;
        end
        function obj = setNodeWeight1(obj,X)
            if (numel(X)~=obj.numberOfNodes)
                error('input must be of size NumberOfNodes');  
            end
            obj.nodeWeights1 = X;
        end
        function obj = setNodeWeight2(obj,X)
            if (numel(X)~=obj.numberOfNodes)
                error('input must be of size NumberOfNodes');  
            end
            obj.nodeWeights2 = X;
        end
         function obj = setEdgeValues(obj,Z)
            if (numel(Z)~=obj.numberOfEdges)
                error('input must be of size NumberOfEdges');  
            end
            obj.edgeValues = Z;
        end
        %==================================================================
        %========================GRADIENT==================================
        %==================================================================
        function grad = gradient(obj,X, withWeights, weights)
            %compute the graph-gradient of a node field X
            if (numel(X)~=obj.numberOfNodes)
                error('input must be of size NumberOfNodes');  
            end
            if (nargin == 1)
                X           = obj.nodeValues;
                withWeights = 0;
            end
            if (nargin == 2)
                withWeights = 0;
            end
            if ((nargin == 3)&&withWeights)
            	if (withWeights&&(~obj.hasWeight))
                    error('No edge weights defined to weight the gradient');
                end   
                weights = obj.edgeWeights;
            end 
            if ((nargin == 4)&& (numel(weights)~=obj.numberOfEdges))
                	error('Weight vector must be of size numberOfEdges');
            end 
            if (~withWeight)
                grad = X(obj.edge2node) - X(obj.edge2noder);
            else
                grad = (X(obj.edge2node) - X(obj.edge2noder)).*weights;
            end
        end
        %==================================================================
        %=======================SUM ON NODES===============================
        %==================================================================
        function X = sumOnNodes(obj,Z,withWeights,weights)
            %sum the value of a value defined on each edge
            
            if (numel(Z)~=obj.numberOfEdges)
                error('input must be of size NumberOfEdges');  
            end
            if (nargin == 1)
                Z           = obj.edgeValues;
                withWeights = 0;
            end
            if (nargin == 2)
                withWeights = 0;
            end
            if ((nargin == 3)&&withWeights)
            	if (withWeights&&(~obj.hasWeight))
                    error('No edge weights defined to weight the sum');
                end   
                weights = obj.edgeWeights;
            end 
            if ((nargin == 4)&& (numel(weights)~=obj.numberOfEdges))
                	error('Weight vector must be of size numberOfEdges');
            end 
            X = zeros(obj.numberOfNodes,1);
            if (withWeight)
                cumSum_tv       = cumsum(Z.*weights);
            else
                cumSum_tv       = cumsum(Z);
            end
            cumSumOnNode_tv     = cumSum_tv(obj.node2edgeNei(2:end)-1);
            X(obj.hasNeighbors) = cumSum_tv([obj.node2edgeNei(2:end)-1 ...
                                ;obj.numberOfEdges]) - [0;cumSumOnNode_tv];
        end
        %==================================================================
        %=======================PRODUCT ON NODES===========================
        %==================================================================
        function X = prodOnNodes(obj,Z)
            %product on each origin node of the value of a value defined 
            %on each edge
            if (nargin == 1)
                Z           = obj.edgeValues;
            elseif (numel(Z)~=obj.numberOfEdges)
                error('input must be of size NumberOfEdges');  
            end
            X = zeros(obj.numberOfNodes,1);
            cumSum_tv           = cumsum(log(Z));
            cumSumOnNode_tv     = cumSum_tv(obj.node2edgeNei(2:end)-1);
            X(obj.hasNeighbors) = exp(cumSum_tv([obj.node2edgeNei(2:end)-1 ...
                                ;obj.numberOfEdges]) - [0;cumSumOnNode_tv]);
        end
        %==================================================================
        %==============DISPATCH NODES VALUE ON =EDGES======================
        %==================================================================
        function Z = split(obj,X)
            %this function takes a value on nodes X and create a vector of 
            %size NumberOfEdges that gives for each direction of the edges 
            %the value associated to the origin node
             if (numel(X)~=obj.numberOfNodes)
                error('input must be of size NumberOfNodes');  
             end
             Z = X(obj.edge2node);
        end
        %==================================================================
        %=================REVERSE VALUES ON EDGES==========================
        %==================================================================
        function Zr = reverse(obj,Z)
            %this function takes a value Z defined on the edge structure 
            %and create a vector Zr of size NumberOfEdges that gives for 
            %each edge index the value of the other node
             if (numel(Z)~=obj.numberOfEdges)
                error('input must be of size NumberOfNodes');  
             end
             Zr = Z(obj.sent2receive);
        end 
    end
    methods(Static)
        function rep = formatTime(s)
            %input = a time length in second
            %output = a string formatting this time.
            days = floor(s/(3600*24));
            s = s - 3600*24*days;
            hours = floor(s/3600);
            s = s - 3600*hours;
            minu = floor(s/60);
            s = s - 60 * minu;
            rep = '';
            if (days>0)
                rep = [rep  sprintf('%d days, ',days)];
            end
            if (hours>0)
                rep = [rep  sprintf('%d hours, ',hours)];
            end
            if (minu>0)
                rep = [rep  sprintf('%d min, ', minu)];
            end
            rep = [rep  sprintf('%d sec.', floor(s))];
        end
    end
end