function vals=plot_by_angle(xwidth,ywidth,r,theta,initial_angle,modelfun,beta)
%Plots radial lines from the centroid based on xwidth and ywidth
%inputs
    %See plot_ellipse for most inputs
    % r (float) current radius
    % theta (float) current angle
%outputs
    %vals: elliptic comparison
%%Author Kevin Johnston

%%

radius=xwidth*ywidth./sqrt((xwidth*cos(theta+initial_angle)).^2+(ywidth*sin(theta+initial_angle)).^2);
vals=base_function(r./radius,modelfun,beta);
