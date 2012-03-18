function [ yhat,fval,exitflag,output,lambda] = solve_gen_lasso(y,K,D,w,method,varargin)
%% SOLVE_GEN_LASSO [ yhat ,exitflag] = solve_gen_lasso(y,K,D,w, opts)
% Solve
%   minimize  ||y-K*yhat||_2^2 + w || D * yhat||_1
%     yhat
% or
%   minimize  ||y-K*yhat||_2 + w || D * yhat||_1
%     yhat

if nargin<4
    if exist('quadprog','file')
        method = 'quadprog';
    elseif exist('cplexqp','file')
        method = 'cplex';
    elseif exist('yalmip','file')
        method = 'yalmip_qcp';
    else
        error('solver not found')
    end
end

nt=size(D,1);
nyhat=size(K,2);

tic
switch method
    case 'quadprog'
        [H,f,A,b]=setup_qp();
        options=optimset('Display','iter','Algorithm','interior-point-convex','TolFun',1e-12,varargin{:});
        [result,~,exitflag,output,lambda]=quadprog(H,f,A,b,[],[],[],[],[],options);
        yhat=result(1:nyhat);
        
    case 'quadprog_aux'
        [H,f,A,b,Aeq,beq]=setup_qp_aux();
        options=optimset('Display','iter','Algorithm','interior-point-convex',varargin{:});
        [result,~,exitflag,output,lambda]=quadprog(H,f,A,b,Aeq,beq,[],[],[],options);
        yhat=result(1:nyhat);
        
    case 'cplex'
        [H,f,A,b]=setup_qp();
        options=cplexoptimset('Diagnostics', 'on');
        [result,~,exitflag,output,lambda]=cplexqp(H,f,A,b,[],[],[],[],[],options);
        yhat=result(1:nyhat);
        
    case 'cplex_aux'
        [H,f,A,b,Aeq,beq]=setup_qp_aux();
        options=cplexoptimset('Diagnostics', 'on');
        [result,~,exitflag,output,lambda]=cplexqp(H,f,A,b,Aeq,beq,[],[],[],options);
        yhat=result(1:nyhat);
        
    case 'yalmip_qcp'
        yhat=sdpvar(nyhat,1);
        comyhat=D*yhat;
        combound = sdpvar(length(comyhat),1);
        err= y-K*yhat;
        errbound = sdpvar(1,1);
        
        Constraints = [-combound <= comyhat <= combound, rcone(err,errbound,0.5)];
        
        exitflag=solvesdp(Constraints, errbound+w*sum(combound),varargin{:});
        yhat=double(yhat);
        output=[];
        lambda=[];
        
    case 'yalmip_socp'
        yhat=sdpvar(nyhat,1);
        comyhat=D*yhat;
        combound = sdpvar(length(comyhat),1);
        err= y-K*yhat;
        errbound = sdpvar(1,1);
        
        Constraints = [-combound <= comyhat <= combound, cone(err,errbound)];
        
        exitflag=solvesdp(Constraints, errbound+w*sum(combound),varargin{:});
        yhat=double(yhat);
        output=[];
        lambda=[];
        
    otherwise
        error('not supported solver')
end
toc
fval=(y-K*yhat)'*(y-K*yhat)+w*sum(abs(D*yhat));

    function [H,f,A,b]=setup_qp()
        H=[K'*K*2,sparse(nyhat,nt);
            sparse(nt,nyhat+nt)];
        f=[-2*y'*K, w*ones(1,nt)]';
        A=[D,-speye(nt);
            -D,-speye(nt)];
        b=sparse(2*nt,1);        
    end

    function [H,f,A,b,Aeq,beq]=setup_qp_aux()
        H=[sparse(nyhat+nt,nyhat+nt+nyhat);
            sparse(nyhat,nyhat+nt),2*speye(nyhat)];
        f=[zeros(1,nyhat), w*ones(1,nt),zeros(1,nyhat)]';
        A=[[D,-speye(nt);
            -D,-speye(nt)],sparse(2*nt,nyhat)];
        b=sparse(2*nt,1);
        Aeq=[K,sparse(nyhat,nt),-speye(nyhat)];
        beq=y;
    end

end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.