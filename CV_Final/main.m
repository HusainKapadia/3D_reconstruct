% Adding the scripts and functions 
p = pwd;
addpath([p '\scripts'],[p '\functions']);

%% Reading the image, features and descriptor files
%(Modify required directories in the 'read_im_feat.m' script)
run('read_im_feat.m');
disp('Data Loaded')
%% Extracting foreground features
%Extracts the foreground features only and updates feat and desc
run('extract_foreground.m');
disp('Foreground extracted')
%% Matching the features in subsequent images Using vl_ubcmatch
%This script returns the matches cell array, containing the matches between
%subsequent images
run('vl_ubcmatches.m');
disp('Matches made')
%% Refining matches using normalized 8 point RANSAC algorithm
%This script returns the newmatches cell array, containing the refined
%matches
run('norm8pointRANSAC_newmatches.m');
disp('Matches refined')
%% Chaining
%Forming the point_view_matrix from newmatches
point_view_matrix = chaining(newmatches);
disp('Point View Matrix generated')
%% Stitching(1)
%Extracting blocks of point view matrix composed of three images each
%This returns PVMb cell array which contains a block in each cell.
run('stitching1.m')
disp('Blocks extracted')
%% Stitching (2)
%Estimating 3d coordinates fo each block using Tomasi_Kanade factorization
%and eliminating Affine ambiguity.
%creates S_cell, that stores the 3d coordinates of the points in each block
%in their 3d coordinate frame
run('stitching2.m')
disp('3D coordinates obtained')    
%% Stitching(3)
%Returns Z, that contains the 3D points of all blocks transformed to the 3D
%coordinate frame of the first block
run('stitching3.m')    
disp('Transformation complete')
%% 3D model plotting
plot3(S_cell{1}(1,:),S_cell{1}(2,:),S_cell{1}(3,:),'.')