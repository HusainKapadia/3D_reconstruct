hesaff_dir = 'C:\D\SC coursework\Q3\computer vision\assignments\assignment 6\hesaff';
haraff_dir = 'C:\D\SC coursework\Q3\computer vision\assignments\assignment 6\haraff';
im_dir = 'C:\D\SC coursework\Q3\computer vision\assignments\assignment 6\TeddyBearPNG';

subfolder = @(base,sub)[base '\' sub];
merge_file = @(dir)subfolder(dir.folder,dir.name);

%% Reading the features and image files
hesaff_file = dir(hesaff_dir);
hesaff_file = hesaff_file(3:end);

haraff_file = dir(haraff_dir);
haraff_file = haraff_file(3:end);

im_file = dir(im_dir);
im_file = im_file(3:end);

feat_hesaff = cell(1,length(hesaff_file));
desc_hesaff = cell(1,length(hesaff_file));

feat_haraff = cell(1,length(haraff_file));
desc_haraff = cell(1,length(haraff_file));

im = cell(1,length(im_file));

tic
for i = 1:16
   [feat_hesaff{i}, desc_hesaff{i}] = sift_file_to_mat(merge_file(hesaff_file(i)));
   [feat_haraff{i}, desc_haraff{i}] = sift_file_to_mat(merge_file(haraff_file(i)));
   im{i} = single(rgb2gray(imread(merge_file(im_file(i)))));
end
toc

m_thresh = 3;               %matching threshold
newmatches = cell(1,16);

%% matching the feature points and removing inconsistent matches
for i = 1:16
    
    feat1 = [feat_haraff{i}, feat_hesaff{i}];
    desc1 = [desc_haraff{i}, desc_hesaff{i}];
    
    if i == 16
        feat2 = [feat_haraff{1}, feat_hesaff{1}];
        desc2 = [desc_haraff{1}, desc_hesaff{1}];
    else
        feat2 = [feat_haraff{i+1}, feat_hesaff{i+1}];
        desc2 = [desc_haraff{i+1}, desc_hesaff{i+1}];
    end
    
    %Finding matches
    [matches,~] = vl_ubcmatch(desc1,desc2);     %,m_thresh
    
%     %plotting matches
%     plotmatches(im{1},im{2},feat1,feat2,matches,'Stacking','o');        
    
    %getting coordinates of matched points
    m1 = feat1(1:2,matches(1,:));
    m2 = feat2(1:2,matches(2,:));
    
    [Ff, inliers_idx_star, n_inliers_star] = norm_8p_algo_RANSAC(m1,m2);
    
    newmatches{i} = matches(:,inliers_idx_star);
    
    plotmatches(im{1},im{2},feat1,feat2,newmatches{i},'Stacking','o');
end

%% Building the point-view matrix

%initialize point view matrix with matched points in image 1
point_view_matrix = newmatches{1}(1,:);

for i = 1:15
    %fill in intersected points
    [~,ia,ib] = intersect(newmatches{i}(1,:), point_view_matrix(i,:));
    point_view_matrix(i+1,ib) = newmatches{i}(2,ia);
    
    %add new points
    [~,ia,~] = setxor(newmatches{i}(1,:), point_view_matrix(i,:));
    point_view_matrix = [point_view_matrix,[zeros(size(point_view_matrix,1)-2,length(ia));newmatches{i}(:,ia)]];
end

%% Treating Matches between last and first image pair:
newmatches_16 = newmatches{16};
%CASE 1:
%points in first row of newmatches_16(i.e. points in image 16) 
%already present in last row of PVM, 
%and that have matches in first row PVM
[~,ia,ib] = intersect(newmatches_16(1,:), point_view_matrix(16,:));
frame1_rep_check = newmatches_16(2,ia);
[~,iar,ibr] = intersect(frame1_rep_check,point_view_matrix(1,:));

for i = 1:length(ibr)
    point_view_matrix(:,ibr(i)) = point_view_matrix(:,ibr(i)) + point_view_matrix(:,ib(iar(i)));
end
point_view_matrix(:,ib(iar))=[];
newmatches_16(:,ia(iar))=[];

%CASE 2:
%points in first row of newmatches_16(i.e. points in image 16) 
%that are not present in last row of PVM, that
%have matches in the first row of PVM
[~,ia,~] = setxor(newmatches_16(1,:), point_view_matrix(16,:));
frame1_rep_check = newmatches_16(2,ia);
[~,iar,ibr] = intersect(frame1_rep_check,point_view_matrix(1,:));
point_view_matrix(end,ibr) = newmatches_16(1,ia(iar));

newmatches_16(:,ia(iar)) = [];

%CASE 3:
%points in the first row of newmatches_16(i.e. points in image 16) that are 
%already present in the last row of PVM
%but have no match in first row of PVM
[~,ia,ib] = intersect(newmatches_16(1,:), point_view_matrix(16,:));
point_view_matrix(1,ib) = newmatches_16(2,ia);

%CASE 4:
%points in the first row of newmatches_16(i.e. points in image 16) that are 
%not present in the last row of PVM
%and have no match in first row of PVM
[~,ia,~] = setxor(newmatches_16(1,:), point_view_matrix(16,:));
point_view_matrix = [point_view_matrix,[newmatches_16(2,ia);zeros(size(point_view_matrix,1)-2,length(ia));newmatches_16(1,ia)]];

