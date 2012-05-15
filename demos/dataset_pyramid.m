function [D0,Dhat,plot_map]=dataset_pyramid()
rng('default')

% Pyramid function
f=@(x) max(0,1-sum(abs(x),2));

% Make noisy data set D0
N=10000;
D0.X=rand(N,2)*2.4-1.2;
Xchull= [-1.1,-1.1;
    -1.1, 1.1;
    1.1, 1.1;
    1.1,-1.1];
D0.tes=delaunayn(D0.X);
D0.adj=make_adj(D0.tes);

D0 = clip_dataset(D0, Xchull);
D0.y = f(D0.X) + randn(size(D0.X,1),1)*0.1;

% Input part of the model data set
Dhat=D0;
Dhat.y=[];
[Dhat.net] = hinge_net(Dhat);

plot_map=@proto_plot_map;

    function proto_plot_map(ttext,D)
        colormap(gray);
        h=trisurf(D.tes,D.X(:,1),D.X(:,2),D.y,1);
        set(h,'EdgeAlpha',0);
        caxis([0,1])
        lightangle(40,80)
        xlabel('x1');
        ylabel('x2');
        zlabel('y');
        xlim([-1.1,1.1]);
        ylim([-1.1,1.1]);
        zlim([-0.1,1.2]);
        view(60,30)
        box off
        title(ttext)
    end
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.