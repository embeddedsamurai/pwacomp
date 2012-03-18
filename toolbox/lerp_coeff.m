function [K] = lerp_coeff( X, tes, XI )
%LERP_COEFF calculate the coefficients for linearly interpolating data 
%   lerp_coeff( X, tes, XI )
%   calculate coefficients for linearly interpolating data for XI from X

p=size(XI,1);
d=size(XI,2);
[t,P]=tsearchn(X,tes,XI);

k=find(~isnan(t));
K=sparse(reshape(k(:,ones(d+1,1))',[],1), ...
         reshape(tes(t(k),:)',[],1), ...
         reshape(P(k,:)',[],1), ...
         p,size(X,1));
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.