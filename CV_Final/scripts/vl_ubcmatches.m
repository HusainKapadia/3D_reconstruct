%Matching the features in subsequent images Using vl_ubcmatch
match_thresh = 2;               % matching threshold for vl_ubcmatch
matches = cell(1,n_imgs);

%getting matches using vl_ubc match
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
    
    %Finding initial matches using vl_ubcmatch
    [matches{i},~] = vl_ubcmatch(desc1,desc2,match_thresh);     %,match_thresh
end

% %plotting matches
% for i = 1:n_imgs
%     figure()
%     if i == n_imgs
%         plotmatches(im{i},im{1},feat{i},feat{1},matches{i},'Stacking','o');
%     else
%         plotmatches(im{i},im{i+1},feat{i},feat{i+1},matches{i},'Stacking','o');
%     end
%    
%     pause(2);
% end