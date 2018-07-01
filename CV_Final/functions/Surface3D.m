%% 3D model plotting
function Surface3D(pointsCloudSet,pointsCloudMeasurementMatrixSet,images);

finalPointCloud=[];
for i = 1:length(pointsCloudSet)
    finalPointCloud=[finalPointCloud pointsCloudSet{i}];
end
finalPointRGBTexture=[];
% include the RGB color fo the 3D points
for i = 1:length(pointsCloudSet)
   %get the point set  
   pointsInSmapleImagePlane=pointsCloudMeasurementMatrixSet{i}(1:2,:);
   sampleImage=images{i};
%    imshow(sampleImage)
%    hold on
%    plot(pointsInSmapleImagePlane(1,:),pointsInSmapleImagePlane(2,:),'ro')
   for j=1:size(pointsInSmapleImagePlane,2)
         tempy=round(pointsInSmapleImagePlane(1,j));
         tempx=round(pointsInSmapleImagePlane(2,j));
         temp=sampleImage(tempx,tempy,:);
         finalPointRGBTexture=[finalPointRGBTexture reshape(temp,3,1)];
   end
end
finalPointRGBTexture=double(finalPointRGBTexture)./255;

X=finalPointCloud(1,:)';
Y=finalPointCloud(2,:)';
Z=finalPointCloud(3,:)';
R=finalPointRGBTexture(1,:)';
G=finalPointRGBTexture(2,:)';
B=finalPointRGBTexture(3,:)';

%% surf the 3D point and interpolate texture color
xlin = linspace(min(X),max(X),100);
ylin = linspace(min(Y),max(Y),100);
[XInterpolated,YInterpolated] = meshgrid(xlin,ylin);
ZInterpolated=griddata(X,Y,Z,XInterpolated,YInterpolated);

colorInterpolated=[];
colorInterpolated(:,:,1)=griddata(X,Y,Z,R,XInterpolated,YInterpolated,ZInterpolated);
colorInterpolated(:,:,2)=griddata(X,Y,Z,G,XInterpolated,YInterpolated,ZInterpolated);
colorInterpolated(:,:,3)=griddata(X,Y,Z,B,XInterpolated,YInterpolated,ZInterpolated);

surf(XInterpolated,YInterpolated,ZInterpolated,colorInterpolated);

%% visualize the 3D point cloud with texture
for i=1:length(finalPointCloud)
    point=finalPointCloud(:,i);
    pointColor=finalPointRGBTexture(:,i);
    hold on
    plot3(point(1),point(2),point(3),'.','MarkerSize',25,...
                     'MarkerEdgeColor',pointColor,...
                     'MarkerEdgeColor',pointColor)
end