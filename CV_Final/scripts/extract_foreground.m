%% Manual Selection of Foreground
% % For each image, click around the foreground to form a polygon around the
% % foreground. The vertice-coordinates of the polygon are stored in cell arrays x and y
% 
% x = cell(1,length(im));
% y = cell(1,length(im));
% 
% %Allowing user to select points to mark foreground boundary
% for i = 1: length(im)
%    imshow(im{i},[]);title('Hit Enter after finishing selection polygon')
%    [x{i},y{i}] = ginput();
%    x{i}(end+1) = x{i}(1);
%    y{i}(end+1) = y{i}(1);
% end

%Uncomment the above section to select foreground manually yourself. The
%selection polygons that we used have been provided in 'foreground_boundary.mat'
load('foreground_boundary.mat')

% %Displaying the foreground selection on the images
% for j = 1 : length(im)
%    figure();
%    imshow(im{j},[]); hold on
%    plot(x{j},y{j});
%    pause(2);
% end

%% Extracting Foreground Features and Descriptors
for i = 1:length(feat)
    in = inpolygon(feat{i}(1,:),feat{i}(2,:),x{i},y{i});
    feat{i} = feat{i}(:,in);
    desc{i} = desc{i}(:,in);
end

% %Displaying the reduced set of features
% for j = 1 : length(im)
%    figure();
%    imshow(im{j},[]); hold on
%    plot(feat{j}(1,:),feat{j}(2,:),'*')
%    pause(2);
% end