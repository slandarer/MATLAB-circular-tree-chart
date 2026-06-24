%% Basic usage and layout properties setting

rng(1)
% Generate random hierarchical dataset (500 items, 3 levels)
ListA = compose('Class-%s', randi([65, 69], [500, 1]));
ListB = compose('Type-%s',  randi([97, 99], [500, 1]));
ListC = compose('Object-%03d', (1:500).');

List  = [ListA, ListB, ListC];
Value = ones(500, 1);

%% Basic usage
figure()
CT1 = circTreeChart(List, 'Value',Value);
CT1.draw;


%% Curvature control (0 = straight line, 1 = full Bezier curve)
figure()
CT2 = circTreeChart(List, 'Value',Value);
CT2.Curvature = 0;
CT2.draw;


%% Edge width and node size
figure()
CT3 = circTreeChart(List, 'Value',Value);
% EdgeWidthLim: [min, max] width mapped from Value
% NodeSizeLim:  [min, max] radius mapped from Value
CT3.EdgeWidthLim = [.01, .1];
CT3.NodeSizeLim = [.1, .1];
CT3.draw;


%% CData
figure()
CT4 = circTreeChart(List, 'Value',Value);
CT4.CData = turbo(6);
CT4.draw;