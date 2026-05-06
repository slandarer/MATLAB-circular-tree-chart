rng(5)
% Generate random hierarchical dataset (500 items, 3 levels)
ListA = compose('Class-%s', randi([65, 69], [500, 1]));
ListB = compose('Type-%s',  randi([97, 99], [500, 1]));
ListC = compose('Object-%03d', (1:500).');

% Introduce missing values
ListA(1:10) = {''};
ListC(1:50) = {''};

List  = [ListA, ListB, ListC];
Value = ones(500, 1);

% Create and configure circular tree chart
CT = circTreeChart(List, 'Value',Value);
CT.EdgeWidthLim = [.02,.1];
CT.NodeSizeLim = [.1,.2];
CT.Curvature = 1;
CT = CT.draw;

% Global style settings
CT.setEdge('FaceColor',[.7,.7,.7])
CT.setLabel('FontName','Monospaced', 'Color','k')
CT.setNode('EdgeColor',[.15,.55,.85], 'LineWidth',2, 'FaceColor','w')

% Customize specific nodes (by layer and index)
CT.setLabelLN(1, 1, 'Color',[.15,.55,.85], 'FontWeight','bold')
CT.setNodeLN(1, 1, 'FaceColor',[.35,.75,1])
% The setColorLN function sets the color of the nth node in the specified layer, 
% as well as the colors of its connections to parent and child nodes.
CT.setColorLN(1, 1, [0.15, 0.55, 0.85])    % Layer1, node1 -> blue
CT.setColorLN(2, 3, [0.9, 0.35, 0.35])     % Layer2, node3 -> red
