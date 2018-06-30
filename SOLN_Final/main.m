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

%% selecting foreground section for each image:
x = cell(1,length(im));
y = cell(1,length(im));

%Allowing user to select points to mark foreground boundary
for i = 1: length(im)
   imshow(im{i},[]);
   [x{i},y{i}] = ginput();
   x{i}(end+1) = x{i}(1);
   y{i}(end+1) = y{i}(1);
end

%displaying the foreground selection on the images
for j = 1 : length(im)
   figure();
   imshow(im{j},[]); hold on
   plot(x{j},y{j});
   pause(2);
end

%% Eliminating background features and descriptors
for i = 1:length(feat)
    in = inpolygon(feat{i}(1,:),feat{i}(2,:),x{i},y{i});
    feat{i} = feat{i}(:,in);
    desc{i} = desc{i}(:,in);
end

for j = 1 : length(im)
   figure();
   imshow(im{j},[]); hold on
   plot(feat{j}(1,:),feat{j}(2,:),'*')
   pause(2);
end

%% Matching the features in subsequent images Using vl_ubcmatch

match_thresh = 2;               %tune the matching threshold here
newmatches = cell(1,n_imgs);
matches = cell(1,n_imgs);
Ff = cell(1,n_imgs);

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
    
%     %plotting matches
%     plotmatches(im{1},im{2},feat1,feat2,matches{i},'Stacking','o');   
end

%% Refining matches using normalized 8 point RANSAC algorithm
sampson_dist_mat = cell(1,n_imgs);
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
    
    %refining the matches using RANSAC
    [Ff{i}, inliers_idx_star, ~,sampson_dist_mat{i}] = norm_8p_algo_RANSAC(m1,m2);
    newmatches{i} = matches{i}(:,inliers_idx_star);
    
%     %plotting newmatches
%     figure()
%     if i==n_imgs
%         plotmatches(im{i},im{1},feat1,feat2,newmatches{i},'Stacking','o');
%     else
%         plotmatches(im{i},im{i+1},feat1,feat2,newmatches{i},'Stacking','o');
%     end
%     pause(2);
end

%% checking RANSAC output for specific images:
n = 16;
figure()
plotmatches(im{n},im{n+1},feat{n},feat{n+1},matches{n},'Stacking','o');
figure()
plotmatches(im{n},im{n+1},feat{n},feat{n+1},newmatches{n},'Stacking','o');


%% Tuning threshold
edges = logspace(0,6,60);
N = cell(size(sampson_dist_mat));
Ncum = cell(size(sampson_dist_mat));
bin = cell(size(sampson_dist_mat));

for j=1:n_imgs
    for i = 1:size(sampson_dist_mat{j},1)
        N{j}(i,:) = histcounts(abs(sampson_dist_mat{j}(i,:)),edges);
        Ncum{j}(i,:) = cumsum(N{j}(i,:))/size(sampson_dist_mat{j},2)*100;
        bin{j}(i) = find(Ncum{j}(i,:)>5,1);
    end
    bin_mean(j)=floor(mean(bin{j}));
end


%% Chaining
point_view_matrix = chaining(newmatches);

% %% Extracting columns with more than 2 matches in point_view_matrix
% point_view_matrix_crop = point_view_matrix;
% reps = zeros(1,size(point_view_matrix,2));
% 
% for i = 1:size(point_view_matrix,2)
%     reps(i) = length(find(point_view_matrix(:,i)));
% end
% 
% point_view_matrix_crop = point_view_matrix_crop(:,(reps>2));

%%  Extracting blocks of features that have matches in 3 consecutive images

%copying first two rows to the bottom of Point_view_matrix to complete the loop
PVM = [point_view_matrix; point_view_matrix(1:2,:)]; 

%Initializing Point_view_matrix blocks: PVMb
PVMb = cell(1,size(point_view_matrix,1));
%Initializing a cell array to store the column number of features in PVM
%that are in a block
column_no = cell(1,size(point_view_matrix,1));

for i = 1:size(point_view_matrix,1)
    for j = 1:size(PVM,2)
        if length(find(PVM(i:i+2,j)))==3
            PVMb{i} = [PVMb{i},PVM(i:i+2,j)];
            column_no{i} = [column_no{i},j];
        end
    end
end
%% Solving for structure and Motion matrices for each block
PVMb = PVMb(1:12);
column_no = column_no(1:12);

M_cell = cell(size(PVMb));
S_cell = cell(size(PVMb));

% appending features of image 1 and image 2 at the bottom of feat to
% complete loop
feat{20} = feat{1} ; feat{21} = feat{2};

for i = 1:size(PVMb,2)
    Points = zeros(6,size(PVMb{i},2));
    for j =1:3
        Points(j*2-1:j*2,:) = feat{i+j-1}(1:2,PVMb{i}(j,:));
    end
    PointsC = Points - mean(Points,2);
    
    %Singular Value Decomposition
    [U,W,V] = svd(PointsC);
    
    U = U(:,1:3);
    W = W(1:3,1:3);
    V = V(:,1:3);
    
    M = U*sqrtm(W);
    S = sqrtm(W)*V';
    

    M_cell{i} = M;
    S_cell{i} = S;
end
    
%% using Procustes
for i = length(S_cell):-1:2
    [~,ia,ib] = intersect(column_no{i-1},column_no{i});
    [~,~,transform] = procrustes(S_cell{i-1}(:,ia)',S_cell{i}(:,ib)');
    
    %Points from next frame to be converted to current frame coordinate system
    [~,~,ib] = setxor(column_no{i-1},column_no{i});
    Y = S_cell{i}(:,ib);
    
    %transforming these points to the current coordinate frame
    Z = transform.b*Y'*transform.T + repmat(transform.c(1,:),size(Y,2),1);
    
    %Appending these points to the current S matrix
    S_cell{i-1} = [S_cell{i-1},Z'];
    
    %Appending new column number to the current frame
    column_no{i-1} = [column_no{i-1},column_no{i}(ib)];
end


%%
    save('M','M');
    
    %solve for affine ambiguity
    L0= zeros(3);
    %Solve for L
    L = lsqnonlin(@myfun,L0);
    % Recover C
    C = chol(L,'lower');
    % Update M and S
    M = M*C;
    S = pinv(C)*S;
    


% %%
% feat = cell(1,length(feat_haraff));
% desc = cell(1,length(feat_haraff));
% for i = 1:length(feat_haraff)
%     feat{i} = [feat_haraff{i}, feat_hesaff{i}];
%     desc{i} = [desc_haraff{i}, desc_hesaff{i}];
% end

