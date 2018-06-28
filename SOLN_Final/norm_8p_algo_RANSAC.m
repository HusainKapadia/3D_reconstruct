function [Ff, inliers_idx_star, n_inliers_star] = norm_8p_algo_RANSAC(m1,m2)
N = 350;             %No. of iterations
n_inliers_star = 0;  %max no. of inliers initialization

%Normalizing the matched points
[m1_hat , T1] = normalize_points(m1);
[m2_hat , T2] = normalize_points(m2);

dist_thresh = 1000;           %tune the inliers distance threshold here

for i = 1:N
    %Finding the model based on 8 sample points
    seed = randperm(length(m1_hat),8);               
    m1_hat_rand =  m1_hat(:,seed);                    
    m2_hat_rand =  m2_hat(:,seed);                   
    
    A_hat = formulate_eq(m1_hat_rand,m2_hat_rand);  

    [~,~,V] = svd(A_hat);

    f = V(:,end);          %the elements of fundamental matrix in  a 9x1 vector
    F_hat = reshape(f,[3,3]);

    % 'F'orcing singularity
    [Uf, Sf, Vf] = svd(F_hat);
    Sf(3,3) = 0;
    Ff_hat = Uf*Sf*Vf';

    %Denormalizing:
    Ff = T2'*Ff_hat*T1;
    
    %Sampson distance:
    %computing denominator vector:
    temp1 = (Ff)*[m1;ones(1,length(m1))];
    temp2 = (Ff)'*[m2;ones(1,length(m2))];
    den = sum([temp1(1:2,:).^2;temp2(1:2,:).^2]);
    
    %computing numerator vector:
    A = formulate_eq(m1,m2);
    num = A*Ff(:);
    
    %sampson distance vector:
    sampson_dist = num'./den;
    
%     %Uncomment for getting sampson_dist matrix to tune threshold
%     sampson_dist_mat(i,:) = sampson_dist;
    
    %checking for inliers              
    inliers_bool = abs(sampson_dist) < dist_thresh;
    n_inliers = sum(inliers_bool);
    
    if n_inliers > n_inliers_star
        n_inliers_star = n_inliers;
        %sampson_dist_star = sampson_dist;
        inliers_bool_star = inliers_bool;
        inliers_idx_star = find(inliers_bool);
        F_star = Ff;
    end
end


%Recomputing F with max number of inliers:
A_hat = formulate_eq(m1_hat(:,inliers_idx_star),m2_hat(:,inliers_idx_star));
[~,~,V] = svd(A_hat,'econ');

f = V(:,9);          %the elements of fundamental matrix in  a 9x1 vector
F_hat = reshape(f,[3,3]);

% 'F'orcing singularity
[Uf, Sf, Vf] = svd(F_hat);
Sf(3,3) = 0;
Ff_hat = Uf*Sf*Vf';

%Denormalizing:
Ff = T2'*Ff_hat*T1;

end