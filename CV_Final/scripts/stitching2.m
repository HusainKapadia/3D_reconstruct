%% Solving for structure and Motion matrices for each block

M_cell = cell(size(PVMb));
S_cell = cell(size(PVMb));

% appending features of image 1 and image 2 at the bottom of feat to
% complete loop
feat{20} = feat{1} ; feat{21} = feat{2}; 

for i = 1:size(PVMb,2)
    if size(PVMb{i},2)>3        %skipping blocks that have three or less features
        Points = zeros(2*size(PVMb{i},1),size(PVMb{i},2));
        for j =1:size(PVMb{i},1)
            Points(j*2-1:j*2,:) = feat{i+j-1}(1:2,PVMb{i}(j,:));
        end
        %centering the points about the mean
        PointsC = Points - mean(Points,2);
        
        %Singular Value Decomposition
        [U,W,V] = svd(PointsC);
        
        U = U(:,1:3);
        W = W(1:3,1:3);
        V = V(:,1:3);
        
        M = U*sqrtm(W);
        S = sqrtm(W)*V';
        
        save('M','M');
        
        %solve for affine ambiguity
        L0= zeros(3);   %Initial guess
        %Solve for L
        L = lsqnonlin(@myfun,L0);
        % Recover C
        if sum(eig(L)>0) ==3    %checking if L is positive definite
            C = chol(L,'lower');
            % Update M and S
            M = M*C;
            S = pinv(C)*S;
        end
        M_cell{i} = M;
        S_cell{i} = S;
    end
end