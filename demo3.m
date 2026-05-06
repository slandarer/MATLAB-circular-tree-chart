%% Bubble-style visualization demo

rng(1)
% Generate random hierarchical dataset (500 items, 3 levels)
ListA = compose('Class-%s', randi([65, 69], [80, 1]));
ListB = compose('Type-%s',  randi([97, 99], [80, 1]));
ListC = compose('Object-%03d', (1:80).');

List  = [ListA, ListB, ListC];
Value = rand(80, 1).*100;

% Create and configure circular tree chart
CT = circTreeChart(List, 'Value',Value);
CT.EdgeWidthLim = [.02,.1];
CT.NodeSizeLim = [.1,1];
CT.Curvature = 1;
CT.NodeAlpha = .3;
CT.EdgeAlpha = .6;
CT.DispEndNodes = 'on';
CT.DispEndLabels = 'on';
CT = CT.draw;

for i = 1:length(CT.labelHdl{1})
    set(CT.labelHdl{1}{i}, 'Visible','off')
end
for i = 1:length(CT.labelHdl{2})
    set(CT.labelHdl{2}{i}, 'Visible','off')
end

