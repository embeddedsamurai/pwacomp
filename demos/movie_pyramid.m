
[D0,Dhat,plot_map]=dataset_pyramid();
K = lerp_coeff(Dhat.X, Dhat.tes, D0.X);

widx=logspace(-5,3,200);
kidx=1:length(widx);
remaining_time=est_remaining_time( kidx(1),kidx(end));
figure(1)
for k=kidx
    w=widx(k);
    [Dhat.y, fval, exitflag, output] = solve_gen_lasso(D0.y,K,Dhat.net,w,'yalmip_qcp',sdpsettings('solver','sdpt3'));
    Dhat.map=nppwa(Dhat.X,Dhat.tes,Dhat.y);

    clf
    plot_map(sprintf('w=%e',w),Dhat);
    filename=sprintf('frames_pyramid_movie/%d.png',k);
    sized_print(512,512,'-dpng',filename);
    remaining_time(k);
end


% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.