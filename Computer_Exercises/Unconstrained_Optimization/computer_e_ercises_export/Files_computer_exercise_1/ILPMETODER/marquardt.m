[newpoint,slut,ww1,stlgd]= marqm(funktion,grad,hess,point',normavbrott,avstandavbrott,ww1,stlgd);
figure(2);
subplot(1,2,2)
plot(newpoint(1),newpoint(2),'ro','Erasemode', 'none');
plot([point(1) newpoint(1)],[point(2) newpoint(2)],'r-','Erasemode', 'none');
subplot(1,2,1)
x(1)=newpoint(1); x(2)=newpoint(2);
plot3(newpoint(1),newpoint(2),feval(funktion,[newpoint(1) newpoint(2)]),'ro','Erasemode','none')
point = newpoint';























