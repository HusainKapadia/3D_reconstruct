%Enter the image, hesaff and heraff directories here
hesaff_dir = 'C:\D\SC coursework\Q3\computer vision\assignments\Final Project\modelCastle_features\hesaff';
haraff_dir = 'C:\D\SC coursework\Q3\computer vision\assignments\Final Project\modelCastle_features\haraff';
im_dir = 'C:\D\SC coursework\Q3\computer vision\assignments\Final Project\model_castle_png';

file_name = @(dir)[dir.folder '\' dir.name];

%% Reading the features and image files
im_file = dir(im_dir);
im_file = im_file(3:end);
n_imgs = length(im_file);

hesaff_file = dir(hesaff_dir);
hesaff_file = hesaff_file(3:end);

haraff_file = dir(haraff_dir);
haraff_file = haraff_file(3:end);

feat_hesaff = cell(1,n_imgs);
desc_hesaff = cell(1,n_imgs);

feat_haraff = cell(1,n_imgs);
desc_haraff = cell(1,n_imgs);

im = cell(1,n_imgs);

tic
for i = 1:n_imgs
   [feat_hesaff{i}, desc_hesaff{i}] = sift_file_to_mat(file_name(hesaff_file(i)));
   [feat_haraff{i}, desc_haraff{i}] = sift_file_to_mat(file_name(haraff_file(i)));
   im{i} = single(rgb2gray(imread(file_name(im_file(i)))));
end
toc

%% Matching the features in subsequent images and Improving matches 
%  using normalized 8 point RANSAC Algorithm
match_thresh = 2;               %tune the matching threshold here
newmatches = cell(1,n_imgs);
Ff = cell(1,n_imgs);

for i = 1:n_imgs
    feat1 = [feat_haraff{i}, feat_hesaff{i}];
    desc1 = [desc_haraff{i}, desc_hesaff{i}];
    
    if i == n_imgs
        feat2 = [feat_haraff{1}, feat_hesaff{1}];
        desc2 = [desc_haraff{1}, desc_hesaff{1}];
    else
        feat2 = [feat_haraff{i+1}, feat_hesaff{i+1}];
        desc2 = [desc_haraff{i+1}, desc_hesaff{i+1}];
    end
    
    %Finding matches
    [matches,~] = vl_ubcmatch(desc1,desc2);     %,match_thresh
    
%     %plotting matches
%     plotmatches(im{1},im{2},feat1,feat2,matches,'Stacking','o');        
    
    %getting coordinates of matched points
    m1 = feat1(1:2,matches(1,:));
    m2 = feat2(1:2,matches(2,:));
    
    [Ff{i}, inliers_idx_star, ~] = norm_8p_algo_RANSAC(m1,m2);
    
    newmatches{i} = matches(:,inliers_idx_star);
    
    %plotmatches(im{1},im{2},feat1,feat2,newmatches{end},'Stacking','o');
end


%% Chaining
point_view_matrix = chaining(newmatches);


