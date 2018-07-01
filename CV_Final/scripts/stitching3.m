%% using Procrustes
% Here we start with the 3d coordinates of features in the last block , 
% and find the trasformation to coordinate frame of the features in the previous block.
% For finding the transformation, we use the Procrustes function, on the
% common features in the two blocks.
% Having found a transformation, we transform all the points in the current
% block to the coordinate frame of the previous block.
% This iterative process continues until, all the points have been
% transformed to the coordinate frame of the first block.

for i = length(S_cell):-1:2
    if ~(isempty(S_cell{i}) || isempty(S_cell{i-1})) %skipping blocks that had too few features
        [~,ia,ib] = intersect(column_no{i-1},column_no{i});
        [~,~,transform] = procrustes(S_cell{i-1}(:,ia)',S_cell{i}(:,ib)');
        
        %Points from next frame to be converted to current frame coordinate system
        [~,~,ib] = setxor(column_no{i-1},column_no{i});
        Y = S_cell{i}(:,ib);
        
        %transforming these points to the current coordinate frame
        if isempty(transform.c)
            Z = transform.b*Y'*transform.T;
        else
            Z = transform.b*Y'*transform.T + repmat(transform.c(1,:),size(Y,2),1);
        end
        
        %Appending these points to the current S matrix
        S_cell{i-1} = [S_cell{i-1},Z'];
        
        %Appending new column number to the current frame
        column_no{i-1} = [column_no{i-1},column_no{i}(ib)];
    end
end
