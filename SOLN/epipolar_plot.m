function epipolar_plot(im1,im2,varargin)
%choose point in im1 and plots the corresponding epipolar line in the
%second image
imshow(im1,[])
[xi, yi] = ginput(1);

subplot(1,2,1)
imshow(im1,[])
hold on
plot(xi,yi,'*r')
hold off

subplot(1,2,2)
imshow(im2,[])
hold on

colors = ['r','g','b'];

for i = 1:nargin-2
    coeffs = varargin{i}*[xi;yi;1];
    
    x = [1,size(im1,2)];
    y = (-coeffs(1)*x - coeffs(3))/coeffs(2);
    line(x,y,'Color',colors(i));
end
end