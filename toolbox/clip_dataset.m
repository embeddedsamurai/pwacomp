function [Dout, rm_vtx ] = clip_dataset(D, Xchull)
%CLIP_DATASET remove simplices included in the outside of the specified convex hull  
% [Dout, rm_vtx] = culltes(D, Xchull)

% mark vertex on the outside
if size(D.X,2)<4
    opts={'Qt','Qbb','Qc','Qz'};
else
    opts={'Qt','Qbb','Qc','Qx','Qz'};    
end
out_vtx=isnan(tsearchn(Xchull,delaunayn(Xchull,opts),D.X));

N=size(D.X,1);
d=size(D.X,2);
Ntes=size(D.tes,1);
idx=1:Ntes;
tesnet=sparse(reshape(D.tes',[],1),reshape(idx(ones(d+1,1),:),[],1),true,N,Ntes);

% remove simplex if all vertices are on the outside
rm_tes=all(out_vtx(D.tes),2)';
tesnet=tesnet(:,~rm_tes);
D.adj=D.adj(~rm_tes,~rm_tes);

% remove unnecessary vertexes not used by any simplex
rm_vtx=~any(tesnet,2);
Dout=D;
Dout.X=Dout.X(~rm_vtx,:);
Xnew=full(cumsum(~rm_vtx));

Dout.tes=Xnew(D.tes(~rm_tes,:));

% if D has output part, also clip it.
if isfield(D,'y')
    Dout.y=D.y(~rmtes,:);
end
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.