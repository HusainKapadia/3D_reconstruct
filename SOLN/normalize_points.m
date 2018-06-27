function [m_hat , T] = normalize_points(m)
% input:
  %m is the 2xn vector of x and y coordinates of n points in an image


c = mean(m,2);              %centroid along each dimension
m_c = m - c;                %centering the points about the centroid

d = mean(sqrt(sum(m_c.^2)));      %The mean distance about the centroid

T =  [sqrt(2)/d, 0,         -c(1)*sqrt(2)/d ;
      0,        sqrt(2)/d,  -c(2)*sqrt(2)/d ;
      0,          0,            1          ];
  
 m_hat = T*[m;ones(1,length(m))];
 m_hat = m_hat(1:2,:);
end