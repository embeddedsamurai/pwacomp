function movie_pyramid()

    iterative_solver=pyramid();

    widx=logspace(-5,3,200);
    kidx=1:length(widx);
    remaining_time=est_remaining_time( kidx(1),kidx(end));
    for k=kidx
        w=widx(k);
        Dhat=iterative_solver(w);
        Dhat.map=nppwa(Dhat.X,Dhat.tes,Dhat.y);

        Ngrid=40;
        [XI,YI]=meshgrid(linspace(-1.1,1.1,Ngrid),linspace(-1.1,1.1,Ngrid));
        ZI=Dhat.map([XI(:),YI(:)]);
        colormap(gray)
        surfl(XI,YI,reshape(ZI,Ngrid,Ngrid),[240,90],'cdata');
        xlim([-1.1,1.1]);
        ylim([-1.1,1.1]);
        zlim([-0.1,0.9]);
        view(60,30)
        axis off
        
        filename=sprintf('frames_pyramid_movie/%d.png',k);
        sized_print(512,512,'-dpng',filename);
        remaining_time(k);
    end
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.