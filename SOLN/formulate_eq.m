function A = formulate_eq(m1,m2)
%Takes in 2 matrices of matched points in 2 images and formulates A matrix
%in A*f = 0 ; where f is the vectorized fundamental matrix

A = zeros(length(m1),9);

for i = 1:length(m1)
    A(i,:) = [m1(1,i)*m2(1,i), m1(1,i)*m2(2,i), m1(1,i), m1(2,i)*m2(1,i), m1(2,i)*m2(2,i), m1(2,i), m2(1,i), m2(2,i), 1];  
end


end