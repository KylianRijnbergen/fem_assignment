function [a,betastar,Y]=BTentropic(X,p,beta,K)
%% evaluates phi(X) in binomial tree 
%% with X the path independent payoff
%% length(X)-1 the number of time steps
%% and probability p for an up-branch
%% with phi the sequentially consistent entropic risk measure
%% inf {phi_0^beta_0(...(phi_T-1^beta_T-1(X))...) |Sum beta_t=beta
%% with beta_t taking values in [0,h,2*h,...,beta]
%% with h=beta/K, so a range of K+1 values 
%%   
%%  

% initializaton
if beta<0, error('beta should be nonnegative'); end
if K<=0, error('K at least 1'); end

[N,m] = size(X); if m>1, error('X should be a vector'); end
if N<2, error('X too short'); end
T=N-1;

if T==1, a=phitbeta(X,p,beta); betastar=beta; end % static case is trivial
% now assume T>1


betaset=linspace(0,beta,K+1); % set of beta values
%old: h=beta/K; betaset=0:h:beta+eps; % set of beta values
%if length(betaset)~=K+1, error('some error in betaset'); end 

betastar=zeros(T,T,K+1); %stores optimal beta_t by index in betaset; -1 is neutral value
%betastar=-ones(T,T,K+1); %stores optimal beta_t by index in betaset; -1 is neutral value

% betastar(i,j,k) is index optimal beta in node (i,j)
% under restriction sum beta_t,...beta_T-1=betaset(k)
% for sum is zero not stored, trivial

% evaluate at T-1 outcome for all beta in betaset. 
% store in Y with k-th column corr to k-th elt in betaset

%old: beta=0 separately: Y = phitbeta(X,p,0); %value corresponding to beta_T-1=0
Y=[]; for k=1:K+1, Y=[Y phitbeta(X,p,betaset(k))]; 
betastar(:,T,k)=(k-1)*ones(T,1); %at T-1, take of course beta_T-1 at (k-1)-th notch  
end %, Y, X
% backward recursion 
for t=T-2:-1:0 
    % loop invariant: Y(:,k) outcome for Sigma beta's = betaset(k)  
    % over period t+1 ... T
    
    % evaluate with beta_t+ Sum beta_>t = betaset(k) 
    % store in k-th column of Yt
    % first column (beta=0):
        Yt=phitbeta(Y(:,1),p,0); %just expected value, nothing to optimize
        betastar(1:t+1,t+1,1)=zeros(t+1,1); 
    for k=2:K+1, 
        Yk=[];
        for kk=1:k 
        %evaluate with beta_t=betaset(kk), Sum other betas = betaset(k-kk-1)
        % so that new sum at t has sum betaset(k)
        Yk(:,kk) = phitbeta(Y(:,k-kk+1),p,betaset(kk));
        end %, Yk
        %now take minumum per node at t over kk
        [Ykmin,kkmin]=min(Yk');Ykmin=Ykmin'; kkmin=kkmin';
        Yt(:,k)=Ykmin;
        betastar(1:t+1,t+1,k)=kkmin-1;
    end
    Y=Yt; Yt=[];
end %, Y
  a=Y(K+1);
