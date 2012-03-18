function [current,omega,domega] = parse_dat_motor_exp()
%PARSE_DAT_MOTOR_EXP parse dat_motor_exp.mat
% [current,omega,domega] = parse_dat_motor_exp()
d=load('dat_motor_exp.mat');
current=d.yout(:,1);
theta=d.yout(:,2);
Ts=1e-2;

omega=zeros(size(theta));
domega=zeros(size(theta));

diffmat=[0,1,0;0,0,2]/[1,-Ts,Ts^2;1,0,0;1,Ts,Ts^2];
for k=2:size(theta,1)-1
    tmp=diffmat*theta(k-1:k+1);
    omega(k)=tmp(1);
    domega(k)=tmp(2);
end

current=current(6:10:end);
omega=omega(6:10:end);
domega=domega(6:10:end);

end

% Copyright 2012 Ichiro Maruta.
% See the file COPYING.txt for full copyright information.