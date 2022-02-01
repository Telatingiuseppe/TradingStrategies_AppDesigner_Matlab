function [CRR_price_Am] = CRR_binomial_price_american_call(S0,K,T,sigma,r,n,stock_type,Drfq,TD)
%CRR_binomial_price_american Computes the binomial price of a call or put
%american option with the
%CRR binomial model
%   with a number n of time steps
%   efficient vectorized version

dt = T/n;
u = exp(sigma*sqrt(dt));
d = 1/u;
pv = exp(-r*dt);

if strcmp (stock_type, "Non-dividend-paying stock") == true ||...
        strcmp (stock_type, "Dividend-paying stock") == true
    
    p = (exp(r*dt)-d)/(u-d);
    S0 = S0 - Drfq*exp(-r*TD);

elseif strcmp (stock_type, "Stock Index") == true ||...
        strcmp (stock_type, "Currency") == true 
    
    p = (exp((r-Drfq)*dt)-d)/(u-d);

end

q = 1-p;

%Computes the price vector of the underlying asset in T (stage n)
upowers = u.^(0:n);
dpowers_reversed = d.^(n:-1:0);
ST = S0.*upowers.*dpowers_reversed;

%Computes the payoff of the option at the maturity (stage n)
f = max(ST-K,0);
    

%Backward procedure 
for t = n-1:-1:0
    f_continuation = (p * f(2:t+2) +q * f(1:t+1))*pv;
    St = S0.*upowers(1:t+1).*dpowers_reversed(n+1-t:n+1);     
    f_intrinsic = max(St-K,0);
    
    f = max(f_continuation,f_intrinsic);
end

% option_price(k) = (f(2)*p + f(1)*q)*exp(-r*dt);
%option price at time 0
 CRR_price_Am =f(1); %last for goes until 0 not 1 

end