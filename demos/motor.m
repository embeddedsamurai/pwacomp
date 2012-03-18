function [D0,Dhat,exitflag] = motor()
%MOTOR example of DC motor system
rng('default')

% Load data set
[current,omega,domega]=parse_dat_motor_exp();
D0=struct;
D0.X=[current,omega];
D0.y=domega;

% Input part of the model data set
Xunit=diag([1.5,35]);
Dhat=struct;
%NDhat=100000;
%Dhat.X=[rand(NDhat,1)*4-2,rand(NDhat,1)*100-50];
Dhat.X=D0.X;
Dhat.tes = delaunayn(Dhat.X/Xunit);
Dhat.adj = make_adj(Dhat.tes);
Dhat = clip_dataset(Dhat, [1,1;-1,1;1,-1;-1,-1]*Xunit);

% Remove unnecessary data
D0.tes = delaunayn(D0.X/Xunit);
D0.adj = make_adj(D0.tes); 
D0 = clip_dataset(D0, Dhat.X);

% Do identification
[net] = hinge_net(Dhat);
K = lerp_coeff(Dhat.X, Dhat.tes, D0.X);
w = 0.5e2;
[Dhat.y, exitflag] = solve_gen_lasso(D0.y, K, net, w,'yalmip_qcp',sdpsettings('solver','sdpt3'));

% show result
clf
h1=subplot(1,2,1);
plot_map('Original',D0);
h2=subplot(1,2,2);
plot_map('Simplified',Dhat);
hlink=linkprop([h1,h2],{'CameraPosition','CameraUpVector'});
setappdata(h1,'link_view',hlink);

    function plot_map(ttext,D)
        colormap(gray);
        h=trisurf(D.tes,D.X(:,1),D.X(:,2),D.y,1);
        set(h,'EdgeAlpha',0);
        caxis([0,1])
        lightangle(40,80)
        xlabel('current');
        ylabel('omega');
        zlabel('domega');
        view([-27.5+250,30])
        xlim([-1.5,1.5])
        ylim([-35,35])
        zlim([-400,400]);
        box off
        title(ttext)
    end
keyboard
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.