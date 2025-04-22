function handles = drawingTool()
    
   clc ; clear all;

%%%%%%%%%%%%%%%%%%%%%% Figure, axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Create a figure and axes for drawing in 2D planes
    % Create a single figure with two subplots
    fig = figure('Name', 'LPPD Drawing Tool', 'NumberTitle', 'off', 'Position', [50 50 1350 750]);
    
    % Create axes for the first subplot (2D drawing)
    axDraw = subplot(1, 2, 1);
    set(gcf,'Pointer','crosshair');
    grid(axDraw, 'on');
    title(axDraw, 'Drawing Tool - 2D View');
    xlabel(axDraw, 'X-axis');
    ylabel(axDraw, 'Y-axis');
    zlabel(axDraw, 'Z-axis');
    axisLimits = [0, 10]; % Default axis limits
    xlim(axDraw, axisLimits);
    ylim(axDraw, axisLimits);
    zlim(axDraw, axisLimits);
    
    % Create axes for the second subplot (3D view)
    axView = subplot(1, 2, 2);
    grid(axView, 'on');
    title(axView, '3D View');
    xlabel(axView, 'X-axis');
    ylabel(axView, 'Y-axis');
    zlabel(axView, 'Z-axis');
    xlim(axView, axisLimits);
    ylim(axView, axisLimits);
    zlim(axView, axisLimits);
    view(axView, 3);
   
    % Adjust subplot positions
    axDraw.Position = [0.05, 0.2, 0.40, 0.75];
    axView.Position = [0.55, 0.2, 0.40, 0.75];

    % Syncrhonise zoom
    zoomObj = zoom(axView);
    set(zoomObj, 'ActionPostCallback', @updateAxes);

    % Synchronize pan
    panObj = pan(fig);
    set(panObj, 'ActionPostCallback', @updateAxes);

    % Set the keyboard shortcuts
    set(fig, 'WindowKeyPressFcn', @keyPressCb);
    set(fig, 'WindowKeyReleaseFcn', @keyReleaseCb);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% UI options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%% Nwk/Obj - Load/Save/Hide/Clear Operation panel and buttons %%% 

    nwkObjPanel = uipanel('Parent', fig, 'Title', 'Nwk/Obj Operations', 'FontSize', 9, ...
        'Units', 'pixels', 'Position', [10, 10, 165, 95]);

    loadNwkBtn = uicontrol(nwkObjPanel, 'Style', 'pushbutton', 'String', 'Load nwk', ...
        'Position', [5, 45, 60, 30], 'BackgroundColor', 'white', 'Callback', @loadNwkFileCb);
    saveNwkBtn = uicontrol(nwkObjPanel, 'Style', 'pushbutton', 'String', 'Save nwk', ...
        'Position', [5, 10, 60, 30], 'BackgroundColor', 'white', 'Callback', @saveNwkCb);
    
    hideObjBtn = uicontrol(nwkObjPanel, 'Style', 'pushbutton', 'String', 'Hide Objects', ...
        'Position', [70, 60, 85, 20], 'BackgroundColor', 'white', 'Callback', @hideObjCb);
    loadToViewBtn = uicontrol(nwkObjPanel, 'Style', 'pushbutton', 'String', 'View Only Load', ...
        'Position', [70, 35, 85, 20], 'BackgroundColor', 'white', 'Callback', @loadToViewCb);
    clearObjBtn = uicontrol(nwkObjPanel, 'Style', 'pushbutton', 'String', 'Clear Objects', ...
        'Position', [70, 10, 85, 20], 'BackgroundColor', 'white', 'Callback', @clearObjCb);

    %%%%%%%% Drawing Operation panel and buttons %%%%%%%

    drawPanel = uipanel('Parent', fig, 'Title', 'Draw Operations', 'FontSize', 9, ...
        'Units', 'pixels', 'Position', [195, 10, 340, 95]);
    
    connectBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Connect', ...
        'Position', [5, 35, 70, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @connectPointsCb);
    autoConnectBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Auto Connect', ...
        'Position', [5, 60, 70, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @autoConnectCb);
    disConnectBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Disconnect', ...
        'Position', [5, 10, 70, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @disConnectCb);

    deletePtsBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Delete Pts', ...
        'Position', [80, 10, 60, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @deletePtsCb);
    editPtsBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Edit Pts', ...
        'Position', [80, 35, 60, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @editPtsCb);
    movePtsBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Move Pts', ...
        'Position', [80, 60, 60, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @movePtsCb);

    undoBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Undo', ...
        'Position', [145, 60, 50, 20], 'Enable', 'off', 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @undoCb);
    redoBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Redo', ...
        'Position', [145, 35, 50, 20], 'Enable', 'off', 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @redoCb);
    clearBtn =  uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'Clear', ...
        'Position', [145, 10, 50, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @clearCb);

    ptSelectBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', 'ptSelect', ...
     'Position', [200, 63, 70, 15], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @ptSelectCb);
    snapToSurfaceBtn = uicontrol(drawPanel, 'Style', 'checkbox', 'String', 'SnapToSurface', ...
     'Position', [200, 35, 100, 30], 'FontSize', 11, 'Value', 0);
    shortestPathBtn = uicontrol(drawPanel, 'Style', 'checkbox', 'String', 'ShortestPath', ...
     'Position', [200, 10, 90, 30], 'FontSize', 11, 'Value', 0, 'Callback', @shortestPathCb);

    % Help Button next to SnapToSurface and ShortestPath Checkbox
    snapHelpBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', '?', ...
    'Position', [302, 42, 15, 15], 'FontSize', 10, ...
    'Callback', @(~, ~) showHelpText('Works with add, move, edit, and auto-connect modes.'));
    shortestHelpBtn = uicontrol(drawPanel, 'Style', 'pushbutton', 'String', '?', ...
    'Position', [292, 17, 15, 15], 'FontSize', 10, ...
    'Callback', @(~, ~) showHelpText(['Works with connect modes. Recommended to always' ...
    ' enable snapToSurface, especially in auto-connect mode,']));

    %%%%%%%%%%%%%%%%%%%%%%% Modify View Panel %%%%%%%%%%%%%%%%%%%%

    modifyViewPanel = uipanel('Parent', fig, 'Title', 'Modify View', 'FontSize', 9, ...
    'Units', 'pixels', 'Position', [545, 10, 580, 95]);

    indexBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'Indexing On', ...
        'Position', [5, 60, 70, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @indexingCb);
    dirBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'Directions On', ...
        'Position', [5, 35, 70, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @directionsCb);
    aspectBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'Aspect Ratio', ...
        'Position', [5, 10, 70, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @aspectCb);

    coordEditBoxLabel = uicontrol(modifyViewPanel, 'Style', 'text', 'String', 'Z:', ...
        'FontSize', 12, 'Position', [90, 60, 12, 20], 'HorizontalAlignment', 'left');
    coordEditBox = uicontrol(modifyViewPanel, 'Style', 'edit', 'String', '0', ...
        'FontSize', 9, 'Position', [110, 60, 50, 20], 'Callback', @updateThirdCoord);
    thicknessLabel = uicontrol(modifyViewPanel, 'Style', 'text', 'String', 'Width:', ...
        'FontSize', 9, 'Position', [82, 35, 32, 20], 'HorizontalAlignment', 'left');
    thicknessBox = uicontrol(modifyViewPanel, 'Style', 'edit', 'String', '1', ...
        'FontSize', 10, 'Position', [110, 35, 50, 20], 'Callback', @updateThirdCoord);
    toggleBtn = uicontrol(modifyViewPanel, 'Style', 'togglebutton', 'String', 'Y-Z plane', ...
        'FontSize', 9, 'Position', [85, 10, 80, 20], 'BackgroundColor', 'white', 'Callback', @toggleAxesCb);

    uicontrol(modifyViewPanel, 'Style', 'text', 'String', 'faceEdit', ...
        'FontSize', 8, 'Position', [175, 72, 70, 15], 'HorizontalAlignment', 'left');
    faceEditBox = uicontrol(modifyViewPanel, 'Style', 'edit', 'String', '', ...
        'FontSize', 10, 'Position', [175, 56, 150, 18]);
    uicontrol(modifyViewPanel, 'Style', 'text', 'String', 'ptEdit', ...
        'FontSize', 8, 'Position', [175, 41, 70, 16], 'HorizontalAlignment', 'left');
    ptEditBox = uicontrol(modifyViewPanel, 'Style', 'edit', 'String', '', ...
        'FontSize', 10, 'Position', [175, 27, 150, 18]);

    displayBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'Display', ...
        'Position', [175, 5, 60, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @displaySelectionsCb);    
    andOrBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'AND', ...
        'Position', [240, 5, 60, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @andOrCb);

    expandDropdown = uicontrol(modifyViewPanel, 'Style', 'popupmenu', 'String', {'Expand Path', 'Expand Children'}, ...
        'FontSize', 10, 'Position', [330, 50, 130, 20], 'Value', 1);
    goBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'Go', ...
        'Position', [340, 25, 30, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @goBtnCb);    
    resetBtn = uicontrol(modifyViewPanel, 'Style', 'pushbutton', 'String', 'Reset', ...
        'Position', [375, 25, 50, 20], 'FontSize', 9, 'BackgroundColor', 'white', 'Callback', @resetBtnCb);

    toggleCylinders = uicontrol(modifyViewPanel, 'Style', 'checkbox', 'String', 'CylinderView', ...
        'Position', [460, 50, 100, 20], 'FontSize', 11, 'Value', 0, 'Callback', @toggleToCylinders);

   % registrationBtn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Registration', ...
   %     'Position', [1100, 70, 80, 20], 'FontSize', 8, 'Callback', @registrationCb);

    showText = annotation(fig, 'textbox', [0.02, 0.135, 0.45, 0.03], 'String', '',...
        'HorizontalAlignment', 'left', 'EdgeColor', 'none', 'FontSize', 9, 'FontWeight', 'bold');


%%%%%%%%%%%%%%%%%% Global variable initialisations %%%%%%%%%%%%%%%%%%%%%%    


    % Store points and handles for points in Draw and View axes
    ptCoordMx = [];
    faceMx = [];
    connectIndices = [];
    disConnectIndices = [];
 
    G = graph();
    global plotObjDraw;
    global plotObjView;
    global hideSliceBtn;
    global np;
    global objNwk;
    global objGraph;
    global refRow;
    global objSubNwk;

    np = 0;

    % Current third coordinate value, set to default value 0
    currentThirdCoord = 0;
    thickness = 1;
    zlim(axDraw, [-thickness, 0]);

    % Define the states for the toggle button
    toggleStates = {'XY', 'YZ', 'XZ'};
    currentState = 1; % Initial state: X-Y axes

    % Table to store all the loaded objects
    rendererTable = table('Size', [0, 4], ...
                   'VariableTypes', {'string', 'string', 'cell', 'cell'}, ...
                   'VariableNames', {'fileName', 'type', 'drawHandle', 'viewHandle'});

    % Add callback function for mouse click on axes
    axDraw.ButtonDownFcn = @addPoint;

    % Button handles
    btnHandles = [connectBtn, autoConnectBtn, deletePtsBtn, editPtsBtn, movePtsBtn, disConnectBtn, ptSelectBtn];
    btnStates = zeros(1, numel(btnHandles)); % Initialize button states (0: inactive, 1: active)

    % Initial state is to show the BMP
    showObj = true; 

    % Initialise the 2D drawing plane
    hold(axView, "on");
    drawBox = patch(axView, 'Faces', [], 'Vertices', [], 'FaceColor', 'k', 'EdgeColor', 'none', 'FaceAlpha', 0.05);
    updateDrawBox(axView, zlim(axDraw));
    hold(axView, "off");

    % Add callback function for mouse click on 2D drawing plane
    set(drawBox, 'ButtonDownFcn', @selectBox);

    % Stacks for undo and redo operations
    undoStack = {}; 
    redoStack = {};
    maxStackSize = 15;

    % Toggle between point and face indices
    indexOn = false;

    % Toggle between directions
    dirOn = false; arrowSize = 0;

    % Toggle between equal aspect ratio
    aspectOn = false;

    % Add annotation with author and supervisor
    annotation('textbox', [0.84, 0.01, 0.15, 0.05], 'String', ...
        {'Authored by Lavanya Vaddavalli', 'Directed by Andreas Linninger'}, ...
        'FontSize', 8, 'FontAngle', 'italic', 'Color', [0.3 0.3 0.3], ...
        'EdgeColor', 'none', 'HorizontalAlignment', 'right');

    fidReport = fopen('drawReport.txt', 'w');  % write mode (overwrite or create)
    fclose(fidReport);

%%%%%%%%%%%%%%%%%%%%%%%% UI Callback functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Callback function to display the help text for ? buttons
    function showHelpText(message)
        helpText = uicontrol(fig, 'Style', 'text', 'String', message, ...
        'Position', [565, 95, 350, 30], 'FontSize', 10, ...
        'BackgroundColor', get(fig, 'Color'), 'ForegroundColor', [0, 0, 1]);
        pause(3);
        if isvalid(helpText)
            delete(helpText);
        end
    end

    % Callback function to add a new point
    function addPoint(~, ~)
        % Store original axes limits
        xlimOriginal = xlim(axDraw);
        ylimOriginal = ylim(axDraw);
        zlimOriginal = zlim(axDraw);
  
        % Get current point coordinates
        currPoint = axDraw.CurrentPoint(1, 1:3);
        x = currPoint(1, 1);
        y = currPoint(1, 2);
        z = currPoint(1, 3);

        % Initialise the third coordinate of a 2D plane to 0
        switch toggleStates{currentState}
            case 'XY'
                z = currentThirdCoord;
            case 'YZ'
                x = currentThirdCoord;
            case 'XZ'
                y = currentThirdCoord;
        end

        pIdx = 0;
        if snapToSurfaceBtn.Value & ~isempty(rendererTable)
            [newCoords, pIdx] = getNearestPtOnSurface([x, y, z]);
            x = newCoords(1); y = newCoords(2); z = newCoords(3);
        end

        if np > 0 && checkDupPt([x,y,z])
           return; 
        end
   
        G = addnode(G, 1);
        np = size(G.Nodes, 1);
        G.Nodes{np, {'X', 'Y', 'Z', 'PtIdx'}} = [x, y, z, pIdx];
        if ~btnStates(2) % If not in auto-connect mode
            pushUndo({'add', [x, y, z], pIdx});
        end

        % Replot the graph on both axes
        rePlotGraph();

        showTextOnFig(['New point added: (', num2str(x), ', ', num2str(y), ', ', num2str(z), ')']);

        % Restore original axes limits
        xlim(axDraw, xlimOriginal);
        ylim(axDraw, ylimOriginal);
        zlim(axDraw, zlimOriginal);
    end


    % Callback function to start dragging the point
    function startDragging(~, event)

        % Get the coordinates of the selected point from the event
        clickPoint = event.IntersectionPoint(1:3);

        % Find the index of the selected point in the graph structure G
        idx = findNearestPoint(clickPoint);

        % Create a temporary mask point
        hold(axDraw, "on");
        maskPoint = scatter3(axDraw, clickPoint(1), clickPoint(2), clickPoint(3), 100, [1 0.5 0], 'filled');
        hold(axDraw, "off");
    
        % Set the callback function for mouse movement
        set(fig, 'WindowButtonMotionFcn', {@dragging, maskPoint, idx});

        % Set the callback function for mouse release
        set(fig, 'WindowButtonUpFcn', {@stopDragging, maskPoint, idx});
    end

    % Callback function for dragging the point
    function dragging(~, ~, maskPoint, idx)
        % Get current point coordinates
        currPoint = get(axDraw, 'CurrentPoint');
        x = currPoint(1, 1);
        y = currPoint(1, 2);
        z = currPoint(1, 3);

        if idx 
            % Do not alter the third coordinate while moving the point in 2D planes
            switch toggleStates{currentState}
                case 'XY'
                    z = G.Nodes.Z(idx);
                case 'YZ'
                    x = G.Nodes.X(idx);
                case 'XZ'
                    y = G.Nodes.Y(idx);
            end
    
            % Update the position of the mask point
            set(maskPoint, 'XData', x, 'YData', y, 'ZData', z);
        end

    end

    % Callback function once the point dragging has stopped.
    function stopDragging(~, ~, maskPoint, idx)

        % Get the final position of the mask point
        x = maskPoint.XData;
        y = maskPoint.YData;
        z = maskPoint.ZData;

        if idx
            switch toggleStates{currentState}
                case 'XY'
                    z = G.Nodes.Z(idx);
                case 'YZ'
                    x = G.Nodes.X(idx);
                case 'XZ'
                    y = G.Nodes.Y(idx);
            end

            pIdx = 0; oldPIdx = G.Nodes.PtIdx(idx);
            if snapToSurfaceBtn.Value & ~isempty(rendererTable)
                [newCoords, pIdx] = getNearestPtOnSurface([x, y, z]);
                x = newCoords(1); y = newCoords(2); z = newCoords(3);
            end

            if np > 0 && checkDupPt([x,y,z])
                return; 
            end
       
            % Update the coordinates of the selected point in G.Nodes
            pushUndo({'edit', [G.Nodes.X(idx), G.Nodes.Y(idx), G.Nodes.Z(idx)], [x y z], oldPIdx, pIdx});
            G.Nodes{idx, {'X', 'Y', 'Z', 'PtIdx'}} = [x, y, z, pIdx];
        
            % Replot the graph on both axes
            rePlotGraph();

        end

        % Clear the mask point
        delete(maskPoint);

        % Remove the callback functions for mouse movement and release
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'WindowButtonUpFcn', '');
    end

    % Callback function to toggle between X-Y, Y-Z, and X-Z planes
    function toggleAxesCb(~, ~)
        % Set the next state in the toggleStates list 
        currentState = mod(currentState, length(toggleStates)) + 1;

      % Change the axes based on the current state
        switch toggleStates{currentState}
            case 'XY'
                view(axDraw, 0, 90);
                coordEditBoxLabel.String = 'Z:';
                toggleBtn.String = 'Y-Z plane';

                currLimits = get(axView, 'ZLim');
                midPt = (currLimits(1) + currLimits(2)) / 2;
                thirdAxisLimits = [midPt - thickness, midPt];               
                zlim(axDraw, thirdAxisLimits);

                axLim = get(axView, 'YLim'); % Restore the limits
                ylim(axDraw, axLim);
            case 'YZ'
                view(axDraw, 90, 0);
                coordEditBoxLabel.String = 'X:';
                toggleBtn.String = 'X-Z plane';
               
                currLimits = get(axView, 'XLim');
                midPt = (currLimits(1) + currLimits(2)) / 2;
                thirdAxisLimits = [midPt - thickness, midPt];
                xlim(axDraw, thirdAxisLimits);

                axLim = get(axView, 'ZLim'); % Restore the limits
                zlim(axDraw, axLim);
            case 'XZ'
                view(axDraw, 0, 0);
                coordEditBoxLabel.String = 'Y:';
                toggleBtn.String = 'X-Y plane';

                currLimits = get(axView, 'YLim');
                midPt = (currLimits(1) + currLimits(2)) / 2;
                thirdAxisLimits = [midPt - thickness, midPt];
                ylim(axDraw, thirdAxisLimits);

                axLim = get(axView, 'XLim'); % Restore the limits
                xlim(axDraw, axLim);
        end
        currentThirdCoord = midPt;
        coordEditBox.String = num2str(midPt);
        updateDrawBox(axView, thirdAxisLimits);

    end

    % Callback function for the Connect button
    function connectPointsCb(~, ~)
         % Toggle connect mode
        if (btnStates(1) == 0 && np > 0)
            showTextOnFig('Connect mode activated. Click two points to connect.');
            set(axDraw, 'ButtonDownFcn', @connectPoints);
            set(plotObjDraw, 'ButtonDownFcn', @connectPoints);
            updateBtnState(1);
        elseif (btnStates(1) == 0 && np == 0)
            updateBtnState(0);
            showTextOnFig('Connect mode not activated. Add points and try again.');
        else
            showTextOnFig('Connect mode deactivated.');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            set(plotObjDraw, 'ButtonDownFcn', '');
            updateBtnState(0);
            connectIndices = [];
        end
    end
    
    % Callback function for mouse click on axes during connect mode
    function connectPoints(~, ~)

        % Get current point coordinates
        currPoint = get(axDraw, 'CurrentPoint');
        x = currPoint(1, 1);
        y = currPoint(1, 2);
        z = currPoint(1, 3);
        
        % Find the nearest point to the clicked location
        switch toggleStates{currentState}
            case 'XY'
                distances = sqrt((G.Nodes.X - x).^2 + (G.Nodes.Y - y).^2);
            case 'YZ'
                distances = sqrt((G.Nodes.Y - y).^2 + (G.Nodes.Z - z).^2);
            case 'XZ'
                distances = sqrt((G.Nodes.X - x).^2 + (G.Nodes.Z - z).^2);
        end

        [~, nearestIdx] = min(distances);
     
        % Add the point index to the list of points to be connected
        connectIndices = [connectIndices, nearestIdx];
            
        % If two points are selected, connect them
        if length(connectIndices) == 2

              if shortestPathBtn.Value
                  undoList = shortestPath(connectIndices);
                  if ~isempty(undoList)
                      undoList = [undoList, {true}];
                      pushUndo(undoList);
                  end
              else     

                  % Add connection w/o shpath
                  if (~isempty(objSubNwk)) % if there is a reference mesh, make avg diameter from neighbors
                      meanDia = avgDia(connectIndices(1), connectIndices(2));
                  else % if no reference mesh, give diameter as 1
                      meanDia = 1;
                  end

                  G = addedge(G, connectIndices(1), connectIndices(2), meanDia);
                  GFaceIdx = findedge(G, connectIndices(1), connectIndices(2));
                  G.Edges.FaceIdx(GFaceIdx) = 0; % new edge, so FIdx = 0
    
                  pushUndo({'connect', [G.Nodes.X(connectIndices(1)), G.Nodes.Y(connectIndices(1)), G.Nodes.Z(connectIndices(1))], ...
                      [G.Nodes.X(connectIndices(2)), G.Nodes.Y(connectIndices(2)), G.Nodes.Z(connectIndices(2))], meanDia, 0});
                  rePlotGraph();
              end

              connectIndices = [];
        end

    end

    % Callback function for the disconnect button
    function disConnectCb(~, ~)
         % Toggle disconnect mode
        if (btnStates(6) == 0 && np > 0)
            showTextOnFig('Disconnect mode activated. Click two points to disconnect.');
            set(axDraw, 'ButtonDownFcn', @disConnectPts);
            set(plotObjDraw, 'ButtonDownFcn', @disConnectPts);
            updateBtnState(6);
        elseif (btnStates(6) == 0 && np == 0)
            updateBtnState(0);
            showTextOnFig('Disconnect mode not activated. Add points and try again.');
        else
            showTextOnFig('disconnect mode deactivated.');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            set(plotObjDraw, 'ButtonDownFcn', '');
            updateBtnState(0);
        end
    end

    function disConnectPts(~, ~)

        % Get current point coordinates
        currPoint = get(axDraw, 'CurrentPoint');
        x = currPoint(1, 1);
        y = currPoint(1, 2);
        z = currPoint(1, 3);
        
        % Find the nearest point to the clicked location
        switch toggleStates{currentState}
            case 'XY'
                distances = sqrt((G.Nodes.X - x).^2 + (G.Nodes.Y - y).^2);
            case 'YZ'
                distances = sqrt((G.Nodes.Y - y).^2 + (G.Nodes.Z - z).^2);
            case 'XZ'
                distances = sqrt((G.Nodes.X - x).^2 + (G.Nodes.Z - z).^2);
        end

        [~, nearestIdx] = min(distances);
     
        % Add the point index to the list of points to be disconnected
        disConnectIndices = [disConnectIndices, nearestIdx];
            
        % If two points are selected, disconnect them
        if length(disConnectIndices) == 2
             if findedge(G, disConnectIndices(1), disConnectIndices(2)) ~= 0
                  Idx = findedge(G, disConnectIndices(1), disConnectIndices(2));
                  
                  dia = G.Edges.Weight(Idx);
                  faceIdx = G.Edges.FaceIdx(Idx);

                  G = rmedge(G, disConnectIndices(1), disConnectIndices(2));
                  pushUndo({'disconnect', [G.Nodes.X(disConnectIndices(1)), G.Nodes.Y(disConnectIndices(1)), G.Nodes.Z(disConnectIndices(1))], ...
                      [G.Nodes.X(disConnectIndices(2)), G.Nodes.Y(disConnectIndices(2)), G.Nodes.Z(disConnectIndices(2))], dia, faceIdx});
                  rePlotGraph();
             end
             disConnectIndices = [];
        end

    end

    % Callback function for the 'Auto Connect' button
    function autoConnectCb(~, ~)
        if (btnStates(2) == 0)
            %autoConnectExistingPts(src, event);
            showTextOnFig('Auto-Connect mode activated. Click to add new points.');
            set(axDraw, 'ButtonDownFcn', @addConnectedPoint);
            updateBtnState(2);
        else
            showTextOnFig('Auto-Connect mode deactivated.');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            updateBtnState(0);
        end
    end


    function addConnectedPoint(src, event)
        addPoint(src, event);

        if np > 1

            if shortestPathBtn.Value
                undoList = shortestPath([(np - 1), np]);
                if ~isempty(undoList)
                    undoList = [undoList, {false}];
                    pushUndo(undoList);
                end    
            else

                % add connection w/o shpath

                if (~isempty(objSubNwk)) % if there is a reference mesh, make avg diameter from neighbors
                    meanDia = avgDia((np-1), np);
                else % if no reference mesh, give diameter as 1
                    meanDia = 1;
                end

                G = addedge(G, (np - 1), np, meanDia);
                GFaceIdx = findedge(G, (np - 1), np);
                G.Edges.FaceIdx(GFaceIdx) = 0; % new edge, so FIdx = 0
                
                pushUndo({'connect', [G.Nodes.X(np-1), G.Nodes.Y(np-1), G.Nodes.Z(np-1)], ...
                      [G.Nodes.X(np), G.Nodes.Y(np), G.Nodes.Z(np)], meanDia, 0});
    
                rePlotGraph();
            end

        end

    end

    function clearCb(~, ~)
        % Empty the graph structure, delete plot objects on axes
        G = graph();
        np = 0;
        delete(plotObjDraw);
        delete(plotObjView);

        % Reset the draw modes
        updateBtnState(0);

        undoStack = {};
        redoStack = {};
        updateUndoRedoButtons();

        shortestPathBtn.Value = 0;
        snapToSurfaceBtn.Value = 0;
               
        set(axDraw, 'ButtonDownFcn', @addPoint);

    end

    % Callback function for the "Delete Pts" button
    function deletePtsCb(~, ~)
        if (btnStates(3) == 0 && np > 0)
            showTextOnFig('Delete mode activated. Click on a point to delete it.');
            set(plotObjDraw, 'ButtonDownFcn', @deleteFromGraph);
            set(axDraw, 'ButtonDownFcn', @deleteFromGraph);
            updateBtnState(3);
        elseif (btnStates(3) == 0 && np == 0)
            updateBtnState(0);
            showTextOnFig('Delete mode not activated. Add points and try again.');        
        else
            showTextOnFig('Delete mode deactivated');
            set(plotObjDraw, 'ButtonDownFcn', '');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            updateBtnState(0);
        end
    end

    function deleteFromGraph(~, event)
        % Get the coordinates of the selected point from the event
        clickPoint = event.IntersectionPoint(1:3);

        % Find the index of the selected point in the graph structure G
        pointIdx = findNearestPoint(clickPoint);

        if pointIdx
            delFaces = find(G.Edges.EndNodes(:, 1) == pointIdx | G.Edges.EndNodes(:, 2) == pointIdx);
            for i=1:length(delFaces)

                src = G.Edges.EndNodes(delFaces(i), 1);
                dst = G.Edges.EndNodes(delFaces(i), 2);

                dia = G.Edges.Weight(delFaces(i));
                faceIdx = G.Edges.FaceIdx(delFaces(i));
               
                pushUndo({'disconnect', [G.Nodes.X(src), G.Nodes.Y(src), G.Nodes.Z(src)], ...
                  [G.Nodes.X(dst), G.Nodes.Y(dst), G.Nodes.Z(dst)], dia, faceIdx});
            end

            pushUndo({'del', [G.Nodes.X(pointIdx), G.Nodes.Y(pointIdx), G.Nodes.Z(pointIdx)], G.Nodes.PtIdx(pointIdx)});

            G = rmnode(G, pointIdx);
            np = np - 1;
            rePlotGraph()
        end

    end

    % Callback function for the "Edit Pts" button
    function editPtsCb(~, ~)
        if (btnStates(4) == 0 && np > 0)
            showTextOnFig('Edit mode activated. Click on a point to edit its coordinates.');
            set(plotObjDraw, 'ButtonDownFcn', @editPoint);
            set(axDraw, 'ButtonDownFcn', @editPoint);
            updateBtnState(4);

        elseif (btnStates(4) == 0 && np == 0)
            updateBtnState(0);
            showTextOnFig('Edit mode not activated. Add points and try again.');
        else
            showTextOnFig('Edit mode deactivated');
            set(plotObjDraw, 'ButtonDownFcn', '');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            updateBtnState(0);

        end
    end

    function editPoint(~, event)
        % Get the coordinates of the selected point from the event
        clickPoint = event.IntersectionPoint(1:3);
        
        % Find the index of the selected point in the graph structure G
        pointIdx = findNearestPoint(clickPoint);
        
        if pointIdx
            % Get the existing coordinates of the point
            existingCoords = G.Nodes(pointIdx, :);
            
            % Create a dialog box to edit coordinates
            dlgTitle = 'Edit Coordinates';
            prompt = {'X-coordinate:', 'Y-coordinate:', 'Z-coordinate:'};
            defaultInput = {num2str(existingCoords.X(1)), num2str(existingCoords.Y(1)),...
                num2str(existingCoords.Z(1))};
            dims = [1 50];
            editedCoords = inputdlg(prompt, dlgTitle, dims, defaultInput); %, opts, 'on');
            
            if ~isempty(editedCoords)
                % Update the coordinates of the selected point
                newX = str2num(editedCoords{1});
                newY = str2num(editedCoords{2});
                newZ = str2num(editedCoords{3});

                pIdx = 0; oldPIdx = G.Nodes.PtIdx(pointIdx);
                if snapToSurfaceBtn.Value & ~isempty(rendererTable)
                    [newCoords, pIdx] = getNearestPtOnSurface([newX, newY, newZ]);
                    newX = newCoords(1); newY = newCoords(2); newZ = newCoords(3);
                end

                if np > 0 && checkDupPt([newX, newY, newZ])
                    return; 
                end

                G.Nodes{pointIdx, {'X', 'Y', 'Z', 'PtIdx'}} = [newX, newY, newZ, pIdx];
                pushUndo({'edit', [existingCoords.X, existingCoords.Y, existingCoords.Z], [newX, newY, newZ], oldPIdx, pIdx});
                
                % Replot the graph
                rePlotGraph();
                expandAxesLimits([newX, newY, newZ]);
                % daspect(axDraw, [1 1 1]);
                % daspect(axView, [1 1 1]);
            end
        end
    end

    function movePtsCb(~, ~)        
        if (btnStates(5) == 0 && np > 0)
            showTextOnFig('Move Pts mode activated. Click on a point to move it using mouse.');
            set(plotObjDraw, 'ButtonDownFcn', @startDragging); % on the point
            set(axDraw, 'ButtonDownFcn', @startDragging); % near a point
            updateBtnState(5);
        elseif (btnStates(5) == 0 && np == 0)
            updateBtnState(0);
            showTextOnFig('Move mode not activated. Add points and try again.');
        else
            showTextOnFig('Move mode deactivated');
            set(plotObjDraw, 'ButtonDownFcn', '');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            updateBtnState(0);
        end
    end    

    % Callback function to update the third coordinate
    function updateThirdCoord(~, ~)

        prevThird = currentThirdCoord;
        prevThick = thickness;

        currentThirdCoord = str2double(coordEditBox.String);       
        if isnan(currentThirdCoord)
            errordlg('Please enter a valid number for the coordinate.', 'Invalid Input', 'modal');
            coordEditBox.String = num2str(prevThird);
            return;
        end

        thickness = str2double(thicknessBox.String);       
        if isnan(thickness)
            errordlg('Please enter a valid number for the coordinate.', 'Invalid Input', 'modal');
            thicknessBox.String = num2str(prevThick);
            return;
        end

        thirdAxes = [currentThirdCoord - thickness, currentThirdCoord];
        updateDrawBox(axView, thirdAxes);

        % Make the 2D axis a thin slice in third axis
        switch toggleStates{currentState}
            case 'XY'
                zlim(axDraw, thirdAxes);
            case 'YZ'
                xlim(axDraw, thirdAxes);
            case 'XZ'
                ylim(axDraw, thirdAxes);
        end

    end

    function loadNwkFileCb(~, ~)

        [fileName, filePath] = uigetfile('*.fMx', 'Select a face matrix file');
        
        if fileName == 0
            disp('File selection canceled');
            return;
        end
    
        % Open the file
        fileId = fopen(fullfile(filePath, fileName), 'rt');
        if fileId == -1
            error('File cannot be opened: %s', fileName);
        end
 
        showTextOnFig("Loading nwk in process...");

        [path, name, ~] = fileparts(fullfile(filePath, fileName));
        nwk = nwkHelp.load(fullfile(path, name));

        if np > 0 
            oldPts = [G.Nodes.X, G.Nodes.Y, G.Nodes.Z];
            newPts = nwk.ptCoordMx;
            overlap = findOverlap(oldPts, newPts);
    
            if overlap >= 50
                warningMsg = sprintf('There is an overlap of %.2f%% of points, hence network not loaded.', overlap);
                msgbox(warningMsg, 'Overlap Detected', 'warn');
                fclose(fileId);
                showTextOnFig("Loading nwk cancelled due to overlap.");
                return;
            elseif overlap > 0 
                choice = questdlg(sprintf('There is %.2f%% overlap. Do you want to proceed with loading the network?', overlap), ...
                                  'Overlap Detected', ...
                                  'Yes', 'No', 'No');
                if strcmp(choice, 'No')
                    fclose(fileId);
                    showTextOnFig("Loading nwk cancelled due to overlap.");
                    return;
                end
            end
        end

        if nwk.nf
            nwk.faceMx(:,2) = nwk.faceMx(:,2) + np;
            nwk.faceMx(:,3) = nwk.faceMx(:,3) + np;
        end

        origPIdFilename = [fullfile(path,name), '.originalPIdx'];
        if exist(origPIdFilename, 'file') == 2
            Pid = load(origPIdFilename);
        else
            Pid = zeros(nwk.np, 1); 
        end

        origFIdFilename = [fullfile(path,name), '.originalFIdx'];
        if exist(origFIdFilename, 'file') == 2
            Fid = load(origFIdFilename);
        else
            Fid = zeros(nwk.nf, 1); 
        end

        % Storing table from G, appending new entries to that table,
        % restoring that table in G
        if np > 0
            nodesTable = G.Nodes; edgesTable = G.Edges;
        else
            nodesTable = table(); edgesTable = table();
        end

        newNodesTable = table(nwk.ptCoordMx(:,1), nwk.ptCoordMx(:,2), nwk.ptCoordMx(:,3), Pid, 'VariableNames', {'X', 'Y', 'Z', 'PtIdx'});
        newEdgesTable = table(nwk.faceMx(:, 2:3), nwk.dia, Fid, 'VariableNames', {'EndNodes', 'Weight', 'FaceIdx'});

        nodesTable = [nodesTable ; newNodesTable];
        edgesTable = [edgesTable ; newEdgesTable];

        prevNp = size(G.Nodes, 1);
        G = []; G = graph(edgesTable);

        if size(G.Nodes, 1) < (prevNp+nwk.np)
            G = addnode(G, (prevNp + nwk.np - size(G.Nodes, 1)));
        end
        G.Nodes = nodesTable;

        % Replot the graph on both axes
        rePlotGraph();
        expandAxesLimits(nwk.ptCoordMx);
        % daspect(axDraw, [1 1 1]);
        % daspect(axView, [1 1 1]);

        showTextOnFig("Loading complete.");

    end

    function loadToViewCb(~, ~)

         [file, path] = uigetfile('*.bmp;*.fMx;*.stl;*.tif;*.nwkx', 'Select a file to load');
         if isequal(file, 0) || isequal(path, 0)
              disp('File selection canceled');
              return
         end

         showTextOnFig("Loading obj in process...");

         [~, ~, ext] = fileparts(fullfile(path, file));

         if strcmp(ext, '.bmp')
               [drawHandle, viewHandle] = loadBmp(path, file);
               file = [file, '(z=', num2str(currentThirdCoord), ')'];
         elseif strcmp(ext, '.fMx') || strcmp(ext, '.nwkx')
               [drawHandle, viewHandle] = loadNwkToView(path, file);
         elseif strcmp(ext, '.stl')
               [drawHandle, viewHandle] = loadStl(path, file);
         elseif strcmp(ext, '.tif')
               [drawHandle, viewHandle] = loadTiff(path, file);
         end

         if strcmp(ext, '.nwkx')
             ext = '.fMx';
         end
         
         rendererTable = [rendererTable; {fullfile(path, file), ext, {drawHandle}, {viewHandle}}];

         showTextOnFig("Loading complete.");

    end

    function [drawHandle, viewHandle] = loadNwkToView(path, file)

        filename = fullfile(path, file);
        [~, name, ext] = fileparts(filename);
        if strcmp(ext, '.fMx') || strcmp(ext, '.nwkx')
            filename = fullfile(path, name);
        end
        objNwk = nwkHelp.load(filename);

        lsFile = [fullfile(path, name), '.ls'];
        if exist(lsFile, 'file') == 2
            objNwk.ls = load(lsFile);
        end

        if (isempty(faceEditBox.String))
            faceSelection = (1:objNwk.nf)'; % the whole graph
        else
            faceSelection = toolHelper.faceEditCb(faceEditBox.String, objNwk);
        end

        if (isempty(ptEditBox.String))
            ptSelection = (1:objNwk.np)'; % the whole graph
        else
            ptSelection = toolHelper.ptEditCb(ptEditBox.String, objNwk);
        end

        updateRefMesh(objNwk, faceSelection, ptSelection);
     
        hold(axDraw, 'on');
        drawHandle = plot(axDraw, objGraph, 'XData', objGraph.Nodes.X, 'YData', objGraph.Nodes.Y,...
            'ZData', objGraph.Nodes.Z, 'Marker', 'o', 'NodeColor', [0.4 0.4 0.4], 'EdgeColor', [0.4 0.4 0.4], ...
            'NodeLabel', {}, 'EdgeLabel', {}, 'ShowArrows', 'off'); 
        set(drawHandle, 'HitTest', 'off');
        hold(axDraw, 'off');

        hold(axView, 'on');
        viewHandle = plot(axView, objGraph, 'XData', objGraph.Nodes.X, 'YData', objGraph.Nodes.Y,...
            'ZData', objGraph.Nodes.Z, 'Marker', 'o', 'NodeColor', [0.4 0.4 0.4], 'EdgeColor', [0.4 0.4 0.4], ...
            'NodeLabel', {}, 'EdgeLabel', {}, 'ShowArrows', 'off'); 
        hold(axView, 'off');

        expandAxesLimits(objSubNwk.ptCoordMx);
    end

    function [hImage2D, hImage3D] = loadBmp(path, file)
         if ~strcmp(toggleStates{currentState}, 'XY')
             showTextOnFig('Please switch to the X-Y plane and try adding the image again.');
             return 
         end

         img = imread(fullfile(path, file));

         [imgHeight, imgWidth, ~] = size(img);
         xLimits = xlim(axDraw);
         yLimits = ylim(axDraw);
         zCoord = currentThirdCoord;
         xNormalized = linspace(xLimits(1), xLimits(2), imgWidth);
         yNormalized = linspace(yLimits(1), yLimits(2), imgHeight);

         [x, y] = meshgrid(xNormalized, yNormalized);
         hold(axView, "on");
         hImage3D = surf(axView, x, y, zCoord * ones(size(x)), img,...
             'FaceColor', 'texturemap', 'EdgeColor', 'none');
         hold(axView, "off");

         hold(axDraw, "on");
         hImage2D = surf(axDraw, [xLimits(1), xLimits(2)], [yLimits(1), yLimits(2)], zCoord * ones(2),...
             'CData', img, 'FaceColor', 'texturemap', 'EdgeColor', 'none', 'FaceAlpha', 1.0);
         uistack(hImage2D, 'bottom');
         set(hImage2D, 'HitTest', 'off');
         grid(axDraw, 'on');
         hold(axDraw, "off");

    end

    function [drawHandle, viewHandle] = loadStl(path, file)

        [TR, ~, ~, ~] = stlread(fullfile(path, file));
        points = TR.Points;
        faces = TR.ConnectivityList;

        hold(axDraw, "on");
        drawHandle = patch(axDraw, 'Faces', faces, 'Vertices', points, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', '[0.75 0.75 0.75]', 'FaceAlpha', 0.2);
        set(drawHandle, 'HitTest', 'off');
        hold(axDraw, "off");

        hold(axView, "on");
        viewHandle = patch(axView, 'Faces', faces, 'Vertices', points, 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', '[0.75 0.75 0.75]', 'FaceAlpha', 0.2);
        hold(axView, "off");

        expandAxesLimits(points);
        % daspect(axDraw, [1 1 1]);
        % daspect(axView, [1 1 1]);

    end

   function [drawHandle, viewHandle] = loadTiff(path, file)
        volData = getVolumeData(fullfile(path, file));
        num_images = size(volData, 4);
        customZCoords = [];
    
        % Create a small uifigure window to edit Z-coordinates
        tifFig = uifigure('Position', [500, 500, 300, 200], 'Name', 'Set Z-Coordinates');
        uilabel(tifFig, 'Position', [20, 150, 260, 40], ...
                      'Text', 'Enter Z-coordinates for each frame:');
        txtArea = uitextarea(tifFig, 'Position', [20, 80, 260, 60], ...
                             'Value', num2str(1:num_images), 'HorizontalAlignment', 'left', ...
                             'WordWrap', 'on', 'Editable', 'on');

        uibutton(tifFig, 'Position', [110, 30, 70, 25], ...
                       'Text', 'OK', 'ButtonPushedFcn', @okCb);

        uiwait(tifFig);

        function okCb(~, ~)
            customZCoords = str2num(txtArea.Value{1});
            if length(customZCoords) ~= num_images
                errordlg(['Please enter exactly ', num2str(num_images), ' z-coordinates.'], 'Error');
                return;
            end
            delete(tifFig);
            [drawHandle, viewHandle] = plotTiff(volData, customZCoords);
            
            % Expand Axes in Z direction
            ZLimits = zlim(axView);
            maxZ = max(max(customZCoords), ZLimits(2));
            minZ = min(min(customZCoords), ZLimits(1));
            set(axView, 'ZLim', [minZ, maxZ]);
            switch toggleStates{currentState}
                case 'YZ'
                    set(axDraw, 'ZLim', [minZ, maxZ]);
                    updateDrawBox(axView, xlim(axDraw)); 
                case 'XZ'
                    set(axDraw, 'ZLim', [minZ, maxZ]);
                    updateDrawBox(axView, ylim(axDraw)); 
            end
            % daspect(axDraw, [1 1 1]);
            % daspect(axView, [1 1 1]);
        end

        hideSliceBtn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Hide Slices', ...
            'Position', [1100, 20, 80, 30], 'Callback', {@hideFigCb, customZCoords});

   end

   function hideFigCb(~, ~, customZCoords)
       % Create a dropdown menu for hiding slices
       hideSliceFig = uifigure('Position', [500, 500, 300, 200], 'Name', 'Hide Slices');
       uilabel(hideSliceFig, 'Position', [10, 160, 100, 20], 'Text', 'Hide Slices: ');
       hideSlices = uilistbox(hideSliceFig, 'Position', [120, 40, 150, 150], ...
           'Items', [{'None'}, arrayfun(@(x) ['z=' num2str(x)], customZCoords, 'UniformOutput', false)], ...
           'Multiselect', 'on');

       uibutton(hideSliceFig, 'Position', [50, 5, 70, 25], 'Text', 'OK', ...
            'ButtonPushedFcn', @okCb);
       uibutton(hideSliceFig, 'Position', [150, 5, 70, 25], 'Text', 'Cancel', ...
            'ButtonPushedFcn', @(~, ~) close(hideSliceFig));

       function okCb(~, ~)
            showTextOnFig("Hiding requested slice in process...");

            selectedSlices = hideSlices.Value;
            if any(strcmp(selectedSlices, 'None'))
              selectedIndices = 'None';
            else
              selectedIndices = cellfun(@(x) str2double(regexprep(x, 'z=', '')), selectedSlices);
            end
            tifRow = find(strcmp(rendererTable.type, '.tif'));
    
            if strcmp(selectedSlices{1}, 'None')
                for k = 1:length(rendererTable.drawHandle{tifRow})
                    alphaData = rendererTable.drawHandle{tifRow}{k}.UserData;
                    set([rendererTable.drawHandle{tifRow}{k}, rendererTable.viewHandle{tifRow}{k}], 'FaceVertexAlphaData', alphaData);
                end
            else
                [~, selectedIdx] = ismember(selectedIndices, customZCoords);
                for k = 1:length(selectedIdx)
                   set([rendererTable.drawHandle{tifRow}{selectedIdx(k)}, rendererTable.viewHandle{tifRow}{selectedIdx(k)}], 'FaceVertexAlphaData', 0.0);
                end
            end
            close(hideSliceFig);
            showTextOnFig("Hiding slices complete.");
       end 
   end

   function [drawHandle, viewHandle] = plotTiff(volData, customZCoords)
        [rows, cols, ~, num_images] = size(volData);
        
        drawHandle = cell(num_images, 1);
        viewHandle = cell(num_images, 1);
        
        xLimits = xlim(axView);
        yLimits = ylim(axView);
        
        for k = 1:num_images
            img = volData(:, :, :, k);
            zCoord = customZCoords(k);
        
            blackPixels = (img(:,:,1) == 0 & img(:,:,2) == 0 & img(:,:,3) == 0);
            nonBlackPixels = ~blackPixels;
    
            % Assign white color to non-black pixels
            img(repmat(nonBlackPixels, [1, 1, 3])) = 255;
            
            alphaData = blackPixels;
            
            x = linspace(xLimits(1), xLimits(2), cols);
            y = linspace(yLimits(1), yLimits(2), rows);
            z = zCoord * ones(size(rows));
            [X, Y, Z] = meshgrid(x, y, z);
            
            % Generate vertices and faces
            vertices = [X(:), Y(:), Z(:)];
            faces = delaunay(X(:), Y(:));
            
            % Generate color and alpha data for patch
            faceColorData = reshape(img, [], 3);
            alphaDataPatch = double(alphaData(:));
            
            hold(axView, "on");
            hPatch3D = patch(axView, 'Vertices', vertices, 'Faces', faces, ...
                'FaceVertexCData', faceColorData, ...
                'FaceAlpha', 'flat', 'FaceVertexAlphaData', alphaDataPatch, ...
                'AlphaDataMapping', 'none', 'EdgeColor', 'none', 'FaceColor', 'flat');
            hold(axView, "off");
            viewHandle{k} = hPatch3D;
            hPatch3D.UserData = alphaDataPatch;
            
            hold(axDraw, "on");
            hPatch2D = patch(axDraw, 'Vertices', vertices, 'Faces', faces, ...
                'FaceVertexCData', faceColorData, ...
                'FaceAlpha', 'flat', 'FaceVertexAlphaData', alphaDataPatch, ...
                'AlphaDataMapping', 'none', 'EdgeColor', 'none', 'FaceColor', 'flat');
            uistack(hPatch2D, 'bottom');
            set(hPatch2D, 'HitTest', 'off');
            hold(axDraw, "off");
            drawHandle{k} = hPatch2D;
            hPatch2D.UserData = alphaDataPatch;
        end
    end

        
    % Callback function to clear Bmp, Nwk, Stl objects
    function clearObjCb(~, ~)
        objNames = rendererTable.fileName;
        
        % Create a dialog box with dropdown menu
        [selection, ok] = listdlg('ListString', objNames, 'SelectionMode', 'single',...
            'PromptString', 'Select an object to clear:', 'Name', 'Select Object', 'ListSize', [300, 100]);        
        
        if ok
            if isequal(rendererTable.type(selection), '.tif')
                num_images = size(rendererTable.drawHandle{selection}, 1);
                for k = 1:num_images
                   delete(rendererTable.drawHandle{selection}{k});
                   delete(rendererTable.viewHandle{selection}{k});
                end
                delete(hideSliceBtn);
            else
                delete(rendererTable.drawHandle{selection});
                delete(rendererTable.viewHandle{selection});
            end
            rendererTable(selection, :) = [];
            rendererTable(any(ismissing(rendererTable), 2), :) = [];
            
            objNwk = []; objGraph = []; objSubNwk = [];
            % should we clear objGraph too, for shortest path?
        end

    end
    
    % Callback function to save the points to a file
    function saveNwkCb(~, ~)
        % Check if G.Edges and G.Nodes are not empty
        if isempty(G.Nodes)
            disp('No points to save');
            return;
        end

        [file, path] = uiputfile('*.fMx', 'Save faces As');
        if isequal(file, 0) || isequal(path, 0)
            disp('Saving canceled.');
            return;
        end

        [~, baseName, ~] = fileparts(file); pFileName = [baseName, '.pMx']; dFileName = [baseName, '.dia'];
  
        fileID = fopen(fullfile(path, pFileName), 'w');
        fprintf(fileID, '%.15f %.15f %.15f\n', [G.Nodes.X, G.Nodes.Y, G.Nodes.Z]');
        fclose(fileID);

        fileID = fopen(fullfile(path, file), 'w');
        fprintf(fileID, '%d %d %d %d %d\n', [ones(height(G.Edges), 1), G.Edges.EndNodes(:, 1), G.Edges.EndNodes(:, 2), ...
            zeros(height(G.Edges), 1), zeros(height(G.Edges), 1)]');
        fclose(fileID);

        fileID = fopen(fullfile(path, dFileName), 'w');
        fprintf(fileID, '%.15f\n', G.Edges.Weight);
        fclose(fileID);

        showTextOnFig(['Point coordinate matrix saved as: ', fullfile(path, pFileName)]);
        showTextOnFig(['Face matrix saved as: ', fullfile(path, file)]);
        showTextOnFig(['Diameter matrix saved as: ', fullfile(path, dFileName)]);

        if (size(find(G.Nodes.PtIdx > 0), 1))
            ptFile = [baseName, '.originalPIdx'];
            fileID = fopen(fullfile(path, ptFile), 'w');
            fprintf(fileID, '%d\n', G.Nodes.PtIdx);
            fclose(fileID);
            showTextOnFig(['Original Point Index vector saved as: ', fullfile(path, ptFile)]);
        end

        if (size(find(G.Edges.FaceIdx > 0), 1))
            faceFile = [baseName, '.originalFIdx'];
            fileID = fopen(fullfile(path, faceFile), 'w');
            fprintf(fileID, '%d\n', G.Edges.FaceIdx);
            fclose(fileID);
            showTextOnFig(['Original Face Index vector saved as: ', fullfile(path, faceFile)]);
        end

    end

    % Update button state
    function updateBtnState(buttonIdx)

        if buttonIdx > 0
            set(btnHandles, 'BackgroundColor', [1, 1, 1], 'ForegroundColor', [0, 0, 0]);
            set(btnHandles(buttonIdx), 'BackgroundColor', [0, 0, 1], 'ForegroundColor', [1, 1, 1]);

            btnStates(:) = 0; % Reset everything to 0
            btnStates(buttonIdx) = 1; % Set the selected button to 1
        else
            % Reset all buttons to white and active
            set(btnHandles, 'BackgroundColor', [1, 1, 1], 'ForegroundColor', [0, 0, 0]);
            btnStates(:) = 0;
        end

        return;
    end
    
    function showTextOnFig(text)
        set(showText, 'String', text);
    end

    % Function to toggle Object visibility
    function hideObjCb(~, ~)

        if isempty(rendererTable)
            showTextOnFig('No objects to hide, load objects and try again...')
            return
        end

        showObj = ~showObj; 
        bmpRows = find(strcmp(rendererTable.type, '.bmp'));       
        objRows = find(strcmp(rendererTable.type, '.fMx') | strcmp(rendererTable.type, '.stl'));
        tifRows = find(strcmp(rendererTable.type, '.tif'));

        if showObj
            if ~isempty(bmpRows)
               set([rendererTable.drawHandle{bmpRows}, rendererTable.viewHandle{bmpRows}], 'FaceAlpha', 0.5); 
            end    
            if ~isempty(objRows)
               set([rendererTable.drawHandle{objRows}, rendererTable.viewHandle{objRows}], 'Visible', 'on');
            end
            if ~isempty(tifRows)
               for k = 1:length(rendererTable.drawHandle{tifRows})
                   alphaData = rendererTable.drawHandle{tifRows}{k}.UserData;
                   set([rendererTable.drawHandle{tifRows}{k}, rendererTable.viewHandle{tifRows}{k}], 'FaceVertexAlphaData', alphaData);
               end 
            end
            set(hideObjBtn, 'String', 'Hide Obj');
        else
            if ~isempty(bmpRows)
               set([rendererTable.drawHandle{bmpRows}, rendererTable.viewHandle{bmpRows}], 'FaceAlpha', 0.0); 
            end   
            if ~isempty(objRows)
               set([rendererTable.drawHandle{objRows}, rendererTable.viewHandle{objRows}], 'Visible', 'off');
            end
            if ~isempty(tifRows)
               set([rendererTable.drawHandle{tifRows}{:}, rendererTable.viewHandle{tifRows}{:}], 'FaceVertexAlphaData', 0.0);
            end
            set(hideObjBtn, 'String', 'Show Obj');
        end

    end 

    function selectBox(~, ~)
        set(fig, 'WindowButtonMotionFcn', @moveBox);
        set(fig, 'WindowButtonUpFcn', @unselectBox);
    end
    
    function unselectBox(~, ~)
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'WindowButtonUpFcn', '');
        switch toggleStates{currentState}
            case 'XY'
                z = get(axDraw, 'ZLim');
                currentThirdCoord = z(2);
            case 'YZ'
                x = get(axDraw, 'XLim');
                currentThirdCoord = x(2);
            case 'XZ'
                y = get(axDraw, 'YLim');
                currentThirdCoord = y(2);
        end
        coordEditBox.String = num2str(currentThirdCoord, "%.2f");
    end

    function moveBox(~, ~)
       currPosition = get(axView, 'CurrentPoint');
       switch toggleStates{currentState}
           case 'XY'
               z = currPosition(2, 3);
               thirdAxes = [z - thickness, z];
               if ((axView.ZLim(1) <= thirdAxes(2) && thirdAxes(2) <= axView.ZLim(2)) || (axView.ZLim(1) <= thirdAxes(1) && thirdAxes(1) <= axView.ZLim(2)))
                   updateDrawBox(axView, thirdAxes);
                   zlim(axDraw, thirdAxes);
               end
           case 'YZ'
               x = currPosition(2, 1);
               thirdAxes = [x - thickness, x];
              if ((axView.XLim(1) <= thirdAxes(2) && thirdAxes(2) <= axView.XLim(2)) || (axView.XLim(1) <= thirdAxes(1) && thirdAxes(1) <= axView.XLim(2)))
                   updateDrawBox(axView, thirdAxes);
                   xlim(axDraw, thirdAxes);
               end
           case 'XZ'
               y = currPosition(2, 2);
               thirdAxes = [y - thickness, y];
               if ((axView.YLim(1) <= thirdAxes(2) && thirdAxes(2) <= axView.YLim(2)) || (axView.YLim(1) <= thirdAxes(1) && thirdAxes(1) <= axView.YLim(2)))
                   updateDrawBox(axView, thirdAxes);
                   ylim(axDraw, thirdAxes);
               end
       end
    end
    
    function updateDrawBox(ax, thirdAxes)
           
        switch toggleStates{currentState}
            case 'XY'
                [x, y, z] = meshgrid(xlim(ax), ylim(ax), thirdAxes);
            case 'YZ'
                [x, y, z] = meshgrid(thirdAxes, ylim(ax), zlim(ax));
            case 'XZ'
                [x, y, z] = meshgrid(xlim(ax), thirdAxes, zlim(ax));
        end

        vertices = [x(:), y(:), z(:)];
        faces = [
            1, 2, 4, 3; % Bottom face
            5, 6, 8, 7; % Top face
            1, 2, 6, 5; % Front face
            3, 4, 8, 7; % Back face
            1, 3, 7, 5; % Left face
            2, 4, 8, 6; % Right face
        ];
        set(drawBox, 'Faces', faces, 'Vertices', vertices);
    end

    function undoCb(~, ~)
        if ~isempty(undoStack)
            lastOp = undoStack{end};
            undoStack(end) = [];
    
            switch lastOp{1}
                case 'add'

                    G = rmnode(G, findNearestPoint(lastOp{2}));
                    np = size(G.Nodes, 1);
                    pushRedo({'del', lastOp{2}, lastOp{3}});

                case 'del'

                    G = addnode(G, 1);
                    np = size(G.Nodes, 1);
                    G.Nodes{np, {'X', 'Y', 'Z'}} = lastOp{2};
                    G.Nodes.PtIdx(np) = lastOp{3};
                    pushRedo({'add', lastOp{2}, lastOp{3}});

                case 'edit'
                    
                    pointIdx = findNearestPoint(lastOp{3});
                    G.Nodes{pointIdx, {'X', 'Y', 'Z'}} = lastOp{2};
                    G.Nodes.PtIdx(pointIdx) = lastOp{4};

                    pushRedo({'edit', lastOp{3}, lastOp{2}, lastOp{5}, lastOp{4}});

                case 'disconnect'
                    
                    pointIdx1 = findNearestPoint(lastOp{2});
                    pointIdx2 = findNearestPoint(lastOp{3});
                    G = addedge(G, pointIdx1, pointIdx2, lastOp{4});
                    
                    GFaceIdx = findedge(G, pointIdx1, pointIdx2);
                    G.Edges.FaceIdx(GFaceIdx) = lastOp{5};

                    pushRedo({'connect', lastOp{2}, lastOp{3}, lastOp{4}, lastOp{5}});

                case 'connect'

                    pointIdx1 = findNearestPoint(lastOp{2});
                    pointIdx2 = findNearestPoint(lastOp{3});
                    G = rmedge(G, pointIdx1, pointIdx2);

                    pushRedo({'disconnect', lastOp{2}, lastOp{3}, lastOp{4}, lastOp{5}});

                case 'shPath'
                    undoNodes = lastOp{2};
                    connFlag = lastOp{4}; 

                    % is it better to backtrack the nodes and delete?
                    % intermittent issue - some pts/faces not deleted on
                    % first undo. why?, is the issue direct matching? match
                    % with tolerance will solve it?

                    for j = size(undoNodes, 1):-1:2

                        ptIdx1 = findNearestPoint(undoNodes(j, :));
                        ptIdx2 = findNearestPoint(undoNodes(j-1, :));

                        G = rmedge(G, ptIdx2, ptIdx1);
                                                
                        if (degree(G, ptIdx1) == 0)
                            if ~connFlag % in autoconnect
                                 G = rmnode(G, ptIdx1);
                            elseif connFlag && j < size(undoNodes, 1) % in connect mode - first node not deleted
                                 G = rmnode(G, ptIdx1);
                            end
                        end
                    end

                    pushRedo({'shPath', lastOp{2}, lastOp{3}, lastOp{4}});
            end
            rePlotGraph();
        end
    end
    
    function redoCb(~, ~)
        if ~isempty(redoStack)
            lastOp = redoStack{end};
            redoStack(end) = [];
    
            switch lastOp{1}
                case 'del'
                    G = addnode(G, 1);
                    np = size(G.Nodes, 1);
                    
                    G.Nodes{np, {'X', 'Y', 'Z'}} = lastOp{2};
                    G.Nodes.PtIdx(np) = lastOp{3};
                    pushUndo({'add', lastOp{2}, lastOp{3}});

                case 'add'

                    G = rmnode(G, findNearestPoint(lastOp{2}));
                    np = size(G.Nodes, 1);
                    pushUndo({'del', lastOp{2}, lastOp{3}});

                case 'edit'

                    pointIdx = findNearestPoint(lastOp{3});
                    G.Nodes{pointIdx, {'X', 'Y', 'Z'}} = lastOp{2};
                    G.Nodes.PtIdx(pointIdx) = lastOp{4};

                    pushUndo({'edit', lastOp{3}, lastOp{2}, lastOp{5}, lastOp{4}});

                case 'disconnect'

                    pointIdx1 = findNearestPoint(lastOp{2});
                    pointIdx2 = findNearestPoint(lastOp{3});

                    G = addedge(G, pointIdx1, pointIdx2, lastOp{4});
                    GFaceIdx = findedge(G, pointIdx1, pointIdx2);
                    G.Edges.FaceIdx(GFaceIdx) = lastOp{5};
                    
                    pushUndo({'connect', lastOp{2}, lastOp{3}, lastOp{4}, lastOp{5}});

                case 'connect'

                    pointIdx1 = findNearestPoint(lastOp{2});
                    pointIdx2 = findNearestPoint(lastOp{3});
                    
                    G = rmedge(G, pointIdx1, pointIdx2);
                    
                    pushUndo({'disconnect', lastOp{2}, lastOp{3}, lastOp{4}, lastOp{5}});

                case 'shPath'

                    redoNodes = lastOp{2};
                    redoPtIdx = lastOp{3};

                    ptIdx2 = find(G.Nodes.X == redoNodes(1,1) & G.Nodes.Y == redoNodes(1,2) & G.Nodes.Z == redoNodes(1,3));

                    if isempty(ptIdx2)  % If node doesn't exist, add it
                         G = addnode(G, 1);
                         np = size(G.Nodes, 1);
                         G.Nodes{np, {'X', 'Y', 'Z', 'PtIdx'}} = [redoNodes(1, :), redoPtIdx(1)];
                         ptIdx2 = np;
                    end

                    for j = 2:size(redoNodes, 1)

                        ptIdx1 = ptIdx2;
                        ptIdx2 = find(G.Nodes.X == redoNodes(j,1) & G.Nodes.Y == redoNodes(j,2) & G.Nodes.Z == redoNodes(j,3));
                        
                        if isempty(ptIdx2)  % If node doesn't exist, add it
                            G = addnode(G, 1);
                            np = size(G.Nodes, 1);
                            G.Nodes{np, {'X', 'Y', 'Z', 'PtIdx'}} = [redoNodes(j, :), redoPtIdx(j)];
                            ptIdx2 = np;
                        end
                        
                        objP1 = find(objGraph.Nodes.X == G.Nodes.X(ptIdx1) & objGraph.Nodes.Y == G.Nodes.Y(ptIdx1) & objGraph.Nodes.Z == G.Nodes.Z(ptIdx1));
                        objP2 = find(objGraph.Nodes.X == G.Nodes.X(ptIdx2) & objGraph.Nodes.Y == G.Nodes.Y(ptIdx2) & objGraph.Nodes.Z == G.Nodes.Z(ptIdx2));
                        
                        objFaceInd = findedge(objGraph, objP1, objP2); objFaceInd = objFaceInd(1); % for duplicate edges(1)
                        origFaceIdx = objGraph.Edges.FaceIdx(objFaceInd);

                        subNwkIdx = find(objSubNwk.fIdx == origFaceIdx);
                        origDia = objSubNwk.dia(subNwkIdx);

                        G = addedge(G, ptIdx1, ptIdx2, origDia);

                        GFaceIdx = findedge(G, ptIdx1, ptIdx2);
                        G.Edges.FaceIdx(GFaceIdx) = origFaceIdx;
                    end
                    pushUndo({'shPath', lastOp{2}, lastOp{3}, lastOp{4}});
            end
            rePlotGraph();
        end
    end

    function indexingCb(~, ~)
        indexOn = ~indexOn;
        if indexOn
            indexBtn.String = 'Indexing Off';
        else
            indexBtn.String = 'Indexing On';
        end
        
        if np > 0
            rePlotGraph();
        end
    end

    function directionsCb(~, ~)
        dirOn = ~dirOn;
        if dirOn
            dirBtn.String = 'Directions Off';
            arrowSize = 10;
        else
            dirBtn.String = 'Directions On';
            arrowSize = 0; 
        end
        
        if np > 0
            rePlotGraph();
        end

    end

    function aspectCb(~, ~)
        aspectOn = ~aspectOn;

        if aspectOn
            daspect(axView, [1, 1, 1]);
            daspect(axDraw, [1, 1, 1]);
            set(aspectBtn, 'BackgroundColor', [0, 0, 1], 'ForegroundColor', [1, 1, 1]);
        else
            daspect(axView, 'auto');
            daspect(axDraw, 'auto');
            set(aspectBtn, 'BackgroundColor', [1, 1, 1], 'ForegroundColor', [0, 0, 0]);
        end    
    end
     
    function shortestPathCb(~, ~)

          if shortestPathBtn.Value    
     
             if (isempty(objGraph) || isempty(objSubNwk))
                % creates ObjSubNetwork and ObjGraph based on conditions 
                displaySelectionsCb();
             end

             snapToSurfaceBtn.Value = 1;

         else
             showTextOnFig('Shortest path mode deactivated.');
             set(axDraw, 'ButtonDownFcn', @addPoint);
             snapToSurfaceBtn.Value = 0;
         end
         
     end

    function undoList = shortestPath(shortestPathIndices)
            
        pt1 = [G.Nodes.X(shortestPathIndices(1)), G.Nodes.Y(shortestPathIndices(1)), G.Nodes.Z(shortestPathIndices(1))];
        pt2 = [G.Nodes.X(shortestPathIndices(2)), G.Nodes.Y(shortestPathIndices(2)), G.Nodes.Z(shortestPathIndices(2))];

        ptIdx1 = findNearestPtOnSurf(pt1);
        ptIdx2 = findNearestPtOnSurf(pt2);
        
        if isempty(ptIdx1) || isempty(ptIdx2)
            showTextOnFig(['Added point is not on the surface backdrop or is on wrong surface backdrop.' ...
                ' Please add point on surface and try again...']);
            shortestPathBtn.Value = 0;
            undoList = {};
            return;
        end    

        [path, ~] = shortestpath(objGraph, ptIdx1, ptIdx2);

        if length(path) < 2
            showTextOnFig('No path exists between the two points');
            undoList = {};
            return;
        end

        % Add the node coordinates to undoNodes
        np = height(G.Nodes);
        undoNodes = zeros(length(path), 3);
        undoNodes(1, :) = pt1; % first point coords
        undoPtIdx(1) = G.Nodes.PtIdx(shortestPathIndices(1));

        pathIdx = zeros(1, length(path)); pathIdx(1) = shortestPathIndices(1);
        edgeIdx = zeros(1, length(path)-1);

        for i = 2:length(pathIdx)

            ptCoords = [objGraph.Nodes.X(path(i)), objGraph.Nodes.Y(path(i)), objGraph.Nodes.Z(path(i))];
            ptIdx = find(G.Nodes.X == ptCoords(1) & G.Nodes.Y == ptCoords(2) & G.Nodes.Z == ptCoords(3));
            
            if isempty(ptIdx) % node doesn't exist in G
                np = np + 1;
                G = addnode(G, 1);
                G.Nodes{np, {'X', 'Y', 'Z', 'PtIdx'}} = [ptCoords, objGraph.Nodes.PtIdx(path(i))];
                pathIdx(i) = np;
            else
                pathIdx(i) = ptIdx;
            end
            undoNodes(i, :) = ptCoords;
            undoPtIdx(i) = G.Nodes.PtIdx(pathIdx(i));

            fIdx = findedge(G, pathIdx(i-1), pathIdx(i));

            if fIdx == 0 % edge doesn't exist in G

                faceInd = findedge(objGraph, path(i-1), path(i));
                origfaceInd = objGraph.Edges.FaceIdx(faceInd);
                subnwkFaceIdx = find(objSubNwk.fIdx ==  origfaceInd(1));
                origfaceDia = objSubNwk.dia(subnwkFaceIdx);
                
                G = addedge(G, pathIdx(i-1), pathIdx(i), origfaceDia);
                GFaceIdx = findedge(G, pathIdx(i-1), pathIdx(i));
                G.Edges.FaceIdx(GFaceIdx) = origfaceInd(1);

                edgeIdx(i-1) = GFaceIdx;
            else
                edgeIdx(i-1) = fIdx; % should we remove this (?)
            end
        end

        undoList = {'shPath', undoNodes, undoPtIdx};

        % move the 2nd point to the end of Graph Nodes
        moveNodeToEnd(shortestPathIndices(2));
        rePlotGraph();
        np = size(G.Nodes, 1);
    end

    % Callback function for the "Pt Select" button
    function ptSelectCb(~, ~)
        if (btnStates(7) == 0 && np > 0)
            showTextOnFig('PtSelect mode activated. Click on a point to display coords');
            set(plotObjDraw, 'ButtonDownFcn', @ptSelect);
            set(axDraw, 'ButtonDownFcn', @ptSelect);
            updateBtnState(7);
        elseif (btnStates(7) == 0 && np == 0)
            updateBtnState(0);
            showTextOnFig('PtSelect mode not activated. Add points and try again.');        
        else
            showTextOnFig('PtSelect mode deactivated');
            set(plotObjDraw, 'ButtonDownFcn', '');
            set(axDraw, 'ButtonDownFcn', @addPoint);
            updateBtnState(0);
            rePlotGraph(); % redo the point highlights
        end
    end

    function ptSelect(~, event)

        clickPoint = event.IntersectionPoint(1:3);
        pointIdx = findNearestPoint(clickPoint);

        if pointIdx
            % get the point coords
            selectNode = G.Nodes(pointIdx, :);
           
            lastNodeIdx = height(G.Nodes);
            set(plotObjDraw, 'NodeColor', 'red', 'MarkerSize', 4); % reset all nodes to red
            highlight(plotObjDraw, lastNodeIdx, 'NodeColor', 'blue', 'MarkerSize', 4); % highlight last node in blue
            highlight(plotObjDraw, pointIdx, 'NodeColor', 'cyan', 'MarkerSize', 6); % highlight selected point

            % display the coords, original index
            ptInfo = sprintf('X: %.3f, Y: %.3f, Z: %.3f, Idx: %d', selectNode.X, selectNode.Y, selectNode.Z, selectNode.PtIdx);
            showTextOnFig(ptInfo);
            writeToReport('Selected point', ptInfo);
        end

    end    

%%%%%%%%%%%%%%%%%%%%%% Utility functions %%%%%%%%%%%%%%%%%%%%%%%%%%%

    function expandAxesLimits(points)
        maxCoords = max(points, [], 1);
        minCoords = min(points, [], 1);
        padding = max(1, 0.05 * (maxCoords - minCoords)); %5% padding
        maxCoords = maxCoords + padding;
        minCoords = minCoords - padding;
        lims = [get(axView, 'XLim'); get(axView, 'YLim'); get(axView, 'ZLim')];
        newLims = [min([minCoords; lims(:, 1).']) ; max([maxCoords; lims(:, 2).'])];
        set(axView, {'XLim', 'YLim', 'ZLim'}, {newLims(:, 1), newLims(:, 2), newLims(:, 3)});
        switch toggleStates{currentState}
            case 'XY'
                set(axDraw, {'XLim', 'YLim'}, {newLims(:, 1), newLims(:, 2)});
            case 'YZ'
                set(axDraw, {'YLim', 'ZLim'}, {newLims(:, 2), newLims(:, 3)});
            case 'XZ'
                set(axDraw, {'XLim', 'ZLim'}, {newLims(:, 1), newLims(:, 3)});
        end
        updateDrawBox(axView, [currentThirdCoord - thickness, currentThirdCoord]); 
    end

    function rePlotGraph()

        delete(plotObjDraw);
        delete(plotObjView);

        np = height(G.Nodes);
  
        if np > 0
            % Replot the graph with updated coordinates
            hold(axDraw, 'on');
            plotObjDraw = plot(axDraw, G, 'XData', G.Nodes.X, 'YData', G.Nodes.Y,...
                'ZData', G.Nodes.Z, 'Marker', 'o', 'NodeColor', 'red', 'EdgeColor', [0.5 0.25 0], ...
                'MarkerSize', 4, 'LineWidth', 4);
            hold(axDraw, 'off');
    
            hold(axView, 'on');
            plotObjView = plot(axView, G, 'XData', G.Nodes.X, 'YData', G.Nodes.Y,...
                'ZData', G.Nodes.Z, 'Marker', 'o', 'NodeColor', 'red', 'EdgeColor', [0.5 0.25 0], ...
                'MarkerSize', 4, 'LineWidth', 4);
            hold(axView, 'off');
    
            % Highlight the last node in blue
            lastNodeIdx = height(G.Nodes);  % Index of the last node
            highlight(plotObjDraw, lastNodeIdx, 'NodeColor', 'blue', 'MarkerSize', 4);
            highlight(plotObjView, lastNodeIdx, 'NodeColor', 'blue', 'MarkerSize', 4);
    
    
            if indexOn
                ptIndex = strcat('p', arrayfun(@(x) {num2str(x)}, (1:height(G.Nodes))'));
                faceIndex = strcat('f', arrayfun(@(x) {num2str(x)}, (1:height(G.Edges))'));
            else
                ptIndex = repmat({''}, height(G.Nodes), 1);
                faceIndex = repmat({''}, height(G.Edges), 1);
            end

            if indexOn && (height(G.Edges) == 0)
                set([plotObjView, plotObjDraw], 'NodeLabel', ptIndex);
            else
                set([plotObjView, plotObjDraw], 'NodeLabel', ptIndex, 'EdgeLabel', faceIndex);
            end
    
            if btnStates(3)
                set(plotObjDraw, 'ButtonDownFcn', @deleteFromGraph);
            elseif btnStates(1)
                set(plotObjDraw, 'ButtonDownFcn', @connectPoints);
            elseif btnStates(6)
                set(plotObjDraw, 'ButtonDownFcn', @disConnectPts);   
            elseif btnStates(4)
                set(plotObjDraw, 'ButtonDownFcn', @editPoint);
            elseif btnStates(5)
                set(plotObjDraw, 'ButtonDownFcn', @startDragging);
            elseif btnStates(7)
                set(plotObjDraw, 'ButtonDownFcn', @ptSelect);
            else
                set(plotObjDraw, 'ButtonDownFcn', @addPoint);
            end
        end
    end

    % Function to find the nearest point in graph to a clicked point
    function pointIdx = findNearestPoint(clickPoint)

        % Calculate the range of each axis
        xRange = diff(xlim(axDraw));
        yRange = diff(ylim(axDraw));
        zRange = diff(zlim(axDraw));
    
        % Calculate dynamic tolerances based on the axis ranges
        dynamicToleranceX = xRange * 1e-2;
        dynamicToleranceY = yRange * 1e-2;
        dynamicToleranceZ = zRange * 1e-2;

        switch toggleStates{currentState}
            case 'XY' 
                pointIdx = find(abs(G.Nodes.X - clickPoint(1)) < dynamicToleranceX & abs(G.Nodes.Y - clickPoint(2)) < dynamicToleranceY);
                distances = sqrt((G.Nodes.X(pointIdx) - clickPoint(1)).^2 + (G.Nodes.Y(pointIdx) - clickPoint(2)).^2);
            case 'YZ'
                pointIdx = find(abs(G.Nodes.Y - clickPoint(2)) < dynamicToleranceY & abs(G.Nodes.Z - clickPoint(3)) < dynamicToleranceZ);
                distances = sqrt((G.Nodes.Y(pointIdx) - clickPoint(2)).^2 + (G.Nodes.Z(pointIdx) - clickPoint(3)).^2);
            case 'XZ'
                pointIdx = find(abs(G.Nodes.X - clickPoint(1)) < dynamicToleranceX & abs(G.Nodes.Z - clickPoint(3)) < dynamicToleranceZ);
                distances = sqrt((G.Nodes.X(pointIdx) - clickPoint(1)).^2 + (G.Nodes.Z(pointIdx) - clickPoint(3)).^2);
        end
        
        if size(pointIdx, 1) > 1              
           [~, minIdx] = min(distances);
           pointIdx = pointIdx(minIdx);
        end

    end

    function autoConnectExistingPts(~, ~)
        for i = 1:np-1
            G = addedge(G, i, i+1);
        end

        if np > 1
            rePlotGraph();
        end
    end

    function volumeData = getVolumeData(filePath)
        info = imfinfo(filePath); 
        num_images = numel(info);
        firstImg = imread(filePath, 1);
        [rows, cols, channels] = size(firstImg);
        if channels ~= 3
            error('Expected RGB images with 3 channels.');
        end
        volumeData = zeros(rows, cols, channels, num_images, 'uint8');
        for k = 1:num_images
            img = imread(filePath, k);
            volumeData(:, :, :, k) = img;
        end
    end

    function pushUndo(operation)
        if length(undoStack) >= maxStackSize
            undoStack(1) = [];
        end
        undoStack{end+1} = operation;
        updateUndoRedoButtons();
    end
    
    function pushRedo(operation)
        if length(redoStack) >= maxStackSize
            redoStack(1) = [];
        end
        redoStack{end+1} = operation;
        updateUndoRedoButtons();
    end
    
    function updateUndoRedoButtons()
        if isempty(undoStack)
            set(undoBtn, 'Enable', 'off');
        else
            set(undoBtn, 'Enable', 'on');
        end
        
        if isempty(redoStack)
            set(redoBtn, 'Enable', 'off');
        else
            set(redoBtn, 'Enable', 'on');
        end
    end

    function overlap = findOverlap(oldPts, newPts)
        overlapCount = 0;
        threshold = 1e-5;
    
        for i = 1:size(oldPts, 1)
            distances = sqrt(sum((newPts - oldPts(i, :)).^2, 2));
            if any(distances < threshold)
                overlapCount = overlapCount + 1;
            end
        end
    
        overlap = (overlapCount / size(newPts, 1)) * 100;
    end

    function [newCoords, originalIdx] = getNearestPtOnSurface(oldCoords)
  
               % In the viewToload objects take the latest for now?
               % % NOTE: We check if there is a stl, and then check if there is a nwk file.
               % objRows = find(strcmp(rendererTable.type, '.stl'));
               % if (isempty(objRows))
               %     objRows = find(strcmp(rendererTable.type, '.fMx'));
               %     filename = char(rendererTable.fileName(objRows(1)));
               %     [path, name, ~] = fileparts(filename);
               %     objSubNwk = nwkHelp.load(fullfile(path, name));
               % else
               %     filename = rendererTable.fileName(objRows(1));
               %     disp(filename);
               %     objSubNwk = nwkConverter.stl2faceMx2(filename);
               % end

           if (isempty(objSubNwk) || isempty(objGraph))
               displaySelectionsCb();
           end

           xRange = xlim(axDraw); yRange = ylim(axDraw); zRange = zlim(axDraw);
           switch toggleStates{currentState} % filter points on the surface slab
              case 'XY'
                  inLim = objSubNwk.ptCoordMx(:, 1) >= xRange(1) & objSubNwk.ptCoordMx(:, 1) <= xRange(2) & ...
                        objSubNwk.ptCoordMx(:, 2) >= yRange(1) & objSubNwk.ptCoordMx(:, 2) <= yRange(2) & ...
                        objSubNwk.ptCoordMx(:, 3) >= currentThirdCoord - thickness & objSubNwk.ptCoordMx(:, 3) <= currentThirdCoord; 
              case 'YZ'
                  inLim = objSubNwk.ptCoordMx(:, 3) >= zRange(1) & objSubNwk.ptCoordMx(:, 3) <= zRange(2) & ...
                        objSubNwk.ptCoordMx(:, 2) >= yRange(1) & objSubNwk.ptCoordMx(:, 2) <= yRange(2) & ...
                        objSubNwk.ptCoordMx(:, 1) >= currentThirdCoord - thickness & objSubNwk.ptCoordMx(:, 1) <= currentThirdCoord;
              case 'XZ'
                  inLim = objSubNwk.ptCoordMx(:, 1) >= xRange(1) & objSubNwk.ptCoordMx(:, 1) <= xRange(2) & ...
                        objSubNwk.ptCoordMx(:, 3) >= zRange(1) & objSubNwk.ptCoordMx(:, 3) <= zRange(2) & ...
                        objSubNwk.ptCoordMx(:, 2) >= currentThirdCoord - thickness & objSubNwk.ptCoordMx(:, 2) <= currentThirdCoord; 
           end
           ptsInLim = objSubNwk.ptCoordMx(inLim, :);

           % take old coords and find nearest point on the stl and add/edit/move point to that point
           distances = sqrt((ptsInLim(:, 1) - oldCoords(1)).^2 + ...
                     (ptsInLim(:, 2) - oldCoords(2)).^2 + ...
                     (ptsInLim(:, 3) - oldCoords(3)).^2);
          [~, minIdx] = min(distances);

          allIndices = find(inLim);
          ogIdx = allIndices(minIdx);
          originalIdx = objSubNwk.pIdx(ogIdx); % works only for surface being a mesh nwk - Temporary for Emilie
          newCoords = ptsInLim(minIdx, :);
    end

    function [pointIdx] = findNearestPtOnSurf(pt)

        % % Calculate the range of each axis
        % xRange = diff(xlim(axDraw)); yRange = diff(ylim(axDraw)); zRange = diff(zlim(axDraw));
        % 
        % % Calculate dynamic tolerances based on the axis ranges
        % dynamicToleranceX = xRange * 1e-4; dynamicToleranceY = yRange * 1e-4; dynamicToleranceZ = zRange * 1e-4;
        tol = 1e-5;

        pointIdx = find((objGraph.Nodes.X - pt(1) < tol) & (objGraph.Nodes.Y - pt(2) < tol) & (objGraph.Nodes.Z - pt(3) < tol));
        distances = sqrt((objGraph.Nodes.X(pointIdx) - pt(1)).^2 + (objGraph.Nodes.Y(pointIdx) - pt(2)).^2 + (objGraph.Nodes.Z(pointIdx) - pt(3)).^2); 
        
        if size(pointIdx, 1) > 1              
           [~, minIdx] = min(distances);
           pointIdx = pointIdx(minIdx);
        end    
    
    end    

    function moveNodeToEnd(ptIdx)

        ptCoords = [G.Nodes.X(ptIdx), G.Nodes.Y(ptIdx), G.Nodes.Z(ptIdx)]; % get point coords
        pIdx = G.Nodes.PtIdx(ptIdx); % Get PtIdx

        [sn, tn] = findedge(G); inletPts = sn(tn == ptIdx); outletPts = tn(sn == ptIdx); % get face indices
        
        inDia = G.Edges.Weight(tn == ptIdx); % we are replacing the target pt
        outDia = G.Edges.Weight(sn == ptIdx); % we are replacing the src pt

        inFaceInd = G.Edges.FaceIdx(tn == ptIdx);
        outFaceInd = G.Edges.FaceIdx(sn == ptIdx); 

        inFaceCoords = G.Nodes(inletPts, :); outFaceCoords = G.Nodes(outletPts, :); % get face indices coords
    
        G = rmnode(G, ptIdx);
        np = size(G.Nodes, 1);
        G = addnode(G, 1); G.Nodes{np + 1, {'X', 'Y', 'Z', 'PtIdx'}} = [ptCoords, pIdx];
    
        for i = 1:length(inletPts)

            newIdx = find(G.Nodes.X == inFaceCoords.X(i) & G.Nodes.Y == inFaceCoords.Y(i) & G.Nodes.Z == inFaceCoords.Z(i));

            G = addedge(G, newIdx, (np + 1), inDia(i));
            GFaceIdx = findedge(G, newIdx, (np + 1));
            G.Edges.FaceIdx(GFaceIdx) = inFaceInd(i);
        end

        for i = 1:length(outletPts)

            newIdx = find(G.Nodes.X == outFaceCoords.X(i) & G.Nodes.Y == outFaceCoords.Y(i) & G.Nodes.Z == outFaceCoords.Z(i));

            G = addedge(G, (np + 1), newIdx, outDia(i));
            GFaceIdx = findedge(G, (np + 1), newIdx);
            G.Edges.FaceIdx(GFaceIdx) = outFaceInd(i);
        end
    end

    function updateAxes(~, ~)
    
        newXLim = get(axView, 'XLim');
        newYLim = get(axView, 'YLim');
        newZLim = get(axView, 'ZLim');
        
        switch toggleStates{currentState}
            case 'XY'
                xlim(axDraw, newXLim);
                ylim(axDraw, newYLim);
            case 'YZ'
                zlim(axDraw, newZLim);
                ylim(axDraw, newYLim);
            case 'XZ'
                zlim(axDraw, newZLim);
                xlim(axDraw, newXLim);
        end
        updateDrawBox(axView, [currentThirdCoord - thickness, currentThirdCoord]);

    end

    function [isDuplicate] = checkDupPt(coords)
        tol = 1e-12; isDuplicate = 0;
    
        if isempty(G.Nodes) 
            isDuplicate = 0;
            return;
        end
    
        matchingPts = find((abs(G.Nodes.X - coords(1)) < tol) & (abs(G.Nodes.Y - coords(2)) < tol) & (abs(G.Nodes.Z - coords(3)) < tol));
        
        if ~isempty(matchingPts)
            warningMsg = sprintf('Duplicate point detected with %.2e tolerance.', tol);
            showTextOnFig(warningMsg);

            choice = questdlg('A duplicate point exists. Do you want to proceed with adding it?', ...
                              'Duplicate Point Detected', 'Yes', 'No', 'No');
            if strcmp(choice, 'No')
                showTextOnFig('New Point is a duplicate point, so not added.');
                isDuplicate = 1;
            end
        end
    end

    function andOrCb(~, ~)
      if strcmp(andOrBtn.String, 'AND')
        andOrBtn.String = 'OR';
        andOrBtn.Tooltip = sprintf('Gives faces, points that are a Intersection\nof faceEdit and ptEdit conditions');
      else
        andOrBtn.String = 'AND';
        andOrBtn.Tooltip = sprintf('Gives faces, points that are a Union\nof faceEdit and ptEdit conditions');
      end
    end


    function displaySelectionsCb(~, ~)

        if (isempty(objNwk)) % if there is no reference mesh
            showTextOnFig("No reference mesh to apply filter conditions");
            return;
        end

        if (isempty(faceEditBox.String))
            faceSelection = (1:objNwk.nf)'; % the whole graph
        else
            faceSelection = toolHelper.faceEditCb(faceEditBox.String, objNwk);
        end

        if (isempty(ptEditBox.String))
            ptSelection = (1:objNwk.np)'; % the whole graph
        else
            ptSelection = toolHelper.ptEditCb(ptEditBox.String, objNwk);
        end

        updateRefMesh(objNwk, faceSelection, ptSelection);
        
        if (~isempty(objSubNwk))
            objRows = find(strcmp(rendererTable.type, '.fMx'));
            if (~isempty(objRows)); objRow = objRows(1); end
    
            if (~isempty(rendererTable.drawHandle{objRow}))
                delete(rendererTable.drawHandle{objRow});
            end
    
            if (~isempty(rendererTable.viewHandle{objRow}))
                delete(rendererTable.viewHandle{objRow});
            end
    
            hold(axDraw, 'on');
            drawHandle = plot(axDraw, objGraph, 'XData', objGraph.Nodes.X, 'YData', objGraph.Nodes.Y,...
                'ZData', objGraph.Nodes.Z, 'Marker', 'o', 'NodeColor', [0.4 0.4 0.4], 'EdgeColor', [0.4 0.4 0.4], ...
                'NodeLabel', {}, 'EdgeLabel', {}, 'ShowArrows', 'off'); 
            set(drawHandle, 'HitTest', 'off');
            hold(axDraw, 'off');
    
            hold(axView, 'on');
            viewHandle = plot(axView, objGraph, 'XData', objGraph.Nodes.X, 'YData', objGraph.Nodes.Y,...
                'ZData', objGraph.Nodes.Z, 'Marker', 'o', 'NodeColor', [0.4 0.4 0.4], 'EdgeColor', [0.4 0.4 0.4], ...
                'NodeLabel', {}, 'EdgeLabel', {}, 'ShowArrows', 'off'); 
            hold(axView, 'off');
    
            rendererTable.drawHandle{objRow} = drawHandle;
            rendererTable.viewHandle{objRow} = viewHandle;
    
            expandAxesLimits(objSubNwk.ptCoordMx);

            showTextOnFig('Selection applied on Reference Mesh');
        end

    end    

    function goBtnCb(~, ~)

        if (isempty(refRow))
            refRows = find(strcmp(rendererTable.type, '.fMx')); refRow = refRows(1);
        end
        
        currState = rendererTable.viewHandle{refRow}.UserData;

        % If a different point is added to graph, take that as latest root point
        % reset the expansion
        if (~isempty(currState))
            firstPtIdx = find(objSubNwk.pIdx == G.Nodes.PtIdx(np));
            if (currState.startPt ~= firstPtIdx)
                resetBtnCb();
            end
        end

        if (isempty(currState))
            if (np == 0)
                disp('Graph is expanded from latest added point, Add a point on surface and try again');
                return;
            end
            firstPtIdx = find(objSubNwk.pIdx == G.Nodes.PtIdx(np));

            currState = [];
            currState.C1 = nwkHelp.ConnectivityMx(objSubNwk);
            currState.C2 = currState.C1';

            currState.visitedPts = false(1, objSubNwk.np);
            currState.visitedFaces = false(1, objSubNwk.nf);

            if (~isempty(firstPtIdx))
                currState.visitedPts(firstPtIdx) = true;
                currState.currentPts = firstPtIdx;
                currState.startPt = firstPtIdx;
            end
        end

        % Based on Dropdown string collect the next pts, faces 
        [ptsDown, facesDown] = nwkHelp.findDownPtsAndFaces(currState.currentPts, currState.C1, currState.C2);
        if (strcmp(expandDropdown.String{expandDropdown.Value}, 'Expand Path'))
            [ptsUp, facesUp] = nwkHelp.findUpPtsAndFaces(currState.currentPts, currState.C1, currState.C2);
            newPts = unique([ptsUp; ptsDown]); newFaces = unique([facesUp; facesDown]);
        else
            newPts = unique(ptsDown); newFaces = unique(facesDown);
        end

        % Remove already visited
        newPts = newPts(~currState.visitedPts(newPts));
        newFaces = newFaces(~currState.visitedFaces(newFaces));
        
        % Book keeping, Mark new points and faces as visited, reset current points
        if isempty(newFaces)
            disp('No new faces to expand.');
            return;
        end
        currState.visitedPts(newPts) = true;
        currState.visitedFaces(newFaces) = true;
        currState.currentPts = newPts;

        % Highlight faces
        viewHandle = rendererTable.viewHandle{refRow};
        drawHandle = rendererTable.drawHandle{refRow};
        highlight(viewHandle, objSubNwk.faceMx(newFaces, 2), ...
            objSubNwk.faceMx(newFaces, 3), 'EdgeColor', 'green', 'LineWidth', 6);
        highlight(drawHandle, objSubNwk.faceMx(newFaces, 2), ...
            objSubNwk.faceMx(newFaces, 3), 'EdgeColor', 'green', 'LineWidth', 6);

        % Safe keep the current structure in viewHandle 
        rendererTable.viewHandle{refRow}.UserData = currState;
    end

    function resetBtnCb(~, ~)
        if (isempty(refRow))
            refRows = find(strcmp(rendererTable.type, '.fMx')); refRow = refRows(1);
        end
        rendererTable.viewHandle{refRow}.UserData = []; % empty current state
        set([rendererTable.viewHandle{refRow}, rendererTable.drawHandle{refRow}], ...
            'EdgeColor', [0.4 0.4 0.4], 'LineWidth', 0.5);  % Remove highlights
    end

    function [meanDia] = avgDia(p1, p2)

        meanDia = 1; %default

        origP1 = G.Nodes.PtIdx(p1);
        origP2 = G.Nodes.PtIdx(p2);

        % cases where origP1, origP2 are 0, then one of the pts is not on mesh, exit
        if (origP1 == 0 || origP2 == 0); return; end

        faceIdx1 = find(objNwk.faceMx(:,2) == origP1 | objNwk.faceMx(:,3) == origP1);
        faceIdx2 = find(objNwk.faceMx(:,2) == origP2 | objNwk.faceMx(:,3) == origP2);

        leftMaxDia = max(objNwk.dia(faceIdx1)); rightMaxDia = max(objNwk.dia(faceIdx2));
        meanDia = mean([leftMaxDia, rightMaxDia]);
    end    

    function toggleToCylinders(~, ~)

        %%% We can make it more efficient by storing the structure
        %%% somewhere and making it not visible, when conditions
        %%% change/clear obj - we flush the stored objects

        % delete existing plots on axDraw and axView
        objRows = find(strcmp(rendererTable.type, '.fMx'));
        if isempty(objRows); return; end % Return when there is no reference mesh
        objRow = objRows(1);

        fig.Pointer = 'watch';
        
        if (~isempty(rendererTable.drawHandle{objRow})); delete(rendererTable.drawHandle{objRow}); end
        if (~isempty(rendererTable.viewHandle{objRow})); delete(rendererTable.viewHandle{objRow}); end

        if toggleCylinders.Value

            hold(axDraw, "on");
            [~, patchDraw] = RenderNwkTV(axDraw, objSubNwk, (1:objSubNwk.nf)', objSubNwk.dia, [], 0.1, '', jet(256));
            set(patchDraw, 'HitTest', 'off');
            hold(axDraw, "off");

            hold(axView, "on");
            [~, patchView] = RenderNwkTV(axView, objSubNwk, (1:objSubNwk.nf)', objSubNwk.dia, [], 0.1, '', jet(256));
            hold(axView, "off");

            % store patches on axDraw and axView to do show/hide/clear obj functions
            rendererTable.drawHandle{objRow} = patchDraw;
            rendererTable.viewHandle{objRow} = patchView;

        else

            hold(axDraw, 'on');
            drawHandle = plot(axDraw, objGraph, 'XData', objGraph.Nodes.X, 'YData', objGraph.Nodes.Y,...
                'ZData', objGraph.Nodes.Z, 'Marker', 'o', 'NodeColor', [0.4 0.4 0.4], 'EdgeColor', [0.4 0.4 0.4], ...
                'NodeLabel', {}, 'EdgeLabel', {}, 'ShowArrows', 'off'); 
            set(drawHandle, 'HitTest', 'off');
            hold(axDraw, 'off');
    
            hold(axView, 'on');
            viewHandle = plot(axView, objGraph, 'XData', objGraph.Nodes.X, 'YData', objGraph.Nodes.Y,...
                'ZData', objGraph.Nodes.Z, 'Marker', 'o', 'NodeColor', [0.4 0.4 0.4], 'EdgeColor', [0.4 0.4 0.4], ...
                'NodeLabel', {}, 'EdgeLabel', {}, 'ShowArrows', 'off'); 
            hold(axView, 'off');
    
            % store patches on axDraw and axView to do show/hide/clear obj functions
            rendererTable.drawHandle{objRow} = drawHandle;
            rendererTable.viewHandle{objRow} = viewHandle;
        end

        fig.Pointer = 'crosshair';

    end

    function keyPressCb(~, event)

        % Ctrl - connect mode, Ctrl+Shift - connect + shortestpath
        mod = event.Modifier;
        if ismember('control', mod) && ~ismember('shift', mod)
            if ~btnStates(1) 
                connectPointsCb();
            end

        elseif ismember('control', mod) && ismember('shift', mod)
            if ~shortestPathBtn.Value 
                shortestPathBtn.Value = 1;
                shortestPathCb();
            end
            if ~btnStates(1)
                connectPointsCb();
            end
        end
    end

    function keyReleaseCb(~, event)

        % Ctrl - connect mode, Ctrl+Shift - connect + shortestpath
        switch event.Key
            case 'control'
                if btnStates(1)
                    connectPointsCb();
                end
            case 'shift'
                if shortestPathBtn.Value
                    shortestPathBtn.Value = 0;
                    shortestPathCb();
                end
                if btnStates(1)
                    connectPointsCb();
                end
        end
    end

    function updateRefMesh(objNwk, faceSelection, ptSelection)

        % Get the subnetwork 
        if (strcmp(andOrBtn.String, 'AND'))
            objSubNwk = toolHelper.faceAndPtSelections(faceSelection, ptSelection, objNwk);
        else
            objSubNwk = toolHelper.faceOrPtSelections(faceSelection, ptSelection, objNwk);
        end

        if (~isempty(objSubNwk))
            % Compute the resistance as edge weights in graph
            if (objSubNwk.nf > 0)
                alpha = nwkSim.ResistanceVector(objSubNwk.ptCoordMx, objSubNwk.faceMx, objSubNwk.dia, objSubNwk.nf);
                objGraph = graph(table([objSubNwk.faceMx(:,2), objSubNwk.faceMx(:,3)], alpha, objSubNwk.fIdx, 'VariableNames', {'EndNodes', 'Weight', 'FaceIdx'}));
            else
                objGraph = graph();
            end
    
            % add isolated nodes count
            if objSubNwk.np > size(objGraph.Nodes, 1)
                diff = (objSubNwk.np - size(objGraph.Nodes, 1));
                objGraph = addnode(objGraph, diff);
            end
    
            objGraph.Nodes{1:objSubNwk.np, {'X', 'Y', 'Z'}} = objSubNwk.ptCoordMx;
            objGraph.Nodes.PtIdx = objSubNwk.pIdx; % Points are not scrambled
        else
            showTextOnFig('Empty selection. Reference Mesh not updated');
        end
    end

   function writeToReport(context, text)
        fid = fopen('drawReport.txt', 'a');        
        if fid == -1
            error('Unable to open or create drawReport.txt');
        end

        currentTime = datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss');
        fprintf(fid, '\n%s: %s: %s\n', char(currentTime), context, text);
        fclose(fid);
   end

end