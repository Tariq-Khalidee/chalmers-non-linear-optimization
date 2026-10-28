x1 = linspace(-3,-2,100);
x2 = linspace(-2,2,100);
x3 = linspace(2,3,100);

f1 = -x1;
f2 = -x2.^2;
f3 = -x3;

plot(x1,f1,'b',x2,f2,'b',x3,f3,'b','LineWidth',2)
hold on

% Included points: filled circles
plot(-3,3,'bo','MarkerFaceColor','b')
plot(-2,2,'bo','MarkerFaceColor','b')
plot(2,-2,'bo','MarkerFaceColor','b')
plot(3,-3,'bo','MarkerFaceColor','b')

% Excluded points: open circles
plot(-2,-4,'bo','MarkerFaceColor','w')
plot(2,-4,'bo','MarkerFaceColor','w')

grid on
xlabel('x')
ylabel('f(x)')
title('Piecewise function')
hold off