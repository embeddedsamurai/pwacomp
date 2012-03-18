function [iteratable_solver]=pyramid()
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

% preparation
[Dhat.net] = hinge_net(Dhat);
K = lerp_coeff(Dhat.X, Dhat.tes, D0.X);


% if iteratable solver (for movie) is requested, return it.
if nargout==1
    iteratable_solver=@proto_iteratable_solver;
    return
end

% Other wise, demonstrate the identification.

w = 0.5;
[Dhat.y, fval, exitflag, output] = solve_gen_lasso(D0.y,K,Dhat.net,w,'yalmip_qcp',sdpsettings('solver','sdpt3'));

% show result
clf
h1=subplot(1,2,1);
plot_map('Original',D0);
h2=subplot(1,2,2);
plot_map('Simplified',Dhat);
hlink=linkprop([h1,h2],{'CameraPosition','CameraUpVector'});
setappdata(h1,'link_view',hlink);

fval
exitflag
output

    function plot_map(ttext,D)
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

    function [Dhat_r, fval, exitflag, output] = proto_iteratable_solver(w)
        Dhat_r=Dhat;
        [Dhat_r.y, fval, exitflag, output] = solve_gen_lasso(D0.y,K,Dhat.net,w,'yalmip_qcp',sdpsettings('solver','sdpt3'));
    end

end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.