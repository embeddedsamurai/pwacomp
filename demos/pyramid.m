% prepare data set
[D0,Dhat,plot_map]=dataset_pyramid();
K = lerp_coeff(Dhat.X, Dhat.tes, D0.X);


% demonstrate the identification.
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


% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.