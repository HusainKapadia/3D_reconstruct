%% Refining matches using normalized 8 point RANSAC algorithm
newmatches = cell(1,n_imgs);
Ff = cell(1,n_imgs);

for i = 1:n_imgs
    feat1 = feat{i};
    desc1 = desc{i};
    
    if i == n_imgs
        feat2 = feat{1};
        desc2 = desc{1};
    else
        feat2 = feat{i+1};
        desc2 = desc{i+1};
    end
    
    %getting coordinates of matched points
    m1 = feat1(1:2,matches{i}(1,:));
    m2 = feat2(1:2,matches{i}(2,:));
    
    %refining the matches using normalized 8 point RANSAC
    %tune the threshold and no.of iterations in the function 'norm_8p_algo_RANSAC'
    [Ff{i}, inliers_idx_star, ~] = norm_8p_algo_RANSAC(m1,m2);
    
    newmatches{i} = matches{i}(:,inliers_idx_star);
end

% %plotting newmatches
for i = 1:n_imgs
    figure()
    if i == n_imgs
        plotmatches(im{i},im{1},feat{i},feat{1},newmatches{i},'Stacking','o');
    else
        plotmatches(im{i},im{i+1},feat{i},feat{i+1},newmatches{i},'Stacking','o');
    end
   
    pause(2);
end
