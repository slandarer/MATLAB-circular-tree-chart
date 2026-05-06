classdef circTreeChart < handle
% circTreeChart: Circular tree (radial hierarchy) visualization
%   Displays hierarchical data as concentric circular layers.
% =========================================================================
% Basic usage
% -------------------------------------------------------------------------
% List = {'AAAA','aaa1'; 'AAAA','aaa2'; 'AAAA','aaa3'; 'AAAA','aaa4';
%     'BBBB','bbb1'; 'BBBB','bbb2'; 'BBBB','bbb3'; 'BBBB','bbb4';
%     'CCCC','ccc1'; 'CCCC','ccc2'; 'CCCC','ccc3'; 'CCCC','ccc4'};
% 
% CT = circTreeChart(List);
% CT.DispEndNodes = 'on';
% CT.DispEndLabels = 'on';
% CT = CT.draw();
% =========================================================================
% Zhaoxu Liu / slandarer (2026). circular tree chart 
% (https://www.mathworks.com/matlabcentral/fileexchange/118325), 
% MATLAB Central File Exchange. Retrieved April 26, 2026.

    properties
        ax
        arginList = {'Curvature', 'Value', 'DrawEndNodes'}
        
        Curvature = 1;          % Edge curvature: 0 = straight, 1 = full Bezier
        List                    % Hierarchical data (N x L cell array)
        
        DispEndNodes = 'off'    % Show leaf nodes
        DispEndLabels = 'off'   % Show leaf labels
        
        layerSizes = []         % Number of nodes per layer
        layerNodes = {}         % Node names per layer
        idList = []             % Hierarchical encoding matrix
        sz                      % Size of input list
        
        baseLayerSizes = []     % Raw layer sizes (before hierarchical grouping)
        baseLayerNodes = {}     % Raw node names
        baseIdList = []         % Raw encoding
        
        thetaSet = []           % Angular positions of data points
        Value = []              % Edge/node weights
        
        % Node and edge size limits [min, max] mapped from data values
        NodeSizeLim  = [0.01, 0.4]
        EdgeWidthLim = [0.01, 0.4]
        NodeAlpha = 1
        EdgeAlpha = 0.3
        
        % Default color palette (RGB normalized to [0,1])
        CData = [110,110,110; 127, 91, 93; 187,128,110; 197,173,143;  59, 71,111; 104, 95,126;  
                  76,103, 86; 112,112,124;  72, 39, 24; 197,119,106; 160,126, 88; 238,208,146] ./ 255;

        maxValue, minValue       % Value range for scaling
        
        nodeHdl                  % Handles to node patches
        edgeHdl                  % Handles to edge patches
        labelHdl                 % Handles to text labels
        edgeIds                  % Edge identifiers for linking
    end

    methods
        function obj = circTreeChart(varargin)          
            % Parse axes handle
            if isa(varargin{1}, 'matlab.graphics.axis.Axes')
                obj.ax = varargin{1};
                varargin(1) = [];
            else
                obj.ax = gca;
            end

            % Store hierarchical list
            obj.List = varargin{1};
            varargin(1) = [];

            % Parse name-value input arguments
            for i = 1:2:(length(varargin) - 1)
                tid = ismember(lower(obj.arginList), lower(varargin{i}));
                if any(tid)
                    obj.(obj.arginList{tid}) = varargin{i + 1};
                end
            end

            % Clean empty entries (propagate to the right)
            obj.List = clearRightAfterEmpty(obj.List);
            obj.Value = abs(obj.Value);
            obj.sz = size(obj.List);

            if size(obj.List, 2) == 2
                obj.EdgeWidthLim = [.02,.06];
                obj.NodeSizeLim = [.07,.15];
            end

            % Initialize values (default 1 for all entries)
            if isempty(obj.Value)
                obj.Value = ones([obj.sz(1), 1]);
            end
            obj.Value(cellfun(@(x) isempty(x) || (ischar(x) && strcmp(x, '')), obj.List(:, end))) = 0;
            obj.minValue = min(obj.Value(obj.Value ~= 0));

            % Step 1: Encode each column independently
            obj.baseIdList = zeros(obj.sz);
            for i = 1:obj.sz(2)
                [tCell, ~, id] = unique(obj.List(:, i));
                obj.baseLayerNodes(i) = {tCell};
                obj.baseLayerSizes(i) = length(tCell);
                obj.baseIdList(:, i)  = id;
            end
            
            % Step 2: Hierarchical encoding (each layer grouped by previous layers)
            obj.idList = zeros(obj.sz);
            for i = 1:obj.sz(2)
                [tArr, ~, id] = unique(obj.baseIdList(:, 1:i), 'rows');
                obj.layerNodes(i) = {obj.baseLayerNodes{i}(tArr(:, i))};
                obj.layerSizes(i) = size(tArr, 1);
                obj.idList(:, i)  = id;
            end

            % Sort by hierarchical path
            [obj.idList, tInd] = sortrows(obj.idList);
            obj.Value = obj.Value(tInd);

            % Calculate value range for scaling
            obj.maxValue = obj.minValue;
            for i = 1:obj.layerSizes(1)
                obj.maxValue = max(obj.maxValue, sum(obj.Value(obj.idList(:, 1) == i)));
            end

            % Append random colors for additional categories
            obj.CData = [obj.CData; rand([obj.layerSizes(1) + 1, 3]) .* 6 + 0.3];

            % Helper: Remove empty entries and propagate to the right
            function C = clearRightAfterEmpty(C)
                % If a cell is empty, clear all cells to its right in the same row
                isEmptyCell = cellfun(@(x) isempty(x) || (ischar(x) && strcmp(x, '')), C);
                [row, col] = find(isEmptyCell);
                uniqueRows = unique(row);
                for ir = uniqueRows'
                    firstEmpty = min(col(row == ir));
                    if ~isempty(firstEmpty) && firstEmpty < size(C, 2)
                        C(ir, firstEmpty + 1:end) = {''};
                    end
                end
            end
        end

        function obj = draw(obj)
            % draw: Render the circular tree chart
            
            % Clamp curvature to [0, 1]
            obj.Curvature(obj.Curvature > 1) = 1;
            obj.Curvature(obj.Curvature < 0) = 0;
            
            tT = linspace(0, 2*pi, 50);
            tX = cos(tT);
            tY = sin(tT);

            % Configure axes
            obj.ax.NextPlot = 'add';
            obj.ax.XColor = 'none';
            obj.ax.YColor = 'none';
            obj.ax.PlotBoxAspectRatio = [1, 1, 1];
            obj.ax.XLim = [-0.1, 0.1] + [-obj.sz(2), obj.sz(2)] + strcmpi(obj.DispEndLabels, 'on') .* [-0.5, 0.5];
            obj.ax.YLim = [-0.1, 0.1] + [-obj.sz(2), obj.sz(2)] + strcmpi(obj.DispEndLabels, 'on') .* [-0.5, 0.5];

            % Angular positions for each data point
            obj.thetaSet = linspace(0, 2*pi, obj.sz(1) + 1).';
            obj.thetaSet(end) = [];

            % Draw root edges
            for i = 1:obj.layerSizes(1)
                if ~isempty(obj.layerNodes{1}{i})
                    tTheta = circMeanTheta(obj.thetaSet(obj.idList(:, 1) == i));
                    tValue = sum(obj.Value(obj.idList(:, 1) == i));
                    tWidth = (tValue - obj.minValue) ./ (obj.maxValue - obj.minValue) .* abs(diff(obj.EdgeWidthLim)) + min(abs(obj.EdgeWidthLim));
                    
                    [L, R] = thickenPolylineVec([cos(tTheta), sin(tTheta); [0.3, -0.5] .* obj.Curvature; 0, 0], tWidth);
                    LL = bezierCurve(L, 50);
                    RR = bezierCurve(R, 50);
                    
                    obj.edgeHdl{1}{i} = fill(obj.ax, [LL(:, 1); RR(end:-1:1, 1)], [LL(:, 2); RR(end:-1:1, 2)], ...
                        obj.CData(i + 1, :), 'EdgeColor', 'none', 'FaceAlpha', obj.EdgeAlpha, 'Tag', 'circTreeEdge');
                    obj.edgeIds{1}(i) = i;
                end
            end

            % Draw intermediate edges (between layers)
            if obj.sz(2) > 1
                for k = 2:obj.sz(2)
                    for i = 1:obj.layerSizes(k)
                        if ~isempty(obj.layerNodes{k}{i})
                            tId = obj.idList(find(obj.idList(:, k) == i, 1), k - 1);
                            CId = obj.idList(find(obj.idList(:, k) == i, 1), 1);
                            
                            tThetaA = circMeanTheta(obj.thetaSet(obj.idList(:, k - 1) == tId));
                            tThetaB = circMeanTheta(obj.thetaSet(obj.idList(:, k) == i));
                            
                            XYA = [cos(tThetaA), sin(tThetaA)] .* (k - 1);
                            XYB = [cos(tThetaB), sin(tThetaB)] .* k;
                            XYM = (XYA + XYB) ./ 2;
                            
                            XYAm = [cos(tThetaA), sin(tThetaA)] .* (k - 0.7) .* obj.Curvature + (1 - obj.Curvature) .* XYM;
                            XYBm = [cos(tThetaB), sin(tThetaB)] .* (k - 0.3) .* obj.Curvature + (1 - obj.Curvature) .* XYM;
                            
                            tValue = sum(obj.Value(obj.idList(:, k) == i));
                            tWidth = (tValue - obj.minValue) ./ (obj.maxValue - obj.minValue) .* abs(diff(obj.EdgeWidthLim)) + min(abs(obj.EdgeWidthLim));
                            
                            [L, R] = thickenPolylineVec([XYB; XYBm; XYAm; XYA], tWidth);
                            LL = bezierCurve(L, 50);
                            RR = bezierCurve(R, 50);
                            
                            obj.edgeHdl{k}{i} = fill(obj.ax, [LL(:, 1); RR(end:-1:1, 1)], [LL(:, 2); RR(end:-1:1, 2)], ...
                                obj.CData(CId + 1, :), 'EdgeColor', 'none', 'FaceAlpha', obj.EdgeAlpha, 'Tag', 'circTreeEdge');
                            obj.edgeIds{k}(i) = i;
                        end
                    end
                end
            end

            % Draw root node (center)
            obj.nodeHdl{1}{1} = fill(obj.ax, tX .* max(abs(obj.NodeSizeLim)) ./ 2, ...
                                             tY .* max(abs(obj.NodeSizeLim)) ./ 2, obj.CData(1, :), ...
                                             'EdgeColor', 'none', 'FaceAlpha', obj.NodeAlpha, 'Tag', 'circTreeNode');
            
            % Draw layer nodes and labels
            for k = 1:obj.sz(2)
                if k < obj.sz(2) || strcmpi(obj.DispEndNodes, 'on') || strcmpi(obj.DispEndLabels, 'on')
                    for i = 1:obj.layerSizes(k)
                        if ~isempty(obj.layerNodes{k}{i})
                            tValue = sum(obj.Value(obj.idList(:, k) == i));
                            CId = obj.idList(find(obj.idList(:, k) == i, 1), 1);
                            tThetaB = circMeanTheta(obj.thetaSet(obj.idList(:, k) == i));
                            tWidth = (tValue - obj.minValue) ./ (obj.maxValue - obj.minValue) .* abs(diff(obj.NodeSizeLim)) + min(abs(obj.NodeSizeLim));

                            % Draw node circle
                            if k < obj.sz(2) || strcmpi(obj.DispEndNodes, 'on')
                                obj.nodeHdl{k + 1}{i} = fill(obj.ax, tX .* tWidth ./ 2 + cos(tThetaB) .* k, ...
                                    tY .* tWidth ./ 2 + sin(tThetaB) .* k, obj.CData(CId + 1, :), ...
                                    'EdgeColor', 'none', 'FaceAlpha', obj.NodeAlpha, 'Tag', 'circTreeNode');
                            end
                            
                            % Draw label
                            if k < obj.sz(2) || strcmpi(obj.DispEndLabels, 'on')
                                if tThetaB > pi * 0.5 && tThetaB < pi * 1.5
                                    obj.labelHdl{k}{i} = text(obj.ax, cos(tThetaB) .* (k + tWidth ./ 2 + 0.1), ...
                                        sin(tThetaB) .* (k + tWidth ./ 2 + 0.1), obj.layerNodes{k}{i}, ...
                                        'FontSize', 13, 'FontName', 'Times New Roman', 'Rotation', tThetaB / pi * 180 + 180, ...
                                        'HorizontalAlignment', 'right', 'Color', obj.CData(CId + 1, :), 'Tag', 'circTreeLabel');
                                else
                                    obj.labelHdl{k}{i} = text(obj.ax, cos(tThetaB) .* (k + tWidth ./ 2 + 0.1), ...
                                        sin(tThetaB) .* (k + tWidth ./ 2 + 0.1), obj.layerNodes{k}{i}, ...
                                        'FontSize', 13, 'FontName', 'Times New Roman', 'Rotation', tThetaB / pi * 180, ...
                                        'HorizontalAlignment', 'left', 'Color', obj.CData(CId + 1, :), 'Tag', 'circTreeLabel');
                                end
                            end
                        end
                    end
                end
            end

            % Clean empty handles
            for i = 1:length(obj.nodeHdl)
                obj.nodeHdl{i}(cellfun(@(x) isempty(x), obj.nodeHdl{i})) = [];
            end
            for i = 1:length(obj.edgeHdl)
                obj.edgeIds{i}(cellfun(@(x) isempty(x), obj.edgeHdl{i})) = [];
                obj.edgeHdl{i}(cellfun(@(x) isempty(x), obj.edgeHdl{i})) = [];
            end
            for i = 1:length(obj.labelHdl)
                obj.labelHdl{i}(cellfun(@(x) isempty(x), obj.labelHdl{i})) = [];
            end

            % Helper: Quadratic Bezier curve
            function pnts = bezierCurve(pnts, N)
                t = linspace(0, 1, N);
                p = size(pnts, 1) - 1;
                coe1 = factorial(p) ./ factorial(0:p) ./ factorial(p:-1:0);
                coe2 = ((t) .^ ((0:p)')) .* ((1 - t) .^ ((p:-1:0)'));
                pnts = (pnts' * (coe1' .* coe2))';
            end
            
            % Helper: Circular mean of angles (handles wrap-around)
            function thetaMean = circMeanTheta(theta)
                x = mean(cos(theta));
                y = mean(sin(theta));
                thetaMean = atan2(y, x);
                thetaMean = mod(thetaMean, 2*pi);
            end
            
            % Helper: Generate thickened polyline boundaries
            function [L, R] = thickenPolylineVec(XY, w)
                X = XY(:, 1);
                Y = XY(:, 2);
                n = length(X);

                dx = zeros(n, 1);
                dy = zeros(n, 1);
  
                dx(2:n-1) = X(3:n) - X(1:n-2);
                dy(2:n-1) = Y(3:n) - Y(1:n-2);

                dx(1) = X(2) - X(1);
                dy(1) = Y(2) - Y(1);
                dx(n) = X(n) - X(n-1);
                dy(n) = Y(n) - Y(n-1);

                len = sqrt(dx.^2 + dy.^2);
                len(len == 0) = eps;
                dx = dx ./ len;
                dy = dy ./ len;

                nx = -dy;
                ny = dx;

                XL = X + nx * w/2;
                YL = Y + ny * w/2;
                XR = X - nx * w/2;
                YR = Y - ny * w/2;

                L = [XL, YL];
                R = [XR, YR];
            end
        end

        function setNode(obj, varargin)
            % setNode: Set properties for all nodes
            nodes = findobj(obj.ax, 'Tag', 'circTreeNode');
            for i = 1:length(nodes)
                set(nodes(i), varargin{:})
            end
        end
        
        function setEdge(obj, varargin)
            % setEdge: Set properties for all edges
            edges = findobj(obj.ax, 'Tag', 'circTreeEdge');
            for i = 1:length(edges)
                set(edges(i), varargin{:})
            end
        end
        
        function setLabel(obj, varargin)
            % setLabel: Set properties for all labels
            labels = findobj(obj.ax, 'Tag', 'circTreeLabel');
            for i = 1:length(labels)
                set(labels(i), varargin{:})
            end
        end

        function setLabelLN(obj, layer, n, varargin)
            % setLabelLN: Set properties for a specific label (layer, node index)
            set(obj.labelHdl{layer}{n}, varargin{:})
        end

        function setNodeLN(obj, layer, n, varargin)
            % setNodeLN: Set properties for a specific node (layer, node index)
            set(obj.nodeHdl{layer + 1}{n}, varargin{:})
        end

        function setColorLN(obj, layer, n, C)
            % setColorLN: Set color for a node and its connected edges
            %   Also propagates color to child edges/nodes
            set(obj.edgeHdl{layer}{n}, 'FaceColor', C)
            set(obj.nodeHdl{layer + 1}{n}, 'FaceColor', C)
            
            % Propagate to child layers
            tid = unique(obj.idList(obj.idList(:, layer) == obj.edgeIds{layer}(n), layer + 1));
            for i = (tid(:)).'
                tn = find(obj.edgeIds{layer + 1} == i);
                if ~isempty(tn)
                    set(obj.edgeHdl{layer + 1}{tn}, 'FaceColor', C)
                end
            end
        end
    end
end