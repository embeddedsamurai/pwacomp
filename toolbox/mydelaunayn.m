function [tes,adj,Xextr]=mydelaunayn(X)
%MYDELAUNAYN N-D Delaunay triangulation with adjacency matrix
%   [tes,adj]=mydelaunayn(X)
%   tes: compatible with DELAUNAYN
%   adj: adjacency matrix among Delaunay simplices
%      adj(i,j)==1 if i-th and j-th simplices has common hyper plane
%
%   REQUIREMENT:
%     This routine requires excutable of Qhull.
%     http://www.qhull.org/


%% Compose input
infile=tempname;
fid=fopen(infile,'w');
d=size(X,2);
N=size(X,1);
fprintf(fid,'%d\n',d);
fprintf(fid,'%d\n',N);
fprintf(fid,strcat('%e',repmat('\t%e',1,d-1),'\n'),X');
fclose(fid);

%% Invoke Qhull
outfile=tempname;
opts={'Qt','Qbb','Qc'};
if d>3
    opts{end+1}='Qx';
end
opts=strcat(opts,{' '});
system(sprintf('qhull d s i %s Fn Fx< %s > %s',cat(2,opts{:}),infile,outfile));

%% Read Results
fid=fopen(outfile,'r');

% compose tessellation matrix
Ntes=fscanf(fid,'%d',1);
tes=fscanf(fid,'%d',[d+1,Ntes])'+1;
idx=1:Ntes;

% compose adjancy matrix
Nadj=fscanf(fid,'%d',1);
adjout=fscanf(fid,'%d',[d+2,Nadj])';
assert(all(adjout(:,1)==d+1));
assert(Nadj==Ntes);
adjmat=[reshape(idx(ones(d+1,1),:),[],1),reshape(adjout(:,2:end)',[],1)];
adjmat(adjmat(:,2)<0,:)=[];
adj=sparse(adjmat(:,1),adjmat(:,2)+1,true,Ntes,Ntes);

% compose list of extreme points
Nextr=fscanf(fid,'%d',1);
Xextr=fscanf(fid,'%d',[1,Nextr])';

%% Cleanup
delete(infile);
delete(outfile);
end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.