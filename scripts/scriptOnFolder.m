
function scriptOnFolder()

    folderName = '/Users/lavanyavaddavalli/Desktop/lppd/tools_latest/data/nwk_data';
    wholeMouse = '/Users/lavanyavaddavalli/Desktop/lppd/tools_latest/data/KF_WM_TV_straight_LCC';

    fMxFiles = dir(fullfile(folderName, '*.fMx'));

    for i = 1:length(fMxFiles)
        fMxPath = fullfile(fMxFiles(i).folder, fMxFiles(i).name);
        [~, baseName, ~] = fileparts(fMxPath);
        nwkFilename = fullfile(folderName, baseName);
        fprintf('Processing: %s\n', nwkFilename);
        try
            mergeDuplicates(nwkFilename, wholeMouse);
        catch ME
            warning('Error processing %s: %s', nwkFilename, ME.message);
        end
    end

end

function mergeDuplicates(filename, WMFilename)

    nwk = nwkHelp.load(filename);

    % Generate digraph from nwk
    [diG] = nwk2Graph(nwk);

    % Group the duplicate points into one group
    [duplicateGroups] = dupGroups(nwk);

    % Modify edges to use one point of the group for each face
    [diG] = mergeFaces(diG, duplicateGroups);

    % Remove self loops
    [diG] = removeSelfLoops(diG);

    % Remove island nodes
    diG = removeIslandNodes(diG);

    % Remove duplicate faces
    [diG] = removeDuplicateFaces(diG, WMFilename);

    % save the graph as nwk, Redo the original indexes
    new_nwk = graph2nwk(diG, nwk);
    nwkHelp.save(filename, new_nwk); % overwrites the network
    mapToOrig(WMFilename, filename);
end

function [diG] = nwk2Graph(nwk)
    diG = digraph(table([nwk.faceMx(:,2), nwk.faceMx(:,3)], nwk.dia, nwk.faceMx(:,1), 'VariableNames', {'EndNodes', 'Diameter', 'GrpId'}));
    if nwk.np > size(diG.Nodes, 1) % add isolated nodes count
        diG = addnode(diG, (nwk.np - size(diG.Nodes, 1)));
    end
    diG.Nodes{1:nwk.np, {'X', 'Y', 'Z'}} = nwk.ptCoordMx;
end

function [duplicateGroups] = dupGroups(nwk)    
    [~, ~, ic] = unique(nwk.ptCoordMx, 'rows');
    numUnique = max(ic);
    duplicateGroups = cell(numUnique, 1);
    for i = 1:numUnique
        duplicateGroups{i} = find(ic == i);
    end
    duplicateGroups = duplicateGroups(cellfun(@numel, duplicateGroups) > 1);
end

function [diG1] = mergeFaces(diG, duplicateGroups)

    % Get existing edge table
    edgeTable = diG.Edges; nodesTable = diG.Nodes;
    endNodes = edgeTable.EndNodes;

    for g = 1:length(duplicateGroups)
        group = duplicateGroups{g};
        mainPt = group(1); % Representative point
        otherPts = group(2:end);
        for i = 1:length(otherPts)
            pt = otherPts(i);
            endNodes(endNodes(:,1) == pt, 1) = mainPt;
            endNodes(endNodes(:,2) == pt, 2) = mainPt;
        end
    end

    % Remove all edges and re-add updated ones
    % Retain edge weights or any properties if needed
    newEdgeTable = edgeTable;
    newEdgeTable.EndNodes = endNodes;

    diG1 = digraph(newEdgeTable);
    diG1.Nodes = nodesTable;
end

function diG = removeSelfLoops(diG)
    selfLoopIdx = find(diG.Edges.EndNodes(:,1) == diG.Edges.EndNodes(:,2));
    if ~isempty(selfLoopIdx)
        diG = rmedge(diG, selfLoopIdx);
    end
end


function [diG] = removeIslandNodes(diG)
    inDeg = indegree(diG);
    outDeg = outdegree(diG);
    totalDeg = inDeg + outDeg;

    isolatedNodeIdx = find(totalDeg == 0);
    if ~isempty(isolatedNodeIdx)
        diG = rmnode(diG, isolatedNodeIdx);
    end
end

function [nwk] = graph2nwk(diG, og_nwk)

    nwk.ptCoordMx = [diG.Nodes.X, diG.Nodes.Y, diG.Nodes.Z];
    nwk.np = size(nwk.ptCoordMx, 1);

    nwk.nf = size(diG.Edges, 1);
    nwk.faceMx = zeros(nwk.nf, 5);

    nwk.faceMx(:, 2:3) = diG.Edges.EndNodes;
    nwk.faceMx(:, 1) = diG.Edges.GrpId;
    nwk.dia = diG.Edges.Diameter;
    nwk.nt = nwk.np + nwk.nf;  

    % Optional
    nwk.grpMx = [];
    nwk.BC = og_nwk.BC;
end

function [diG] = removeDuplicateFaces(diG, WMFilename)

    % Remove any duplicate repeated edges in same direction
    [~, uniqueIdx] = unique(diG.Edges, 'rows', 'stable');
    dupIdx = setdiff((1:size(diG.Edges, 1))', uniqueIdx);
    if ~isempty(dupIdx)
        diG = rmedge(diG, dupIdx);
    end

    nwk = nwkHelp.load(WMFilename);

    endNodes = diG.Edges.EndNodes;
    nEdges = size(endNodes, 1);
    toRemove = false(nEdges, 1);

    for i = 1:nEdges
        src = endNodes(i,1); target = endNodes(i,2);
        
        % Check if reverse edge exists
        reverseIdx = find(endNodes(:,1) == target & endNodes(:,2) == src, 1);

        if isempty(reverseIdx) || reverseIdx <= i
            continue;  % Skip if no reverse or already checked in previous iteration
        end

        coord1 = [diG.Nodes.X(src), diG.Nodes.Y(src), diG.Nodes.Z(src)];
        coord2 = [diG.Nodes.X(target), diG.Nodes.Y(target), diG.Nodes.Z(target)];

        origPtIdx1 = find(all(abs(nwk.ptCoordMx - coord1) < 1e-4, 2), 1);
        origPtIdx2 = find(all(abs(nwk.ptCoordMx - coord2) < 1e-4, 2), 1);

        if isempty(origPtIdx1) || isempty(origPtIdx2)
            warning('Could not map points [%d, %d] to nwk.ptCoordMx', src, target);
            continue;
        end

        % Check face direction in nwk.faceMx
        isForward = any(all(nwk.faceMx(:,2:3) == [origPtIdx1, origPtIdx2], 2));
        isReverse = any(all(nwk.faceMx(:,2:3) == [origPtIdx2, origPtIdx1], 2));

        % Mark one edge for removal based on direction
        if isForward && ~isReverse
            toRemove(reverseIdx) = true;
        elseif ~isForward && isReverse
            toRemove(i) = true;
        end
    end

    % Remove marked edges
    diG = rmedge(diG, find(toRemove));

    % Remove any duplicate repeated edges in same direction
    [~, uniqueIdx] = unique(diG.Edges, 'rows', 'stable');
    dupIdx = setdiff((1:size(diG.Edges, 1))', uniqueIdx);
    if ~isempty(dupIdx)
        diG = rmedge(diG, dupIdx);
    end

end


function mapToOrig(filename1, filename2)

    %filename1 = '/Users/lavanyavaddavalli/Desktop/lppd/tools_latest/data/KF_WM_TV_straight_LCC';
    %filename2 = '/Users/lavanyavaddavalli/Desktop/lppd/tools_latest/data/KF_WM_TV_rVA';
    
    nwk = nwkHelp.load(filename1);
    subnwk = nwkHelp.load(filename2);
    
    findOrigIdx(nwk, subnwk, filename2);
end

function findOrigIdx(nwk, subnwk, filename2)

    % Stores the original point index for each point in sub network
    origPIdx = findNearestPoint(subnwk.ptCoordMx, nwk);
    
    % Stores the original face index for each face in sub network
    inletPIdx = origPIdx(subnwk.faceMx(:,2));
    outletPIdx = origPIdx(subnwk.faceMx(:,3));   
    tmpFaces = [inletPIdx(:), outletPIdx(:)];

    sortedTmp = sort(tmpFaces, 2);
    sortedNwk = sort(nwk.faceMx(:,2:3), 2);
    [~, origFIdx] = ismember(sortedTmp, sortedNwk, 'rows');

    % save orginal PIdx file, FIdx file
    fileID = fopen([filename2, '.originalPIdx'], 'w');
    fprintf(fileID, '%d\n', origPIdx);
    fclose(fileID);

    fileID = fopen([filename2, '.originalFIdx'], 'w');
    fprintf(fileID, '%d\n', origFIdx);
    fclose(fileID);
    
    % Stores the original diameter for each face in sub network
    % For new faces not in reference mesh, diameter will 
    % be mean of left and right max
    origDia = ones(size(origFIdx)); 
    validFaces = origFIdx > 0;
    origDia(validFaces) = nwk.dia(origFIdx(validFaces));

    newFaces = ~validFaces;
    origDia(newFaces) = arrayfun(@(p1, p2) avgDia(nwk, p1, p2), inletPIdx(newFaces), outletPIdx(newFaces));

    % Save original diameter file
    fileID = fopen([filename2, '.dia'], 'w');
    fprintf(fileID, '%f\n', origDia);
    fclose(fileID);

end

function [ptIdx] = findNearestPoint(ptCoords, nwk)
    tol = 1e-7;
    D = pdist2(ptCoords, nwk.ptCoordMx);
    [minD, idx] = min(D, [], 2);
    ptIdx = idx;
    ptIdx(minD >= tol) = 0;
end

function [meanDia] = avgDia(nwk, origP1, origP2)

    meanDia = 1; %default

    % cases where origP1, origP2 are 0, then one of the pts is not on mesh, exit
    if (origP1 == 0 || origP2 == 0); return; end

    % all faces that point p1 is connected to are taken
    faceIdx1 = find(nwk.faceMx(:,2) == origP1 | nwk.faceMx(:,3) == origP1);

    % all faces that point p2 is connected to are taken
    faceIdx2 = find(nwk.faceMx(:,2) == origP2 | nwk.faceMx(:,3) == origP2);

    leftMaxDia = max(nwk.dia(faceIdx1));
    rightMaxDia = max(nwk.dia(faceIdx2));
    
    meanDia = mean([leftMaxDia, rightMaxDia]);
end    