function main_chikv_hbc_model
% set the path for the current directory and subdirectories (this needs to
% be run the first time the code is executed.
restoredefaultpath ;prefix = mfilename('fullpath');
dirs = regexp(prefix,'[\\/]');addpath(genpath(prefix(1:dirs(end))))

clear global ; clf; format shortE; close all;  % close previous sessions
set(0,'DefaultAxesFontSize',18);set(gca,'FontSize',18);close(gcf); % increase font size
rng(101); % set the random number generator seed for reproducibility
global str 

str.data='chikv';%  poly  'PP model'
str.model=str.data;

% Define the problem by defining the structure array str.*
% str.data = poly polysum linear harmonic1 harmonic2 harmonic3 - built in
str= define_default_params(str); % set the default paramter values
str= change_default_params(str); % user code to change the default paramter values

%  fit the data and analyze the fit
estimate_parameters; % str passed through global (will fix later)

end



function str= change_default_params(str)
%% CHANGE_PROBLEM_DEFAULTS  sub for user routine to change the default values

str.evaluate_model=@evaluate_chikv_hbc_model; % name of the function to fit the data
str.ode_function=@ode_chikv_hbc;
str.cross_validation_analysis=@none;%cross_validation_analysis;

str.plabel =  {'\theta_2','\pi_1', '\pi_2'}; % Default labels
str.noise_sd=0; % additive noise standard deviation for generated data
str.tend = 300;
str.tbeg = 0;
str.nbootstrap=20;% number of bootstrap samples

str.psol=[0.7,0.5,.8]'; % initial guess at the solution for the parameters
str.ub = [.8,0.7, 0.9]';
str.lb = [.1,0.1, 0.1]';
str.z0 = ...
    [10000 *(1-str.psol(1)) - 20*(1-str.psol(1)),
     10000* str.psol(1) - 20*str.psol(1),
     20 * (1-str.psol(1)),
     20 * str.psol(1),
     0,
     0,
     20 * (1-str.psol(1)),
     20 * str.psol(1),
     100000,
     0,
     0]; % initial conditions for differential equation model
str.p0=0.9*str.psol ; % initial guess at the solution (=psol for initial testing)
str.pref=str.psol; % reference solution for regularization is initial guess
str.wpref = ones(size(str.psol)); % default weights for regularization.

%% OPTIMIZATION METHOD PARAMETERS
str.min_method='chikv_optimize';%  lsqnonlin  fminunc  MPP NL minimization program

% Current optimization programs  only require function
% values, not the Jacobian or Hessian from the user
% Name of the nonlinear  minimization (optimization) function to be used.  Some of these functions
% require the user supply the residual R(X) and others require f(X)= R'*R
% lsqnonlin  nonlinear least squares program, provide the residual
% fminunc  unconstrained optimization, provide f(X)= R'*R
% MPP  Moore-Penrose pseudoinverse for linear problems, must have defined the matrix str.A

% The optimization routine requires a function to be minimized.  The
% default names can be changed to a user provided function
str.eval_residual=@eval_residual; % name of the function returning the residuals
str.eval_function=@eval_function; % name of the function returning the f(p)=R'*R
% these default functions only require function values.

end

function [ydata_fit,zsol_fit] = evaluate_chikv_hbc_model(p,tdata,str)
% EVALUATE_MODEL User routine to evaluate the model at the data points
% and generate the fitted approximations to the observable data


ntdata=length(tdata);
z0 =  ...
    [10000 *(1-p(1)) - 20*(1-p(1)),
     10000* p(1) - 20*p(1),
     20 * (1-p(1)),
     20 * p(1),
     0,
     0,
     20 * (1-p(1)),
     20 * p(1),
     100000,
     0,
     0];
[tsol,zsol_fit] = balance_and_solve_chikv(tdata, z0, p, str);
if length(tsol) ~= length(tdata)% check of ODE solver was successful
    warning('ODE solver failed to reach the final time. Augmenting solution with zeros')
    [nt, nz] = size(zsol_fit); zsol_fit=[zsol_fit;zeros(length(tdata)-nt,nz)];
    keyboard 
end

ydata_fit=[zsol_fit(:,7)+zsol_fit(:,8)]; % variables observed
%ydata_fit=zsol_fit; % only observe all variables

end
