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

%initializing the image, feature and descriptor cells
im = cell(1,n_imgs);
feat = cell(1,n_imgs);
desc = cell(1,n_imgs);

tic
for i = 1:n_imgs
   [feat_hesaff, desc_hesaff] = sift_file_to_mat(file_name(hesaff_file(i)));
   [feat_haraff, desc_haraff] = sift_file_to_mat(file_name(haraff_file(i)));
   feat{i} = [feat_haraff, feat_hesaff];
   desc{i} = [desc_haraff, desc_hesaff];
   im{i} = single(rgb2gray(imread(file_name(im_file(i)))));
end
toc
clear feat_hesaff feat_haraff desc_hesaff desc_haraff