function [adj] = make_adj(tes)
%MAKE_ADJ [adj] = make_adj(tes)
%   tes: matrix from DELAUNAYN
%   adj: adjacency matrix among Delaunay simplices
%      adj(i,j)==1 if i-th and j-th simplices has common hyper plane

d=size(tes,2)-1;
N=max(tes(:));

Ntes=size(tes,1);
tmp=1:Ntes;
tidx=sparse(reshape(tmp(ones(1,d+1),:),[],1),reshape(tes',[],1),1,Ntes,N);

adj_i=zeros(2*(d+1)*Ntes,1);
adj_j=zeros(2*(d+1)*Ntes,1);
cnt=0;
for k=1:Ntes
    for l=1:d+1
        tmp=tes(k,(1:(d+1))~=l);
        tmp2=tidx(:,tmp);
        adjsimp=tmp2(:,1);
        for m=2:d
            adjsimp=adjsimp.*tmp2(:,m);
        end
        adjsimp(k)=0; %#ok<SPRIX>
        adjsimp=find(adjsimp,1);
        if ~isempty(adjsimp)
            cnt=cnt+1;
            adj_i(cnt)=k;
            adj_j(cnt)=adjsimp;
        end
    end
end
adj=sparse(adj_i(1:cnt),adj_j(1:cnt),1,Ntes,Ntes);

end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.