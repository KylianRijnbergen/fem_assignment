function Y=phitbeta(X,p,beta)
%% evaluates one-step phi_t(X) in binomial tree 
%% with X the path independent payoff at t+1
%% and probability p for an up-branch
%% with phi the entropic risk measure
%% with parameter beta

% initializaton
N=length(X);
% take conditional mean out of exponential to avoid numerical problems
Xu=X(1:N-1); Xd=X(2:N); %% Xu, Xd are vectors with the values of Xu and Xd
M = p*Xu+(1-p)*Xd; %% Hence, M is also a vector 
if beta==0, Y = M; 
else Y = M-log(p*exp(-beta*(Xu-M))+(1-p)*exp(-beta*(Xd-M)))/beta;
end
X, 