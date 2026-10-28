[x1,x2] = meshgrid(-5 : 0.1 : 5, -5 : 0.1 : 5); 

f = -x1 + x2 

surf(x1,x2,f)

xlabel('x_1')
ylabel('x_2')
zlabel('f(x_1,x_2)')
title('f(x_1,x_2) = -x_1 + x_2')