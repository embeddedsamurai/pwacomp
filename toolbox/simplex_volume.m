function [ vol ] = simplex_volume(X)
%SIMPLEX_VOLUME calculate the volume of the simplex
%   SIMPLEX_VOLUME(X) calculate the volume of the simplex whose vertexes
%   are row vectors of X.

k=size(X,1)-1;
V=bsxfun(@minus,X(2:end,:),X(1,:));
vol=sqrt(det(V*V'))/factorial(k);
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.