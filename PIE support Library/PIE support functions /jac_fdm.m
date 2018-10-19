function [jac] = jac_fdm(x,f)
%% Jacobian finite difference approximation of the jacient of the multivaruate f at x
% usage: [jac] = jac_fdm(x,@f)
%
% input:
% x is an n dimensional column vector
% @f is the function handle mapping R^n to R^m
%
% output:
% jac is the n X m dimensional matrix of partial derivatives
% e.g.  jac_ij = df_i/dx_j

fp = feval(f,x);

nxvar = length(x);
nfvar= length(fp);

jac = NaN(nfvar,nxvar);
dx = 1.e-3; % dimensional delta x
xdiff=x;
for ix=1:nxvar
    xdiff(ix) = x(ix)+ dx;
    fp = feval(f,xdiff);
    xdiff(ix)=x(ix)-dx;
    fm = feval(f,xdiff);
    jac(:,ix)=(fp-fm)/(2.0*dx);
end
end