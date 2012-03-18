function [net] = hinge_net(varargin)
%HINGE_NET compose net matrix which represents hinge sparsity regularization
% [net] = hinge_net(X,tes,adj [,weight_func])
% [net] = hinge_net(D [,weight_func])
% compose net which lets net*yhat be the outerpolationg error

% parse arguments
default_weight_func = @(~,~,~) 1;
weight_func=[];

switch nargin
    case {1,2}
        D=varargin{1};
        X=D.X;
        tes=D.tes;
        adj=D.adj;
        if nargin==2
            weight_func=varargin{2};
        end
    case {3,4}
        X=varargin{1};
        tes=varargin{2};
        adj=varargin{3};
        if nargin==4
            weight_func=varargin{4};
        end
end

if isempty(weight_func)
    weight_func=default_weight_func;
elseif ~isa(weight_func,'function_handle')
    switch weight_func
        case 'angle'
            weight_func=@weight_func_angle;
        case 'angle_normalized'
            weight_func=@weight_func_angle_normalized;
        otherwise
            error('weight_func: %s is not supported.\n',weight_func);
    end
end

% preparation
N=size(X,1);
d=size(X,2);
[s1p,s2p]=find(triu(adj));
Nadj=length(s1p);
Ntes=size(tes,1);
idx=1:Ntes;
tesnet=sparse(reshape(tes',[],1),reshape(idx(ones(d+1,1),:),[],1),true,N,Ntes);
idx=1:Nadj;
net_i=reshape(idx(ones(d+2,1),:),[],1);
net_js=zeros(Nadj*(d+2),2);

% sweep every adjacent pair of simplexes
for k=1:Nadj
    s1_idx=tesnet(:,s1p(k));
    s2_idx=tesnet(:,s2p(k));
    hplane_idx=and(s1_idx,s2_idx);
    hplane=X(hplane_idx,:);
    p1_idx=find(xor(s1_idx,hplane_idx));
    p2_idx=find(xor(s2_idx,hplane_idx));
    hplane_idx=find(hplane_idx);
    p1=X(p1_idx,:);
    p2=X(p2_idx,:);
    
    weight=weight_func(p1,hplane,p2);
    coeffs = [p2,1]/[[p1;hplane],ones(d+1,1)];
    weight_rev=weight_func(p2,hplane,p1);
    coeffs_rev = [p1,1]/[[p2;hplane],ones(d+1,1)];
    
    net_js((1+(k-1)*(d+2)):k*(d+2),:) = ...
        [[p2_idx;p1_idx;hplane_idx], [-1;coeffs']*weight + [coeffs_rev(1);-1;coeffs_rev(2:end)']*weight_rev];
end
net=sparse(net_i,net_js(:,1),net_js(:,2),Nadj,N);

%    function extrapolation_error(simplex,point)
%    end

% weighting functions
    function weight=weight_func_angle(~,hplane,p2)
        % Calculate normal vector
        T=[hplane(2:d,:)',p2'] - hplane(1,:)'*ones(1,d);
        n=(T*T')\((p2-hplane(1,:))');
        weight=norm(n)/norm((p2-hplane(1,:))*n);
    end

    function weight=weight_func_angle_normalized(~,hplane,p2)
        weight=weight_func_angle([],hplane,p2)*simplex_volume(hplane);
    end

end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.