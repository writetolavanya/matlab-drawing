
function mapToOrig()
    filename1 = '/Users/lavanyavaddavalli/Desktop/lppd/data/S58.2022/S58_bb7_b';
    filename2 = '/Users/lavanyavaddavalli/Desktop/lppd/data/S58.2022/S58_sub';
    
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
    
    % Stores the original diameter for each face in sub network
    origDia = nwk.dia(origFIdx);

    % save orginal PIdx file, FIdx, diameter file
    fileID = fopen([filename2, '.dia'], 'w');
    fprintf(fileID, '%f\n', origDia);
    fclose(fileID);

    fileID = fopen([filename2, '.originalPIdx'], 'w');
    fprintf(fileID, '%d\n', origPIdx);
    fclose(fileID);

    fileID = fopen([filename2, '.originalFIdx'], 'w');
    fprintf(fileID, '%d\n', origFIdx);
    fclose(fileID);
end

function [ptIdx] = findNearestPoint(ptCoords, nwk)
    tol = 1e-7;
    D = pdist2(ptCoords, nwk.ptCoordMx);
    [minD, idx] = min(D, [], 2);
    ptIdx = idx;
    ptIdx(minD >= tol) = 0;
end
