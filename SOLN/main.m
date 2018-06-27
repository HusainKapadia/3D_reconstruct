%% FUNDAMENTAL MATRIX ESTIMATION:

%% obtaining the features and descriptors 
subfolder = @(base, sub) [base '\' sub];
merge_file = @(dir) subfolder(dir.folder, dir.name);

imgfldr = 'C:\D\SC coursework\Q3\computer vision\assignments\assignment 5\TeddyBearPNG';
img_files = dir(imgfldr);
img_files = img_files(3:end);

%%
%loading all images
im = cell(length(img_files),1);
for i =1:length(img_files)     
    im{i} = single(rgb2gray(imread(merge_file(img_files(i)))));
end
%% pseudo step 1 & 2


im1 = im{1};
im2 = im{2};

peak_thresh = 7;
edge_thresh = 7.5;
[fe1, desc1] = vl_sift(im1,'PeakThresh',peak_thresh,'edgethresh',edge_thresh);
[fe2, desc2] = vl_sift(im2,'PeakThresh',peak_thresh,'edgethresh',edge_thresh);


%% step 3 - Matching descriptors
match_thresh = 4;
[matches, scores] = vl_ubcmatch(desc1, desc2, match_thresh);
%plotmatches(im1,im2,fe1,fe2,matches,'Stacking','h');      %visualizing matches

%% step 4
n = 100;                                            %no. of equations       
seed = randperm(length(matches),n);               %randomly selecting n matched points
m1 = fe1(1:2,matches(1,seed));                     %image coordinates of n matched points in im1
m2 = fe2(1:2,matches(2,seed));                     %%image coordinates of n matched points in im2 

A = zeros(n,9);

for i = 1:n
    A(i,:) = [m1(1,i)*m2(1,i), m1(1,i)*m2(2,i), m1(1,i), m1(2,i)*m2(1,i), m1(2,i)*m2(2,i), m1(2,i), m2(1,i), m2(2,i), 1];  
end
%%
[~,~,V] = svd(A,'econ');    %remove econ if using just 8 points

f = V(:,end);          %the elements of fundamental matrix in  a 9x1 vector
F = reshape(f,[3,3]);

% Enforcing singularity
[Uf, Sf, Vf] = svd(F);
Sf(3,3) = 0;
Ff = Uf*Sf*Vf';

%% plotting epipolar line
%epipolar_plot(im1,im2,Ff);


%% 3 Normalized 8 point Algorithm

[m1_hat , T1] = normalize_points(m1);

[m2_hat , T2] = normalize_points(m2);

A = formulate_eq(m1_hat,m2_hat);

[~,~,V] = svd(A,'econ');

f = V(:,end);          %the elements of fundamental matrix in  a 9x1 vector
F_hat = reshape(f,[3,3]);

% Enforcing singularity
[Uf, Sf, Vf] = svd(F_hat);
Sf(3,3) = 0;
Ff_hat = Uf*Sf*Vf';

%Denormalizing:
Ff_hat_denorm_noRansac = T2'*Ff_hat*T1;

%% plotting epipolar line
%epipolar_plot(im1,im2,Ff_hat_denorm_noRansac);

%% RANSAC
N = 350;             %No. of iterations
n_inliers_star = 0;  %max no. of inliers

%Normalizing the matched points
[m1_hat , T1] = normalize_points(m1);
[m2_hat , T2] = normalize_points(m2);
tic
for i = 1:N
    %Finding the model based on 8 sample points
    seed = randperm(length(m1_hat),8);               
    m1_hat_rand =  m1_hat(1:2,seed);                    
    m2_hat_rand =  m2_hat(1:2,seed);                   
    
    A_hat = formulate_eq(m1_hat_rand,m2_hat_rand);  

    [~,~,V] = svd(A_hat);

    f = V(:,end);          %the elements of fundamental matrix in  a 9x1 vector
    F_hat = reshape(f,[3,3]);

    % Enforcing singularity
    [Uf, Sf, Vf] = svd(F_hat);
    Sf(3,3) = 0;
    Ff_hat = Uf*Sf*Vf';

    %Denormalizing:
    Ff_hat_denorm = T2'*Ff_hat*T1;

    %Sampson distance:
    temp1 = (Ff_hat_denorm)*[m1;ones(1,length(m1))];
    sum1 =sum(temp1(1:2,:).^2);
    
    temp2 = (Ff_hat_denorm)'*[m2;ones(1,length(m2))];
    sum2 =sum(temp2(1:2,:).^2);
    
    den = sum([sum1;sum2]);
    A = formulate_eq(m1,m2);
    num = A*Ff_hat_denorm(:);
    
    sampson_dist = num'./den;
    
    %checking for inliers
    dist_thresh = 50;
    inliers_bool = abs(sampson_dist) < dist_thresh;
    n_inliers = sum(inliers_bool);
    
    if n_inliers > n_inliers_star
        %Computing the inliers, and refitting the model over the inliers instead of
        %only on the sample points
        sampson_dist_star = sampson_dist;
        n_inliers_star = n_inliers;
        inliers_bool_star = inliers_bool;
        F_star = Ff_hat_denorm;
        
    end
end
toc
%% plot epipolar line
epipolar_plot(im1,im2,Ff,Ff_hat_denorm_noRansac,F_star);
legend('With 8 point algorithm','Normalized 8 point algorithm','Normalized 8 point algorithm with RANSAC','Location','none');
