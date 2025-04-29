
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