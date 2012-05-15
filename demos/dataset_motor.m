function [D0,Dhat,plot_map] = dataset_motor()
%DATASET_MOTOR data set for example of DC motor system
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
[Dhat.net] = hinge_net(Dhat);

plot_map=@proto_plot_map;

    function proto_plot_map(ttext,D)
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
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.