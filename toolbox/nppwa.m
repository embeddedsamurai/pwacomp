function [ Pi_D ] = nppwa(D_X,tes,D_y)
%NPPWA Compose non-parametric data-based PWA map
%  [ Pi_D ] = nppwa(D_X,tesnet,D_y)

    d=size(D_X,2);
    function y=fproto(X)
        [T,P]=tsearchn(D_X,tes,X);
        inside=~isnan(T);
        y=ones(size(X,1),1)*nan;
        y(inside)=sum(P(inside,:).*reshape(D_y(tes(T(inside),:)),[],d+1),2);
    end

Pi_D = @fproto;
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.