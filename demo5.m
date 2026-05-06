%% 4-layer demo
ListA = compose('Class-%s', randi([65, 69], [500, 1]));
ListB = compose('Type-%s',  randi([97, 99], [500, 1]));
ListC = compose('Prop-%s',  randi([97, 99], [500, 1]));
ListD = compose('Object-%03d', (1:500).');

List  = [ListA, ListB, ListC, ListD];
CT1 = circTreeChart(List);
CT1.draw