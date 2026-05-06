%% Two-layer demo

treeList = {'Competition', 'Math Competition'; 'Competition', 'English Competition';
    'Competition', 'MCM/ICM'; 'Competition', 'National Mathematical Contest in Modeling';
    'Competition', 'Network Challenge Tournament'; 'Competition', 'English Translation Contest';
    'Programming', 'python'; 'Programming', 'MATLAB'; 'Programming', 'C#'; 'Programming', 'C++';
    'Programming', 'C'; 'Programming', 'java'; 'Programming', 'js'; 'Programming', 'R';
    'Programming', 'html'; 'Programming', 'php'; 'Programming', 'rust'; 'Programming', 'julia';
    'Programming', 'perl'; 'Programming', 'carbon'; 'Programming', 'lisp';
    'Skill', 'office'; 'Skill', 'LaTeX'; 'Skill', 'PS'; 'Skill', 'PR';
    'Skill', 'excel'; 'Skill', 'Video Editing'; 'Skill', 'bat';
    'Fundamental Knowledge', 'Algebraic Set Theory'; 'Fundamental Knowledge', 'Fourier Analysis';
    'Fundamental Knowledge', 'Abstract Algebra'; 'Fundamental Knowledge', 'Mathematical Analysis';
    'Fundamental Knowledge', 'Advanced Algebra'; 'Fundamental Knowledge', 'Analytic Geometry';
    'Fundamental Knowledge', 'Real Analysis'; 'Fundamental Knowledge', 'Complex Analysis';
    'Fundamental Knowledge', 'Operations Research'; 'Fundamental Knowledge', 'Functional Analysis';
    'Fundamental Knowledge', 'Tensor Decomposition'; 'Fundamental Knowledge', 'Probability Theory';
    'Development Tool', 'eclipse'; 'Development Tool', 'git'; 'Development Tool', 'gitee';
    'Development Tool', 'jupyter'; 'Development Tool', 'macos'; 'Development Tool', 'postman';
    'Development Tool', 'vscode'; 'Development Tool', 'mdnice'; 'Development Tool', 'pycharm';
    'Development Tool', 'vim'; 'Development Tool', 'svn';
    'Hobby', 'Chinese Painting'; 'Hobby', 'Table Tennis'; 'Hobby', 'Origami';
    'Hobby', 'Carving'; 'Hobby', 'Basketball'; 'Hobby', 'Soccer';
    'Hobby', 'Singing'; 'Hobby', 'Dancing'; 'Hobby', 'Rap';
    'Hobby', 'Suspenders Production'; 'Hobby', 'Hairdressing'};

figure()
CT = circTreeChart(treeList);
CT.DispEndNodes = 'on';
CT.DispEndLabels = 'on';
CT.draw;