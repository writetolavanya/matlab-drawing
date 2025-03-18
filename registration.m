function registrationCb(~, ~)

    registerFig = figure('Position', [200, 200, 800, 600], 'Name', 'Registration Tool', ...
                 'NumberTitle', 'off', 'Color', [1 1 1]);
    axLeft = axes('Parent', registerFig, 'Units', 'pixels', 'Position', [50, 250, 300, 300], ...
                  'Box', 'on', 'Color', [1 1 1]);
    xlabel(axLeft, 'X'); ylabel(axLeft, 'Y'); zlabel(axLeft, 'Z');
    view(axLeft, 3);

    axRight = axes('Parent', registerFig, 'Units', 'pixels', 'Position', [450, 250, 300, 300], ...
                   'Box', 'on', 'Color', [1 1 1]);
    xlabel(axRight, 'X'); ylabel(axRight, 'Y'); zlabel(axRight, 'Z');
    view(axRight, 3);

    rightHandle = copyobj(rendererTable.viewHandle{1}, axRight); % reference to register on
    leftHandle = copyobj(plotObjView, axLeft); 

    pointNames = {'A','B','C','D'};
    coordNames = {'x','y','z'};

    leftBoxes = gobjects(4,3);
    baseX = 120; baseY = 150; dx = 50; dy = 25;
    for i = 1:4
        uicontrol(registerFig, 'Style', 'text', 'String', pointNames{i}, ...
                  'Position', [baseX-20, baseY - (i-1)*dy, 15, 20], ...
                  'BackgroundColor', [1 1 1]);
        for j = 1:3
            leftBoxes(i,j) = uicontrol(registerFig, 'Style', 'edit', ...
                'Position', [baseX + (j-1)*dx, baseY - (i-1)*dy, 40, 20]);
        end
    end
    uicontrol(registerFig, 'Style', 'text', 'String', '  x             y          z', ...
              'Position', [baseX, baseY+20, 120, 20], ...
              'BackgroundColor', [1 1 1]);

    rightBoxes = gobjects(4,3);
    baseXr = 520; baseYr = 150; dxr = 50; dyr = 25;
    for i = 1:4
        % Label for the row
        uicontrol(registerFig, 'Style', 'text', 'String', pointNames{i}, ...
                  'Position', [baseXr-20, baseYr - (i-1)*dyr, 15, 20], ...
                  'BackgroundColor', [1 1 1]);
        for j = 1:3
            rightBoxes(i,j) = uicontrol(registerFig, 'Style', 'edit', ...
                'Position', [baseXr + (j-1)*dxr, baseYr - (i-1)*dyr, 40, 20]);
        end
    end
    uicontrol(registerFig, 'Style', 'text', 'String', '  x             y           z', ...
              'Position', [baseXr, baseYr+20, 120, 20], ...
              'BackgroundColor', [1 1 1]);

    registerBtn = uicontrol(registerFig, 'Style', 'pushbutton', 'String', 'Register', ...
                            'Position', [350, 20, 100, 30]);

end  